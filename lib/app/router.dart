import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/session_store.dart';
import '../features/catalog/catalog_screen.dart';
import '../features/catalog/food_detail_screen.dart';
import '../features/checklist/checklist_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/habits/habit_form_screen.dart';
import '../features/profile/privacy_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/shell/home_shell.dart';
import '../features/weight/weight_screen.dart';

/// Factory agar tiap test dapat router segar (tidak bocor state antar-test).
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: readSession().isSignedIn ? '/home' : '/login',
    refreshListenable: sessionRefresh,
    redirect: (context, state) {
      final signedIn = readSession().isSignedIn;
      final onLogin = state.matchedLocation == '/login';
      if (!signedIn && !onLogin) return '/login';
      if (signedIn && onLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (ctx, st) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (ctx, st, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (ctx, st) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/checklist', builder: (ctx, st) => const ChecklistScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/weight', builder: (ctx, st) => const WeightScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (ctx, st) => const ProfileScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: '/habit-form',
        builder: (ctx, st) => HabitFormScreen(habitId: st.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/catalog',
        builder: (ctx, st) => CatalogScreen(
          initialTab:
              int.tryParse(st.uri.queryParameters['tab'] ?? '0') ?? 0,
        ),
      ),
      GoRoute(
        path: '/food/:id',
        builder: (ctx, st) => FoodDetailScreen(id: st.pathParameters['id'] ?? ''),
      ),
      GoRoute(path: '/privacy', builder: (ctx, st) => const PrivacyScreen()),
    ],
  );
}
