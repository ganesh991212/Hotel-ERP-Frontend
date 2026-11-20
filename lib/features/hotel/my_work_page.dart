import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';
import 'attendance_page.dart';
import 'rota.dart';

/// The signed-in person's own work: cooking, serving, billing, depending on what their role does. The server
/// decides which sections apply and computes every number; this page only lays them out.
final _myWorkProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, period) async {
  return Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/dashboard/me?period=$period'));
});

class MyWorkPage extends ConsumerStatefulWidget {
  const MyWorkPage({super.key});

  @override
  ConsumerState<MyWorkPage> createState() => _MyWorkPageState();
}

class _MyWorkPageState extends ConsumerState<MyWorkPage> {
  String _period = 'today';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(_myWorkProvider(_period));
    return PageBody(children: [
      Reveal(index: 0, child: PageHeading(l.tabOverview, actions: const [ClockButton()])),
      Reveal(
        index: 1,
        child: Wrap(spacing: 8, children: [
          CountChip(label: l.periodToday, count: null, selected: _period == 'today', onTap: () => setState(() => _period = 'today')),
          CountChip(label: l.periodWeek, count: null, selected: _period == 'week', onTap: () => setState(() => _period = 'week')),
        ]),
      ),
      const SizedBox(height: Gap.m),
      const MyShiftsCard(),
      const SizedBox(height: Gap.m),
      data.when(
        loading: () => const LoadingBlock(),
        error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
        data: (d) {
          final sections = (d['sections'] as List).cast<Map<String, dynamic>>();
          if (sections.isEmpty) return Glass(child: EmptyState(icon: Icons.insights_rounded, title: l.noWorkYet));
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final (i, sec) in sections.indexed) ...[
              if (i > 0) const SizedBox(height: Gap.m),
              Reveal(index: 2 + i, child: _Section(sec)),
            ],
          ]);
        },
      ),
    ]);
  }
}

/// One stat: big number, label, and (for averages) the team's figure underneath for context.
class _Stat {
  const _Stat(this.icon, this.value, this.label, [this.team]);
  final IconData icon;
  final String value;
  final String label;
  final String? team;
}

class _Section extends StatelessWidget {
  const _Section(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String mins(dynamic v) => v == null ? '–' : l.minutesDecimal(v.toString());
    String? team(dynamic v) => v == null ? null : l.teamAverage(mins(v));
    final (title, stats) = switch (s['kind']) {
      'cooking' => (
          l.myCooking,
          [
            _Stat(Icons.soup_kitchen_outlined, '${s['orders_cooked']}', l.statOrdersCooked),
            _Stat(Icons.restaurant_rounded, '${s['items_cooked']}', l.statItemsCooked),
            _Stat(Icons.timer_outlined, mins(s['avg_prep_minutes']), l.statAvgCook, team(s['team_avg_prep_minutes'])),
            _Stat(Icons.hourglass_bottom_rounded, mins(s['avg_wait_before_start_minutes']), l.statAvgWaitStart,
                team(s['team_avg_wait_before_start_minutes'])),
            _Stat(Icons.queue_rounded, '${s['in_queue_now']}', l.statInQueue),
          ]
        ),
      'serving' => (
          l.myServing,
          [
            _Stat(Icons.done_all_rounded, '${s['orders_served']}', l.statOrdersServed),
            _Stat(Icons.table_restaurant_outlined, '${s['tables_served']}', l.statTablesServed),
            _Stat(Icons.directions_walk_rounded, mins(s['avg_serve_minutes']), l.statAvgServe, team(s['team_avg_serve_minutes'])),
            _Stat(Icons.edit_note_rounded, '${s['orders_taken']}', l.statOrdersTaken,
                formatInr(s['orders_taken_minor'] ?? 0, showPaise: false)),
            _Stat(Icons.notifications_active_outlined, '${s['ready_to_serve_now']}', l.statReadyNow),
          ]
        ),
      _ => (
          l.myBilling,
          [
            _Stat(Icons.receipt_long_outlined, '${s['bills_raised']}', l.statBillsRaised,
                formatInr(s['bills_raised_minor'] ?? 0, showPaise: false)),
            _Stat(Icons.payments_outlined, formatInr(s['collected_minor'] ?? 0, showPaise: false), l.statCollected,
                _byMethod(s['collected_by_method_minor'] as Map?)),
            _Stat(Icons.pending_actions_outlined, '${s['unpaid_bills_now']}', l.statUnpaidNow,
                formatInr(s['unpaid_now_minor'] ?? 0, showPaise: false)),
          ]
        ),
    };
    return Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardTitle(title),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, c) {
          final cols = (c.maxWidth / (context.isPhone ? 150 : 200)).floor().clamp(2, 5);
          final w = (c.maxWidth - (cols - 1) * 16) / cols;
          return Wrap(spacing: 16, runSpacing: 18, children: [
            for (final st in stats) SizedBox(width: w, child: _StatTile(st)),
          ]);
        }),
      ]),
    );
  }

  /// "UPI ₹1,200 · Cash ₹300" from server-summed amounts (formatting only).
  static String? _byMethod(Map? m) {
    if (m == null || m.isEmpty) return null;
    return m.entries.map((e) => '${e.key} ${formatInr(e.value as int, showPaise: false)}').join(' · ');
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.s);
  final _Stat s;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      BigStat(value: s.value, label: s.label, icon: s.icon, compact: true),
      if (s.team != null) ...[
        const SizedBox(height: 2),
        Text(s.team!, style: tt.labelSmall?.copyWith(color: context.tokens.dim)),
      ],
    ]);
  }
}
