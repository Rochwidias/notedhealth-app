import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_store.dart';

/// Mirror [readSession] untuk UI. Setiap aksi auth di repository sudah
/// menulis ke Hive; panggil [SessionController.refresh] setelahnya agar
/// UI ikut terbarui (router refresh otomatis via [sessionRefresh]).
final sessionProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => readSession();

  void refresh() => state = readSession();
}
