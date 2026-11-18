import 'package:material_ui/material_ui.dart';

/// Design tokens. Feature code reads colours, radii and motion only from here (rule: theme tokens only).
///
/// Visual language: soft mint glass. Translucent cards over a green gradient, near-black ink,
/// a dark contrast panel for live work, large display numerals, pill-shaped controls.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.bgTop,
    required this.bgBottom,
    required this.card,
    required this.cardStrong,
    required this.solid,
    required this.well,
    required this.hair,
    required this.line,
    required this.line2,
    required this.ink,
    required this.dim,
    required this.faint,
    required this.accent,
    required this.accentSoft,
    required this.accentDeep,
    required this.onAccent,
    required this.night,
    required this.night2,
    required this.onNight,
    required this.nightDim,
    required this.ok,
    required this.warn,
    required this.danger,
    required this.info,
    required this.shadow,
    this.paper = const Color(0xFFFFFFFF),
    this.paperInk = const Color(0xFF111111),
  });

  final Color bgTop, bgBottom;
  final Color card, cardStrong, solid, well, hair, line, line2;
  final Color ink, dim, faint;
  final Color accent, accentSoft, accentDeep, onAccent;
  final Color night, night2, onNight, nightDim;
  final Color ok, warn, danger, info;
  final List<BoxShadow> shadow;

  /// Print surface for QR codes: always white with near-black ink so codes scan in any theme.
  final Color paper, paperInk;

  static const light = AppTokens(
    bgTop: Color(0xFFE9F2E5),
    bgBottom: Color(0xFFB9DFAE),
    card: Color(0x9EFAFFF7),
    cardStrong: Color(0xDBFAFFF7),
    solid: Color(0xFFF6FBF3),
    well: Color(0xFFE4EFDF),
    hair: Color(0xE6FFFFFF),
    line: Color(0x171D1D1B),
    line2: Color(0x291D1D1B),
    ink: Color(0xFF1D1D1B),
    dim: Color(0xFF5C5A54),
    faint: Color(0xFF75726A),
    accent: Color(0xFF66A05F),
    accentSoft: Color(0xFFCFE7C7),
    accentDeep: Color(0xFF2F5A29),
    onAccent: Color(0xFFFFFFFF),
    night: Color(0xFF333333),
    night2: Color(0xFF424242),
    onNight: Color(0xFFF4F2EC),
    nightDim: Color(0xFFA9A69C),
    ok: Color(0xFF3F8F5A),
    warn: Color(0xFFB86B12),
    danger: Color(0xFFB3412E),
    info: Color(0xFF3B6E8F),
    shadow: [
      BoxShadow(color: Color(0x591E4619), blurRadius: 40, offset: Offset(0, 18), spreadRadius: -26),
    ],
  );

  static const dark = AppTokens(
    bgTop: Color(0xFF16201A),
    bgBottom: Color(0xFF223A24),
    card: Color(0x8C26332A),
    cardStrong: Color(0xD926332A),
    solid: Color(0xFF1F2A22),
    well: Color(0xFF2A372D),
    hair: Color(0x1FFFFFFF),
    line: Color(0x1FF4F2EC),
    line2: Color(0x33F4F2EC),
    ink: Color(0xFFF1F4EE),
    dim: Color(0xFFB9BDB2),
    faint: Color(0xFF959A8E),
    accent: Color(0xFF7DBA74),
    accentSoft: Color(0xFF34503A),
    accentDeep: Color(0xFFCFE7C7),
    onAccent: Color(0xFF10170F),
    night: Color(0xFF0E1410),
    night2: Color(0xFF1A221C),
    onNight: Color(0xFFF4F2EC),
    nightDim: Color(0xFFA9A69C),
    ok: Color(0xFF79C08C),
    warn: Color(0xFFE0A050),
    danger: Color(0xFFE57A66),
    info: Color(0xFF86B6D6),
    shadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 18), spreadRadius: -26),
    ],
  );

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) => t < 0.5 ? this : (other as AppTokens? ?? this);
}

/// Radii, spacing and motion. Shared by every screen.
abstract final class Rad {
  static const app = 38.0;
  static const card = 28.0;
  static const tile = 18.0;
  static const pill = 999.0;
}

abstract final class Gap {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 14.0;
  static const l = 20.0;
  static const xl = 28.0;
}

abstract final class Motion {
  /// cubic-bezier(.22, 1, .36, 1): fast start, long soft settle.
  static const ease = Cubic(.22, 1, .36, 1);
  static const fast = Duration(milliseconds: 220);
  static const medium = Duration(milliseconds: 420);
  static const slow = Duration(milliseconds: 650);
  static const stagger = Duration(milliseconds: 45);
}

abstract final class Breakpoints {
  static const tablet = 700.0;
  static const desktop = 1100.0;
  static const wall = 1600.0; // kitchen TV / large monitor
}

extension TokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  double get width => MediaQuery.sizeOf(this).width;
  bool get isPhone => width < Breakpoints.tablet;
  bool get isDesktop => width >= Breakpoints.desktop;
  bool get isWall => width >= Breakpoints.wall;
  double get gutter => isPhone ? 16 : 28;
}
