import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:notedhealth/app/router.dart';
import 'package:notedhealth/core/hive_fast.dart';
import 'package:notedhealth/main.dart';

/// Bungkus app dengan ProviderScope seperti main() di produksi.
Future<void> pumpApp(WidgetTester tester) {
  return tester.pumpWidget(
    ProviderScope(child: NotedHealthApp(router: buildRouter())),
  );
}

Future<void> loginAsGuest(WidgetTester tester) async {
  await tester.tap(find.text('Masuk sebagai Tamu'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('notedhealth_test');
    Hive.init(dir.path);
    await initializeDateFormatting('id_ID', null);
    for (final name in ['session', 'habits', 'weights', 'daily_logs', 'prefs']) {
      await Hive.openBox(name);
    }
  });

  // clear() dilepas tanpa await (future flush Hive pending di tester,
  // memori langsung konsisten) agar setUp tak gantung.
  setUp(() {
    for (final name in ['session', 'habits', 'weights', 'daily_logs', 'prefs']) {
      detachHive(Hive.box(name).clear(), 'clear/$name');
    }
  });

  testWidgets('layar login tampil dan tamu masuk ke Beranda asli', (tester) async {
    await pumpApp(tester);

    expect(find.text('Halo lagi!'), findsOneWidget);
    expect(find.text('Masuk dengan Google'), findsOneWidget);
    expect(find.text('Masuk sebagai Tamu'), findsOneWidget);

    await loginAsGuest(tester);

    // Dashboard asli: sapaan + kartu skor (bukan placeholder).
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.textContaining('Halo'), findsOneWidget);
    expect(find.text('Layar Beranda — menyusul'), findsNothing);
  });

  testWidgets('navigasi 4 tab ke layar asli', (tester) async {
    await pumpApp(tester);
    await loginAsGuest(tester);

    await tester.tap(find.text('Habit'));
    await tester.pumpAndSettle();
    expect(find.text('Checklist Hari Ini'), findsOneWidget);
    expect(find.text('Buat habit pertama'), findsOneWidget);

    await tester.tap(find.text('Berat'));
    await tester.pumpAndSettle();
    expect(find.text('Catat berat'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Data diri'), findsOneWidget);
  });

  test('router punya rute login, shell, form, katalog, dan privasi', () {
    expect(buildRouter().configuration.routes.length, 6);
  });
}
