import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:notedhealth/core/i18n/app_localizations.dart';

import '../auth/session_provider.dart';
import '../auth/session_store.dart';
import '../../core/format.dart';
import '../auth/auth_repository.dart';
import 'prefs_store.dart';
import '../weight/weight_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/ico_chip.dart';
import '../../widgets/svg_icon.dart';

/// Layar Profil — frame 08 (+ sheet tinggi badan).
/// Hero avatar, data diri, pengingat, aplikasi, hapus data.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _busy = false;

  Future<void> _editText({
    required String title,
    required String initial,
    required String hint,
    required String? Function(String) onSave,
  }) async {
    final c = TextEditingController(text: initial);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr(context, 'Batal'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr(context, 'Simpan'))),
        ],
      ),
    );
    if (ok == true && mounted) {
      final err = onSave(c.text.trim());
      if (err != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  /// Sheet tinggi badan — frame 08 (sheetTinggi): big input + preview BMI.
  Future<void> _showHeightSheet() async {
    final prefs = ref.read(prefsProvider);
    final latest = ref.read(latestWeightProvider);
    final ctrl = TextEditingController(
      text: prefs.heightCm?.toStringAsFixed(0) ?? '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          final theme = Theme.of(ctx);
          final isDark = theme.brightness == Brightness.dark;
          final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
          final lang = Localizations.localeOf(context).languageCode;
          final surface3 = isDark ? AppColors.darkSurface3 : AppColors.lightSurface3;
          final cm = double.tryParse(ctrl.text.replaceAll(',', '.'));
          final valid = cm != null && cm >= 100 && cm <= 250;
          final bmi = (valid && latest != null)
              ? latest.valueKg / ((cm / 100) * (cm / 100))
              : null;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: surface3,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(tr(context, 'Tinggi badan'), style: AppText.display(20)),
                  const SizedBox(height: 4),
                  Text(
                    tr(context, 'Cukup diisi sekali — dipakai hitung BMI.'),
                    style: AppText.body(12.5, color: muted),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextField(
                          controller: ctrl,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: AppText.display(57.6, weight: FontWeight.w600),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: '172',
                          ),
                          onChanged: (_) => setS(() {}),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 6),
                        child: Text(tr(context, 'cm'), style: AppText.body(17.6, weight: FontWeight.w800, color: muted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (bmi != null)
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.successSoftDark : AppColors.successSoftLight,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'BMI ${fmtKg(bmi, lang: lang)} · ${tr(context, bmiCategory(bmi))}',
                              style: TextStyle(
                                fontSize: 12.48,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.successDark : AppColors.successLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tr(context, 'dengan berat {x} kg')
                                .replaceAll('{x}', fmtKg(latest!.valueKg, lang: lang)),
                            style: AppText.body(12, color: muted),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(tr(context, 'Rentang valid 100–250 cm'), style: AppText.body(12.5, color: muted)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(tr(context, 'Batal')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!valid) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(tr(context, 'Isi 100–250 cm.'))),
                              );
                              return;
                            }
                            ref.read(prefsProvider.notifier).setHeightCm(cm);
                            Navigator.pop(ctx);
                          },
                          child: Text(tr(context, 'Simpan')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _signOut() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(context, 'Keluar?')),
        content: Text(
          tr(
            context,
            'Kamu bisa masuk lagi kapan saja. Data di perangkat ini tetap tersimpan.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr(context, 'Batal'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr(context, 'Keluar'))),
        ],
      ),
    );
    if (yes != true) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      ref.read(sessionProvider.notifier).refresh();
      if (mounted) context.go('/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal keluar: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _wipeLocal() async {
    final session = ref.read(sessionProvider);
    final isGoogle = session.mode == AuthMode.google;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isGoogle ? tr(context, 'Hapus akun & data?') : tr(context, 'Hapus semua data?'),
        ),
        content: Text(
          isGoogle
              ? tr(
                  context,
                  'Akun Google dan seluruh data cloud ikut terhapus permanen. Lanjutkan?',
                )
              : tr(
                  context,
                  'Seluruh habit, berat, dan skor di perangkat ini terhapus permanen. Lanjutkan?',
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr(context, 'Batal'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr(context, 'Hapus')),
          ),
        ],
      ),
    );
    if (yes != true) return;
    setState(() => _busy = true);
    try {
      if (isGoogle) {
        await ref.read(authRepositoryProvider).deleteAccount();
      } else {
        for (final name in ['habits', 'weights', 'daily_logs', 'prefs']) {
          if (Hive.isBoxOpen(name)) await Hive.box(name).clear();
        }
        await ref.read(authRepositoryProvider).signOut();
      }
      ref.read(sessionProvider.notifier).refresh();
      if (mounted) context.go('/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = ref.watch(sessionProvider);
    final prefs = ref.watch(prefsProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final isGoogle = session.mode == AuthMode.google;
    final dangerSoft = isDark ? AppColors.dangerSoftDark : AppColors.dangerSoftLight;
    final danger = isDark ? AppColors.dangerDark : AppColors.dangerLight;

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'Profil')), centerTitle: false),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _Hero(
                  name: prefs.name,
                  subtitle: isGoogle
                      ? (session.email ?? tr(context, 'Akun Google'))
                      : tr(context, 'Mode tamu · data di perangkat ini'),
                  avatar: prefs.name.isEmpty ? '?' : prefs.name.characters.first.toUpperCase(),
                  onEdit: () => _editText(
                    title: tr(context, 'Nama'), initial: prefs.name, hint: tr(context, 'Nama panggilan'),
                    onSave: (v) {
                      if (v.length < 2) return tr(context, 'Nama minimal 2 huruf.');
                      ref.read(prefsProvider.notifier).setName(v);
                      return null;
                    },
                  ),
                ),
                _Sec(tr(context, 'Data diri')),
                _Row(
                  icon: 'i-pencil', tone: IcoTone.violet,
                  label: tr(context, 'Nama'), desc: tr(context, 'Tampil di dashboard'), value: prefs.name,
                  onTap: () => _editText(
                    title: tr(context, 'Nama'), initial: prefs.name, hint: tr(context, 'Nama panggilan'),
                    onSave: (v) {
                      if (v.length < 2) return tr(context, 'Nama minimal 2 huruf.');
                      ref.read(prefsProvider.notifier).setName(v);
                      return null;
                    },
                  ),
                ),
                _Row(
                  icon: 'i-target', tone: IcoTone.blue,
                  label: tr(context, 'Target berat'), desc: tr(context, 'Dipakai hitung selisih'),
                  value: prefs.targetKg == null
                      ? tr(context, 'Belum diisi')
                      : '${fmtKg(prefs.targetKg!, lang: lang)} kg',
                  onTap: () => _editText(
                    title: tr(context, 'Target berat'),
                    initial: prefs.targetKg == null
                        ? ''
                        : fmtKg(prefs.targetKg!, lang: lang),
                    hint: tr(context, 'contoh 68'),
                    onSave: (v) {
                      final kg = parseKg(v);
                      if (kg == null || kg < 20 || kg > 300) return tr(context, 'Isi 20–300 kg.');
                      ref.read(prefsProvider.notifier).setTargetKg(kg);
                      return null;
                    },
                  ),
                ),
                _Row(
                  icon: 'i-height', tone: IcoTone.green,
                  label: tr(context, 'Tinggi badan'), desc: tr(context, 'Untuk hitung BMI'),
                  value: prefs.heightCm == null
                      ? tr(context, 'Belum diisi')
                      : '${prefs.heightCm!.toStringAsFixed(0)} cm',
                  onTap: _showHeightSheet,
                ),
                _Sec(tr(context, 'Pengingat harian')),
                _TimeCard(
                  icon: 'i-clock', tone: IcoTone.amber,
                  time: '07:00', label: tr(context, 'Pagi — cek checklist'),
                  on: prefs.reminderMorning,
                  onChanged: (v) => ref.read(prefsProvider.notifier).setReminderMorning(v),
                ),
                _TimeCard(
                  icon: 'i-moon', tone: IcoTone.violet,
                  time: '21:00', label: tr(context, 'Malam — catat berat & skor'),
                  on: prefs.reminderNight,
                  onChanged: (v) => ref.read(prefsProvider.notifier).setReminderNight(v),
                ),
                _Sec(tr(context, 'Aplikasi')),
                _Row(
                  icon: 'i-moon', tone: IcoTone.violet,
                  label: tr(context, 'Mode gelap'), desc: tr(context, 'Sementara ikuti preferensi sistem'),
                  trailing: Switch(
                    value: prefs.themeModeName == 'dark',
                    onChanged: (v) => ref
                        .read(prefsProvider.notifier)
                        .setThemeModeName(v ? 'dark' : 'system'),
                  ),
                  onTap: () => ref.read(prefsProvider.notifier).setThemeModeName(
                      prefs.themeModeName == 'dark' ? 'system' : 'dark'),
                ),
                _Row(
                  icon: 'i-globe', tone: IcoTone.blue,
                  label: tr(context, 'Bahasa'), desc: tr(context, 'Ganti bahasa aplikasi'),
                  trailing: const _LangSeg(),
                ),
                _Row(
                  icon: 'i-leaf', tone: IcoTone.green,
                  label: tr(context, 'Katalog menu sehat'), desc: tr(context, 'Makanan & minuman favorit'),
                  onTap: () => context.push('/catalog'),
                ),
                _Row(
                  icon: 'i-shield', tone: IcoTone.blue,
                  label: tr(context, 'Privasi & Legal'), desc: tr(context, 'Kebijakan, syarat layanan & kredit'),
                  onTap: () => context.push('/privacy'),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _busy ? null : _signOut,
                    child: Text(tr(context, 'Keluar')),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dangerSoft,
                      foregroundColor: danger,
                    ),
                    onPressed: _busy ? null : _wipeLocal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SvgIcon('i-trash', size: 18),
                        const SizedBox(width: 8),
                        Text(isGoogle
                            ? tr(context, 'Hapus akun & data')
                            : tr(context, 'Hapus semua data')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'NotedHealth v0.1.0',
                    style: AppText.body(12, color: isDark ? AppColors.darkMuted : AppColors.lightMuted),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.name, required this.subtitle, required this.avatar, required this.onEdit});

  final String name;
  final String subtitle;
  final String avatar;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final primaryInk = isDark ? AppColors.primaryInkDark : AppColors.primaryInkLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, Color(0xFFFF9F43)],
                  ),
                ),
                child: Material(
                  key: const ValueKey('avatar-edit'),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(34),
                    child: Center(
                      child: Text(
                        avatar,
                        style: AppText.display(38.4, color: const Color(0xFF4A3200)),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryInk,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                  ),
                  child: const Center(
                    child: SvgIcon('i-pencil', size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(name, style: const TextStyle(fontSize: 17.6, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(subtitle, style: AppText.body(12, color: muted)),
        ],
      ),
    );
  }
}

class _Sec extends StatelessWidget {
  const _Sec(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16.32,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
    );
  }
}

/// Row-btn mockup: kartu radius 18, ico-chip + label/desc + value/chevron/trailing.
class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.tone,
    required this.label,
    required this.desc,
    this.value,
    this.trailing,
    this.onTap,
  });

  final String icon;
  final IcoTone tone;
  final String label;
  final String desc;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final primaryInk = isDark ? AppColors.primary : AppColors.primaryInkLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF1E1B2E))
                .withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              IcoChip(icon: icon, tone: tone),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 14.4, fontWeight: FontWeight.w800)),
                    Text(desc, style: AppText.body(12.16, color: muted)),
                  ],
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(fontSize: 14.08, fontWeight: FontWeight.w800, color: primaryInk),
                ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ] else if (onTap != null) ...[
                const SizedBox(width: 8),
                SvgIcon('i-next', size: 16, color: muted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu jam pengingat — frame 08 time-card.
class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.icon,
    required this.tone,
    required this.time,
    required this.label,
    required this.on,
    required this.onChanged,
  });

  final String icon;
  final IcoTone tone;
  final String time;
  final String label;
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF1E1B2E))
                .withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onChanged(!on),
          child: Row(
            children: [
              IcoChip(icon: icon, tone: tone),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(time, style: AppText.display(21.6)),
                    Text(label, style: const TextStyle(fontSize: 14.08, fontWeight: FontWeight.w800)),
                    Text(tr(context, 'Notifikasi lokal tiap hari'), style: AppText.body(12, color: muted)),
                  ],
                ),
              ),
              Switch(value: on, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmen bahasa ID/EN — frame 08 lang-seg, ganti bahasa app langsung.
class _LangSeg extends ConsumerWidget {
  const _LangSeg();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = ref.watch(langProvider);

    Widget btn(String label, {required bool on}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: on
                ? (isDark ? AppColors.primaryInkDark : AppColors.primaryInkLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.52,
              fontWeight: FontWeight.w800,
              color: on ? Colors.white : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => ref.read(prefsProvider.notifier).setLang('id'),
              child: btn('ID', on: lang == 'id'),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => ref.read(prefsProvider.notifier).setLang('en'),
              child: btn('EN', on: lang == 'en'),
            ),
          ),
        ],
      ),
    );
  }
}
