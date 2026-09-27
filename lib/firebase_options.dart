// STUB SEMENTARA — ditimpa otomatis oleh `flutterfire configure`.
// Dibuat agar `flutter analyze` / `flutter test` bisa jalan sambil
// menunggu project Firebase diaktifkan di console.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError('Platform belum dikonfigurasi flutterfire');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'STUB-akan-ditimpa-flutterfire',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'notedhealth-app',
  );
}
