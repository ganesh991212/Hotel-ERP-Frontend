import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/auth/session.dart';
import '../core/theme/tokens.dart';
import '../core/branding/branding.dart';
import '../core/l10n/locale.dart';
import '../core/push/permission/notif_permission.dart';
import '../core/push/push_service.dart';
import '../core/sound/alert_sound.dart';
import '../features/hotel/printer_dialog.dart';
import '../features/hotel/settings_dialog.dart';
import 'feedback.dart';
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
      NavTab('/p/categories', l.tabCategories, Icons.category_outlined),
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
    ref.listen(outletEventsProvider, (_, next) {
      final kind = alertFor(s, next.value);
      if (kind != null) ref.read(alertSoundProvider).play(kind);
    });
    final tabs = tabsFor(context, s);
    final current = tabs.where((t) => location.startsWith(t.path)).firstOrNull?.path ?? tabs.firstOrNull?.path ?? '';
    final g = context.gutter;
    final phone = context.isPhone;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Stack(children: [
          SafeArea(
            bottom: false,
            child: Column(children: [
              Padding(
                padding: EdgeInsets.fromLTRB(g, phone ? 10 : 22, g, 0),
                child: Row(children: [
                  Expanded(child: Align(alignment: Alignment.centerLeft, child: _Brand(session: s))),
                  const SizedBox(width: 8),
                  ..._actions(context, ref, s, compact: phone),
                ]),
              ),
              if (!s.platform && s.subscriptionStatus != 'ACTIVE' && s.subscriptionStatus != 'TRIAL')
                _SubscriptionBanner(status: s.subscriptionStatus),
              if (kIsWeb && !s.platform && s.canAny(['kitchen.cook', 'order.serve', 'order.confirm', 'kot.print']))
                const _EnableAlertsBanner(),
              Expanded(child: child),
            ]),
          ),
          if (tabs.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomDock(tabs: tabs, current: current, onSelect: (p) => context.go(p)),
            ),
        ]),
      ),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref, Session s, {required bool compact}) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    return [
      const LanguageButton(),
      const SizedBox(width: 8),
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

class _Brand extends ConsumerWidget {
  const _Brand({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final logo = ref.watch(brandingProvider).value?.logo;
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 18, 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Rad.pill),
        border: Border.all(color: t.line2),
        color: t.card,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        logo != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.memory(logo, width: 24, height: 24, fit: BoxFit.contain),
              )
            : _HalfDot(color: t.accentDeep),
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
      onSelected: (v) async {
        final sound = ref.read(alertSoundProvider);
        switch (v) {
          case 'logout':
            ref.read(sessionProvider.notifier).logout();
          case 'sound':
            await sound.setEnabled(!sound.enabled);
            if (context.mounted) showDone(context, sound.enabled ? l.soundOn : l.soundOff);
          case 'test':
            await sound.play(AlertKind.newOrder, force: true);
            if (context.mounted && sound.lastFailed) showDone(context, l.soundBlocked);
          case 'printer':
            if (context.mounted) showPrinterDialog(context);
        }
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
        if (!session.platform) ...[
          PopupMenuItem(value: 'sound', child: Row(children: [
            Icon(ref.read(alertSoundProvider).enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded, size: 18),
            const SizedBox(width: 10),
            Text(ref.read(alertSoundProvider).enabled ? l.soundAlertsOn : l.soundAlertsOff),
          ])),
          PopupMenuItem(value: 'test', child: Row(children: [
            const Icon(Icons.campaign_outlined, size: 18),
            const SizedBox(width: 10),
            Text(l.testSound),
          ])),
          PopupMenuItem(value: 'printer', child: Row(children: [
            const Icon(Icons.print_outlined, size: 18),
            const SizedBox(width: 10),
            Text(l.printerSetup),
          ])),
          const PopupMenuDivider(),
        ],
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

/// Browser only: one tap unlocks loud in-app sound for this session (autoplay policy) and asks for
/// notification permission. Browsers never allow a custom notification sound, so the copy says to keep the
/// tab open for the loud alert; background notifications use the system sound.
class _EnableAlertsBanner extends ConsumerStatefulWidget {
  const _EnableAlertsBanner();

  @override
  ConsumerState<_EnableAlertsBanner> createState() => _EnableAlertsBannerState();
}

class _EnableAlertsBannerState extends ConsumerState<_EnableAlertsBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final sound = ref.watch(alertSoundProvider);
    final perm = notificationPermission();
    if (_dismissed || (sound.unlocked && perm != 'default') || !sound.enabled) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(context.gutter, 12, context.gutter, 0),
      child: Glass(
        strong: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 8, children: [
          Icon(Icons.campaign_outlined, color: t.accentDeep),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(perm == 'denied' ? l.enableAlertsDenied : l.enableAlertsBody),
          ),
          FilledButton.icon(
            onPressed: () async {
              await sound.play(AlertKind.ready, force: true); // the tap itself unlocks audio
              if (notificationPermission() == 'default') {
                await requestNotificationPermission();
                final s = ref.read(sessionProvider).value;
                if (s != null) {
                  ref.read(pushServiceProvider).reset();
                  await ref.read(pushServiceProvider).register(s.userId);
                }
              }
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.notifications_active_outlined, size: 18),
            label: Text(l.enableAlerts),
          ),
          TextButton(onPressed: () => setState(() => _dismissed = true), child: Text(l.notNow)),
        ]),
      ),
    );
  }
}

/// Space pages leave at the bottom so the floating dock never covers content.
const double kDockClearance = 104;

/// Floating glass navigation dock. Phones: icon over label, full width when few tabs; with more tabs the bar
/// stays within the screen and the tabs scroll sideways inside it, keeping the selected tab in view.
/// Larger screens: icon + label, centred, with Dock-style magnification under the mouse.
class _BottomDock extends StatelessWidget {
  const _BottomDock({required this.tabs, required this.current, required this.onSelect});
  final List<NavTab> tabs;
  final String current;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final phone = context.isPhone;
    final g = context.gutter;
    final t = context.tokens;
    final pills = PillTabs<String>(
      items: [for (final t in tabs) (t.path, t.label)],
      icons: [for (final t in tabs) t.icon],
      stacked: phone,
      elevated: true,
      expand: phone && tabs.length <= 4,
      magnify: !phone,
      selected: current,
      onSelect: onSelect,
    );
    // Frosted glass: content scrolling underneath blurs instead of showing through as text.
    final bar = DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Rad.pill), boxShadow: t.shadow),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Rad.pill),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: pills),
      ),
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(g, 0, g, phone ? 10 : 18),
        // The bar never grows past the screen: PillTabs scrolls its tabs inside it when they do not fit.
        child: LayoutBuilder(builder: (context, c) {
          final fill = phone && tabs.length <= 4;
          return Center(
            child: fill
                ? SizedBox(width: c.maxWidth, child: bar)
                : ConstrainedBox(constraints: BoxConstraints(maxWidth: c.maxWidth), child: bar),
          );
        }),
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
      padding: EdgeInsets.fromLTRB(g, 18, g, kDockClearance + MediaQuery.paddingOf(context).bottom),
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
      // Stack heading over actions until there is clearly room for one row (avoids wrapping the title).
      child: context.width < 1000
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


/// Which loud alert (if any) a live event deserves for this person. Mirrors the server's push rules so the
/// open app and a backgrounded phone ring for the same things.
AlertKind? alertFor(Session s, Map<String, dynamic>? ev) {
  if (ev == null) return null;
  final type = ev['type'];
  final order = ev['order'] as Map<String, dynamic>?;
  if (order == null) return null;
  final status = order['status'];
  final mode = (s.me['outlet'] as Map?)?['kitchen_mode'];
  if (type == 'order.ready' && s.can('order.serve')) return AlertKind.ready;
  if (type == 'order.created' && status == 'PLACED' && s.can('order.confirm')) return AlertKind.newOrder;
  if (type == 'order.created' && status == 'CONFIRMED') {
    if (mode == 'CHEF_ACCEPT' && s.can('kitchen.cook')) return AlertKind.newOrder;
    if (mode == 'ADMIN_PRINT' && s.can('kot.print')) return AlertKind.newOrder;
  }
  if (type == 'order.assigned' && order['chef']?['id'] == s.userId) return AlertKind.newOrder;
  return null;
}
