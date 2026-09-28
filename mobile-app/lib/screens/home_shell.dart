import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/sync_status_banner.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';

/// Bottom navigation shell with the four worker sections.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    TasksScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> titles = <String>[
      l10n.navToday,
      l10n.navTasks,
      l10n.navHistory,
      l10n.navProfile,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: Column(
        children: <Widget>[
          const SyncStatusBanner(),
          Expanded(
            child: IndexedStack(index: _index, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) => setState(() => _index = value),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: l10n.navTasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
