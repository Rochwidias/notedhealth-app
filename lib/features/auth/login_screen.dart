import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

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
      const SnackBar(
        content:
            Text('Login Google segera hadir — masuk sebagai Tamu dulu ya.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final line = theme.colorScheme.outline;

    final previewItems = [
      ('i-list', 'Skor harian 0–100 dari habit'),
      ('i-scale', 'Timbang berat — grafik 7 & 30 hari'),
      ('i-leaf', 'Katalog sehat — menu makan & minum'),
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
                    child: SvgIcon(
                      'i-logo',
                      size: 76,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'NotedHealth',
                    textAlign: TextAlign.center,
                    style: AppText.display(30, color: text),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk dengan Google, atau coba sebagai Tamu dulu.',
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
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SvgIcon(
                                    item.$1,
                                    size: 19,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.$2,
                                    style: AppText.body(13.5,
                                        color: text, weight: FontWeight.w600),
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
                          _busy ? 'Memproses…' : 'Masuk dengan Google',
                          style: AppText.body(15,
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
                        child: Text('atau',
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
                        Text(_busy ? 'Memproses…' : 'Masuk sebagai Tamu'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Google: tersimpan aman di akunmu · Tamu: lokal di perangkat ini.',
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
