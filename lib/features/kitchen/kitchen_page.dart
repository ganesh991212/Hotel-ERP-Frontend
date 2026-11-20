import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';
import '../../ui/status.dart';
import '../floor/cart.dart' show orderLineDetails;
import '../floor/print_actions.dart';

/// Board refreshes on every outlet event and polls every 5 s as the documented fallback.
final kitchenBoardProvider = liveProvider<Map<String, dynamic>>(
  (api) async => Map<String, dynamic>.from(await api.get('/api/v1/kitchen/board')),
  poll: const Duration(seconds: 5),
);

class KitchenPage extends ConsumerWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider).value!;
    final board = ref.watch(kitchenBoardProvider);
    final live = ref.watch(outletEventsProvider);
    final online = live.value?['type'] != 'disconnected' && !live.hasError;
    // Wall screens (kitchen TV) get bigger type.
    final scale = context.isWall ? 1.25 : 1.0;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: board.when(
        loading: () => const LoadingBlock(height: 400),
        error: (e, _) => Center(child: EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e))),
        data: (b) => _Board(b: b, session: s, online: online),
      ),
    );
  }
}

class _Board extends ConsumerWidget {
  const _Board({required this.b, required this.session, required this.online});
  final Map<String, dynamic> b;
  final Session session;
  final bool online;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final chefs = (b['chefs'] as List).cast<Map<String, dynamic>>();
    final me = chefs.where((c) => c['is_me'] == true).firstOrNull;
    final others = chefs.where((c) => c['is_me'] != true).toList();
    final grabs = (b['up_for_grabs'] as List).cast<Map<String, dynamic>>();
    final ready = (b['ready'] as List).cast<Map<String, dynamic>>();
    final onPaper = (b['on_paper'] as List? ?? const []).cast<Map<String, dynamic>>();
    final acceptMode = b['kitchen_mode'] == 'CHEF_ACCEPT';
    final isChef = session.can('kitchen.cook') && me != null;

    final header = PageHeading(l.tabKitchen, actions: [
      StatusChip(
        icon: online ? Icons.wifi_tethering_rounded : Icons.sync_problem_rounded,
        label: online ? l.live : l.reconnecting,
        color: online ? t.ok : t.warn,
      ),
      StatusChip(icon: Icons.route_outlined, label: _modeLabel(context, b['kitchen_mode']), color: t.dim),
      if (isChef) _ShiftSwitch(chef: me),
    ]);

    final grabsCard = Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardTitle(acceptMode ? l.upForGrabs : l.waitingForChef,
            trailing: Text('${grabs.length}', style: Theme.of(context).textTheme.displaySmall)),
        const SizedBox(height: 12),
        if (grabs.isEmpty)
          EmptyState(icon: Icons.check_circle_outline, title: l.noNewOrders, body: l.noNewOrdersBody)
        else
          for (final o in grabs)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TicketCard(
                o: o,
                action: acceptMode && isChef && me['on_shift'] == true
                    ? _ActionButton(label: l.pickUp, icon: Icons.pan_tool_alt_outlined, path: '/api/v1/orders/${o['id']}/accept', done: l.pickedUp)
                    : null,
              ),
            ),
      ]),
    );

    final mineCard = isChef ? _MyQueue(chef: me, max: b['max_queue_orders'] as int) : null;

    final othersCard = Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardTitle(isChef ? l.otherChefs : l.chefs),
        const SizedBox(height: 12),
        if (others.isEmpty)
          EmptyState(icon: Icons.groups_2_outlined, title: l.noOtherChefs)
        else
          for (final c in others) _ChefLane(chef: c, manage: session.can('kitchen.manage')),
      ]),
    );

    final readyCard = Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardTitle(l.readyToServe, trailing: Text('${ready.length}', style: Theme.of(context).textTheme.displaySmall)),
        const SizedBox(height: 10),
        if (ready.isEmpty)
          Text(l.nothingWaiting, style: Theme.of(context).textTheme.bodySmall)
        else
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (final o in ready)
              _ReadyPill(o: o, canServe: session.can('order.serve')),
          ]),
      ]),
    );

    final w = context.width;
    final cols = <Widget>[
      ?mineCard,
      grabsCard,
      othersCard,
    ];
    return PageBody(children: [
      Reveal(index: 0, child: header),
      if (!online)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Glass(
            strong: true,
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Icon(Icons.history_toggle_off_rounded, color: t.warn),
              const SizedBox(width: 10),
              Expanded(child: Text(l.staleBanner)),
            ]),
          ),
        ),
      if (w >= Breakpoints.desktop)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final (i, c) in cols.indexed) ...[
            if (i > 0) const SizedBox(width: Gap.m),
            Expanded(child: Reveal(index: i + 1, child: c)),
          ],
        ])
      else
        for (final (i, c) in cols.indexed)
          Padding(padding: const EdgeInsets.only(bottom: Gap.m), child: Reveal(index: i + 1, child: c)),
      if (onPaper.isNotEmpty) ...[
        const SizedBox(height: Gap.m),
        Reveal(
          index: 5,
          child: Glass(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              CardTitle(l.onPaperTitle, trailing: Text('${onPaper.length}', style: Theme.of(context).textTheme.displaySmall)),
              Text(l.onPaperHelp, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 10),
              for (final o in onPaper)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    paperChip(context),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('${orderTitle(context, o)} · ${orderLine(o)}',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    KotPrintButton(order: o),
                    MarkReadyButton(order: o, onDone: () => ref.invalidate(kitchenBoardProvider)),
                  ]),
                ),
            ]),
          ),
        ),
      ],
      const SizedBox(height: Gap.m),
      Reveal(index: 6, child: readyCard),
    ]);
  }

  String _modeLabel(BuildContext context, String mode) {
    final l = AppLocalizations.of(context);
    return switch (mode) {
      'CHEF_ACCEPT' => l.modeChefAccept,
      'AUTO_ASSIGN' => l.modeAutoAssign,
      _ => l.modeAdminPrint,
    };
  }
}

/// My strict queue: the head is large and actionable; the rest are locked until it is ready.
class _MyQueue extends StatelessWidget {
  const _MyQueue({required this.chef, required this.max});
  final Map<String, dynamic> chef;
  final int max;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final queue = (chef['queue'] as List).cast<Map<String, dynamic>>();
    return NightPanel(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(l.myQueue, style: tt.titleLarge?.copyWith(color: t.onNight))),
          Text('${queue.length}/$max', style: tt.displaySmall?.copyWith(color: t.onNight)),
        ]),
        const SizedBox(height: 14),
        if (queue.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(chef['on_shift'] == true ? l.queueEmpty : l.offShiftBody,
                textAlign: TextAlign.center, style: tt.bodyMedium?.copyWith(color: t.nightDim)),
          )
        else
          for (final (i, o) in queue.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: i == 0 ? _HeadTicket(o: o) : _QueuedRow(o: o, position: i + 1),
            ),
      ]),
    );
  }
}

class _HeadTicket extends StatelessWidget {
  const _HeadTicket({required this.o});
  final Map<String, dynamic> o;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final cooking = o['status'] == 'PREPARING';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: t.night2, borderRadius: BorderRadius.circular(Rad.tile)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text('#${o['number']}', style: tt.displaySmall?.copyWith(color: t.onNight)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(orderPlace(context, o),
                style: tt.titleMedium?.copyWith(color: t.onNight)),
          ),
          OrderStatusChip(o['status'], solid: true),
        ]),
        const SizedBox(height: 6),
        _ElapsedLine(o: o, onNight: true),
        const SizedBox(height: 12),
        for (final it in (o['items'] as List))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 34,
                child: Text('${it['qty']}×', style: tt.titleMedium?.copyWith(color: t.accent)),
              ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(it['name'], style: tt.titleMedium?.copyWith(color: t.onNight)),
                  for (final d in orderLineDetails(it)) Text(d, style: tt.bodyMedium?.copyWith(color: t.nightDim)),
                  if (it['note'] != null) Text(it['note'], style: tt.bodySmall?.copyWith(color: t.warn)),
                ]),
              ),
            ]),
          ),
        if (o['note'] != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.sticky_note_2_outlined, size: 16, color: t.warn),
            const SizedBox(width: 6),
            Expanded(child: Text(o['note'], style: tt.bodySmall?.copyWith(color: t.warn))),
          ]),
        ],
        const SizedBox(height: 14),
        cooking
            ? _ActionButton(
                label: l.markReady,
                icon: Icons.check_rounded,
                path: '/api/v1/orders/${o['id']}/ready',
                done: l.markedReady,
                accent: true)
            : _ActionButton(
                label: l.startCooking,
                icon: Icons.local_fire_department_rounded,
                path: '/api/v1/orders/${o['id']}/start',
                done: l.started,
                accent: true),
      ]),
    );
  }
}

class _QueuedRow extends StatelessWidget {
  const _QueuedRow({required this.o, required this.position});
  final Map<String, dynamic> o;
  final int position;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final items = (o['items'] as List).map((i) => '${i['qty']}× ${i['name']}').join(', ');
    return Row(children: [
      Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: t.night2, shape: BoxShape.circle),
        child: Text('$position', style: tt.labelLarge?.copyWith(color: t.onNight)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(orderTitle(context, o),
              style: tt.bodyMedium?.copyWith(color: t.onNight)),
          Text(items, maxLines: 1, overflow: TextOverflow.ellipsis, style: tt.labelSmall?.copyWith(color: t.nightDim)),
        ]),
      ),
      Tooltip(message: l.lockedUntilHead, child: Icon(Icons.lock_outline_rounded, size: 18, color: t.nightDim)),
    ]);
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.o, this.action});
  final Map<String, dynamic> o;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.solid,
        borderRadius: BorderRadius.circular(Rad.tile),
        border: Border.all(color: t.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text('#${o['number']}', style: tt.titleLarge),
          const SizedBox(width: 8),
          Expanded(child: Text(orderPlace(context, o), style: tt.titleMedium)),
          StatusChip(icon: channelIcon(o['channel']), label: channelLabel(context, o['channel']), color: t.dim),
          KotPrintButton(order: o),
        ]),
        const SizedBox(height: 4),
        _ElapsedLine(o: o),
        const SizedBox(height: 8),
        for (final it in (o['items'] as List)) ...[
          Text('${it['qty']}×  ${it['name']}${it['note'] != null ? '  ·  ${it['note']}' : ''}', style: tt.bodyMedium),
          for (final d in orderLineDetails(it))
            Padding(padding: const EdgeInsets.only(left: 22), child: Text(d, style: tt.bodySmall)),
        ],
        if (o['note'] != null) Text(o['note'], style: tt.bodySmall?.copyWith(color: t.warn)),
        if (action != null) ...[const SizedBox(height: 12), action!],
      ]),
    );
  }
}

class _ElapsedLine extends StatelessWidget {
  const _ElapsedLine({required this.o, this.onNight = false});
  final Map<String, dynamic> o;
  final bool onNight;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final mins = minutesSince(o['started_at'] ?? o['created_at']);
    final late = mins > (o['est_prep_minutes'] as int? ?? 15);
    final color = late ? t.warn : (onNight ? t.nightDim : t.dim);
    return Row(children: [
      Icon(late ? Icons.timer_off_outlined : Icons.timer_outlined, size: 14, color: color),
      const SizedBox(width: 5),
      Text(
        o['started_at'] != null ? l.cookingFor(mins, o['est_prep_minutes']) : l.waitingFor(mins),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    ]);
  }
}

class _ChefLane extends ConsumerWidget {
  const _ChefLane({required this.chef, required this.manage});
  final Map<String, dynamic> chef;
  final bool manage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final queue = (chef['queue'] as List).cast<Map<String, dynamic>>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Avatar(chef['name'], size: 34),
          const SizedBox(width: 10),
          Expanded(child: Text(chef['name'], style: tt.titleMedium)),
          StatusChip(
            icon: chef['on_shift'] == true ? Icons.circle : Icons.circle_outlined,
            label: chef['on_shift'] == true ? l.onShift : l.offShift,
            color: chef['on_shift'] == true ? t.ok : t.faint,
          ),
        ]),
        const SizedBox(height: 8),
        if (queue.isEmpty)
          Padding(padding: const EdgeInsets.only(left: 44), child: Text(l.idle, style: tt.bodySmall))
        else
          for (final o in queue)
            Padding(
              padding: const EdgeInsets.only(left: 44, bottom: 6),
              child: Row(children: [
                Expanded(
                  child: Text(
                    '#${o['number']} · ${orderPlace(context, o)} · '
                    '${(o['items'] as List).map((i) => '${i['qty']}× ${i['name']}').join(', ')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),
                OrderStatusChip(o['status']),
                if (manage)
                  IconButton(
                    tooltip: l.returnToBoard,
                    icon: const Icon(Icons.undo_rounded, size: 18),
                    onPressed: () => _returnToBoard(context, ref, o),
                  ),
              ]),
            ),
        Divider(color: t.line),
      ]),
    );
  }

  Future<void> _returnToBoard(BuildContext context, WidgetRef ref, Map o) async {
    final l = AppLocalizations.of(context);
    final reason = TextEditingController();
    await showGlassDialog(
      context,
      title: l.returnToBoard,
      body: StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FieldLabel(l.reason, help: l.reasonAuditedHelp),
          TextField(controller: reason, autofocus: true),
          DialogActions(
            primary: l.returnToBoard,
            onPrimary: () async {
              final ok = await guard(ctx, () => ref.read(apiProvider).post('/api/v1/orders/${o['id']}/reassign', {
                    'reason': reason.text.trim().isEmpty ? '-' : reason.text.trim(),
                  }));
              if (ok && ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        ]),
      ),
    );
  }
}

class _ReadyPill extends ConsumerWidget {
  const _ReadyPill({required this.o, required this.canServe});
  final Map<String, dynamic> o;
  final bool canServe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: t.accentSoft,
        borderRadius: BorderRadius.circular(Rad.pill),
        border: Border.all(color: t.hair),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.notifications_active_rounded, size: 16, color: t.accentDeep),
        const SizedBox(width: 6),
        Text(orderTitle(context, o), style: tt.labelLarge),
        const SizedBox(width: 6),
        Text(l.minutesAgo(minutesSince(o['ready_at'])), style: tt.labelSmall),
        if (canServe) ...[
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
            onPressed: () => guard(context, () async {
              await ref.read(apiProvider).post('/api/v1/orders/${o['id']}/serve');
              ref.invalidate(kitchenBoardProvider);
            }),
            child: Text(l.serve),
          ),
        ],
      ]),
    );
  }
}

class _ShiftSwitch extends ConsumerWidget {
  const _ShiftSwitch({required this.chef});
  final Map<String, dynamic> chef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final on = chef['on_shift'] == true;
    return Glass(
      strong: true,
      padding: const EdgeInsets.fromLTRB(14, 2, 6, 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(on ? l.onShift : l.offShift, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(width: 6),
        Switch(
          value: on,
          onChanged: (v) => guard(context, () async {
            await ref.read(apiProvider).put('/api/v1/kitchen/chefs/${chef['id']}/shift', {'on_shift': v});
            ref.invalidate(kitchenBoardProvider);
          }),
        ),
      ]),
    );
  }
}

/// Button that POSTs, shows progress, refreshes the board and confirms with a snackbar.
class _ActionButton extends ConsumerStatefulWidget {
  const _ActionButton({required this.label, required this.icon, required this.path, required this.done, this.accent = false});
  final String label;
  final IconData icon;
  final String path;
  final String done;
  final bool accent;

  @override
  ConsumerState<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends ConsumerState<_ActionButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return FilledButton.icon(
      style: widget.accent
          ? FilledButton.styleFrom(backgroundColor: t.accent, foregroundColor: t.onAccent, minimumSize: const Size.fromHeight(48))
          : FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
      onPressed: _busy
          ? null
          : () async {
              setState(() => _busy = true);
              final ok = await guard(context, () => ref.read(apiProvider).post(widget.path));
              ref.invalidate(kitchenBoardProvider);
              if (mounted) {
                setState(() => _busy = false);
                if (ok) showDone(this.context, widget.done);
              }
            },
      icon: _busy
          ? SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: t.onNight))
          : Icon(widget.icon, size: 18),
      label: Text(widget.label),
    );
  }
}
