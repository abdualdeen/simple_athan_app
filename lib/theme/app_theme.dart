import 'package:flutter/material.dart';

/// Palette used across the app.
abstract final class AppColors {
  static const Color emerald = Color(0xFF0B3D2E);
  static const Color emeraldDeep = Color(0xFF062A1F);
  static const Color emeraldSoft = Color(0xFF14563F);
  static const Color gold = Color(0xFFC9A227);
  static const Color goldDark = Color(0xFF8A6D12);
  static const Color goldSoft = Color(0xFFE7CE8A);
  static const Color cream = Color(0xFFF7F4EC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF13241D);
  static const Color inkMuted = Color(0xFF5F6F67);
}

abstract final class AppTheme {
  static ThemeData get light {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.emerald,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.emerald,
          secondary: AppColors.gold,
          surface: AppColors.surface,
          onSurface: AppColors.ink,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: _textTheme,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.emeraldDeep,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static TextTheme get _textTheme {
    final TextTheme base = Typography.material2021().black;
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.2,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        color: AppColors.inkMuted,
        height: 1.45,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: AppColors.inkMuted,
      ),
    );
  }
}
