import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/registration.dart';
import '../../repositories/form_repository.dart';

class ResponsesPage extends StatefulWidget {
  final String formId;
  final String title;

  const ResponsesPage({super.key, required this.formId, required this.title});

  @override
  State<ResponsesPage> createState() => _ResponsesPageState();
}

class _ResponsesPageState extends State<ResponsesPage> {
  final _repo = FormRepository();
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
        (r.membershipId ?? '').toLowerCase().contains(_search)).toList();
  }

  Future<void> _togglePayment(EventRegistration reg) async {
    try {
      await _repo.togglePaymentStatus(widget.formId, reg.id, reg.paymentStatus);
      if (mounted) {
        final newStatus = reg.paymentStatus == 'Verified' ? 'Pending' : 'Verified';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment → $newStatus'), behavior: SnackBarBehavior.floating),
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
      appBar: AppBar(title: Text('Responses: ${widget.title}', overflow: TextOverflow.ellipsis)),
      body: StreamBuilder<List<EventRegistration>>(
        stream: _repo.watchResponses(widget.formId),
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
                    hintText: 'Search responses…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => _searchController.clear())
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text('${all.length} responses', style: const TextStyle(color: RobocekColors.muted, fontSize: 12)),
                    const Spacer(),
                    Text('${all.where((r) => r.isVerified).length} verified', style: const TextStyle(color: RobocekColors.green, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_outlined, size: 48, color: RobocekColors.muted),
                            SizedBox(height: 12),
                            Text('No responses yet', style: TextStyle(color: RobocekColors.muted)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => _ResponseCard(
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

// ─── Response Card ────────────────────────────────────────────────────────────

class _ResponseCard extends StatelessWidget {
  final EventRegistration reg;
  final int index;
  final VoidCallback onTogglePayment;

  const _ResponseCard({required this.reg, required this.index, required this.onTogglePayment});

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
                  backgroundColor: RobocekColors.cyan.withValues(alpha: 0.15),
                  child: Text('$index', style: const TextStyle(color: RobocekColors.cyan, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reg.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      if (reg.email != null) Text(reg.email!, style: const TextStyle(color: RobocekColors.muted, fontSize: 12), overflow: TextOverflow.ellipsis),
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (reg.branch?.isNotEmpty == true) _Chip(Icons.school_outlined, reg.branch!),
                if (reg.year?.isNotEmpty == true) _Chip(Icons.calendar_today_outlined, reg.year!),
                if (reg.phone?.isNotEmpty == true) _Chip(Icons.phone_outlined, reg.phone!),
              ],
            ),
            if (reg.hasMembership) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 13, color: RobocekColors.cyan),
                  const SizedBox(width: 4),
                  Text(reg.membershipId!, style: const TextStyle(color: RobocekColors.cyan, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
            if (reg.feePaid != null || reg.utrNumber != null) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                children: [
                  if (reg.feePaid != null) _Chip(Icons.currency_rupee_rounded, 'Paid: ${reg.feePaid}'),
                  if (reg.utrNumber != null) _Chip(Icons.receipt_outlined, 'UTR: ${reg.utrNumber}'),
                ],
              ),
            ],
            // Custom answers from form fields
            if (reg.customAnswers?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              ...reg.customAnswers!.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('${e.key}:', style: const TextStyle(color: RobocekColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(e.value?.toString() ?? '', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  )),
            ],
            if (reg.registeredAt != null) ...[
              const SizedBox(height: 6),
              Text('Registered: ${reg.registeredAt}', style: const TextStyle(color: RobocekColors.muted, fontSize: 11)),
            ],
            if (reg.paymentStatus != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onTogglePayment,
                  icon: Icon(isVerified ? Icons.cancel_outlined : Icons.check_circle_outline_rounded, size: 16),
                  label: Text(isVerified ? 'Mark Pending' : 'Verify Payment'),
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

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: RobocekColors.muted),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: RobocekColors.muted, fontSize: 12)),
        ],
      );
}
