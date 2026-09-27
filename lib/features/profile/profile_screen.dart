import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive_ce.dart';

import '../auth/session_provider.dart';
import '../auth/session_store.dart';
import '../../core/format.dart';
import '../auth/auth_repository.dart';
import 'prefs_store.dart';
import '../weight/weight_repository.dart';
import '../../widgets/svg_icon.dart';

/// Layar Profil — frame 08 (+ sheet tinggi).
/// Data diri, pengingat, aplikasi, keluar / hapus data.
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
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

  Future<void> _signOut() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Kamu bisa masuk lagi kapan saja. Data di perangkat ini tetap tersimpan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
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
        title: Text(isGoogle ? 'Hapus akun & data?' : 'Hapus semua data?'),
        content: Text(
          isGoogle
              ? 'Akun Google dan seluruh data cloud ikut terhapus permanen. Lanjutkan?'
              : 'Seluruh habit, berat, dan skor di perangkat ini terhapus permanen. Lanjutkan?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
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
    final cs = Theme.of(context).colorScheme;
    final session = ref.watch(sessionProvider);
    final prefs = ref.watch(prefsProvider);
    final isGoogle = session.mode == AuthMode.google;
    final latest = ref.watch(latestWeightProvider);
    final bmi = latest == null ? null : prefs.bmi(latest.valueKg);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), centerTitle: false),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _Hero(
                  name: prefs.name,
                  subtitle: isGoogle
                      ? (session.email ?? 'Akun Google')
                      : 'Mode tamu · data di perangkat ini',
                  avatar: prefs.name.isEmpty ? '?' : prefs.name.characters.first.toUpperCase(),
                ),
                const _Sec('Data diri'),
                _Row(
                  icon: 'i-pencil', tint: cs.primary,
                  label: 'Nama', desc: 'Tampil di dashboard', value: prefs.name,
                  onTap: () => _editText(
                    title: 'Nama', initial: prefs.name, hint: 'Nama panggilan',
                    onSave: (v) {
                      if (v.length < 2) return 'Nama minimal 2 huruf.';
                      ref.read(prefsProvider.notifier).setName(v);
                      return null;
                    },
                  ),
                ),
                _Row(
                  icon: 'i-target', tint: const Color(0xFF0E9BD8),
                  label: 'Target berat', desc: 'Dipakai hitung selisih',
                  value: prefs.targetKg == null ? 'Belum diisi' : '${fmtKg(prefs.targetKg!)} kg',
                  onTap: () => _editText(
                    title: 'Target berat',
                    initial: prefs.targetKg == null ? '' : fmtKg(prefs.targetKg!),
                    hint: 'contoh 68',
                    onSave: (v) {
                      final kg = parseKg(v);
                      if (kg == null || kg < 20 || kg > 300) return 'Isi 20–300 kg.';
                      ref.read(prefsProvider.notifier).setTargetKg(kg);
                      return null;
                    },
                  ),
                ),
                _Row(
                  icon: 'i-height', tint: const Color(0xFF12855B),
                  label: 'Tinggi badan', desc: 'Untuk hitung BMI',
                  value: prefs.heightCm == null ? 'Belum diisi' : '${prefs.heightCm!.toStringAsFixed(0)} cm',
                  onTap: () => _editText(
                    title: 'Tinggi badan',
                    initial: prefs.heightCm?.toStringAsFixed(0) ?? '',
                    hint: 'contoh 172',
                    onSave: (v) {
                      final cm = double.tryParse(v.replaceAll(',', '.'));
                      if (cm == null || cm < 100 || cm > 250) return 'Isi 100–250 cm.';
                      ref.read(prefsProvider.notifier).setHeightCm(cm);
                      return null;
                    },
                  ),
                ),
                if (bmi != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'BMI ${fmtKg(bmi)} · ${bmiCategory(bmi)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const _Sec('Pengingat harian'),
                _TimeCard(
                  icon: 'i-clock', tint: const Color(0xFFB7791F),
                  time: '07:00', label: 'Pagi — cek checklist',
                  on: prefs.reminderMorning,
                  onChanged: (v) => ref.read(prefsProvider.notifier).setReminderMorning(v),
                ),
                _TimeCard(
                  icon: 'i-moon', tint: cs.primary,
                  time: '21:00', label: 'Malam — catat berat & skor',
                  on: prefs.reminderNight,
                  onChanged: (v) => ref.read(prefsProvider.notifier).setReminderNight(v),
                ),
                Text(
                  'Notifikasi lokal aktif penuh di tahap berikutnya.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const _Sec('Aplikasi'),
                _Row(
                  icon: 'i-moon', tint: cs.primary,
                  label: 'Mode gelap', desc: 'Terang / gelap / sistem',
                  trailing: DropdownButton<String>(
                    value: prefs.themeModeName,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('Sistem')),
                      DropdownMenuItem(value: 'light', child: Text('Terang')),
                      DropdownMenuItem(value: 'dark', child: Text('Gelap')),
                    ],
                    onChanged: (v) {
                      if (v != null) ref.read(prefsProvider.notifier).setThemeModeName(v);
                    },
                  ),
                ),
                const _Row(
                  icon: 'i-globe', tint: Color(0xFF0E9BD8),
                  label: 'Bahasa', desc: 'Indonesia', value: 'ID',
                ),
                _Row(
                  icon: 'i-leaf', tint: const Color(0xFF12855B),
                  label: 'Katalog menu sehat', desc: 'Makanan & minuman favorit',
                  onTap: () => context.push('/catalog'),
                ),
                _Row(
                  icon: 'i-shield', tint: const Color(0xFF0E9BD8),
                  label: 'Privasi & Legal', desc: 'Kebijakan, syarat & kredit',
                  onTap: () => context.push('/privacy'),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _signOut,
                  icon: const SvgIcon('i-next'),
                  label: const Text('Keluar'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: cs.error),
                  onPressed: _busy ? null : _wipeLocal,
                  icon: const SvgIcon('i-trash'),
                  label: Text(isGoogle ? 'Hapus akun & data' : 'Hapus semua data'),
                ),
                const SizedBox(height: 14),
                const Center(child: Text('NotedHealth v0.1.0 · by @rochwidias', style: TextStyle(fontSize: 12))),
              ],
            ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String name;
  final String subtitle;
  final String avatar;
  const _Hero({required this.name, required this.subtitle, required this.avatar});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30, backgroundColor: cs.primary,
            child: Text(avatar, style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sec extends StatelessWidget {
  final String title;
  const _Sec(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
    );
  }
}

class _Row extends StatelessWidget {
  final String icon;
  final Color tint;
  final String label;
  final String desc;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Row({
    required this.icon, required this.tint, required this.label, required this.desc,
    this.value, this.trailing, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: tint.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
          child: Center(child: SvgIcon(icon, size: 20, color: tint)),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(desc),
        trailing: trailing ??
            (value != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(value!, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(width: 4),
                      if (onTap != null) SvgIcon('i-next', size: 16, color: cs.onSurfaceVariant),
                    ],
                  )
                : (onTap != null ? SvgIcon('i-next', size: 16, color: cs.onSurfaceVariant) : null)),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String icon;
  final Color tint;
  final String time;
  final String label;
  final bool on;
  final ValueChanged<bool> onChanged;
  const _TimeCard({
    required this.icon, required this.tint, required this.time,
    required this.label, required this.on, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: tint.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
          child: Center(child: SvgIcon(icon, size: 20, color: tint)),
        ),
        title: Text(time, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        subtitle: Text('$label\nNotifikasi lokal tiap hari'),
        trailing: Switch(value: on, onChanged: onChanged),
      ),
    );
  }
}
