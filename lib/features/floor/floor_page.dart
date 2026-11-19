import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';
import '../../ui/status.dart';
import 'print_actions.dart';

final _tablesProvider = liveProvider<List<Map<String, dynamic>>>(
    (api) async => ((await api.get('/api/v1/tables')) as List).cast<Map<String, dynamic>>());
/// Open orders plus served orders not billed yet ("attention" scope): the next step for those is the bill.
final _openOrdersProvider = liveProvider<List<Map<String, dynamic>>>(
  (api) async => ((await api.get('/api/v1/orders?scope=attention')) as List).cast<Map<String, dynamic>>(),
  poll: const Duration(seconds: 15),
);
final menuDataProvider = FutureProvider.autoDispose<(List<Map<String, dynamic>>, List<Map<String, dynamic>>)>((ref) async {
  final api = ref.read(apiProvider);
  final cats = ((await api.get('/api/v1/categories')) as List).cast<Map<String, dynamic>>();
  final items = ((await api.get('/api/v1/items')) as List).cast<Map<String, dynamic>>();
  return (cats, items);
});

String newClientRef() {
  final r = Random.secure();
  return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

class FloorPage extends ConsumerStatefulWidget {
  const FloorPage({super.key});

  @override
  ConsumerState<FloorPage> createState() => _FloorPageState();
}

class _FloorPageState extends ConsumerState<FloorPage> {
  String _area = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(sessionProvider).value!;
    final tables = ref.watch(_tablesProvider);
    final orders = ref.watch(_openOrdersProvider).value ?? const [];
    final placed = orders.where((o) => o['status'] == 'PLACED').toList();
    final ready = orders.where((o) => o['status'] == 'READY').toList();
    // Nobody picked these up in time (server alert): first, so someone acts.
    final overdue = orders.where(isPickupOverdue).toList();
    // Waiting for a chef: printable as KOT when nobody in the kitchen is picking up on a screen.
    final waiting = s.can('kot.print')
        ? orders.where((o) => o['status'] == 'CONFIRMED' && !isPickupOverdue(o)).toList()
        : <Map<String, dynamic>>[];
    final onPaper = orders.where((o) => o['on_paper'] == true && o['status'] == 'PREPARING').toList();
    // Served, not billed: the table still owes money.
    final toBill = s.can('bill.manage') ? orders.where((o) => o['status'] == 'SERVED').toList() : <Map<String, dynamic>>[];
    final attention = [...overdue, ...ready, ...placed, ...onPaper, ...waiting, ...toBill];

    return PageBody(children: [
      Reveal(index: 0, child: PageHeading(l.tabFloor)),
      Reveal(
        index: 1,
        child: Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CardTitle(l.needsAttention, trailing: Text('${attention.length}', style: Theme.of(context).textTheme.displaySmall)),
            const SizedBox(height: 10),
            if (attention.isEmpty)
              Text(l.allCalm, style: Theme.of(context).textTheme.bodySmall)
            else
              for (final o in attention) _AttentionRow(o: o, session: s),
          ]),
        ),
      ),
      const SizedBox(height: Gap.m),
      tables.when(
        loading: () => const LoadingBlock(),
        error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
        data: (list) {
          final areas = <String>{for (final t in list) t['area'] ?? ''}.where((a) => a.isNotEmpty).toList()..sort();
          final shown = _area.isEmpty ? list : list.where((t) => t['area'] == _area).toList();
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (areas.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  CountChip(label: l.all, count: list.length, selected: _area.isEmpty, onTap: () => setState(() => _area = '')),
                  for (final a in areas)
                    CountChip(
                      label: a,
                      count: list.where((t) => t['area'] == a).length,
                      selected: _area == a,
                      onTap: () => setState(() => _area = a),
                    ),
                ]),
              ),
            if (shown.isEmpty)
              Glass(child: EmptyState(icon: Icons.table_restaurant_outlined, title: l.noTables, body: l.noTablesBody))
            else
              LayoutBuilder(builder: (context, c) {
                final cols = (c.maxWidth / (context.isPhone ? 160 : 210)).floor().clamp(2, 8);
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: [
                    for (final (i, t) in shown.indexed)
                      Reveal(
                        index: 2 + i.clamp(0, 10),
                        child: _TableTile(
                          table: t,
                          orders: orders.where((o) => o['table']?['id'] == t['id'] && o['status'] != 'SERVED').toList(),
                          canOrder: s.can('order.create') && s.feature('WAITER_ORDERING'),
                        ),
                      ),
                  ],
                );
              }),
          ]);
        },
      ),
    ]);
  }
}

class _AttentionRow extends ConsumerWidget {
  const _AttentionRow({required this.o, required this.session});
  final Map<String, dynamic> o;
  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final isReady = o['status'] == 'READY';
    final items = (o['items'] as List).map((i) => '${i['qty']}× ${i['name']}').join(', ');
    final status = o['status'];
    final next = nextStepText(context, o, kitchenMode: (session.me['outlet'] as Map?)?['kitchen_mode'] as String?);
    final toBill = status == 'SERVED' && o['bill_id'] == null && o['table'] != null && session.can('bill.manage');
    final action = isReady
        ? (session.can('order.serve') ? (l.markServed, 'serve') : null)
        : status == 'PLACED' && session.can('order.confirm')
            ? (l.confirmOrder, 'confirm')
            : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        isPickupOverdue(o)
            ? const PickupOverdueChip()
            : o['on_paper'] == true && status == 'PREPARING'
                ? paperChip(context)
                : OrderStatusChip(o['status']),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.orderNumberTable(o['number'], o['table']?['label'] ?? '-'), style: tt.titleSmall),
            Text(items, maxLines: 1, overflow: TextOverflow.ellipsis, style: tt.bodySmall),
            if (next != null)
              Text(next,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelMedium?.copyWith(color: context.tokens.accentDeep)),
          ]),
        ),
        if (status == 'CONFIRMED') KotPrintButton(order: o),
        MarkReadyButton(order: o, onDone: () => ref.invalidate(_openOrdersProvider)),
        if (toBill)
          FilledButton.icon(
            onPressed: () async {
              await showBillDialog(context, o['table'] as Map);
              ref.invalidate(_openOrdersProvider);
              ref.invalidate(_tablesProvider);
            },
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: Text(l.billNow),
          ),
        if (action != null)
          FilledButton(
            onPressed: () => guard(context, () async {
              await ref.read(apiProvider).post('/api/v1/orders/${o['id']}/${action.$2}');
              ref.invalidate(_openOrdersProvider);
            }),
            child: Text(action.$1),
          ),
      ]),
    );
  }
}

class _TableTile extends StatelessWidget {
  const _TableTile({required this.table, required this.orders, required this.canOrder});
  final Map<String, dynamic> table;
  final List<Map<String, dynamic>> orders;
  final bool canOrder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final busy = orders.isNotEmpty || table['state'] == 'BILL_PENDING';
    final inactive = table['status'] != 'ACTIVE';
    final top = orders.isEmpty ? null : orders.first['status'] as String;
    return Glass(
      strong: busy,
      onTap: inactive ? null : () => showTableSheet(context, table, canOrder: canOrder),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(table['label'], style: tt.displaySmall),
          const Spacer(),
          Icon(busy ? Icons.restaurant_rounded : Icons.event_seat_outlined, color: busy ? t.accent : t.faint),
        ]),
        Text(table['area'] ?? '', style: tt.labelMedium),
        const Spacer(),
        Row(children: [
          Icon(Icons.chair_outlined, size: 14, color: t.dim),
          const SizedBox(width: 4),
          Text(l.seats(table['seats']), style: tt.labelMedium),
        ]),
        const SizedBox(height: 8),
        if (inactive)
          StatusChip(icon: Icons.block, label: l.inactive, color: t.faint)
        else if (top != null)
          OrderStatusChip(top)
        else if (table['state'] == 'BILL_PENDING')
          // Served but not paid: guests are still seated and owe this much (amount computed by the server).
          StatusChip(
            icon: Icons.receipt_long_outlined,
            label: '${l.billPending} · ${formatInr(table['unbilled_total_minor'] ?? 0, showPaise: false)}',
            color: t.warn,
          )
        else
          StatusChip(icon: Icons.check_circle_outline, label: l.free, color: t.ok),
      ]),
    );
  }
}

/// Table detail: open orders and the order composer.
Future<void> showTableSheet(BuildContext context, Map<String, dynamic> table, {required bool canOrder}) {
  final l = AppLocalizations.of(context);
  return showGlassDialog(
    context,
    title: l.tableLabel(table['label']),
    maxWidth: 720,
    body: OrderComposer(table: table, canOrder: canOrder),
  );
}

class OrderComposer extends ConsumerStatefulWidget {
  const OrderComposer({super.key, required this.table, required this.canOrder});
  final Map<String, dynamic> table;
  final bool canOrder;

  @override
  ConsumerState<OrderComposer> createState() => _OrderComposerState();
}

class _OrderComposerState extends ConsumerState<OrderComposer> {
  final Map<String, int> _qty = {};
  final _note = TextEditingController();
  final _search = TextEditingController();
  String _cat = '';
  Map<String, dynamic>? _quote;
  Timer? _debounce;
  bool _busy = false;
  String _clientRef = newClientRef();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _change(String id, int delta) {
    setState(() {
      final v = (_qty[id] ?? 0) + delta;
      if (v <= 0) {
        _qty.remove(id);
      } else {
        _qty[id] = v.clamp(1, 20);
      }
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _requote);
  }

  List<Map<String, dynamic>> get _lines => [for (final e in _qty.entries) {'item_id': e.key, 'qty': e.value}];

  Future<void> _requote() async {
    if (_qty.isEmpty) {
      setState(() => _quote = null);
      return;
    }
    try {
      final q = await ref.read(apiProvider).post('/api/v1/orders/quote', {'items': _lines});
      if (mounted) setState(() => _quote = Map<String, dynamic>.from(q));
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _place() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final ok = await guard(context, () async {
      await ref.read(apiProvider).post('/api/v1/orders', {
        'table_id': widget.table['id'],
        'items': _lines,
        if (_note.text.trim().isNotEmpty) 'note': _note.text.trim(),
        'client_ref': _clientRef, // same ref on retry => no duplicate order
      });
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ref.invalidate(_openOrdersProvider);
      _clientRef = newClientRef();
      Navigator.of(context).pop();
      showDone(context, l.orderSent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final orders = (ref.watch(_openOrdersProvider).value ?? const [])
        .where((o) => o['table']?['id'] == widget.table['id'])
        .toList();
    final menu = ref.watch(menuDataProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (ref.watch(sessionProvider).value!.can('bill.manage'))
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton.icon(
            onPressed: () => showBillDialog(context, widget.table),
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: Text(l.billTable),
          ),
        ),
      if (orders.isNotEmpty) ...[
        Text(l.openOrders, style: tt.titleMedium),
        const SizedBox(height: 6),
        for (final o in orders)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              OrderStatusChip(o['status']),
              const SizedBox(width: 10),
              Expanded(
                child: Text('#${o['number']} · ${(o['items'] as List).map((i) => '${i['qty']}× ${i['name']}').join(', ')}',
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              Text(formatInr(o['total_minor']), style: tt.labelLarge),
              KotPrintButton(order: o),
              MarkReadyButton(order: o, onDone: () => ref.invalidate(_openOrdersProvider)),
            ]),
          ),
        const SizedBox(height: 12),
        Divider(color: t.line),
      ],
      if (!widget.canOrder)
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l.cannotTakeOrders, style: tt.bodySmall))
      else
        menu.when(
          loading: () => const LoadingBlock(height: 160),
          error: (e, _) => Text(errorText(context, e)),
          data: (m) {
            final (cats, items) = m;
            final q = _search.text.trim().toLowerCase();
            final shown = items
                .where((i) => _cat.isEmpty || i['category_id'] == _cat)
                .where((i) => q.isEmpty || (i['name'] as String).toLowerCase().contains(q))
                .toList();
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 8),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.searchMenu),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  CountChip(label: l.all, count: null, selected: _cat.isEmpty, onTap: () => setState(() => _cat = '')),
                  for (final c in cats) ...[
                    const SizedBox(width: 8),
                    CountChip(label: c['name'], count: null, selected: _cat == c['id'], onTap: () => setState(() => _cat = c['id'])),
                  ],
                ]),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView(shrinkWrap: true, children: [
                  for (final i in shown)
                    _MenuLine(
                      item: i,
                      qty: _qty[i['id']] ?? 0,
                      onAdd: i['is_available'] == true ? () => _change(i['id'], 1) : null,
                      onRemove: () => _change(i['id'], -1),
                    ),
                ]),
              ),
              const SizedBox(height: 8),
              TextField(controller: _note, decoration: InputDecoration(hintText: l.kitchenNoteHint)),
              const SizedBox(height: 14),
              QuoteSummary(quote: _quote),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _qty.isEmpty || _busy || _quote == null ? null : _place,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(l.sendToKitchen),
              ),
            ]);
          },
        ),
    ]);
  }
}

class _MenuLine extends StatelessWidget {
  const _MenuLine({required this.item, required this.qty, required this.onAdd, required this.onRemove});
  final Map<String, dynamic> item;
  final int qty;
  final VoidCallback? onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final available = item['is_available'] == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        VegMark(veg: item['is_veg'] == true),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['name'], style: tt.bodyMedium?.copyWith(color: available ? t.ink : t.faint)),
            Text(available ? formatInr(item['price_minor']) : l.soldOut, style: tt.labelSmall),
          ]),
        ),
        QtyStepper(qty: qty, onAdd: onAdd, onRemove: onRemove),
      ]),
    );
  }
}

class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.qty, required this.onAdd, required this.onRemove});
  final int qty;
  final VoidCallback? onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    if (qty == 0) {
      return OutlinedButton(
        onPressed: onAdd,
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        child: Text(l.add),
      );
    }
    return Container(
      decoration: BoxDecoration(color: t.night, borderRadius: BorderRadius.circular(Rad.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
            tooltip: l.decrease,
            onPressed: onRemove,
            icon: Icon(Icons.remove_rounded, size: 18, color: t.onNight),
            visualDensity: VisualDensity.compact),
        Text('$qty', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: t.onNight)),
        IconButton(
            tooltip: l.increase,
            onPressed: onAdd,
            icon: Icon(Icons.add_rounded, size: 18, color: t.onNight),
            visualDensity: VisualDensity.compact),
      ]),
    );
  }
}

/// Indian veg/non-veg mark: square outline with a dot (green) or triangle (brown), plus a label for
/// screen readers so the meaning is not colour-only.
class VegMark extends StatelessWidget {
  const VegMark({super.key, required this.veg});
  final bool veg;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final c = veg ? t.ok : t.danger;
    return Semantics(
      label: veg ? l.veg : l.nonVeg,
      child: Container(
        width: 16,
        height: 16,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(border: Border.all(color: c, width: 1.4), borderRadius: BorderRadius.circular(3)),
        child: veg
            ? DecoratedBox(decoration: BoxDecoration(color: c, shape: BoxShape.circle))
            : CustomPaint(painter: _TrianglePainter(c)),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawPath(
        Path()
          ..moveTo(s.width / 2, 0)
          ..lineTo(s.width, s.height)
          ..lineTo(0, s.height)
          ..close(),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter o) => o.color != color;
}

/// Totals exactly as the server computed them.
class QuoteSummary extends StatelessWidget {
  const QuoteSummary({super.key, required this.quote});
  final Map<String, dynamic>? quote;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final q = quote;
    if (q == null) return const SizedBox.shrink();
    Widget row(String a, int v, {bool strong = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Expanded(child: Text(a, style: strong ? tt.titleMedium : tt.bodyMedium)),
            Text(formatInr(v), style: strong ? tt.titleMedium : tt.bodyMedium),
          ]),
        );
    return Column(children: [
      row(l.subtotal, q['subtotal_minor']),
      if ((q['tax_minor'] as int) > 0) row(l.tax, q['tax_minor']),
      if ((q['service_charge_minor'] as int) > 0) row(l.serviceCharge, q['service_charge_minor']),
      row(l.total, q['total_minor'], strong: true),
    ]);
  }
}
