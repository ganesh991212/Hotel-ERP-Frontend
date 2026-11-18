import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/shell.dart';
import '../../ui/status.dart';

final dashboardProvider = liveProvider<Map<String, dynamic>>(
  (api) async => Map<String, dynamic>.from(await api.get('/api/v1/dashboard/summary')),
  poll: const Duration(seconds: 60),
);

class HotelOverviewPage extends ConsumerWidget {
  const HotelOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider).value!;
    final data = ref.watch(dashboardProvider);
    final l = AppLocalizations.of(context);
    return data.when(
      loading: () => const LoadingBlock(height: 400),
      error: (e, _) => Center(child: EmptyState(icon: Icons.cloud_off_rounded, title: l.errGeneric)),
      data: (d) => _Dashboard(d: d, name: s.firstName),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.d, required this.name});
  final Map<String, dynamic> d;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? l.goodMorning(name) : (hour < 17 ? l.goodAfternoon(name) : l.goodEvening(name));
    final w = context.width;

    final a = _RevenueCard(d: d);
    final b = _HourlyCard(d: d);
    final c = _PrepDialCard(d: d);
    final live = _LiveOrdersCard(d: d);
    final e = _InsightsCard(d: d);
    final f = _WeekCard(d: d);

    Widget grid;
    if (w >= Breakpoints.desktop) {
      grid = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 3,
          child: Column(children: [
            SizedBox(
              height: 330,
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: Reveal(index: 1, child: a)),
                const SizedBox(width: Gap.m),
                Expanded(child: Reveal(index: 2, child: b)),
                const SizedBox(width: Gap.m),
                Expanded(child: Reveal(index: 3, child: c)),
              ]),
            ),
            const SizedBox(height: Gap.m),
            SizedBox(
              height: 300,
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: Reveal(index: 5, child: e)),
                const SizedBox(width: Gap.m),
                Expanded(flex: 2, child: Reveal(index: 6, child: f)),
              ]),
            ),
          ]),
        ),
        const SizedBox(width: Gap.m),
        Expanded(child: SizedBox(height: 644, child: Reveal(index: 4, child: live))),
      ]);
    } else if (w >= Breakpoints.tablet) {
      Widget pair(Widget x, Widget y, double h, int i) => SizedBox(
            height: h,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: Reveal(index: i, child: x)),
              const SizedBox(width: Gap.m),
              Expanded(child: Reveal(index: i + 1, child: y)),
            ]),
          );
      grid = Column(children: [
        pair(a, b, 320, 1),
        const SizedBox(height: Gap.m),
        pair(c, e, 320, 3),
        const SizedBox(height: Gap.m),
        SizedBox(height: 300, child: Reveal(index: 5, child: f)),
        const SizedBox(height: Gap.m),
        SizedBox(height: 520, child: Reveal(index: 6, child: live)),
      ]);
    } else {
      grid = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final (i, (wdg, h)) in [(a, 300.0), (b, 300.0), (c, 320.0), (live, 520.0), (e, 300.0), (f, 280.0)].indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.m),
            child: SizedBox(height: h, child: Reveal(index: i + 1, child: wdg)),
          ),
      ]);
    }

    return PageBody(children: [
      Reveal(index: 0, child: Text(greeting, style: context.isPhone ? tt.displaySmall : tt.displayMedium)),
      const SizedBox(height: 18),
      Reveal(index: 0, child: _StatusStrip(d: d)),
      const SizedBox(height: 18),
      grid,
    ]);
  }
}

/// Row of pill bars plus big numerals (top strip of the reference).
class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.d});
  final Map<String, dynamic> d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final st = Map<String, dynamic>.from(d['by_status'] ?? {});
    int n(String k) => (st[k] ?? 0) as int;
    final total = math.max(1, d['orders_today'] as int);
    final waiting = n('PLACED') + n('CONFIRMED') + n('ASSIGNED');
    final cooking = n('PREPARING');
    final served = n('SERVED');
    final tablesTotal = math.max(1, d['tables_total'] as int);
    final busyPct = ((d['tables_busy'] as int) * 100 / tablesTotal).round();

    final bars = [
      (2, PillBar(label: l.waiting, text: '$waiting', style: BarStyle.night, fill: waiting / total + .2)),
      (2, PillBar(label: l.cooking, text: '$cooking', style: BarStyle.accent, fill: cooking / total + .2)),
      (5, PillBar(label: l.tablesBusy, text: '$busyPct%', style: BarStyle.striped)),
      (2, PillBar(label: l.servedToday, text: '$served', style: BarStyle.outline)),
    ];
    final stats = [
      BigStat(value: '${d['orders_today']}', label: l.ordersToday, icon: Icons.receipt_outlined, compact: context.isPhone),
      BigStat(
          value: formatInrCompact(d['revenue_today_minor'] as int),
          label: l.revenueToday,
          icon: Icons.currency_rupee_rounded,
          compact: context.isPhone),
      BigStat(
          value: d['avg_prep_minutes'] == null ? '–' : '${(d['avg_prep_minutes'] as num).round()}m',
          label: l.avgPrep,
          icon: Icons.timer_outlined,
          compact: context.isPhone),
    ];
    if (context.isPhone) {
      return Column(children: [
        Row(children: [Expanded(child: bars[0].$2), const SizedBox(width: 10), Expanded(child: bars[1].$2)]),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: bars[2].$2), const SizedBox(width: 10), Expanded(child: bars[3].$2)]),
        const SizedBox(height: 16),
        Row(children: [for (final s in stats) Expanded(child: s)]),
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (final (i, (flex, bar)) in bars.indexed) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(flex: flex, child: bar),
          ],
        ]),
      ),
      const SizedBox(width: 28),
      for (final (i, s) in stats.indexed) ...[if (i > 0) const SizedBox(width: 28), s],
    ]);
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.d});
  final Map<String, dynamic> d;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final net = d['net_month_minor'] as int;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Rad.card),
        boxShadow: t.shadow,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.accent, t.accentDeep],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: t.onAccent),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.storefront_outlined, color: t.onAccent.withValues(alpha: .9)),
            const Spacer(),
            Text(DateFormat.MMMd().format(DateTime.now()), style: tt.labelMedium?.copyWith(color: t.onAccent)),
          ]),
          const Spacer(),
          Text(l.thisMonth, style: tt.labelMedium?.copyWith(color: t.onAccent.withValues(alpha: .85))),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(formatInr(d['revenue_month_minor'] as int, showPaise: false),
                style: tt.displayMedium?.copyWith(color: t.onAccent)),
          ),
          const SizedBox(height: 4),
          Text(l.expensesAmount(formatInr(d['expenses_month_minor'] as int, showPaise: false)),
              style: tt.bodySmall?.copyWith(color: t.onAccent.withValues(alpha: .85))),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Rad.pill),
              border: Border.all(color: t.onAccent.withValues(alpha: .6)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(net >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 16, color: t.onAccent),
              const SizedBox(width: 6),
              Text(l.netAmount(formatInr(net, showPaise: false)),
                  style: tt.labelLarge?.copyWith(color: t.onAccent)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _HourlyCard extends StatelessWidget {
  const _HourlyCard({required this.d});
  final Map<String, dynamic> d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final hourly = (d['hourly'] as List).cast<Map>();
    // Hours are bucketed in the hotel's timezone on the server; use its clock, not the device's.
    final now = (d['now_hour'] as int?) ?? DateTime.now().hour;
    final hours = [for (var i = 6; i >= 0; i--) (now - i) % 24];
    final counts = [for (final h in hours) hourly[h]['orders'] as int];
    final peak = math.max(1, counts.fold<int>(0, math.max));
    final total = d['orders_today'] as int;
    return Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CardTitle(l.ordersByHour,
            trailing: RoundButton(
                icon: Icons.north_east_rounded,
                tooltip: l.openFloor,
                size: 36,
                onTap: () => GoRouter.of(context).go('/h/floor'))),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('$total', style: tt.displaySmall),
          const SizedBox(width: 10),
          Flexible(child: Text(l.ordersSoFarToday, style: tt.bodySmall)),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: CapsuleBars(
            height: double.infinity,
            values: [for (final c in counts) c / peak],
            labels: [for (final h in hours) DateFormat.j().format(DateTime(2000, 1, 1, h)).replaceAll(' ', '')],
            highlight: hours.length - 1,
            highlightLabel: '${counts.last}',
          ),
        ),
      ]),
    );
  }
}

/// Dial showing average prep time against a 20-minute target (the reference's time tracker).
class _PrepDialCard extends StatelessWidget {
  const _PrepDialCard({required this.d});
  final Map<String, dynamic> d;

  static const targetMinutes = 20;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final avg = (d['avg_prep_minutes'] as num?)?.toDouble();
    final chefs = (d['chefs'] as List).cast<Map>();
    final onShift = chefs.where((c) => c['on_shift'] == true).length;
    final cooking = ((d['by_status'] as Map?)?['PREPARING'] ?? 0) as int;
    return Glass(
      child: Column(children: [
        CardTitle(l.kitchenPace,
            trailing: RoundButton(
                icon: Icons.north_east_rounded,
                tooltip: l.openKitchen,
                size: 36,
                onTap: () => GoRouter.of(context).go('/h/kitchen'))),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: avg == null ? 0 : (avg / targetMinutes).clamp(0, 1)),
                duration: Motion.slow,
                curve: Motion.ease,
                builder: (_, v, _) => CustomPaint(
                  painter: _DialPainter(progress: v, track: t.line2, fill: avg != null && avg > targetMinutes ? t.warn : t.accent, tick: t.faint, knob: t.night),
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(avg == null ? '–' : NumberFormat('0.0').format(avg),
                          style: tt.displayMedium?.copyWith(fontFamily: displayFont)),
                      Text(l.avgPrepMinutes, style: tt.labelMedium),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(children: [
          StatusChip(icon: Icons.person_outline, label: l.chefsOnShift(onShift), color: t.accentDeep),
          const Spacer(),
          StatusChip(icon: Icons.local_fire_department_rounded, label: l.cookingNow(cooking), color: t.accent),
        ]),
      ]),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.progress, required this.track, required this.fill, required this.tick, required this.knob});
  final double progress;
  final Color track, fill, tick, knob;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final tickPaint = Paint()
      ..color = tick
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 60; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 60;
      final len = i % 5 == 0 ? 7.0 : 4.0;
      canvas.drawLine(c + Offset(math.cos(a), math.sin(a)) * (r - 2),
          c + Offset(math.cos(a), math.sin(a)) * (r - 2 - len), tickPaint);
    }
    final ringR = r * .72;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, ringR, ring..color = track.withValues(alpha: .35));
    if (progress > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: ringR), -math.pi / 2, 2 * math.pi * progress, false,
          ring..color = fill);
      final a = -math.pi / 2 + 2 * math.pi * progress;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * (r - 12), 4, Paint()..color = knob);
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) => old.progress != progress || old.fill != fill;
}

/// Live orders in the dark panel (the reference's onboarding-tasks column).
class _LiveOrdersCard extends StatelessWidget {
  const _LiveOrdersCard({required this.d});
  final Map<String, dynamic> d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final live = (d['live_orders'] as List).cast<Map>();
    final total = d['orders_today'] as int;
    final served = ((d['by_status'] as Map?)?['SERVED'] ?? 0) as int;
    final pct = total == 0 ? 0 : (served * 100 / total).round();
    final ch = Map<String, dynamic>.from(d['by_channel'] ?? {});
    int share(String k) => total == 0 ? 0 : (((ch[k] ?? 0) as int) * 100 / total).round();
    return Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(l.servedShare, style: tt.titleLarge)),
          Text('$pct%', style: tt.displaySmall),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          for (final (i, (k, label)) in [('QR', l.channelQr), ('WAITER', l.channelWaiter), ('ADMIN', l.channelAdmin)].indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${share(k)}%', style: tt.labelSmall),
                const SizedBox(height: 4),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    color: i == 0 ? t.accent : t.well,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.line),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.labelMedium?.copyWith(color: i == 0 ? t.onAccent : t.ink)),
                  ),
                ),
              ]),
            ),
          ],
        ]),
        const SizedBox(height: 14),
        Expanded(
          child: NightPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(child: Text(l.liveOrders, style: tt.titleLarge?.copyWith(color: t.onNight))),
                Text('${live.length}', style: tt.displaySmall?.copyWith(color: t.onNight)),
              ]),
              const SizedBox(height: 10),
              Expanded(
                child: live.isEmpty
                    ? Center(child: Text(l.noLiveOrders, style: tt.bodyMedium?.copyWith(color: t.nightDim)))
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: live.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _LiveRow(o: live[i]),
                      ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _LiveRow extends StatelessWidget {
  const _LiveRow({required this.o});
  final Map o;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final (icon, label, color) = orderStatusLook(context, o['status']);
    final done = o['status'] == 'READY';
    return Row(children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: t.night2, shape: BoxShape.circle),
        child: Icon(channelIcon(o['channel']), size: 17, color: t.onNight),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.orderNumberTable(o['number'], o['table']?['label'] ?? '-'),
              style: tt.bodyMedium?.copyWith(color: t.onNight)),
          Text('$label · ${l.minutesAgo(minutesSince(o['created_at']))}',
              style: tt.labelSmall?.copyWith(color: t.nightDim)),
        ]),
      ),
      Tooltip(
        message: label,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: done ? t.accent : t.night2, shape: BoxShape.circle),
          child: Icon(done ? Icons.check_rounded : icon, size: 13, color: done ? t.onAccent : color),
        ),
      ),
    ]);
  }
}

/// Accordion card: top dishes, chefs, payment-free summary.
class _InsightsCard extends StatefulWidget {
  const _InsightsCard({required this.d});
  final Map<String, dynamic> d;

  @override
  State<_InsightsCard> createState() => _InsightsCardState();
}

class _InsightsCardState extends State<_InsightsCard> {
  int _open = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final items = (widget.d['top_items'] as List).cast<Map>();
    final chefs = (widget.d['chefs'] as List).cast<Map>();
    Widget section(int i, String title, Widget body) => Column(children: [
          InkWell(
            onTap: () => setState(() => _open = _open == i ? -1 : i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(children: [
                Expanded(child: Text(title, style: tt.titleMedium)),
                AnimatedRotation(
                  turns: _open == i ? .5 : 0,
                  duration: Motion.fast,
                  child: Icon(Icons.expand_more_rounded, color: t.dim),
                ),
              ]),
            ),
          ),
          AnimatedCrossFade(
            duration: Motion.fast,
            crossFadeState: _open == i ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(padding: const EdgeInsets.only(bottom: 10), child: body),
          ),
          Divider(color: t.line),
        ]);
    return Glass(
      child: SingleChildScrollView(
        child: Column(children: [
          section(
            0,
            l.topDishes,
            items.isEmpty
                ? Text(l.noDataYet, style: tt.bodySmall)
                : Column(children: [
                    for (final it in items.take(4))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: t.well, borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.ramen_dining_outlined, size: 18, color: t.dim),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(it['name'], style: tt.bodyMedium, overflow: TextOverflow.ellipsis),
                              Text(l.soldCount(it['qty']), style: tt.labelSmall),
                            ]),
                          ),
                          Text(formatInr(it['revenue_minor'], showPaise: false), style: tt.labelLarge),
                        ]),
                      ),
                  ]),
          ),
          section(
            1,
            l.chefs,
            chefs.isEmpty
                ? Text(l.noChefsYet, style: tt.bodySmall)
                : Column(children: [
                    for (final c in chefs)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Avatar(c['name'], size: 32),
                          const SizedBox(width: 10),
                          Expanded(child: Text(c['name'], style: tt.bodyMedium)),
                          Text(l.doneCount(c['completed_today']), style: tt.labelMedium),
                          const SizedBox(width: 8),
                          StatusChip(
                            icon: c['on_shift'] == true ? Icons.circle : Icons.circle_outlined,
                            label: c['on_shift'] == true ? l.onShift : l.offShift,
                            color: c['on_shift'] == true ? t.ok : t.faint,
                          ),
                        ]),
                      ),
                  ]),
          ),
          section(
            2,
            l.avgTicket,
            Row(children: [
              Text(formatInr(widget.d['avg_ticket_minor'] as int), style: tt.headlineSmall),
              const SizedBox(width: 8),
              Text(l.perOrderToday, style: tt.bodySmall),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Week strip with revenue per day; today is circled (the reference's week calendar).
class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.d});
  final Map<String, dynamic> d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final week = (d['week'] as List).cast<Map>();
    final peak = math.max(1, week.fold<int>(0, (a, b) => math.max(a, b['revenue_minor'] as int)));
    final first = DateTime.parse(week.first['date']);
    final last = DateTime.parse(week.last['date']);
    return Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Text('${DateFormat.MMMd().format(first)} – ${DateFormat.MMMd().format(last)}',
                style: tt.titleLarge, textAlign: context.isPhone ? TextAlign.start : TextAlign.center),
          ),
        ]),
        const SizedBox(height: 4),
        Text(l.revenueLast7Days, style: tt.bodySmall, textAlign: context.isPhone ? TextAlign.start : TextAlign.center),
        const SizedBox(height: 12),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final (i, day) in week.indexed)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(left: i == 0 ? BorderSide.none : BorderSide(color: t.line)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(children: [
                    Text(DateFormat.E().format(DateTime.parse(day['date'])), style: tt.labelMedium),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: i == week.length - 1
                          ? BoxDecoration(color: t.night, shape: BoxShape.circle)
                          : null,
                      child: Text('${DateTime.parse(day['date']).day}',
                          style: tt.titleMedium?.copyWith(color: i == week.length - 1 ? t.onNight : t.dim)),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: math.max(.08, (day['revenue_minor'] as int) / peak),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: i == week.length - 1 ? t.accent : t.accentSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      child: Text(formatInrCompact(day['revenue_minor'] as int), style: tt.labelSmall),
                    ),
                  ]),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}
