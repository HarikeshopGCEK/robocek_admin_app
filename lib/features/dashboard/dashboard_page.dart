import 'package:flutter/material.dart';

import '../../app/theme.dart';

class DashboardPage extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good evening, Admin',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Here is what is happening across your club today.',
              style: TextStyle(color: RobocekColors.muted),
            ),
            const SizedBox(height: 24),
            _WelcomeCard(onManageMembers: () => onNavigate(1)),
            const SizedBox(height: 24),
            Text(
              'At a glance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Total members',
                    value: '248',
                    icon: Icons.groups_rounded,
                    color: RobocekColors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Pending review',
                    value: '12',
                    icon: Icons.pending_actions_rounded,
                    color: RobocekColors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Active events',
                    value: '06',
                    icon: Icons.event_available_rounded,
                    color: RobocekColors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Form responses',
                    value: '84',
                    icon: Icons.forum_rounded,
                    color: RobocekColors.cyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Quick actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _QuickActionGrid(onNavigate: onNavigate),
            const SizedBox(height: 28),
            Text(
              'Recent activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Card(
              child: Column(
                children: [
                  _ActivityTile(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'New member registrations',
                    subtitle: '12 members waiting for review',
                    color: RobocekColors.amber,
                  ),
                  Divider(height: 1, indent: 64),
                  _ActivityTile(
                    icon: Icons.event_note_rounded,
                    title: 'Next event',
                    subtitle: 'Robotics workshop • Tomorrow, 10:00 AM',
                    color: RobocekColors.blue,
                  ),
                  Divider(height: 1, indent: 64),
                  _ActivityTile(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Latest form response',
                    subtitle: 'Workshop registration received',
                    color: RobocekColors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'ROBOCEK ADMIN  •  Built for the robotics club',
                style: TextStyle(color: RobocekColors.muted, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final VoidCallback onManageMembers;

  const _WelcomeCard({required this.onManageMembers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E4F9B), Color(0xFF16315D)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Club operations',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keep ROBOCEK moving forward.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: onManageMembers,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: const Text('Review members'),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.rocket_launch_rounded,
            size: 68,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: RobocekColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _QuickActionGrid({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Add member', Icons.person_add_alt_1_rounded, RobocekColors.blue, 1),
      ('New event', Icons.add_circle_outline_rounded, RobocekColors.green, 2),
      ('Create form', Icons.note_add_outlined, RobocekColors.cyan, 3),
      ('Import roster', Icons.upload_file_rounded, RobocekColors.amber, 1),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onNavigate(action.$4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action.$2, color: action.$3),
                  const SizedBox(height: 8),
                  Text(
                    action.$1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.14),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: RobocekColors.muted, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: RobocekColors.muted,
      ),
    );
  }
}
