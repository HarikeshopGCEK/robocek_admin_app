import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/registration.dart';
import '../../repositories/event_repository.dart';

class RegistrationsPage extends StatefulWidget {
  final String eventId;
  final String title;
  final bool isCustomForm;

  const RegistrationsPage({
    super.key,
    required this.eventId,
    required this.title,
    this.isCustomForm = false,
  });

  @override
  State<RegistrationsPage> createState() => _RegistrationsPageState();
}

class _RegistrationsPageState extends State<RegistrationsPage> {
  final _repo = EventRepository();
  final _searchController = TextEditingController();
  String _search = '';

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

  List<EventRegistration> _filtered(List<EventRegistration> all) {
    if (_search.isEmpty) return all;
    return all.where((r) =>
        (r.fullName ?? '').toLowerCase().contains(_search) ||
        (r.email ?? '').toLowerCase().contains(_search) ||
        (r.membershipId ?? '').toLowerCase().contains(_search) ||
        (r.utrNumber ?? '').toLowerCase().contains(_search)).toList();
  }

  Future<void> _togglePayment(EventRegistration reg) async {
    try {
      await _repo.togglePaymentStatus(widget.eventId, reg.id, reg.paymentStatus);
      if (mounted) {
        final newStatus = reg.paymentStatus == 'Verified' ? 'Pending' : 'Verified';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment status → $newStatus'), behavior: SnackBarBehavior.floating),
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
      appBar: AppBar(title: Text(widget.title, overflow: TextOverflow.ellipsis)),
      body: StreamBuilder<List<EventRegistration>>(
        stream: _repo.watchRegistrations(widget.eventId),
        builder: (ctx, snap) {
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search registrations…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${all.length} registrations',
                      style: const TextStyle(color: RobocekColors.muted, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${all.where((r) => r.isVerified).length} verified',
                      style: const TextStyle(color: RobocekColors.green, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 48, color: RobocekColors.muted),
                            SizedBox(height: 12),
                            Text('No registrations yet', style: TextStyle(color: RobocekColors.muted)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => _RegistrationCard(
                          reg: filtered[i],
                          index: i + 1,
                          onTogglePayment: () => _togglePayment(filtered[i]),
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

// ─── Registration Card ────────────────────────────────────────────────────────

class _RegistrationCard extends StatelessWidget {
  final EventRegistration reg;
  final int index;
  final VoidCallback onTogglePayment;

  const _RegistrationCard({
    required this.reg,
    required this.index,
    required this.onTogglePayment,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = reg.isVerified;
    final paymentColor = isVerified ? RobocekColors.green : RobocekColors.amber;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: RobocekColors.blue.withValues(alpha: 0.2),
                  child: Text('$index', style: const TextStyle(color: RobocekColors.cyan, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reg.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(reg.email ?? '', style: const TextStyle(color: RobocekColors.muted, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (reg.paymentStatus != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: paymentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(reg.paymentStatus!, style: TextStyle(color: paymentColor, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (reg.branch?.isNotEmpty == true) _InfoChip(Icons.school_outlined, reg.branch!),
                if (reg.year?.isNotEmpty == true) _InfoChip(Icons.calendar_today_outlined, reg.year!),
                if (reg.phone?.isNotEmpty == true) _InfoChip(Icons.phone_outlined, reg.phone!),
              ],
            ),
            if (reg.hasMembership) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RobocekColors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: RobocekColors.cyan.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.badge_outlined, size: 13, color: RobocekColors.cyan),
                    const SizedBox(width: 5),
                    Text(reg.membershipId!, style: const TextStyle(color: RobocekColors.cyan, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
            if (reg.feePaid != null || reg.utrNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (reg.feePaid != null)
                    _InfoChip(Icons.currency_rupee_rounded, 'Fee: ${reg.feePaid}'),
                  if (reg.utrNumber != null) ...[
                    const SizedBox(width: 12),
                    _InfoChip(Icons.receipt_outlined, 'UTR: ${reg.utrNumber}'),
                  ],
                ],
              ),
            ],
            // Show custom answers
            if (reg.customAnswers?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              ...reg.customAnswers!.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e.key}: ', style: const TextStyle(color: RobocekColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                        Expanded(child: Text(e.value?.toString() ?? '', style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  )),
            ],
            if (reg.paymentStatus != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onTogglePayment,
                  icon: Icon(isVerified ? Icons.cancel_outlined : Icons.check_circle_outline_rounded, size: 16),
                  label: Text(isVerified ? 'Mark as Pending' : 'Verify Payment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isVerified ? RobocekColors.amber : RobocekColors.green,
                    side: BorderSide(color: isVerified ? RobocekColors.amber : RobocekColors.green),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: RobocekColors.muted),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: RobocekColors.muted, fontSize: 12)),
      ],
    );
  }
}
