import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/member.dart';
import '../../repositories/member_repository.dart';
import 'member_details_page.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> with SingleTickerProviderStateMixin {
  final _repo = MemberRepository();
  late final TabController _tabController;
  final _searchController = TextEditingController();

  String _search = '';
  String _branchFilter = 'All';
  String _yearFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() => setState(() => _search = _searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Member> _filtered(List<Member> all, bool? approvedOnly) {
    var list = all.where((m) {
      if (approvedOnly == true) return m.isApproved;
      if (approvedOnly == false) return !m.isApproved;
      return true;
    }).toList();

    if (_branchFilter != 'All') list = list.where((m) => (m.branch ?? '') == _branchFilter).toList();
    if (_yearFilter != 'All') list = list.where((m) => m.displayYear == _yearFilter).toList();

    if (_search.isNotEmpty) {
      list = list.where((m) {
        return (m.fullName ?? '').toLowerCase().contains(_search) ||
            (m.email ?? '').toLowerCase().contains(_search) ||
            (m.branch ?? '').toLowerCase().contains(_search) ||
            (m.membershipId ?? '').toLowerCase().contains(_search) ||
            m.displayYear.toLowerCase().contains(_search);
      }).toList();
    }

    list.sort((a, b) => (a.fullName ?? '').compareTo(b.fullName ?? ''));
    return list;
  }

  Set<String> _branches(List<Member> all) =>
      {'All', ...all.map((m) => m.branch ?? '').where((b) => b.isNotEmpty)};

  Set<String> _years(List<Member> all) =>
      {'All', ...all.map((m) => m.displayYear).where((y) => y.isNotEmpty)};

  Future<void> _approve(Member m) async {
    final confirm = await _showConfirm(
      context,
      title: 'Approve Member',
      message: 'Approve ${m.displayName} and generate a Membership ID?',
      confirmLabel: 'Approve',
      confirmColor: RobocekColors.green,
    );
    if (!confirm) return;
    try {
      await _repo.approveMember(m);
      if (mounted) _showSnack('Approved ${m.displayName}!', success: true);
    } catch (e) {
      if (mounted) _showSnack('Failed to approve: $e', success: false);
    }
  }

  Future<void> _delete(Member m) async {
    final confirm = await _showConfirm(
      context,
      title: 'Delete Member',
      message: 'Delete "${m.displayName}"? This removes their profile permanently.',
      confirmLabel: 'Delete',
      confirmColor: Colors.redAccent,
    );
    if (!confirm) return;
    try {
      await _repo.deleteMember(m);
      if (mounted) _showSnack('Deleted ${m.displayName}.', success: true);
    } catch (e) {
      if (mounted) _showSnack('Failed to delete: $e', success: false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? RobocekColors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Member>>(
      stream: _repo.watchAll(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)));
        }

        final all = snap.data ?? [];
        final pending = _filtered(all, false);
        final approved = _filtered(all, true);
        final everyone = _filtered(all, null);

        final branches = _branches(all).toList()..sort();
        final years = _years(all).toList()..sort();

        return Column(
          children: [
            // Search & Filters
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search members…',
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
                  Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown(
                          label: 'Branch',
                          value: _branchFilter,
                          items: branches,
                          onChanged: (v) => setState(() => _branchFilter = v ?? 'All'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FilterDropdown(
                          label: 'Year',
                          value: _yearFilter,
                          items: years,
                          onChanged: (v) => setState(() => _yearFilter = v ?? 'All'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Export button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${all.length} total · ${all.where((m) => m.isApproved).length} approved · ${all.where((m) => !m.isApproved).length} pending',
                    style: const TextStyle(color: RobocekColors.muted, fontSize: 12),
                  ),
                  TextButton.icon(
                    onPressed: all.isEmpty ? null : () => _exportMembers(all),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Export'),
                    style: TextButton.styleFrom(foregroundColor: RobocekColors.cyan),
                  ),
                ],
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Pending (${all.where((m) => !m.isApproved).length})'),
                Tab(text: 'Approved (${all.where((m) => m.isApproved).length})'),
                Tab(text: 'All (${all.length})'),
              ],
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MemberList(members: pending, onApprove: _approve, onDelete: _delete),
                  _MemberList(members: approved, onApprove: null, onDelete: _delete),
                  _MemberList(members: everyone, onApprove: _approve, onDelete: _delete),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _exportMembers(List<Member> members) {
    // Show export info dialog since file_picker/xlsx not available without packages
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Members'),
        content: Text(
          'Export to Excel requires the xlsx package.\n\n'
          'Total members: ${members.length}\n'
          'Approved: ${members.where((m) => m.isApproved).length}\n'
          'Pending: ${members.where((m) => !m.isApproved).length}\n\n'
          'Use the web admin panel at robocek-web-admin to export Excel files.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}

// ─── Member List ─────────────────────────────────────────────────────────────

class _MemberList extends StatelessWidget {
  final List<Member> members;
  final Future<void> Function(Member)? onApprove;
  final Future<void> Function(Member) onDelete;

  const _MemberList({
    required this.members,
    required this.onApprove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded, size: 48, color: RobocekColors.muted),
            SizedBox(height: 12),
            Text('No members found', style: TextStyle(color: RobocekColors.muted)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _MemberCard(
        member: members[i],
        onApprove: onApprove,
        onDelete: onDelete,
      ),
    );
  }
}

// ─── Member Card ─────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final Member member;
  final Future<void> Function(Member)? onApprove;
  final Future<void> Function(Member) onDelete;

  const _MemberCard({
    required this.member,
    required this.onApprove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = member.isApproved;
    final statusColor = isApproved ? RobocekColors.green : RobocekColors.amber;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MemberDetailsPage(member: member)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: RobocekColors.blue.withValues(alpha: 0.18),
                    child: Text(
                      (member.displayName.isNotEmpty ? member.displayName[0] : '?').toUpperCase(),
                      style: const TextStyle(
                        color: RobocekColors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member.email ?? '',
                          style: const TextStyle(color: RobocekColors.muted, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(isApproved: isApproved, color: statusColor),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (member.branch?.isNotEmpty == true)
                    _InfoChip(icon: Icons.school_outlined, text: member.branch!),
                  if (member.displayYear.isNotEmpty)
                    _InfoChip(icon: Icons.calendar_today_outlined, text: member.displayYear),
                  if (member.displayPhone.isNotEmpty)
                    _InfoChip(icon: Icons.phone_outlined, text: member.displayPhone),
                ],
              ),
              if (isApproved && member.membershipId?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: RobocekColors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: RobocekColors.cyan.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.badge_outlined, size: 14, color: RobocekColors.cyan),
                      const SizedBox(width: 6),
                      Text(
                        member.membershipId!,
                        style: const TextStyle(
                          color: RobocekColors.cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isApproved && onApprove != null)
                    FilledButton.icon(
                      onPressed: () => onApprove!(member),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: RobocekColors.green.withValues(alpha: 0.2),
                        foregroundColor: RobocekColors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => onDelete(member),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isApproved;
  final Color color;

  const _StatusBadge({required this.isApproved, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isApproved ? 'Approved' : 'Pending',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

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

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, isDense: true),
      isExpanded: true,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }
}

// ─── Confirm Dialog ───────────────────────────────────────────────────────────

Future<bool> _showConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required Color confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: confirmColor),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
