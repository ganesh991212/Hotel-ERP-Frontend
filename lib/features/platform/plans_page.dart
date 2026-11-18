import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';
import 'hotels_page.dart' show featureLabel, platformPlansProvider;

class PlansPage extends ConsumerWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(platformPlansProvider);
    return PageBody(children: [
      Reveal(index: 0, child: PageHeading(l.tabPlans)),
      data.when(
        loading: () => const LoadingBlock(),
        error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
        data: (plans) {
          final cards = [for (final (i, p) in plans.indexed) Reveal(index: i + 1, child: _PlanCard(plan: p, highlight: i == 1))];
          if (context.isDesktop) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final (i, c) in cards.indexed) ...[if (i > 0) const SizedBox(width: Gap.m), Expanded(child: c)],
            ]);
          }
          return Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: Gap.m), child: c)]);
        },
      ),
    ]);
  }
}

class _PlanCard extends ConsumerStatefulWidget {
  const _PlanCard({required this.plan, required this.highlight});
  final Map<String, dynamic> plan;
  final bool highlight;

  @override
  ConsumerState<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends ConsumerState<_PlanCard> {
  Future<void> _patch(Map<String, dynamic> body) async {
    await guard(context, () => ref.read(apiProvider).patch('/api/v1/platform/plans/${widget.plan['id']}', body));
    ref.invalidate(platformPlansProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final p = widget.plan;
    final features = Map<String, dynamic>.from(p['features']);
    final limits = Map<String, dynamic>.from(p['limits']);
    final header = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(p['name'], style: tt.headlineSmall?.copyWith(color: widget.highlight ? t.onNight : t.ink))),
        if (p['is_placeholder'] == true)
          StatusChip(icon: Icons.info_outline, label: l.placeholderPrice, color: t.warn, solid: widget.highlight),
      ]),
      const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(formatInr(p['price_minor'], showPaise: false), style: tt.displaySmall?.copyWith(color: widget.highlight ? t.onNight : t.ink)),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(l.perMonthShort, style: tt.bodySmall?.copyWith(color: widget.highlight ? t.nightDim : t.dim)),
        ),
        const Spacer(),
        IconButton(
          tooltip: l.editPrice,
          onPressed: () => _editPrice(context),
          icon: Icon(Icons.edit_outlined, size: 18, color: widget.highlight ? t.onNight : t.ink),
        ),
      ]),
    ]);
    return Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        widget.highlight ? NightPanel(child: header) : Padding(padding: const EdgeInsets.all(4), child: header),
        const SizedBox(height: 12),
        Text(l.features, style: tt.titleMedium),
        for (final f in features.keys)
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(featureLabel(context, f), style: tt.bodyMedium),
            value: features[f] == true,
            onChanged: (v) => _patch({'features': {f: v}}),
          ),
        const SizedBox(height: 8),
        Text(l.limits, style: tt.titleMedium),
        const SizedBox(height: 4),
        for (final k in limits.keys)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Expanded(child: Text(featureLabel(context, k), style: tt.bodyMedium)),
              InkWell(
                borderRadius: BorderRadius.circular(Rad.pill),
                onTap: () => _editLimit(context, k, limits[k]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: t.well, borderRadius: BorderRadius.circular(Rad.pill)),
                  child: Text(limits[k] == null ? l.unlimited : '${limits[k]}', style: tt.labelLarge),
                ),
              ),
            ]),
          ),
      ]),
    );
  }

  Future<void> _editPrice(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final c = TextEditingController(text: minorToInput(widget.plan['price_minor']));
    await showGlassDialog(
      context,
      title: l.editPrice,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(l.monthlyPrice, help: l.priceChangeHelp),
        TextField(controller: c, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '₹ ')),
        Builder(
          builder: (ctx) => DialogActions(
            primary: l.save,
            onPrimary: () async {
              final v = parseInrToMinor(c.text);
              if (v == null) return showDone(ctx, l.errAmount);
              await _patch({'price_minor': v});
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        ),
      ]),
    );
  }

  Future<void> _editLimit(BuildContext context, String key, Object? current) async {
    final l = AppLocalizations.of(context);
    final c = TextEditingController(text: current?.toString() ?? '');
    await showGlassDialog(
      context,
      title: featureLabel(context, key),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(l.limit, help: l.limitHelp),
        TextField(controller: c, keyboardType: TextInputType.number),
        Builder(
          builder: (ctx) => DialogActions(
            primary: l.save,
            onPrimary: () async {
              final txt = c.text.trim();
              await _patch({'limits': {key: txt.isEmpty ? null : int.tryParse(txt) ?? 0}});
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        ),
      ]),
    );
  }
}
