import 'dart:io';

import 'package:flutter/material.dart';
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
  await tester.pumpAndSettle();
  final guest = find.text('Masuk sebagai Tamu');
  // Session Hive bisa masih basi (clear async) — langsung di dashboard juga oke.
  if (guest.evaluate().isNotEmpty) {
    await tester.tap(guest);
    await tester.pumpAndSettle();
  }
}

/// Pastikan widget ada di tree (scroll list dulu bila lazy) lalu tampil di layar.
Future<void> show(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      target,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('notedhealth_test');
    Hive.init(dir.path);
    await initializeDateFormatting('id_ID', null);
    for (final name in [
      'session',
      'habits',
      'weights',
      'daily_logs',
      'prefs',
      'favorites',
    ]) {
      await Hive.openBox(name);
    }
  });

  // clear() dilepas tanpa await (future flush Hive pending di tester,
  // memori langsung konsisten) agar setUp tak gantung.
  setUp(() {
    for (final name in [
      'session',
      'habits',
      'weights',
      'daily_logs',
      'prefs',
      'favorites',
    ]) {
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

  test('router punya rute login, shell, form, katalog, favorit, riwayat, privasi',
      () {
    expect(buildRouter().configuration.routes.length, 8);
  });

  testWidgets('badge avatar profil membuka dialog edit nama', (tester) async {
    await pumpApp(tester);
    await loginAsGuest(tester);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('avatar-edit')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Nama panggilan'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('kartu streak di beranda membuka checklist', (tester) async {
    await pumpApp(tester);
    await loginAsGuest(tester);

    await tester.tap(find.text('Streak'));
    await tester.pumpAndSettle();
    expect(find.text('Checklist Hari Ini'), findsOneWidget);
  });

  testWidgets('favorit: toggle hati di detail lalu tampil di halaman Favorit',
      (tester) async {
    await pumpApp(tester);
    await loginAsGuest(tester);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await show(tester, find.text('Makanan & minuman favorit'));
    await tester.tap(find.text('Makanan & minuman favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada favorit'), findsOneWidget);

    await tester.tap(find.text('Buka katalog'));
    await tester.pumpAndSettle();
    await show(tester, find.text('Salad Sayur Segar'));
    await tester.tap(find.text('Salad Sayur Segar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('fav-toggle')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

    // Kembali ke katalog (hati = IconButton pertama, back = kedua).
    await tester.tap(find.byType(IconButton).at(1));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

    // Tombol hati appbar (back = 0, hati = 1) → halaman Favorit.
    await tester.tap(find.byType(IconButton).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Salad Sayur Segar'), findsOneWidget);
  });

  testWidgets('riwayat lengkap: link Semua lalu tap baris buka sheet ubah',
      (tester) async {
    Hive.box('weights').put(
      '2026-09-27',
      {'valueKg': 72.5, 'date': '2026-09-27'},
    );
    await pumpApp(tester);
    await loginAsGuest(tester);

    await tester.tap(find.text('Berat'));
    await tester.pumpAndSettle();
    await show(tester, find.text('Semua'));
    await tester.tap(find.text('Semua'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat'), findsWidgets);

    await show(tester, find.text('27 Sep 2026'));
    await tester.tap(find.text('27 Sep 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Ubah catatan'), findsOneWidget);
  });
}
