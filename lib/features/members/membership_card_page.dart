import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../models/member.dart';

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
                                Text(
                                  'ROBOCEK',
                                  style: TextStyle(
                                    color: RobocekColors.cyan,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'GCEK Robotics Club',
                                  style: TextStyle(color: Colors.white60, fontSize: 11),
                                ),
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
                              child: const Text(
                                'MEMBER',
                                style: TextStyle(
                                  color: RobocekColors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: RobocekColors.blue.withValues(alpha: 0.25),
                          child: Text(
                            (member.displayName.isNotEmpty ? member.displayName[0] : '?').toUpperCase(),
                            style: const TextStyle(
                              color: RobocekColors.cyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          member.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (member.branch?.isNotEmpty == true) member.branch,
                            if (member.displayYear.isNotEmpty) member.displayYear,
                          ].join(' • '),
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
                                const Text(
                                  'MEMBER ID',
                                  style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.2),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  member.membershipId ?? 'N/A',
                                  style: const TextStyle(
                                    color: RobocekColors.cyan,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'VALID FOR',
                                  style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.2),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  '2025 – 2026',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
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
                        const SnackBar(
                          content: Text('Membership ID copied'),
                          behavior: SnackBarBehavior.floating,
                        ),
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
