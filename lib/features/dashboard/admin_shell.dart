import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'dashboard_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    _AdminDestination('Overview', Icons.space_dashboard_rounded),
    _AdminDestination('Members', Icons.groups_rounded),
    _AdminDestination('Events', Icons.event_rounded),
    _AdminDestination('Forms', Icons.assignment_rounded),
  ];

  void _selectDestination(int index) {
    setState(() => _selectedIndex = index);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final title = _destinations[_selectedIndex].label;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Open navigation',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ROBOCEK ADMIN',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: RobocekColors.cyan,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Badge(
              smallSize: 8,
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: RobocekColors.blue.withValues(alpha: 0.2),
              child: const Text(
                'A',
                style: TextStyle(
                  color: RobocekColors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _NavigationDrawer(
        selectedIndex: _selectedIndex,
        onSelected: _selectDestination,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardPage(onNavigate: _selectDestination),
          const _SectionPlaceholder(
            title: 'Members',
            description:
                'Review pending members, approved members, and the complete roster.',
            icon: Icons.groups_rounded,
          ),
          const _SectionPlaceholder(
            title: 'Events',
            description:
                'Create events, manage registrations, and share event links.',
            icon: Icons.event_rounded,
          ),
          const _SectionPlaceholder(
            title: 'Forms',
            description:
                'Build custom registration forms and review responses.',
            icon: Icons.assignment_rounded,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _NavigationDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _NavigationDrawer({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: RobocekColors.blue.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: RobocekColors.cyan,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROBOCEK',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Control center',
                    style: TextStyle(color: RobocekColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 28, 8),
          child: Text(
            'WORKSPACE',
            style: TextStyle(
              color: RobocekColors.muted,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.space_dashboard_outlined),
          selectedIcon: Icon(Icons.space_dashboard_rounded),
          label: Text('Overview'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups_rounded),
          label: Text('Members'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.event_outlined),
          selectedIcon: Icon(Icons.event_rounded),
          label: Text('Events'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment_rounded),
          label: Text('Forms'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 24, 28, 8),
          child: Text(
            'TOOLS',
            style: TextStyle(
              color: RobocekColors.muted,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('Import roster'),
          enabled: false,
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Settings'),
          enabled: false,
        ),
        const SizedBox(height: 32),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 24),
          child: Text(
            'ROBOCEK ADMIN  •  v1.0.0',
            style: TextStyle(color: RobocekColors.muted, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _SectionPlaceholder({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: RobocekColors.blue),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: RobocekColors.muted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              label: Text('Add $title'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDestination {
  final String label;
  final IconData icon;

  const _AdminDestination(this.label, this.icon);
}
