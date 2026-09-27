import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'svg_icon.dart';

/// Chip ikon 34×34 dengan l warna lembut (violet/amber/hijau/merah/biru).
enum IcoTone { violet, amber, green, red, blue }

class IcoChip extends StatelessWidget {
  const IcoChip({
    super.key,
    required this.icon,
    required this.tone,
    this.emoji,
    this.size = 34,
  });

  final String icon;
  final IcoTone tone;

  /// Jika diisi, tampilkan emoji ini alih-alih SVG [icon].
  final String? emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (bg, fg) = switch (tone) {
      IcoTone.violet => (
          isDark
              ? AppColors.primarySoftDark
              : AppColors.primarySoftLight,
          theme.colorScheme.primary,
        ),
      IcoTone.amber => (
          isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight,
          isDark ? AppColors.accent : AppColors.amberTextLight,
        ),
      IcoTone.green => (
          isDark
              ? AppColors.successSoftDark
              : AppColors.successSoftLight,
          isDark ? AppColors.successDark : AppColors.successLight,
        ),
      IcoTone.red => (
          isDark ? AppColors.dangerSoftDark : AppColors.dangerSoftLight,
          isDark ? AppColors.dangerDark : AppColors.dangerLight,
        ),
      IcoTone.blue => (
          isDark ? AppColors.infoSoftDark : AppColors.infoSoftLight,
          AppColors.info,
        ),
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: emoji != null && emoji!.isNotEmpty
          ? Text(emoji!, style: TextStyle(fontSize: size * 0.47))
          : SvgIcon(icon, size: size * 0.53, color: fg),
    );
  }
}
