import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: NotedHealthApp()));
}

class NotedHealthApp extends StatelessWidget {
  const NotedHealthApp({super.key, this.router});

  /// Router injeksian (untuk test); produksi memakai [appRouter].
  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NotedHealth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router ?? appRouter,
    );
  }
}
