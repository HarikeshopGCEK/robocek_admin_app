import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/member.dart';
import '../../models/event.dart';
import '../../models/custom_form.dart';
import '../../repositories/member_repository.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/form_repository.dart';

class DashboardPage extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: _DashboardContent(onNavigate: onNavigate),
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const _DashboardContent({required this.onNavigate});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  final _memberRepo = MemberRepository();
  final _eventRepo = EventRepository();
  final _formRepo = FormRepository();

  List<Member> _members = [];
  List<RobocekEvent> _events = [];
  List<CustomForm> _forms = [];

  @override
  void initState() {
    super.initState();
    _memberRepo.watchAll().listen((list) {
      if (mounted) setState(() => _members = list);
    });
    _eventRepo.watchAll().listen((list) {
      if (mounted) setState(() => _events = list);
    });
    _formRepo.watchAll().listen((list) {
      if (mounted) setState(() => _forms = list);
    });
  }

  int get _totalResponses => _forms.fold(0, (acc, _) => acc);

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final pendingCount = _members.where((m) => !m.isApproved).length;
    final approvedCount = _members.where((m) => m.isApproved).length;
    final activeEvents = _events.where((e) => (e.status ?? '').toLowerCase() == 'upcoming' || (e.status ?? '').toLowerCase() == 'ongoing').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, Admin',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Here is what is happening across your club today.',
          style: TextStyle(color: RobocekColors.muted),
        ),
        const SizedBox(height: 24),
        _WelcomeCard(onManageMembers: () => widget.onNavigate(1)),
        const SizedBox(height: 24),
        Text(
          'At a glance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Total members',
                value: '${_members.length}',
                icon: Icons.groups_rounded,
                color: RobocekColors.blue,
                onTap: () => widget.onNavigate(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Pending review',
                value: '$pendingCount',
                icon: Icons.pending_actions_rounded,
                color: RobocekColors.amber,
                onTap: () => widget.onNavigate(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Active events',
                value: '$activeEvents',
                icon: Icons.event_available_rounded,
                color: RobocekColors.green,
                onTap: () => widget.onNavigate(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Custom forms',
                value: '${_forms.length}',
                icon: Icons.assignment_rounded,
                color: RobocekColors.cyan,
                onTap: () => widget.onNavigate(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Quick actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _QuickActionGrid(onNavigate: widget.onNavigate),
        const SizedBox(height: 28),
        Text(
          'Recent activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _ActivityTile(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Member approvals needed',
                subtitle: pendingCount > 0 ? '$pendingCount member${pendingCount != 1 ? 's' : ''} waiting for review' : 'All members approved',
                color: pendingCount > 0 ? RobocekColors.amber : RobocekColors.green,
                onTap: () => widget.onNavigate(1),
              ),
              const Divider(height: 1, indent: 64),
              _ActivityTile(
                icon: Icons.event_note_rounded,
                title: 'Events',
                subtitle: _events.isEmpty
                    ? 'No events yet — create one!'
                    : '${_events.length} event${_events.length != 1 ? 's' : ''} · $activeEvents active',
                color: RobocekColors.blue,
                onTap: () => widget.onNavigate(2),
              ),
              const Divider(height: 1, indent: 64),
              _ActivityTile(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Custom forms',
                subtitle: _forms.isEmpty
                    ? 'No forms yet — create one!'
                    : '${_forms.length} form${_forms.length != 1 ? 's' : ''} · ${_forms.where((f) => f.isActive).length} active',
                color: RobocekColors.cyan,
                onTap: () => widget.onNavigate(3),
              ),
              if (approvedCount > 0) ...[
                const Divider(height: 1, indent: 64),
                _ActivityTile(
                  icon: Icons.verified_user_rounded,
                  title: 'Approved members',
                  subtitle: '$approvedCount of ${_members.length} members approved',
                  color: RobocekColors.green,
                  onTap: () => widget.onNavigate(1),
                ),
              ],
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
  final VoidCallback onTap;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 14),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(color: RobocekColors.muted, fontSize: 12),
              ),
            ],
          ),
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
      ('Review Members', Icons.manage_accounts_rounded, RobocekColors.blue, 1),
      ('New Event', Icons.add_circle_outline_rounded, RobocekColors.green, 2),
      ('Create Form', Icons.note_add_outlined, RobocekColors.cyan, 3),
      ('Import Roster', Icons.upload_file_rounded, RobocekColors.amber, 4),
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
  final VoidCallback onTap;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
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
      onTap: onTap,
    );
  }
}
