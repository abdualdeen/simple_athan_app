import 'package:flutter/material.dart';

/// The decorative scene shown in the home header.
enum AppMotif {
  /// Crescent and sparkles, used by every theme except sakura and olive.
  crescent,

  /// Blossom tree, drifting petals and a crescent moon.
  sakura,

  /// Olive branches, drifting leaves and a sun.
  olive,

  /// Night sky with a moon, twinkling stars and shooting stars.
  nightSky,
}

enum AppThemeChoice {
  emerald('Emerald'),
  dark('Dark'),
  olive('Olive'),
  sakura('Sakura'),
  sky('Night Sky');

  const AppThemeChoice(this.label);

  final String label;

  static AppThemeChoice fromName(String? name) => values.firstWhere(
    (AppThemeChoice choice) => choice.name == name,
    orElse: () => AppThemeChoice.emerald,
  );
}

/// Semantic colors used by the app's custom widgets.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    this.motif = AppMotif.crescent,
    required this.primary,
    required this.primaryDeep,
    required this.primarySoft,
    required this.accent,
    required this.accentDark,
    required this.accentSoft,
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.label,
    required this.onPrimary,
    required this.error,
  });

  final Brightness brightness;

  /// The decorative header scene that matches this theme.
  final AppMotif motif;
  final Color primary;
  final Color primaryDeep;
  final Color primarySoft;
  final Color accent;
  final Color accentDark;
  final Color accentSoft;
  final Color background;
  final Color surface;
  final Color ink;
  final Color inkMuted;

  /// Accent color for text and outlines drawn on [surface].
  final Color label;
  final Color onPrimary;
  final Color error;

  List<Color> get headerGradient => <Color>[primarySoft, primary, primaryDeep];

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      motif: t < 0.5 ? motif : other.motif,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      label: Color.lerp(label, other.label, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

abstract final class AppPalettes {
  static const AppPalette emerald = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFF0B3D2E),
    primaryDeep: Color(0xFF062A1F),
    primarySoft: Color(0xFF14563F),
    accent: Color(0xFFC9A227),
    accentDark: Color(0xFF8A6D12),
    accentSoft: Color(0xFFE7CE8A),
    background: Color(0xFFF7F4EC),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF13241D),
    inkMuted: Color(0xFF5F6F67),
    label: Color(0xFF1F5C45),
    onPrimary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF2E7D5B),
    primaryDeep: Color(0xFF07130F),
    primarySoft: Color(0xFF1B4A38),
    accent: Color(0xFFE0C15C),
    accentDark: Color(0xFFC9A227),
    accentSoft: Color(0xFFF0DCA0),
    background: Color(0xFF0C1512),
    surface: Color(0xFF14201B),
    ink: Color(0xFFEAF2EE),
    inkMuted: Color(0xFF9AA8A2),
    label: Color(0xFF7FC9A4),
    onPrimary: Color(0xFFFFFFFF),
    error: Color(0xFFFFB4AB),
  );

  static const AppPalette olive = AppPalette(
    brightness: Brightness.light,
    motif: AppMotif.olive,
    primary: Color(0xFF5B6B3A),
    primaryDeep: Color(0xFF3A4524),
    primarySoft: Color(0xFF6F7F4A),
    accent: Color(0xFFC9A227),
    accentDark: Color(0xFF8A6D12),
    accentSoft: Color(0xFFE7CE8A),
    background: Color(0xFFF5F2E6),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF23281A),
    inkMuted: Color(0xFF6B705C),
    label: Color(0xFF5B6B3A),
    onPrimary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
  );

  static const AppPalette sakura = AppPalette(
    brightness: Brightness.light,
    motif: AppMotif.sakura,
    primary: Color(0xFFA84463),
    primaryDeep: Color(0xFF6E2A44),
    primarySoft: Color(0xFFC05A78),
    accent: Color(0xFFC9A227),
    accentDark: Color(0xFF8A6D12),
    accentSoft: Color(0xFFE7CE8A),
    background: Color(0xFFFDF3F5),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF3A1F2A),
    inkMuted: Color(0xFF8A6B75),
    label: Color(0xFFB03A5B),
    onPrimary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
  );

  static const AppPalette sky = AppPalette(
    brightness: Brightness.dark,
    motif: AppMotif.nightSky,
    primary: Color(0xFF2E4A6B),
    primaryDeep: Color(0xFF0A1120),
    primarySoft: Color(0xFF1B2C45),
    accent: Color(0xFFE3C568),
    accentDark: Color(0xFFC0A44E),
    accentSoft: Color(0xFFF4E7C3),
    background: Color(0xFF0B1322),
    surface: Color(0xFF131E30),
    ink: Color(0xFFE6EDF8),
    inkMuted: Color(0xFF93A5BC),
    label: Color(0xFF8FB8E8),
    onPrimary: Color(0xFFFFFFFF),
    error: Color(0xFFFFB4AB),
  );

  static AppPalette forChoice(AppThemeChoice choice) => switch (choice) {
    AppThemeChoice.emerald => emerald,
    AppThemeChoice.dark => dark,
    AppThemeChoice.olive => olive,
    AppThemeChoice.sakura => sakura,
    AppThemeChoice.sky => sky,
  };
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalettes.emerald;
}

abstract final class AppTheme {
  static ThemeData get light => forChoice(AppThemeChoice.emerald);

  static ThemeData forChoice(AppThemeChoice choice) {
    final AppPalette palette = AppPalettes.forChoice(choice);
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: palette.brightness,
        ).copyWith(
          primary: palette.primary,
          onPrimary: palette.onPrimary,
          secondary: palette.accent,
          surface: palette.surface,
          onSurface: palette.ink,
          error: palette.error,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      textTheme: _textTheme(palette),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: palette.inkMuted.withValues(alpha: 0.2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.primaryDeep,
        contentTextStyle: TextStyle(color: palette.onPrimary, fontSize: 13.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      extensions: <ThemeExtension<dynamic>>[palette],
    );
  }

  static TextTheme _textTheme(AppPalette palette) {
    final TextTheme base = palette.brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: palette.ink,
        height: 1.2,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: palette.ink,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: palette.ink,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        color: palette.inkMuted,
        height: 1.45,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: palette.inkMuted,
      ),
    );
  }
}
