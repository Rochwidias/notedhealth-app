import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_ce/hive.dart';

import 'session_store.dart';

/// Error auth yang pesannya aman ditampilkan langsung di snackbar.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Seluruh operasi login/keluar/hapus akun.
///
/// - Google → Firebase Auth + Firestore (`users/{uid}/...`).
/// - Tamu → murni lokal (Hive), tanpa menyentuh Firebase sama sekali.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? db})
      : _authOverride = auth,
        _dbOverride = db;

  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _dbOverride;

  /// Akses lazy — jalur Tamu tak pernah menyentuh Firebase,
  /// jadi konstruksi repo aman tanpa Firebase.initializeApp() (test).
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _db => _dbOverride ?? FirebaseFirestore.instance;

  bool _gsiReady = false;

  Future<void> _ensureGsi() async {
    if (_gsiReady) return;
    await GoogleSignIn.instance.initialize();
    _gsiReady = true;
  }

  /// Masuk dengan Google. Jika sebelumnya mode tamu, data lokal
  /// otomatis dipindah ke Firestore (merge) agar catatan tak hilang.
  Future<SessionState> signInWithGoogle() async {
    final prev = readSession();
    try {
      await _ensureGsi();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException('Token Google kosong — coba lagi.');
      }
      final cred = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      final user = cred.user;
      if (user == null) throw const AuthException('Login Google gagal.');
      final session = SessionState(
        mode: AuthMode.google,
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
      await writeSession(session);
      if (prev.mode == AuthMode.guest) {
        await _migrateGuestData(user.uid);
      }
      return session;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Login dibatalkan.');
      }
      throw AuthException('Login Google gagal (${e.code.name}).');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyAuth(e.code));
    }
  }

  /// Masuk sebagai tamu — 100% lokal, tanpa Firebase.
  Future<SessionState> continueAsGuest() async {
    const session = SessionState(mode: AuthMode.guest, uid: 'guest');
    await writeSession(session);
    return session;
  }

  Future<void> signOut() async {
    final mode = readSession().mode;
    if (mode == AuthMode.google) {
      await _auth.signOut();
      try {
        await GoogleSignIn.instance.signOut();
      } on GoogleSignInException {
        // Abaikan — sesi Firebase sudah keluar.
      }
    }
    await writeSession(const SessionState.signedOut());
  }

  /// Hapus akun Google + seluruh datanya (cloud & lokal). Khusus Google.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('Tidak ada sesi Google.');
    final uid = user.uid;
    try {
      // Hapus subkoleksi milik user (data kecil, batch per koleksi).
      for (final col in ['habits', 'weights', 'daily_logs']) {
        final snap = await _db.collection('users/$uid/$col').get();
        if (snap.docs.isEmpty) continue;
        var batch = _db.batch();
        var n = 0;
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
          if (++n == 400) {
            await batch.commit();
            batch = _db.batch();
            n = 0;
          }
        }
        if (n > 0) await batch.commit();
      }
      await _db.doc('users/$uid').delete().catchError((_) {});
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthException(
            'Sesi kedaluwarsa — keluar lalu masuk lagi, baru hapus akun.');
      }
      throw AuthException(_friendlyAuth(e.code));
    }
    await _clearLocalBoxes();
    await writeSession(const SessionState.signedOut());
  }

  /// Pindah isi box lokal tamu ke Firestore milik [uid], lalu kosongkan box.
  /// Box `habits`/`weights`/`daily_logs` baru terisi mulai Plan C/D —
  /// fungsi ini defensif: box yang belum ada dilewati.
  Future<void> _migrateGuestData(String uid) async {
    const targets = {
      'habits': 'habits', // doc auto-ID
      'weights': 'weights', // doc auto-ID
      'daily_logs': 'daily_logs', // doc ID = tanggal
    };
    try {
      for (final entry in targets.entries) {
        if (!Hive.isBoxOpen(entry.key)) continue;
        final box = Hive.box(entry.key);
        if (box.isEmpty) continue;
        final batch = _db.batch();
        for (final key in box.keys) {
          final value = box.get(key);
          if (value is! Map) continue;
          final data = Map<String, dynamic>.from(value);
          final ref = entry.key == 'daily_logs'
              ? _db.doc('users/$uid/${entry.value}/$key')
              : _db.collection('users/$uid/${entry.value}').doc();
          batch.set(ref, data, SetOptions(merge: true));
        }
        await batch.commit();
        await box.clear();
      }
    } on FirebaseException {
      throw const AuthException(
          'Masuk berhasil, tapi data tamu gagal dipindah — periksa koneksi.');
    }
  }

  Future<void> _clearLocalBoxes() async {
    for (final name in ['habits', 'weights', 'daily_logs']) {
      if (Hive.isBoxOpen(name)) await Hive.box(name).clear();
    }
  }

  String _friendlyAuth(String code) {
    switch (code) {
      case 'network-request-failed':
        return 'Tidak ada koneksi — periksa internet lalu coba lagi.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan — tunggu sebentar.';
      default:
        return 'Login Google gagal ($code).';
    }
  }
}
