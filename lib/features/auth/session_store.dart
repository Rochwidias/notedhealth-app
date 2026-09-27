import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import '../../core/hive_fast.dart';

/// Mode sesi login.
enum AuthMode { signedOut, guest, google }

/// Status sesi — satu-satunya sumber kebenaran adalah box Hive `session`
/// (agar guard router yang berjalan di luar Riverpod bisa baca sinkron).
/// [sessionProvider] me-mirror state ini untuk UI.
class SessionState {
  const SessionState({
    required this.mode,
    this.uid,
    this.email,
    this.displayName,
  });

  const SessionState.signedOut()
      : mode = AuthMode.signedOut,
        uid = null,
        email = null,
        displayName = null;

  final AuthMode mode;
  final String? uid;
  final String? email;
  final String? displayName;

  bool get isSignedIn => mode != AuthMode.signedOut;
  bool get isGuest => mode == AuthMode.guest;
  bool get isGoogle => mode == AuthMode.google;

  Map<String, dynamic> toMap() => {
        'mode': mode.name,
        if (uid != null) 'uid': uid,
        if (email != null) 'email': email,
        if (displayName != null) 'displayName': displayName,
      };

  factory SessionState.fromMap(Map<dynamic, dynamic> map) {
    final mode = AuthMode.values.asNameMap()[map['mode']] ?? AuthMode.signedOut;
    if (mode == AuthMode.signedOut) return const SessionState.signedOut();
    return SessionState(
      mode: mode,
      uid: map['uid'] as String?,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
    );
  }
}

const _boxName = 'session';
const _key = 'state';

/// Didengar go_router agar guard rute refresh tiap sesi berubah.
final ValueNotifier<int> sessionRefresh = ValueNotifier<int>(0);

SessionState readSession() {
  if (!Hive.isBoxOpen(_boxName)) return const SessionState.signedOut();
  final raw = Hive.box(_boxName).get(_key);
  if (raw is! Map) return const SessionState.signedOut();
  return SessionState.fromMap(raw);
}

Future<void> writeSession(SessionState session) async {
  detachHive(Hive.box(_boxName).put(_key, session.toMap()), 'session');
  sessionRefresh.value++;
}
