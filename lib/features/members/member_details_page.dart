import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../models/member.dart';
import '../../repositories/member_repository.dart';

class MemberDetailsPage extends StatelessWidget {
  final Member member;

  const MemberDetailsPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
        actions: [
          if (member.membershipId?.isNotEmpty == true)
            IconButton(
              tooltip: 'View Membership Card',
              icon: const Icon(Icons.badge_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MembershipCardPage(member: member)),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar & name header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: RobocekColors.blue.withValues(alpha: 0.18),
                      child: Text(
                        (member.displayName.isNotEmpty ? member.displayName[0] : '?').toUpperCase(),
                        style: const TextStyle(color: RobocekColors.cyan, fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      member.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: (member.isApproved ? RobocekColors.green : RobocekColors.amber).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        member.isApproved ? 'Approved Member' : 'Pending Approval',
                        style: TextStyle(
                          color: member.isApproved ? RobocekColors.green : RobocekColors.amber,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Membership ID card
              if (member.membershipId?.isNotEmpty == true)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1E4F9B), Color(0xFF16315D)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_rounded, color: RobocekColors.cyan, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Membership ID', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            member.membershipId!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: member.membershipId!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Membership ID copied'), behavior: SnackBarBehavior.floating),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // Info fields
              _SectionTitle('Personal Information'),
              _DetailCard(
                children: [
                  _InfoRow(icon: Icons.email_outlined, label: 'Email', value: member.email ?? '—'),
                  _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: member.displayPhone.isNotEmpty ? member.displayPhone : '—'),
                  _InfoRow(icon: Icons.school_outlined, label: 'Branch', value: member.branch ?? '—'),
                  _InfoRow(icon: Icons.calendar_today_outlined, label: 'Year / Semester', value: member.displayYear.isNotEmpty ? member.displayYear : '—'),
                ],
              ),
              const SizedBox(height: 16),
              _SectionTitle('Account Details'),
              _DetailCard(
                children: [
                  _InfoRow(icon: Icons.fingerprint_rounded, label: 'UID', value: member.uid ?? member.id),
                  _InfoRow(icon: Icons.access_time_rounded, label: 'Registered', value: member.createdAt ?? '—'),
                  if (member.approvedAt != null)
                    _InfoRow(icon: Icons.check_circle_outline_rounded, label: 'Approved', value: member.approvedAt!),
                ],
              ),
              // Show extra fields
              if (member.extra.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionTitle('All Fields'),
                _DetailCard(
                  children: member.extra.entries
                      .where((e) => !['uid', 'fullName', 'email', 'phone', 'phoneNumber', 'branch', 'year', 'yearSemester', 'status', 'membershipId', 'createdAt', 'approvedAt'].contains(e.key))
                      .where((e) => e.value != null && e.value.toString().isNotEmpty)
                      .map((e) => _InfoRow(icon: Icons.info_outline_rounded, label: e.key, value: e.value.toString()))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              // Actions
              if (!member.isApproved)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final repo = MemberRepository();
                      try {
                        await repo.approveMember(member);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Member approved!'),
                              backgroundColor: RobocekColors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Approve Member'),
                    style: FilledButton.styleFrom(
                      backgroundColor: RobocekColors.green.withValues(alpha: 0.2),
                      foregroundColor: RobocekColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(color: RobocekColors.muted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8),
        ),
      );
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const Divider(height: 1, indent: 48),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: RobocekColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: RobocekColors.muted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Membership Card Page ─────────────────────────────────────────────────────

class MembershipCardPage extends StatelessWidget {
  final Member member;

  const MembershipCardPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership Card')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Digital Membership Card',
                  style: TextStyle(color: RobocekColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 340),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A3A6B), Color(0xFF0B1B3A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RobocekColors.cyan.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.smart_toy_rounded, color: RobocekColors.cyan, size: 28),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ROBOCEK', style: TextStyle(color: RobocekColors.cyan, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 15)),
                                Text('GCEK Robotics Club', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: RobocekColors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: RobocekColors.green.withValues(alpha: 0.5)),
                              ),
                              child: const Text('MEMBER', style: TextStyle(color: RobocekColors.green, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: RobocekColors.blue.withValues(alpha: 0.25),
                          child: Text(
                            (member.displayName.isNotEmpty ? member.displayName[0] : '?').toUpperCase(),
                            style: const TextStyle(color: RobocekColors.cyan, fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          member.displayName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${member.branch ?? ''} ${member.displayYear.isNotEmpty ? '• ${member.displayYear}' : ''}',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        Container(height: 1, color: Colors.white12),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('MEMBER ID', style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.2)),
                                const SizedBox(height: 3),
                                Text(
                                  member.membershipId ?? 'N/A',
                                  style: const TextStyle(color: RobocekColors.cyan, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1),
                                ),
                              ],
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('VALID FOR', style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.2)),
                                SizedBox(height: 3),
                                Text('2025 – 2026', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    if (member.membershipId != null) {
                      Clipboard.setData(ClipboardData(text: member.membershipId!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membership ID copied'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy Membership ID'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
