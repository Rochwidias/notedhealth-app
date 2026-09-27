import 'package:flutter_test/flutter_test.dart';

import 'package:notedhealth/app/router.dart';
import 'package:notedhealth/main.dart';

void main() {
  testWidgets('layar login tampil dan bisa masuk', (tester) async {
    await tester.pumpWidget(NotedHealthApp(router: buildRouter()));

    expect(find.text('NotedHealth'), findsOneWidget);
    expect(find.text('Masuk dengan Google'), findsOneWidget);
    expect(find.text('Masuk sebagai Tamu'), findsOneWidget);

    await tester.tap(find.text('Masuk sebagai Tamu'));
    await tester.pumpAndSettle();

    expect(find.text('Layar Beranda — menyusul'), findsOneWidget);
    expect(find.text('Checklist'), findsOneWidget);
  });

  testWidgets('shell punya 4 tab', (tester) async {
    await tester.pumpWidget(NotedHealthApp(router: buildRouter()));

    await tester.tap(find.text('Masuk sebagai Tamu'));
    await tester.pumpAndSettle();

    expect(find.text('Berat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  test('router punya rute login dan shell', () {
    expect(buildRouter().configuration.routes.length, 2);
  });
}
