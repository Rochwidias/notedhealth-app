import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/prefs_store.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Hive.initFlutter();
  await Hive.openBox('session');
  await Hive.openBox('habits');
  await Hive.openBox('weights');
  await Hive.openBox('daily_logs');
  await Hive.openBox('prefs');
  // Firebase stub — login Google aktif nanti; dibungkus agar mode Tamu
  // tetap jalan penuh tanpa Firebase.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Cache offline Firestore — app tetap jalan tanpa internet.
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
    await GoogleSignIn.instance.initialize();
  } catch (_) {
    // Abaikan — mode Tamu 100% lokal.
  }
  runApp(ProviderScope(child: NotedHealthApp(router: buildRouter())));
}

class NotedHealthApp extends ConsumerWidget {
  const NotedHealthApp({super.key, this.router});

  /// Router injeksian (untuk test); produksi diisi dari main().
  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'NotedHealth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router ?? buildRouter(),
    );
  }
}
