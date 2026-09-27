import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/shell/home_shell.dart';
import '../features/shell/placeholder_screen.dart';

/// Factory router — dipanggil ulang tiap test agar state navigasi tidak bocor
/// antar-test. Produksi memakai [appRouter].
GoRouter buildRouter() => GoRouter(
      initialLocation: '/login',
      routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(shell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Beranda'),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/checklist',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Checklist'),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/weight',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Berat'),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Profil'),
          ),
        ]),
      ],
    ),
  ],
);

/// Router produksi (satu instance untuk app berjalan).
final GoRouter appRouter = buildRouter();
