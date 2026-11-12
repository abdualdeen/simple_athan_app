// Simply Athan - prayer times and Qibla app.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
  emeraldDark('Emerald Dark'),
  olive('Olive'),
  oliveDark('Olive Dark'),
  sakura('Sakura'),
  sakuraDark('Sakura Dark'),
  sky('Night Sky'),
  skyLight('Night Sky Light');

  const AppThemeChoice(this.label);

  final String label;

  static AppThemeChoice fromName(String? name) => values.firstWhere(
    (AppThemeChoice choice) => choice.name == name,
    orElse: () => AppThemeChoice.emerald,
  );

  /// The light or dark counterpart of this theme, used when the auto night
  /// theme switches at sunset and sunrise.
  AppThemeChoice get counterpart => switch (this) {
    AppThemeChoice.emerald => AppThemeChoice.emeraldDark,
    AppThemeChoice.emeraldDark => AppThemeChoice.emerald,
    AppThemeChoice.olive => AppThemeChoice.oliveDark,
    AppThemeChoice.oliveDark => AppThemeChoice.olive,
    AppThemeChoice.sakura => AppThemeChoice.sakuraDark,
    AppThemeChoice.sakuraDark => AppThemeChoice.sakura,
    AppThemeChoice.sky => AppThemeChoice.skyLight,
    AppThemeChoice.skyLight => AppThemeChoice.sky,
  };
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

  static const AppPalette emeraldDark = AppPalette(
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

  static const AppPalette oliveDark = AppPalette(
    brightness: Brightness.dark,
    motif: AppMotif.olive,
    primary: Color(0xFF71874A),
    primaryDeep: Color(0xFF12150B),
    primarySoft: Color(0xFF44502A),
    accent: Color(0xFFE0C15C),
    accentDark: Color(0xFFC9A227),
    accentSoft: Color(0xFFF0DCA0),
    background: Color(0xFF141609),
    surface: Color(0xFF1E2114),
    ink: Color(0xFFF2F4E8),
    inkMuted: Color(0xFFA8AD98),
    label: Color(0xFFC2D188),
    onPrimary: Color(0xFFFFFFFF),
    error: Color(0xFFFFB4AB),
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

  static const AppPalette sakuraDark = AppPalette(
    brightness: Brightness.dark,
    motif: AppMotif.sakura,
    primary: Color(0xFFA84E6E),
    primaryDeep: Color(0xFF1C0F16),
    primarySoft: Color(0xFF6E3248),
    accent: Color(0xFFE0C15C),
    accentDark: Color(0xFFC9A227),
    accentSoft: Color(0xFFF0DCA0),
    background: Color(0xFF170E12),
    surface: Color(0xFF22161B),
    ink: Color(0xFFF7E9EE),
    inkMuted: Color(0xFFB39AA5),
    label: Color(0xFFE39CB4),
    onPrimary: Color(0xFFFFFFFF),
    error: Color(0xFFFFB4AB),
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

  static const AppPalette skyLight = AppPalette(
    brightness: Brightness.light,
    motif: AppMotif.nightSky,
    primary: Color(0xFF2E4A6B),
    primaryDeep: Color(0xFF16273F),
    primarySoft: Color(0xFF3D5A80),
    accent: Color(0xFFC9A227),
    accentDark: Color(0xFF8A6D12),
    accentSoft: Color(0xFFE7CE8A),
    background: Color(0xFFF2F5FA),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF18273B),
    inkMuted: Color(0xFF61718A),
    label: Color(0xFF3A6B9E),
    onPrimary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
  );

  static AppPalette forChoice(AppThemeChoice choice) => switch (choice) {
    AppThemeChoice.emerald => emerald,
    AppThemeChoice.emeraldDark => emeraldDark,
    AppThemeChoice.olive => olive,
    AppThemeChoice.oliveDark => oliveDark,
    AppThemeChoice.sakura => sakura,
    AppThemeChoice.sakuraDark => sakuraDark,
    AppThemeChoice.sky => sky,
    AppThemeChoice.skyLight => skyLight,
  };
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalettes.emerald;
}

abstract final class AppTheme {
  static ThemeData get light => forChoice(AppThemeChoice.emerald);

  // The theme is resolved on every controller tick (once a second), so the
  // built ThemeData is cached per choice; a new instance each time would make
  // every inherited-theme dependent rebuild on every tick.
  static final Map<AppThemeChoice, ThemeData> _cache =
      <AppThemeChoice, ThemeData>{};

  static ThemeData forChoice(AppThemeChoice choice) =>
      _cache.putIfAbsent(choice, () => _build(choice));

  static ThemeData _build(AppThemeChoice choice) {
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
