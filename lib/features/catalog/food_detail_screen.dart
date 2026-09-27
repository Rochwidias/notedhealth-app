import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/ico_chip.dart';
import '../../widgets/svg_icon.dart';
import 'food_data.dart';

/// Detail menu — frame 11. Foto full-bleed + info + tombol "saya makan ini".
class FoodDetailScreen extends StatelessWidget {
  const FoodDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final item = findFood(id);
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Menu tidak ditemukan.')),
      );
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Foto full-bleed 240px
          SizedBox(
            height: 240,
            width: double.infinity,
            child: Image.asset(
              item.asset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: surface2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppText.display(24),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              _DetailChip(
                                label: '${item.kcal} kkal',
                                bg: isDark
                                    ? AppColors.dangerSoftDark
                                    : AppColors.dangerSoftLight,
                                fg: isDark
                                    ? AppColors.dangerDark
                                    : AppColors.dangerLight,
                              ),
                              if (item.badge != null)
                                _DetailChip(
                                  label: item.badge!,
                                  bg: isDark
                                      ? AppColors.successSoftDark
                                      : AppColors.successSoftLight,
                                  fg: isDark
                                      ? AppColors.successDark
                                      : AppColors.successLight,
                                ),
                              _DetailChip(
                                label: item.portion,
                                bg: surface2,
                                fg: muted,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: line),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const SvgIcon('i-back'),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  item.desc,
                  style: AppText.body(14.4, color: muted),
                ),
                const SizedBox(height: 6),
                _Sec('Bahan utama'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  child: Column(
                    children: [
                      for (var i = 0; i < item.ingredients.length; i++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Row(
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.successDark
                                      : AppColors.successLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.ingredients[i],
                                  style: AppText.body(14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < item.ingredients.length - 1)
                          Divider(height: 1, thickness: 1, color: line),
                      ],
                    ],
                  ),
                ),
                _Sec('Tips sehat'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.accentSoftDark
                        : AppColors.accentSoftLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IcoChip(icon: 'i-sparkle', tone: IcoTone.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.tip,
                          style: AppText.body(13.6, weight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dicatat! Pelacakan kalori penuh menyusul.'),
                    ),
                  ),
                  child: const Text('Tandai: saya makan ini'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Catatan ringan untuk riwayat hari ini (opsional)',
                  textAlign: TextAlign.center,
                  style: AppText.body(12, color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12.48, fontWeight: FontWeight.w800, color: fg),
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
