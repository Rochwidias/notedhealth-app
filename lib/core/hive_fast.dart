import 'dart:async';

import 'package:flutter/foundation.dart';

/// Lepas future tulis Hive tanpa ditunggu pemanggil.
///
/// Future flush hive_ce tak kunjung selesai di flutter_tester
/// (di device/emulator flush jalan normal). Data mendarat di memori
/// secara sinkron sehingga baca langsung konsisten; flush dilepas
/// detached dan kegagalannya dicatat log. UI/state di-update sinkron
/// oleh pemanggil tepat setelah fungsi ini.
void detachHive(Future<dynamic> write, String what) {
  unawaited(write.then(
    (_) {},
    onError: (Object e) => debugPrint('hive $what gagal: $e'),
  ));
}
