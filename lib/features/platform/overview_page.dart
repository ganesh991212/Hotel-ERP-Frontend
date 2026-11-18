import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';
import 'hotels_page.dart' show platformHotelsProvider, hotelStatusChip;

final platformSummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
    (ref) async => Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/platform/summary')));

class PlatformOverviewPage extends ConsumerWidget {
  const PlatformOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(sessionProvider).value!;
    final sum = ref.watch(platformSummaryProvider);
    final hotels = ref.watch(platformHotelsProvider).value ?? const [];
    final tt = Theme.of(context).textTheme;
    final t = context.tokens;
    final hour = DateTime.now().hour;
    final greet = hour < 12 ? l.goodMorning(s.firstName) : (hour < 17 ? l.goodAfternoon(s.firstName) : l.goodEvening(s.firstName));
    return sum.when(
      loading: () => const LoadingBlock(height: 400),
      error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
      data: (d) {
        final st = Map<String, dynamic>.from(d['by_status']);
        final total = math.max(1, d['hotels_total'] as int);
        int n(String k) => (st[k] ?? 0) as int;
        final signups = (d['signups'] as List).cast<Map>();
        final peak = math.max(1, signups.fold<int>(0, (a, b) => math.max(a, b['count'] as int)));

        final strip = Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              SizedBox(width: 150, child: PillBar(label: l.subActive, text: '${n('ACTIVE')}', style: BarStyle.night, fill: n('ACTIVE') / total + .2)),
              SizedBox(width: 150, child: PillBar(label: l.subTrial, text: '${n('TRIAL')}', style: BarStyle.accent, fill: n('TRIAL') / total + .2)),
              SizedBox(width: 220, child: PillBar(label: l.subPastDue, text: '${n('PAST_DUE')}', style: BarStyle.striped)),
              SizedBox(width: 150, child: PillBar(label: l.subSuspended, text: '${n('SUSPENDED')}', style: BarStyle.outline)),
            ]),
          ),
          if (!context.isPhone) ...[
            BigStat(value: '${d['hotels_total']}', label: l.hotels, icon: Icons.apartment_rounded),
            const SizedBox(width: 28),
            BigStat(value: formatInrCompact(d['mrr_minor']), label: l.mrr, icon: Icons.autorenew_rounded),
            const SizedBox(width: 28),
            BigStat(value: '${d['orders_30d']}', label: l.orders30d, icon: Icons.receipt_outlined),
          ],
        ]);

        final collected = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Rad.card),
            boxShadow: t.shadow,
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [t.accent, t.accentDeep]),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.account_balance_wallet_outlined, color: t.onAccent),
            const Spacer(),
            Text(l.collected30d, style: tt.labelMedium?.copyWith(color: t.onAccent)),
            FittedBox(child: Text(formatInr(d['collected_30d_minor'], showPaise: false), style: tt.displayMedium?.copyWith(color: t.onAccent))),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Rad.pill), border: Border.all(color: t.onAccent.withValues(alpha: .6))),
              child: Text(l.trialsEnding(d['trials_ending_7d']), style: tt.labelLarge?.copyWith(color: t.onAccent)),
            ),
          ]),
        );

        final signupCard = Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CardTitle(l.signups),
            const SizedBox(height: 12),
            Expanded(
              child: signups.isEmpty
                  ? Center(child: Text(l.noDataYet, style: tt.bodySmall))
                  : CapsuleBars(
                      height: double.infinity,
                      values: [for (final x in signups) (x['count'] as int) / peak],
                      labels: [for (final x in signups) DateFormat.MMM().format(DateTime.parse(x['month']))],
                      highlight: signups.length - 1,
                      highlightLabel: '${signups.last['count']}',
                    ),
            ),
          ]),
        );

        final plans = Map<String, dynamic>.from(d['by_plan']);
        final planCard = Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CardTitle(l.planMix,
                trailing: RoundButton(
                    icon: Icons.north_east_rounded, tooltip: l.tabPlans, size: 36, onTap: () => GoRouter.of(context).go('/p/plans'))),
            const SizedBox(height: 12),
            for (final (i, e) in plans.entries.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PillBar(
                  label: e.key,
                  text: '${e.value}',
                  style: i == 0 ? BarStyle.night : (i == 1 ? BarStyle.accent : BarStyle.outline),
                  fill: (e.value as int) / total + .15,
                ),
              ),
          ]),
        );

        final recent = Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CardTitle(l.recentHotels,
                trailing: RoundButton(
                    icon: Icons.north_east_rounded, tooltip: l.tabHotels, size: 36, onTap: () => GoRouter.of(context).go('/p/hotels'))),
            const SizedBox(height: 8),
            Expanded(
              child: NightPanel(
                child: hotels.isEmpty
                    ? Center(child: Text(l.noHotels, style: tt.bodyMedium?.copyWith(color: t.nightDim)))
                    : ListView(padding: EdgeInsets.zero, children: [
                        for (final h in hotels.take(8))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(children: [
                              Avatar(h['name'], size: 32),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(h['name'], style: tt.bodyMedium?.copyWith(color: t.onNight), overflow: TextOverflow.ellipsis),
                                  Text('${h['plan_name'] ?? '-'} · ${h['city'] ?? ''}', style: tt.labelSmall?.copyWith(color: t.nightDim)),
                                ]),
                              ),
                              hotelStatusChip(context, h['status'], solid: true),
                            ]),
                          ),
                      ]),
              ),
            ),
          ]),
        );

        final wide = context.isDesktop;
        return PageBody(children: [
          Reveal(index: 0, child: Text(greet, style: context.isPhone ? tt.displaySmall : tt.displayMedium)),
          const SizedBox(height: 18),
          Reveal(index: 0, child: strip),
          const SizedBox(height: 18),
          if (wide)
            SizedBox(
              height: 620,
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(
                  flex: 3,
                  child: Column(children: [
                    Expanded(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Expanded(child: Reveal(index: 1, child: collected)),
                        const SizedBox(width: Gap.m),
                        Expanded(flex: 2, child: Reveal(index: 2, child: signupCard)),
                      ]),
                    ),
                    const SizedBox(height: Gap.m),
                    Expanded(child: Reveal(index: 3, child: planCard)),
                  ]),
                ),
                const SizedBox(width: Gap.m),
                Expanded(child: Reveal(index: 4, child: recent)),
              ]),
            )
          else
            for (final (i, (w, h)) in [(collected, 240.0), (signupCard, 260.0), (planCard, 260.0), (recent, 420.0)].indexed)
              Padding(padding: const EdgeInsets.only(bottom: Gap.m), child: SizedBox(height: h, child: Reveal(index: i + 1, child: w))),
        ]);
      },
    );
  }
}
