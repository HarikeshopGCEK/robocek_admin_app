import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';
import 'event_editor_page.dart';
import 'registrations_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final _repo = EventRepository();
  final _searchController = TextEditingController();
  String _search = '';
  String _statusFilter = 'All';

  final _statusOptions = ['All', 'Upcoming', 'Ongoing', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _search = _searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RobocekEvent> _filtered(List<RobocekEvent> all) {
    var list = all;
    if (_statusFilter != 'All') {
      list = list.where((e) => (e.status ?? '').toLowerCase() == _statusFilter.toLowerCase()).toList();
    }
    if (_search.isNotEmpty) {
      list = list.where((e) =>
          e.title.toLowerCase().contains(_search) ||
          e.category.toLowerCase().contains(_search) ||
          (e.venue ?? '').toLowerCase().contains(_search)).toList();
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void _openCreate() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventEditorPage(repo: _repo)),
      );

  void _openEdit(RobocekEvent event) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventEditorPage(repo: _repo, event: event)),
      );

  void _openRegistrations(RobocekEvent event) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RegistrationsPage(eventId: event.id, title: event.title)),
      );

  Future<void> _delete(RobocekEvent event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${event.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.deleteEvent(event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _changeStatus(RobocekEvent event, String newStatus) async {
    try {
      await _repo.updateStatus(event.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status → $newStatus'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Event'),
      ),
      body: StreamBuilder<List<RobocekEvent>>(
        stream: _repo.watchAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final all = snap.data ?? [];
          final filtered = _filtered(all);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search events…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _statusOptions.map((s) {
                          final selected = _statusFilter == s;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(s),
                              selected: selected,
                              onSelected: (_) => setState(() => _statusFilter = s),
                              selectedColor: RobocekColors.blue.withValues(alpha: 0.25),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} event${filtered.length != 1 ? 's' : ''}',
                      style: const TextStyle(color: RobocekColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_note_rounded, size: 48, color: RobocekColors.muted),
                            SizedBox(height: 12),
                            Text('No events found', style: TextStyle(color: RobocekColors.muted)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) => _EventCard(
                          event: filtered[i],
                          onEdit: () => _openEdit(filtered[i]),
                          onDelete: () => _delete(filtered[i]),
                          onViewRegistrations: () => _openRegistrations(filtered[i]),
                          onChangeStatus: (s) => _changeStatus(filtered[i], s),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Event Card ───────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final RobocekEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewRegistrations;
  final ValueChanged<String> onChangeStatus;

  const _EventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.onViewRegistrations,
    required this.onChangeStatus,
  });

  Color _statusColor(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'upcoming':
        return RobocekColors.blue;
      case 'ongoing':
        return RobocekColors.green;
      case 'completed':
        return RobocekColors.muted;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return RobocekColors.amber;
    }
  }

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'workshop':
        return RobocekColors.cyan;
      case 'competition':
        return RobocekColors.amber;
      case 'seminar':
        return RobocekColors.blue;
      case 'hackathon':
        return RobocekColors.green;
      default:
        return RobocekColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(event.status);
    final catColor = _categoryColor(event.category);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              event.category,
                              style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              event.displayStatus,
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
                    const PopupMenuItem(value: 'registrations', child: ListTile(leading: Icon(Icons.people_outline), title: Text('View Registrations'))),
                    const PopupMenuItem(value: 'Upcoming', child: ListTile(leading: Icon(Icons.schedule_outlined), title: Text('Set: Upcoming'))),
                    const PopupMenuItem(value: 'Ongoing', child: ListTile(leading: Icon(Icons.play_circle_outline), title: Text('Set: Ongoing'))),
                    const PopupMenuItem(value: 'Completed', child: ListTile(leading: Icon(Icons.check_circle_outline), title: Text('Set: Completed'))),
                    const PopupMenuItem(value: 'Cancelled', child: ListTile(leading: Icon(Icons.cancel_outlined), title: Text('Set: Cancelled'))),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))),
                  ],
                  onSelected: (val) {
                    switch (val) {
                      case 'edit':
                        onEdit();
                      case 'registrations':
                        onViewRegistrations();
                      case 'delete':
                        onDelete();
                      default:
                        onChangeStatus(val);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _IconText(icon: Icons.calendar_today_outlined, text: event.date),
                if (event.time?.isNotEmpty == true) _IconText(icon: Icons.access_time_outlined, text: event.time!),
                _IconText(icon: Icons.location_on_outlined, text: event.displayVenue),
              ],
            ),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: RobocekColors.muted, fontSize: 13),
              ),
            ],
            if (event.isPaid) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: RobocekColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Fee: ${event.nonMemberFee ?? event.registrationFee ?? '₹50'}',
                      style: const TextStyle(color: RobocekColors.amber, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (event.isFreeForMembers) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: RobocekColors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Free for members',
                        style: TextStyle(color: RobocekColors.green, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (event.hasRegistrationForm)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewRegistrations,
                      icon: const Icon(Icons.people_outline_rounded, size: 16),
                      label: const Text('Registrations'),
                      style: OutlinedButton.styleFrom(foregroundColor: RobocekColors.cyan),
                    ),
                  ),
                if (event.hasRegistrationForm) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: RobocekColors.muted),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: RobocekColors.muted, fontSize: 12)),
      ],
    );
  }
}
