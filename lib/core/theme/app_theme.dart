import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppText {
  static TextStyle display(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w600,
    double height = 1.05,
  }) {
    return TextStyle(
      fontFamily: 'Fredoka',
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }

  static TextStyle body(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w500,
    double height = 1.5,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final surface3 = isDark ? AppColors.darkSurface3 : AppColors.lightSurface3;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final primaryInk =
        isDark ? AppColors.primaryInkDark : AppColors.primaryInkLight;
    final primarySoft =
        isDark ? AppColors.primarySoftDark : AppColors.primarySoftLight;
    final success = isDark ? AppColors.successDark : AppColors.successLight;
    final danger = isDark ? AppColors.dangerDark : AppColors.dangerLight;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      // Dark: #9D86FF (terang) supaya teks violet kontras di atas surface gelap.
      primary: isDark ? AppColors.primary : AppColors.primaryInkLight,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: const Color(0xFF1E1B2E),
      surface: surface,
      onSurface: text,
      onSurfaceVariant: muted,
      outline: line,
      outlineVariant: line,
      error: danger,
      onError: isDark ? const Color(0xFF1E1B2E) : Colors.white,
      primaryContainer: primarySoft,
      onPrimaryContainer: isDark ? AppColors.primary : AppColors.primaryInkLight,
      tertiary: success,
      scrim: Colors.black54,
    );

    final baseText = TextStyle(
      fontFamily: 'PlusJakartaSans',
      color: text,
      fontWeight: FontWeight.w500,
      height: 1.5,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'PlusJakartaSans',
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        displayLarge: AppText.display(40, color: text),
        displayMedium: AppText.display(32, color: text),
        headlineLarge: AppText.display(26, color: text),
        headlineMedium: AppText.display(22, color: text),
        headlineSmall: AppText.display(19, color: text),
        titleLarge: baseText.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
        titleMedium: baseText.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        titleSmall: baseText.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        bodyLarge: baseText.copyWith(fontSize: 15.5),
        bodyMedium: baseText.copyWith(fontSize: 14),
        bodySmall: baseText.copyWith(fontSize: 12, color: muted),
        labelLarge: baseText.copyWith(fontSize: 14.5, fontWeight: FontWeight.w800),
        labelMedium: baseText.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
        labelSmall: baseText.copyWith(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: line),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppText.display(
          21,
          color: text,
          weight: FontWeight.w600,
          height: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryInk,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: line, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        hintStyle: TextStyle(color: muted, fontWeight: FontWeight.w500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        height: 68,
        elevation: 0,
        indicatorColor: primarySoft,
        labelTextStyle: WidgetStatePropertyAll(
          baseText.copyWith(fontSize: 11, fontWeight: FontWeight.w800),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? primaryInk : muted,
            size: 24,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: text,
        contentTextStyle: baseText.copyWith(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: bg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryInk,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryInk
              : surface3,
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: primaryInk,
        labelStyle: baseText.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
