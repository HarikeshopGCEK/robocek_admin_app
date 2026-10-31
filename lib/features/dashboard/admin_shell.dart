import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../repositories/auth_repository.dart';
import '../events/events_page.dart';
import '../forms/forms_page.dart';
import '../imports/roster_import_page.dart';
import '../members/members_page.dart';
import 'dashboard_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;
  final _authRepo = AuthRepository();

  static const _destinations = [
    _AdminDestination('Overview', Icons.space_dashboard_rounded),
    _AdminDestination('Members', Icons.groups_rounded),
    _AdminDestination('Events', Icons.event_rounded),
    _AdminDestination('Forms', Icons.assignment_rounded),
    _AdminDestination('Import', Icons.upload_file_rounded),
  ];

  void _selectDestination(int index) {
    setState(() => _selectedIndex = index);
    Navigator.of(context).maybePop();
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true) await _authRepo.signOut();
  }

  String _getAdminInitial() {
    final user = FirebaseAuth.instance.currentUser;
    return (user?.email?.substring(0, 1) ?? 'A').toUpperCase();
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _signOut,
              child: Tooltip(
                message: 'Sign out',
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: RobocekColors.blue.withValues(alpha: 0.2),
                  child: Text(
                    _getAdminInitial(),
                    style: const TextStyle(
                      color: RobocekColors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _NavigationDrawer(
        selectedIndex: _selectedIndex,
        onSelected: _selectDestination,
        onSignOut: _signOut,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardPage(onNavigate: _selectDestination),
          const MembersPage(),
          const EventsPage(),
          const FormsPage(),
          const RosterImportPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex > 3 ? 0 : _selectedIndex, // only show 4 in bottom nav
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Members',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_rounded),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Forms',
          ),
        ],
      ),
    );
  }
}

class _NavigationDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onSignOut;

  const _NavigationDrawer({
    required this.selectedIndex,
    required this.onSelected,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                child: const Icon(Icons.smart_toy_rounded, color: RobocekColors.cyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ROBOCEK',
                      style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                    Text(
                      user?.email ?? 'Admin',
                      style: const TextStyle(color: RobocekColors.muted, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 28, 8),
          child: Text(
            'WORKSPACE',
            style: TextStyle(color: RobocekColors.muted, fontSize: 11, letterSpacing: 1.2),
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
            style: TextStyle(color: RobocekColors.muted, fontSize: 11, letterSpacing: 1.2),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.upload_file_outlined),
          selectedIcon: Icon(Icons.upload_file_rounded),
          label: Text('Import roster'),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
            onTap: onSignOut,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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

class _AdminDestination {
  final String label;
  final IconData icon;

  const _AdminDestination(this.label, this.icon);
}
