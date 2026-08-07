import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color/type/shape tokens from the "Organic" design handoff
/// (design/Prayer times app design.zip) — warm cream/terracotta/sage
/// palette, Caprasimo headings + Figtree body, pill radii.
class AppTheme {
  AppTheme._();

  // --color-bg
  static const _bgLight = Color(0xFFF5EAD8);
  static const _bgDark = Color(0xFF2E2B25);
  // --color-surface
  static const _surfaceLight = Color(0xFFEBDDC5);
  static const _surfaceDark = Color(0xFF474238);
  // --color-text
  static const _textLight = Color(0xFF201E1D);
  static const _textDark = Color(0xFFF5EAD8);
  // --color-divider
  static const _dividerDark = Color(0xFF645C50);
  static const _dividerLight = Color(0xFFD8CBB0);
  // --color-accent (terracotta) ramp
  static const accent100 = Color(0xFFF3E0CF);
  static const accent300 = Color(0xFFDDA875);
  static const accent = Color(0xFFC67139);
  static const accent700 = Color(0xFFA85A2A);
  static const accent900 = Color(0xFF7A4019);
  // --color-accent-2 (sage) ramp
  static const accent2_100 = Color(0xFFE4E8DA);
  static const accent2 = Color(0xFF7A8A5E);
  static const accent2_700 = Color(0xFF5E6B47);

  static const radiusPill = 999.0;
  static const radiusLg = 24.0;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _bgLight;
    final surface = isDark ? _surfaceDark : _surfaceLight;
    final text = isDark ? _textDark : _textLight;
    final divider = isDark ? _dividerDark : _dividerLight;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent700,
      onPrimary: _bgLight,
      secondary: accent2_700,
      onSecondary: _bgLight,
      error: const Color(0xFFB3261E),
      onError: _bgLight,
      surface: surface,
      onSurface: text,
      outline: divider,
    );

    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);
    // Caprasimo/Figtree are Latin-only -- they have no Arabic glyphs, so
    // Arabic text silently falls back to the platform default font (losing
    // the design's bold-serif/clean-sans look entirely) unless an
    // Arabic-capable fallback is registered. Rakkas (display) and Noto Sans
    // Arabic (body) are the closest-feeling Arabic pairings to each.
    final arabicHeadingFamily = GoogleFonts.rakkas().fontFamily!;
    final arabicBodyFamily = GoogleFonts.notoSansArabic().fontFamily!;
    final headingFont = GoogleFonts.caprasimoTextTheme(base.textTheme)
        .apply(fontFamilyFallback: [arabicHeadingFamily]);
    final bodyFont = GoogleFonts.figtreeTextTheme(base.textTheme)
        .apply(fontFamilyFallback: [arabicBodyFamily]);

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      dividerColor: divider,
      textTheme: bodyFont.copyWith(
        titleLarge: headingFont.titleLarge?.copyWith(color: text),
        titleMedium: headingFont.titleMedium?.copyWith(color: text),
        headlineSmall: headingFont.headlineSmall?.copyWith(color: text),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        titleTextStyle: headingFont.titleLarge?.copyWith(color: text),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: divider),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent700,
          foregroundColor: _bgLight,
          shape: const StadiumBorder(),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: const StadiumBorder(),
          selectedBackgroundColor: accent100,
          selectedForegroundColor: accent700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent100,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => bodyFont.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected) ? accent700 : text.withValues(alpha: 0.55),
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? accent700 : text.withValues(alpha: 0.55),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          borderSide: BorderSide(color: divider),
        ),
      ),
    );
  }
}
