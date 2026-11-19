import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../core/theme/theme.dart';
import '../core/theme/tokens.dart';
import '../l10n/app_localizations.dart';

/// Page backdrop: soft mint gradient that the translucent cards sit on.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.bgTop, Color.lerp(t.bgTop, t.bgBottom, .45)!, t.bgBottom],
          stops: const [0, .55, 1],
        ),
      ),
      child: child,
    );
  }
}

/// Translucent card with a white hairline and soft green shadow.
class Glass extends StatelessWidget {
  const Glass({super.key, required this.child, this.padding, this.strong = false, this.onTap, this.color});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool strong;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(Rad.card);
    return Container(
      decoration: BoxDecoration(
        color: color ?? (strong ? t.cardStrong : t.card),
        borderRadius: radius,
        border: Border.all(color: t.hair),
        boxShadow: t.shadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding ?? EdgeInsets.all(context.isPhone ? 16 : 20), child: child),
        ),
      ),
    );
  }
}

/// The dark contrast panel used for live lists (kitchen queue, live orders).
class NightPanel extends StatelessWidget {
  const NightPanel({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.night,
        borderRadius: BorderRadius.circular(Rad.card - 4),
        boxShadow: t.shadow,
      ),
      padding: padding ?? const EdgeInsets.all(18),
      child: DefaultTextStyle.merge(style: TextStyle(color: t.onNight), child: child),
    );
  }
}

class CardTitle extends StatelessWidget {
  const CardTitle(this.title, {super.key, this.trailing, this.onNight = false});
  final String title;
  final Widget? trailing;
  final bool onNight;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge;
    return Row(children: [
      Expanded(
        child: Text(title,
            style: onNight ? style?.copyWith(color: context.tokens.onNight) : style, overflow: TextOverflow.ellipsis),
      ),
      ?trailing,
    ]);
  }
}

/// White round button (the ↗ / bell / avatar buttons).
class RoundButton extends StatelessWidget {
  const RoundButton({super.key, required this.icon, required this.tooltip, this.onTap, this.dark = false, this.size = 40});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool dark;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: dark ? t.night : t.cardStrong,
        shape: CircleBorder(side: BorderSide(color: dark ? t.night : t.hair)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, size: size * .45, color: dark ? t.onNight : t.ink),
          ),
        ),
      ),
    );
  }
}

/// Staggered entrance: fade + rise + slight scale, delayed by [index]. Mirrors the reference's
/// card choreography when switching tabs.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Motion.slow);
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Motion.ease);

  @override
  void initState() {
    super.initState();
    Future.delayed(Motion.stagger * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _a,
      builder: (_, child) => Opacity(
        opacity: _a.value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - _a.value)),
          child: Transform.scale(scale: .985 + .015 * _a.value, child: child),
        ),
      ),
      child: widget.child,
    );
  }
}

/// Segmented pill navigation with a sliding dark indicator. The leading edge moves first and the
/// trailing edge follows, giving the stretch-then-settle motion of the reference.
///
/// When the items are wider than the space given, the bar stays inside that space and the items scroll
/// sideways within it (the indicator scrolls with them). With a mouse, [magnify] enlarges the item under the
/// pointer and, less, its neighbours, like the macOS Dock.
class PillTabs<T> extends StatefulWidget {
  const PillTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
    this.expand = false,
    this.icons,
    this.stacked = false,
    this.elevated = false,
    this.magnify = false,
  });
  final List<(T, String)> items;
  final T selected;
  final ValueChanged<T> onSelect;
  final bool expand;

  /// Optional icon per item (bottom dock). [stacked] puts the icon above a small label (phones).
  final List<IconData>? icons;
  final bool stacked;

  /// Stronger glass + shadow when floating over content (bottom dock).
  final bool elevated;

  /// Mouse hover magnification (macOS Dock style). No effect on touch screens, which have no hover.
  final bool magnify;

  /// Largest scale of the item directly under the pointer, and how far (logical px) the effect reaches.
  static const maxScale = 1.22;
  static const reach = 110.0;

  @override
  State<PillTabs<T>> createState() => _PillTabsState<T>();
}

class _PillTabsState<T> extends State<PillTabs<T>> {
  final _keys = <GlobalKey>[];
  final _stackKey = GlobalKey();
  Rect? _rect;
  Rect? _prev;

  /// Pointer x in the item row's coordinates while a mouse hovers the bar; null otherwise.
  double? _hoverX;

  double _scaleFor(int i) {
    final x = _hoverX;
    if (x == null || i >= _keys.length) return 1;
    final box = _keys[i].currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.hasSize) return 1;
    final centre = box.localToGlobal(box.size.center(Offset.zero), ancestor: stack).dx;
    final d = (x - centre) / PillTabs.reach;
    // Gaussian falloff: full size under the pointer, neighbours partly, far items untouched.
    return 1 + (PillTabs.maxScale - 1) * math.exp(-d * d * 2.2);
  }

  @override
  void didUpdateWidget(covariant PillTabs<T> old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final i = widget.items.indexWhere((e) => e.$1 == widget.selected);
    if (i < 0 || i >= _keys.length || !mounted) return;
    final box = _keys[i].currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.hasSize) return;
    final off = box.localToGlobal(Offset.zero, ancestor: stack);
    final r = off & box.size;
    if (r != _rect) {
      // Dock only: keep the newly selected tab in view when the bar scrolls (phones with many tabs).
      if (widget.elevated) {
        Scrollable.ensureVisible(_keys[i].currentContext!, duration: Motion.medium, curve: Motion.ease, alignment: .5);
      }
      setState(() {
        _prev = _rect;
        _rect = r;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    while (_keys.length < widget.items.length) {
      _keys.add(GlobalKey());
    }
    final movingRight = _prev != null && _rect != null && _rect!.left > _prev!.left;
    final items = [
      for (var i = 0; i < widget.items.length; i++)
        _pill(context, i, widget.items[i]),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.elevated ? t.solid.withValues(alpha: .78) : t.cardStrong,
        borderRadius: BorderRadius.circular(Rad.pill),
        border: Border.all(color: t.hair),
      ),
      child: widget.expand
          ? _row(movingRight, Row(children: [for (final w in items) Expanded(child: w)]))
          // Sized to its items when they fit; otherwise as wide as allowed, with the items scrolling inside.
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: _row(movingRight, Row(mainAxisSize: MainAxisSize.min, children: items)),
            ),
    );
  }

  Widget _row(bool movingRight, Widget row) {
    final t = context.tokens;
    final stack = Stack(key: _stackKey, children: [
      if (_rect != null)
        TweenAnimationBuilder<double>(
          key: ValueKey(_rect),
          tween: Tween(begin: _prev == null ? 1 : 0, end: 1),
          duration: Motion.medium,
          builder: (_, v, _) => _Indicator(
              from: _prev ?? _rect!, to: _rect!, progress: v, movingRight: movingRight, color: t.night),
        ),
      row,
    ]);
    if (!widget.magnify || MediaQuery.disableAnimationsOf(context)) return stack;
    return MouseRegion(
      onHover: (e) => setState(() => _hoverX = e.localPosition.dx),
      onExit: (_) => setState(() => _hoverX = null),
      child: stack,
    );
  }

  Widget _pill(BuildContext context, int i, (T, String) item) {
    final t = context.tokens;
    final sel = item.$1 == widget.selected;
    return Semantics(
      selected: sel,
      button: true,
      child: InkWell(
        key: _keys[i],
        borderRadius: BorderRadius.circular(Rad.pill),
        onTap: () => widget.onSelect(item.$1),
        child: Padding(
          padding: widget.stacked
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 7)
              : const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: AnimatedScale(
            scale: _scaleFor(i),
            duration: _hoverX == null ? Motion.fast : const Duration(milliseconds: 90),
            curve: Motion.ease,
            child: _label(context, i, item.$2, sel ? t.onNight : t.dim),
          ),
        ),
      ),
    );
  }
}

extension on _PillTabsState {
  Widget _label(BuildContext context, int i, String text, Color color) {
    final tt = Theme.of(context).textTheme;
    final icon = widget.icons == null ? null : widget.icons![i];
    final label = AnimatedDefaultTextStyle(
      duration: Motion.fast,
      textAlign: TextAlign.center,
      style: (widget.stacked ? tt.labelSmall! : tt.labelLarge!).copyWith(color: color),
      child: Text(text, textAlign: TextAlign.center, maxLines: 1),
    );
    if (icon == null) return label;
    final glyph = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: Motion.fast,
      builder: (_, c, _) => Icon(icon, size: widget.stacked ? 20 : 18, color: c),
    );
    return widget.stacked
        ? Column(mainAxisSize: MainAxisSize.min, children: [glyph, const SizedBox(height: 2), label])
        : Row(mainAxisSize: MainAxisSize.min, children: [glyph, const SizedBox(width: 8), label]);
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator(
      {required this.from, required this.to, required this.progress, required this.movingRight, required this.color});
  final Rect from;
  final Rect to;
  final double progress;
  final bool movingRight;
  final Color color;

  static const _lead = Interval(0, .72, curve: Motion.ease);
  static const _trail = Interval(.22, 1, curve: Motion.ease);

  @override
  Widget build(BuildContext context) {
    // The edge in the direction of travel leads; the other trails, so the pill stretches then settles.
    final l = movingRight ? _trail.transform(progress) : _lead.transform(progress);
    final r = movingRight ? _lead.transform(progress) : _trail.transform(progress);
    final rect = Rect.fromLTRB(
      from.left + (to.left - from.left) * l,
      to.top,
      from.right + (to.right - from.right) * r,
      to.bottom,
    );
    return Positioned.fromRect(
      rect: rect,
      child: DecoratedBox(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Rad.pill))),
    );
  }
}

/// Status is icon + label, never colour alone (rule 8).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.icon, required this.label, required this.color, this.solid = false});
  final IconData icon;
  final String label;
  final Color color;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fg = solid ? t.onNight : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(Rad.pill),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg)),
      ]),
    );
  }
}

/// Large display numeral with a small icon+label caption (84 Team / 37 Hiring).
class BigStat extends StatelessWidget {
  const BigStat({super.key, required this.value, required this.label, required this.icon, this.compact = false});
  final String value;
  final String label;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(value, style: compact ? tt.displaySmall : tt.displayLarge),
      ),
      const SizedBox(height: 2),
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: context.tokens.dim),
        const SizedBox(width: 5),
        Flexible(child: Text(label, style: tt.labelMedium, overflow: TextOverflow.ellipsis)),
      ]),
    ]);
  }
}

enum BarStyle { night, accent, striped, outline }

/// Labelled pill bar (Interviews 17% / Hired 15% / Project time striped).
class PillBar extends StatelessWidget {
  const PillBar({super.key, required this.label, required this.text, required this.style, this.fill = 1});
  final String label;
  final String text;
  final BarStyle style;
  final double fill;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final fg = switch (style) {
      BarStyle.night => t.onNight,
      BarStyle.accent => t.onAccent,
      _ => t.ink,
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: tt.labelMedium, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 6),
      SizedBox(
        height: 36,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Rad.pill),
          child: Stack(fit: StackFit.expand, children: [
            Container(
              decoration: BoxDecoration(
                color: style == BarStyle.outline ? Colors.transparent : t.well.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(Rad.pill),
                border: style == BarStyle.outline ? Border.all(color: t.line2) : null,
              ),
            ),
            if (style == BarStyle.striped) CustomPaint(painter: _StripePainter(t.line2)),
            if (style == BarStyle.night || style == BarStyle.accent)
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                // Never thinner than the label, so text always sits on the fill and keeps contrast.
                widthFactor: fill.clamp(.3, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: style == BarStyle.night ? t.night : t.accent,
                    borderRadius: BorderRadius.circular(Rad.pill),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(text, style: tt.labelMedium?.copyWith(color: fg)),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    for (double x = -size.height; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) => old.color != color;
}

/// Vertical capsule bars (the Progress card). [values] are ratios 0..1 for drawing only.
class CapsuleBars extends StatelessWidget {
  const CapsuleBars({super.key, required this.values, required this.labels, this.highlight, this.highlightLabel, this.height = 150});
  final List<double> values;
  final List<String> labels;
  final int? highlight;
  final String? highlightLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      height: height,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (i == highlight && highlightLabel != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(Rad.pill)),
                  child: Text(highlightLabel!,
                      style: tt.labelSmall?.copyWith(color: t.onAccent), maxLines: 1, overflow: TextOverflow.fade),
                ),
              Expanded(
                child: Stack(alignment: Alignment.bottomCenter, children: [
                  Container(width: 1.4, color: t.line2),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: values[i].clamp(0.0, 1.0)),
                    duration: Motion.slow,
                    curve: Motion.ease,
                    builder: (_, v, _) => FractionallySizedBox(
                      heightFactor: v < .04 ? .04 : v,
                      child: Container(
                        width: 9,
                        decoration: BoxDecoration(
                          color: i == highlight ? t.accent : (v < .05 ? t.faint : t.night),
                          borderRadius: BorderRadius.circular(Rad.pill),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 6),
              Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(color: i == highlight ? t.accent : t.night, shape: BoxShape.circle)),
              const SizedBox(height: 6),
              Text(labels[i],
                  style: tt.labelSmall?.copyWith(color: i == highlight ? t.ink : t.faint), maxLines: 1),
            ]),
          ),
      ]),
    );
  }
}

/// Avatar with initials; colour picked deterministically from the accent family.
class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 36});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .map((p) => p.replaceAll(RegExp(r'[^\p{L}]', unicode: true), ''))
        .where((p) => p.isNotEmpty)
        .toList();
    final initials = parts.isEmpty ? '?' : parts.take(2).map((p) => p[0].toUpperCase()).join();
    final palette = [t.accentSoft, t.well, t.bgBottom, t.accent.withValues(alpha: .35)];
    final bg = palette[name.codeUnits.fold<int>(0, (a, b) => a + b) % palette.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: t.hair, width: 2)),
      child: Text(initials,
          style: TextStyle(fontFamily: displayFont, fontSize: size * .38, color: t.accentDeep, fontWeight: FontWeight.w500)),
    );
  }
}

/// Filter chip with a count suffix (All 10 / Design 3).
class CountChip extends StatelessWidget {
  const CountChip({super.key, required this.label, required this.count, required this.selected, required this.onTap});
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: selected ? t.night : t.cardStrong,
      shape: StadiumBorder(side: BorderSide(color: selected ? t.night : t.hair)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: tt.labelLarge?.copyWith(color: selected ? t.onNight : t.ink)),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text('$count', style: tt.labelSmall?.copyWith(color: selected ? t.nightDim : t.faint)),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Equal-width choice buttons (6 h / 7 h / 8 h / 9 h).
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({super.key, required this.options, required this.value, required this.onChanged});
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    return Row(children: [
      for (final (i, o) in options.indexed) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(
          child: Material(
            color: o.$1 == value ? t.night : t.well,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onChanged == null ? null : () => onChanged!(o.$1),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: o.$1 == value ? t.night : t.line),
                ),
                child: Text(o.$2,
                    style: tt.labelLarge?.copyWith(color: o.$1 == value ? t.onNight : t.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ),
      ],
    ]);
  }
}

/// Glass modal with dimmed, blurred backdrop and a soft scale-in.
Future<T?> showGlassDialog<T>(BuildContext context, {required String title, required Widget body, double maxWidth = 460}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: Motion.medium,
    pageBuilder: (ctx, _, _) => _GlassDialog(title: title, body: body, maxWidth: maxWidth),
    transitionBuilder: (ctx, a, _, child) {
      final c = CurvedAnimation(parent: a, curve: Motion.ease);
      return Stack(children: [
        Positioned.fill(
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6 * c.value, sigmaY: 6 * c.value),
              child: ColoredBox(color: context.tokens.night.withValues(alpha: .28 * c.value)),
            ),
          ),
        ),
        Opacity(opacity: c.value, child: Transform.scale(scale: .96 + .04 * c.value, child: child)),
      ]);
    },
  );
}

class _GlassDialog extends StatelessWidget {
  const _GlassDialog({required this.title, required this.body, required this.maxWidth});
  final String title;
  final Widget body;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: MediaQuery.sizeOf(context).height * .9),
            child: Material(
              color: t.solid,
              borderRadius: BorderRadius.circular(Rad.card),
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
                    IconButton(
                        tooltip: l.close, onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ]),
                  const SizedBox(height: 12),
                  body,
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.help});
  final String text;
  final String? help;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(text, style: tt.labelLarge),
        if (help != null) Text(help!, style: tt.bodySmall),
      ]),
    );
  }
}

class DialogActions extends StatelessWidget {
  const DialogActions({super.key, required this.primary, required this.onPrimary, this.busy = false});
  final String primary;
  final VoidCallback? onPrimary;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.cancel)),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: busy ? null : onPrimary,
          child: busy
              ? SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: context.tokens.onNight))
              : Text(primary),
        ),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.action});
  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: t.well, shape: BoxShape.circle),
          child: Icon(icon, color: t.dim),
        ),
        const SizedBox(height: 12),
        Text(title, style: tt.titleMedium, textAlign: TextAlign.center),
        if (body != null) ...[
          const SizedBox(height: 4),
          Text(body!, style: tt.bodySmall, textAlign: TextAlign.center),
        ],
        if (action != null) ...[const SizedBox(height: 14), action!],
      ]),
    );
  }
}

class LoadingBlock extends StatelessWidget {
  const LoadingBlock({super.key, this.height = 220});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Center(
          child: SizedBox.square(
              dimension: 26, child: CircularProgressIndicator(strokeWidth: 2.4, color: context.tokens.accent)),
        ),
      );
}
