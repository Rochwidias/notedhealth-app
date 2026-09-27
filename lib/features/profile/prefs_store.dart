import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../core/hive_fast.dart';

/// Preferensi profil dari box Hive `prefs`:
/// nama, target berat, tinggi badan, pengingat, mode tema.
final prefsProvider =
    NotifierProvider<PrefsController, PrefsState>(PrefsController.new);

/// ThemeMode aplikasi mengikuti preferensi (default ikut sistem).
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(prefsProvider).themeMode;
});

class PrefsState {
  const PrefsState({
    this.name = '',
    this.targetKg,
    this.heightCm,
    this.reminderMorning = true,
    this.reminderNight = true,
    this.themeModeName = 'system',
  });

  final String name;
  final double? targetKg;
  final double? heightCm;
  final bool reminderMorning;
  final bool reminderNight;
  final String themeModeName; // system | light | dark

  ThemeMode get themeMode => switch (themeModeName) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  PrefsState copyWith({
    String? name,
    double? targetKg,
    double? heightCm,
    bool? reminderMorning,
    bool? reminderNight,
    String? themeModeName,
  }) =>
      PrefsState(
        name: name ?? this.name,
        targetKg: targetKg ?? this.targetKg,
        heightCm: heightCm ?? this.heightCm,
        reminderMorning: reminderMorning ?? this.reminderMorning,
        reminderNight: reminderNight ?? this.reminderNight,
        themeModeName: themeModeName ?? this.themeModeName,
      );

  /// BMI = kg ÷ m². Null bila berat/tinggi belum diisi.
  double? bmi(double? weightKg) {
    if (weightKg == null || heightCm == null || heightCm! <= 0) return null;
    final m = heightCm! / 100;
    return weightKg / (m * m);
  }
}

String bmiCategory(double bmi) {
  if (bmi < 18.5) return 'Kurus';
  if (bmi < 25) return 'Normal';
  if (bmi < 30) return 'Berlebih';
  return 'Obesitas';
}

class PrefsController extends Notifier<PrefsState> {
  Box get _box => Hive.box('prefs');

  @override
  PrefsState build() {
    double? numOf(String key) {
      final v = _box.get(key);
      return v is num ? v.toDouble() : null;
    }

    return PrefsState(
      name: (_box.get('name') as String?) ?? '',
      targetKg: numOf('targetKg'),
      heightCm: numOf('heightCm'),
      reminderMorning: (_box.get('reminderMorning') as bool?) ?? true,
      reminderNight: (_box.get('reminderNight') as bool?) ?? true,
      themeModeName: (_box.get('themeMode') as String?) ?? 'system',
    );
  }

  Future<void> _save(String key, Object? value) async {
    if (value == null) {
      detachHive(_box.delete(key), 'prefs/$key');
    } else {
      detachHive(_box.put(key, value), 'prefs/$key');
    }
  }

  Future<void> setName(String v) async {
    await _save('name', v.trim());
    state = state.copyWith(name: v.trim());
  }

  Future<void> setTargetKg(double? v) async {
    if (v != null && (v < 20 || v > 300)) {
      throw const FormatException('Target harus 20–300 kg.');
    }
    await _save('targetKg', v);
    // copyWith tak bisa set null → bangun ulang manual.
    state = PrefsState(
      name: state.name,
      targetKg: v,
      heightCm: state.heightCm,
      reminderMorning: state.reminderMorning,
      reminderNight: state.reminderNight,
      themeModeName: state.themeModeName,
    );
  }

  Future<void> setHeightCm(double? v) async {
    if (v != null && (v < 100 || v > 250)) {
      throw const FormatException('Tinggi harus 100–250 cm.');
    }
    await _save('heightCm', v);
    state = PrefsState(
      name: state.name,
      targetKg: state.targetKg,
      heightCm: v,
      reminderMorning: state.reminderMorning,
      reminderNight: state.reminderNight,
      themeModeName: state.themeModeName,
    );
  }

  Future<void> setReminderMorning(bool v) async {
    await _save('reminderMorning', v);
    state = state.copyWith(reminderMorning: v);
  }

  Future<void> setReminderNight(bool v) async {
    await _save('reminderNight', v);
    state = state.copyWith(reminderNight: v);
  }

  Future<void> setThemeModeName(String v) async {
    await _save('themeMode', v);
    state = state.copyWith(themeModeName: v);
  }
}
