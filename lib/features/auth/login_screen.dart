import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/svg_icon.dart';
import 'auth_repository.dart';
import 'session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _busy = false;

  Future<void> _login(Future<void> Function(AuthRepository repo) action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action(ref.read(authRepositoryProvider));
      ref.read(sessionProvider.notifier).refresh();
      if (mounted) context.go('/home');
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Login Google aktif lagi setelah Firebase project siap.
  /// Sementara: snackbar ramah, arahkan ke Tamu.
  void _googleSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            tr(context, 'Login Google segera hadir — masuk sebagai Tamu dulu ya.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final line = theme.colorScheme.outline;

    final isDark = theme.brightness == Brightness.dark;
    // Chip ikon 3 warna sesuai mockup: violet / amber / hijau.
    final chipVioletBg =
        isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final chipAmberBg =
        isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final chipAmberFg = isDark ? AppColors.accent : AppColors.amberTextLight;
    final chipGreenBg =
        isDark ? AppColors.successSoftDark : AppColors.successSoftLight;
    final chipGreenFg = isDark ? AppColors.successDark : AppColors.successLight;

    final previewItems = [
      ('i-target', 'Skor harian', '0–100 dari habit', chipVioletBg,
          theme.colorScheme.primary),
      ('i-scale', 'Timbang berat', 'grafik 7 & 30 hari', chipAmberBg,
          chipAmberFg),
      ('i-leaf', 'Katalog sehat', 'menu makan & minum', chipGreenBg,
          chipGreenFg),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primaryInkLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryInkLight
                                .withValues(alpha: 0.4),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: SvgIcon(
                          'i-logo',
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    tr(context, 'Halo lagi!'),
                    textAlign: TextAlign.center,
                    style: AppText.display(30, color: text),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(context, 'Masuk dengan Google, atau coba sebagai Tamu dulu.'),
                    textAlign: TextAlign.center,
                    style: AppText.body(14.5, color: muted),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: line),
                      boxShadow: [
                        BoxShadow(
                          color: text.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (final item in previewItems)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: item.$4,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SvgIcon(
                                    item.$1,
                                    size: 18,
                                    color: item.$5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tr(context, item.$2),
                                        style: AppText.body(14,
                                            color: text,
                                            weight: FontWeight.w800,
                                            height: 1.25),
                                      ),
                                      Text(
                                        tr(context, item.$3),
                                        style: AppText.body(11.5,
                                            color: muted, height: 1.3),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _busy ? null : _googleSoon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: text,
                      side: BorderSide(color: line, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 17),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgIconGoogle(size: 20),
                        const SizedBox(width: 10),
                        Text(
                          _busy
                              ? tr(context, 'Memproses…')
                              : tr(context, 'Masuk dengan Google'),
                          style: AppText.body(16,
                              color: text, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: Divider(color: line)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(tr(context, 'atau'),
                            style: AppText.body(12.5, color: muted)),
                      ),
                      Expanded(child: Divider(color: line)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _login((r) => r.continueAsGuest()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgIcon('i-user', size: 20, color: text),
                        const SizedBox(width: 10),
                        Text(_busy
                            ? tr(context, 'Memproses…')
                            : tr(context, 'Masuk sebagai Tamu')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    tr(context,
                        'Google: tersimpan aman di akunmu · Tamu: lokal di perangkat ini.'),
                    textAlign: TextAlign.center,
                    style: AppText.body(11.5, color: muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SvgIconGoogle extends StatelessWidget {
  const SvgIconGoogle({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/i-google.svg',
      width: size,
      height: size,
    );
  }
}
