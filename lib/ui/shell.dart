import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/auth/session.dart';
import '../core/theme/tokens.dart';
import '../features/hotel/settings_dialog.dart';
import '../l10n/app_localizations.dart';
import 'components.dart';
import 'status.dart';

class NavTab {
  const NavTab(this.path, this.label, this.icon);
  final String path;
  final String label;
  final IconData icon;
}

/// Tabs are derived from permissions and plan features. Hiding is UX only; the API enforces.
List<NavTab> tabsFor(BuildContext context, Session s) {
  final l = AppLocalizations.of(context);
  if (s.platform) {
    return [
      NavTab('/p/overview', l.tabOverview, Icons.space_dashboard_outlined),
      NavTab('/p/hotels', l.tabHotels, Icons.apartment_rounded),
      NavTab('/p/plans', l.tabPlans, Icons.workspace_premium_outlined),
    ];
  }
  return [
    if (s.can('dashboard.view')) NavTab('/h/overview', l.tabOverview, Icons.space_dashboard_outlined),
    if (s.can('order.create') || s.can('order.serve')) NavTab('/h/floor', l.tabFloor, Icons.table_restaurant_outlined),
    if (s.can('kitchen.cook') || s.can('kitchen.manage')) NavTab('/h/kitchen', l.tabKitchen, Icons.soup_kitchen_outlined),
    if (s.can('menu.manage') || s.can('menu.availability')) NavTab('/h/menu', l.tabMenu, Icons.restaurant_menu),
    if (s.can('table.manage')) NavTab('/h/tables', l.tabTables, Icons.qr_code_2_rounded),
    if (s.can('staff.manage')) NavTab('/h/team', l.tabTeam, Icons.groups_2_outlined),
    if (s.can('expense.view') && s.feature('EXPENSES')) NavTab('/h/expenses', l.tabExpenses, Icons.receipt_long_outlined),
  ];
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider).value;
    if (s == null) return const SizedBox.shrink();
    final tabs = tabsFor(context, s);
    final current = tabs.where((t) => location.startsWith(t.path)).firstOrNull?.path ?? tabs.firstOrNull?.path ?? '';
    final pills = PillTabs<String>(
      items: [for (final t in tabs) (t.path, t.label)],
      selected: current,
      onSelect: (p) => context.go(p),
      expand: context.isPhone && tabs.length <= 3,
    );
    final g = context.gutter;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: EdgeInsets.fromLTRB(g, context.isPhone ? 10 : 22, g, 0),
              child: context.isPhone
                  ? Column(children: [
                      Row(children: [
                        Expanded(child: Align(alignment: Alignment.centerLeft, child: _Brand(session: s))),
                        const SizedBox(width: 8),
                        ..._actions(context, ref, s, compact: true),
                      ]),
                      const SizedBox(height: 12),
                      tabs.length <= 3
                          ? pills
                          : SingleChildScrollView(scrollDirection: Axis.horizontal, child: pills),
                    ])
                  : Row(children: [
                      _Brand(session: s),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: pills),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ..._actions(context, ref, s, compact: false),
                    ]),
            ),
            if (!s.platform && s.subscriptionStatus != 'ACTIVE' && s.subscriptionStatus != 'TRIAL')
              _SubscriptionBanner(status: s.subscriptionStatus),
            Expanded(child: child),
          ]),
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref, Session s, {required bool compact}) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    return [
      if (!s.platform && s.can('settings.manage'))
        compact
            ? RoundButton(icon: Icons.tune_rounded, tooltip: l.settings, onTap: () => showSettingsDialog(context))
            : OutlinedButton.icon(
                onPressed: () => showSettingsDialog(context),
                icon: Icon(Icons.tune_rounded, size: 18, color: t.ink),
                label: Text(l.settings),
              ),
      if (!s.platform) ...[const SizedBox(width: 8), const _AlertsBell()],
      const SizedBox(width: 8),
      _ProfileButton(session: s),
    ];
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 18, 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Rad.pill),
        border: Border.all(color: t.line2),
        color: t.card,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _HalfDot(color: t.accentDeep),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            session.hotelName ?? l.appName,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }
}

/// Brand mark: a half-filled dot.
class _HalfDot extends StatelessWidget {
  const _HalfDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 1.6)),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: .5,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              ),
            ),
          ),
        ),
      );
}

final _alertsProvider = liveProvider<List<dynamic>>(
  (api) async => (await api.get('/api/v1/orders?scope=open')) as List<dynamic>,
  poll: const Duration(seconds: 30),
);

/// Bell with a badge: orders ready to serve and QR orders waiting for confirmation.
class _AlertsBell extends ConsumerWidget {
  const _AlertsBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider).value!;
    if (!s.can('order.view')) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final orders = ref.watch(_alertsProvider).value ?? const [];
    final alerts = orders.where((o) => o['status'] == 'READY' || o['status'] == 'PLACED').toList();
    return Stack(clipBehavior: Clip.none, children: [
      RoundButton(
        icon: Icons.notifications_none_rounded,
        tooltip: l.alerts,
        onTap: () => showGlassDialog(
          context,
          title: l.alerts,
          body: alerts.isEmpty
              ? EmptyState(icon: Icons.notifications_off_outlined, title: l.noAlerts)
              : Column(children: [
                  for (final o in alerts)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: OrderStatusChip(o['status']),
                      title: Text(l.orderNumberTable(o['number'], o['table']?['label'] ?? '-')),
                      subtitle: Text(l.minutesAgo(minutesSince(o['ready_at'] ?? o['created_at']))),
                    ),
                ]),
        ),
      ),
      if (alerts.isNotEmpty)
        Positioned(
          right: -2,
          top: -4,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
                color: t.accent, borderRadius: BorderRadius.circular(Rad.pill), border: Border.all(color: t.hair, width: 2)),
            child: Text('${alerts.length}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: t.onAccent)),
          ),
        ),
    ]);
  }
}

class _ProfileButton extends ConsumerWidget {
  const _ProfileButton({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      tooltip: l.yourProfile,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: context.tokens.solid,
      onSelected: (v) {
        if (v == 'logout') ref.read(sessionProvider.notifier).logout();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Avatar(session.name),
            title: Text(session.name),
            subtitle: Text(roleLabel(context, session.role)),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'logout', child: Row(children: [
          const Icon(Icons.logout_rounded, size: 18),
          const SizedBox(width: 10),
          Text(l.signOut),
        ])),
      ],
      child: IgnorePointer(child: RoundButton(icon: Icons.person_outline_rounded, tooltip: l.yourProfile)),
    );
  }
}

class _SubscriptionBanner extends StatelessWidget {
  const _SubscriptionBanner({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = AppLocalizations.of(context);
    final suspended = status == 'SUSPENDED' || status == 'CANCELLED';
    return Padding(
      padding: EdgeInsets.fromLTRB(context.gutter, 12, context.gutter, 0),
      child: Glass(
        strong: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(suspended ? Icons.lock_outline : Icons.warning_amber_rounded, color: suspended ? t.danger : t.warn),
          const SizedBox(width: 10),
          Expanded(child: Text(suspended ? l.bannerSuspended : l.bannerPastDue)),
          TextButton(onPressed: () => showSettingsDialog(context, billing: true), child: Text(l.managePlan)),
        ]),
      ),
    );
  }
}

/// Standard scrollable page body with gutters.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.maxWidth = 1500});
  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final g = context.gutter;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(g, 18, g, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, {super.key, this.actions = const []});
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final head = Text(title, style: context.isPhone ? tt.displaySmall : tt.displayMedium);
    if (actions.isEmpty) return Padding(padding: const EdgeInsets.only(bottom: 16), child: head);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: context.isPhone
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              head,
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ])
          : Row(children: [
              Expanded(child: head),
              for (final a in actions) Padding(padding: const EdgeInsets.only(left: 10), child: a),
            ]),
    );
  }
}
