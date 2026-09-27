import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localizations.dart';
import '../../widgets/svg_icon.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: SvgIcon('i-home'),
            selectedIcon: SvgIcon('i-home'),
            label: tr(context, 'Beranda'),
          ),
          NavigationDestination(
            icon: SvgIcon('i-list'),
            selectedIcon: SvgIcon('i-list'),
            label: tr(context, 'Habit'),
          ),
          NavigationDestination(
            icon: SvgIcon('i-scale'),
            selectedIcon: SvgIcon('i-scale'),
            label: tr(context, 'Berat'),
          ),
          NavigationDestination(
            icon: SvgIcon('i-user'),
            selectedIcon: SvgIcon('i-user'),
            label: tr(context, 'Profil'),
          ),
        ],
      ),
      floatingActionButton: null,
      backgroundColor: scheme.surface,
    );
  }
}
