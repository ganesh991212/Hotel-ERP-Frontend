import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

const displayFont = 'Outfit';
const bodyFont = 'Inter';

ThemeData buildTheme(Brightness brightness) {
  final t = brightness == Brightness.light ? AppTokens.light : AppTokens.dark;
  final scheme = ColorScheme.fromSeed(seedColor: t.accent, brightness: brightness).copyWith(
    primary: t.night,
    onPrimary: t.onNight,
    secondary: t.accent,
    onSecondary: t.onAccent,
    surface: t.solid,
    onSurface: t.ink,
    error: t.danger,
    outline: t.line2,
  );
  final text = TextTheme(
    displayLarge: TextStyle(fontFamily: displayFont, fontSize: 56, height: 1.0, letterSpacing: -1.2, color: t.ink),
    displayMedium: TextStyle(fontFamily: displayFont, fontSize: 44, height: 1.05, letterSpacing: -1, color: t.ink),
    displaySmall: TextStyle(fontFamily: displayFont, fontSize: 34, height: 1.1, letterSpacing: -.6, color: t.ink),
    headlineSmall: TextStyle(fontFamily: displayFont, fontSize: 24, height: 1.2, color: t.ink),
    titleLarge: TextStyle(fontFamily: displayFont, fontSize: 21, height: 1.25, color: t.ink),
    titleMedium: TextStyle(fontFamily: bodyFont, fontSize: 15, fontWeight: FontWeight.w500, color: t.ink),
    titleSmall: TextStyle(fontFamily: bodyFont, fontSize: 13.5, fontWeight: FontWeight.w500, color: t.ink),
    bodyLarge: TextStyle(fontFamily: bodyFont, fontSize: 15, color: t.ink),
    bodyMedium: TextStyle(fontFamily: bodyFont, fontSize: 13.5, color: t.ink),
    bodySmall: TextStyle(fontFamily: bodyFont, fontSize: 12, color: t.dim),
    labelLarge: TextStyle(fontFamily: bodyFont, fontSize: 13.5, fontWeight: FontWeight.w500, color: t.ink),
    labelMedium: TextStyle(fontFamily: bodyFont, fontSize: 12, fontWeight: FontWeight.w500, color: t.dim),
    labelSmall: TextStyle(fontFamily: bodyFont, fontSize: 11, fontWeight: FontWeight.w500, color: t.faint),
  );
  // Telugu/Devanagari glyphs come from on-demand fonts (core/l10n/locale.dart); Latin stays Outfit/Inter.
  final textWithScripts = text.apply(fontFamilyFallback: const ['NotoSansTelugu', 'NotoSansDevanagari']);
  final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.pill));
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: bodyFont,
    fontFamilyFallback: const ['NotoSansTelugu', 'NotoSansDevanagari'],
    textTheme: textWithScripts,
    scaffoldBackgroundColor: t.bgTop,
    extensions: [t],
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: DividerThemeData(color: t.line, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.night,
        foregroundColor: t.onNight,
        shape: pill,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.ink,
        backgroundColor: t.cardStrong,
        side: BorderSide(color: t.hair),
        shape: pill,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: t.ink, shape: pill, textStyle: text.labelLarge),
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: t.ink)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.well,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: t.line)),
      enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: t.line)),
      focusedBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: t.accent, width: 1.4)),
      labelStyle: text.bodyMedium?.copyWith(color: t.dim),
      hintStyle: text.bodyMedium?.copyWith(color: t.faint),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? t.onAccent : t.solid),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? t.accent : t.line2),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? t.night : t.solid),
      checkColor: WidgetStatePropertyAll(t.onNight),
      side: BorderSide(color: t.line2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: t.night,
      contentTextStyle: text.bodyMedium?.copyWith(color: t.onNight),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: t.night, borderRadius: BorderRadius.circular(10)),
      textStyle: text.bodySmall?.copyWith(color: t.onNight),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
    }),
  );
}
