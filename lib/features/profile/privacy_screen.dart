import 'package:flutter/material.dart';
import 'package:notedhealth/core/i18n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/ico_chip.dart';
import '../../widgets/svg_icon.dart';

/// Privasi & Legal — frame 14: intro, kebijakan, syarat layanan, kredit.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final primaryInk = isDark ? AppColors.primary : AppColors.primaryInkLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Privasi & Legal')),
        leading: IconButton(
          icon: const SvgIcon('i-back'),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Intro kartu primary-soft
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IcoChip(icon: 'i-shield', tone: IcoTone.violet),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tr(
                      context,
                      'Datamu milikmu. Ringkasan singkat cara NotedHealth menangani data:',
                    ),
                    style: AppText.body(13.76, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          _Sec(tr(context, 'Kebijakan privasi')),
          _Card(
            children: [
              tr(
                context,
                'Email & nama hanya diambil dari Google Sign-In — untuk login, bukan untuk iklan',
              ),
              tr(
                context,
                'Berat badan, habit, & skor harian tersimpan di Cloud Firestore atas nama akunmu',
              ),
              tr(
                context,
                'Hanya kamu yang bisa membaca datanya — aturan keamanan Firestore menolak akses siapa pun selain pemilik akun',
              ),
              tr(
                context,
                'Tidak dibagikan ke pihak ketiga, tidak ada tracking atau analytics iklan',
              ),
              tr(context, 'Hapus akun di Profil = seluruh data ikut terhapus permanen'),
              tr(context, 'Pengingat 07.00 & 21.00 adalah notifikasi lokal di perangkat, tanpa server'),
            ],
            line: line,
            muted: muted,
          ),
          const SizedBox(height: 9),
          Text(
            tr(
              context,
              'Versi lengkap kebijakan privasi akan tersedia di URL publik saat rilis (wajib untuk Google Play).',
            ),
            style: AppText.body(12, color: muted),
          ),
          _Sec(tr(context, 'Syarat layanan')),
          _RowBtn(
            icon: 'i-book',
            tone: IcoTone.violet,
            label: tr(context, 'Ketentuan penggunaan'),
            desc: tr(context, 'Tanggung jawab pengguna & batasan aplikasi'),
            muted: muted,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr(context, 'Halaman ketentuan menyusul.'))),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tr(
              context,
              'NotedHealth adalah pencatat kebiasaan, bukan alat medis — tidak memberi diagnosis atau saran medis.',
            ),
            style: AppText.body(12, color: muted),
          ),
          _Sec(tr(context, 'Kredit')),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
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
            child: Column(
              children: [
                const IcoChip(icon: 'i-sparkle', tone: IcoTone.violet),
                const SizedBox(height: 10),
                Text(tr(context, 'Desain & pengembangan oleh'), style: AppText.body(12, color: muted)),
                const SizedBox(height: 2),
                Text(
                  '@rochwidias',
                  style: AppText.display(22.4, color: primaryInk),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            tr(
              context,
              'Foto: Pexels (Pexels License) · Font: Plus Jakarta Sans & Fredoka (SIL OFL 1.1) · Ikon SVG buatan sendiri',
            ),
            textAlign: TextAlign.center,
            style: AppText.body(12, color: muted),
          ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.32)),
    );
  }
}

/// Kartu tight berisi daftar poin (ingr) + pemisah antar baris.
class _Card extends StatelessWidget {
  const _Card({required this.children, required this.line, required this.muted});

  final List<String> children;
  final Color line;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final success = isDark ? AppColors.successDark : AppColors.successLight;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(color: success, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(children[i], style: AppText.body(13.5))),
                ],
              ),
            ),
            if (i < children.length - 1) Divider(height: 1, thickness: 1, color: line),
          ],
        ],
      ),
    );
  }
}

/// Row-btn gaya mockup (dipakai baris "Ketentuan penggunaan").
class _RowBtn extends StatelessWidget {
  const _RowBtn({
    required this.icon,
    required this.tone,
    required this.label,
    required this.desc,
    required this.muted,
    this.onTap,
  });

  final String icon;
  final IcoTone tone;
  final String label;
  final String desc;
  final Color muted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;

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
            SvgIcon('i-next', size: 16, color: muted),
          ],
        ),
      ),
    ),
    );
  }
}
