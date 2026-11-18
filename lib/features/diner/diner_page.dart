import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/api_client.dart';
import '../../core/api/realtime.dart';
import '../../core/auth/session.dart';
import '../../core/l10n/locale.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/status.dart';
import '../floor/floor_page.dart' show QtyStepper, QuoteSummary, VegMark, newClientRef;

/// Public page opened by scanning a table QR. Sends item ids and quantities only; every amount
/// shown is computed by the server.
class DinerPage extends ConsumerStatefulWidget {
  const DinerPage({super.key, required this.qrToken});
  final String qrToken;

  @override
  ConsumerState<DinerPage> createState() => _DinerPageState();
}

class _DinerPageState extends ConsumerState<DinerPage> {
  Map<String, dynamic>? _menu;
  Object? _error;
  String? _session;
  final Map<String, int> _qty = {};
  Map<String, dynamic>? _quote;
  List<Map<String, dynamic>> _orders = [];
  RealtimeChannel? _ws;
  StreamSubscription? _wsSub;
  Timer? _debounce;
  String _cat = '';
  final _scroll = ScrollController();
  final _catKeys = <String, GlobalKey>{};
  VoidCallback? _quoteListener; // rebuilds the open cart dialog when a fresh server quote lands

  ApiClient get _api => ref.read(apiProvider);
  String get _prefKey => 'diner.session.${widget.qrToken}';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _ws?.close();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _boot() async {
    try {
      final m = Map<String, dynamic>.from(await _api.public('GET', '/api/v1/d/${widget.qrToken}'));
      setState(() => _menu = m);
      final p = await SharedPreferences.getInstance();
      _session = p.getString(_prefKey);
      if (_session != null) await _refreshOrders();
    } catch (e) {
      setState(() => _error = e);
    }
  }

  Future<String> _ensureSession() async {
    if (_session != null) return _session!;
    final r = await _api.public('POST', '/api/v1/d/${widget.qrToken}/session');
    _session = r['session_token'];
    (await SharedPreferences.getInstance()).setString(_prefKey, _session!);
    _listen();
    return _session!;
  }

  void _listen() {
    if (_ws != null || _session == null) return;
    _ws = RealtimeChannel('/ws/d', () => _session ?? '')..connect();
    _wsSub = _ws!.events.listen((ev) {
      if (ev['order'] != null || ev['type'] == 'resync') _refreshOrders();
    });
  }

  Future<void> _refreshOrders() async {
    try {
      final r = await _api.public('GET', '/api/v1/d/orders/mine', headers: {'X-Diner-Token': _session!});
      if (!mounted) return;
      setState(() => _orders = (r as List).cast<Map<String, dynamic>>());
      _listen();
    } on ApiException catch (e) {
      if (e.code == 'session_expired' || e.code == 'no_session') {
        _session = null;
        (await SharedPreferences.getInstance()).remove(_prefKey);
      }
    }
  }

  void _change(String id, int d) {
    setState(() {
      final v = (_qty[id] ?? 0) + d;
      v <= 0 ? _qty.remove(id) : _qty[id] = v.clamp(1, 20);
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (_qty.isEmpty) return setState(() => _quote = null);
      try {
        final q = await _api.public('POST', '/api/v1/d/${widget.qrToken}/quote', body: {'items': _lines});
        if (mounted) setState(() => _quote = Map<String, dynamic>.from(q));
        _quoteListener?.call();
      } catch (e) {
        if (mounted) showError(context, e);
      }
    });
  }

  List<Map<String, dynamic>> get _lines => [for (final e in _qty.entries) {'item_id': e.key, 'qty': e.value}];

  int get _count => _qty.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    if (_error != null) {
      return Scaffold(
        body: AppBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Glass(child: EmptyState(icon: Icons.qr_code_scanner_rounded, title: l.qrInvalid, body: l.qrInvalidBody)),
            ),
          ),
        ),
      );
    }
    final m = _menu;
    if (m == null) return const Scaffold(body: AppBackground(child: LoadingBlock(height: 600)));
    final cats = (m['categories'] as List).cast<Map<String, dynamic>>().where((c) => (c['items'] as List).isNotEmpty).toList();
    for (final c in cats) {
      _catKeys.putIfAbsent(c['id'], GlobalKey.new);
    }
    final ordering = m['ordering_enabled'] == true;
    final live = _orders.where((o) => o['status'] != 'SERVED' && o['status'] != 'CANCELLED').toList();

    return Scaffold(
      backgroundColor: t.bgTop,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Stack(children: [
                CustomScrollView(controller: _scroll, slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Reveal(
                        index: 0,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(m['hotel']['name'], style: tt.titleLarge)),
                            const LanguageButton(),
                            const SizedBox(width: 8),
                            StatusChip(
                                icon: Icons.table_restaurant_outlined,
                                label: l.tableLabel(m['table']['label']),
                                color: t.accentDeep),
                          ]),
                          const SizedBox(height: 10),
                          Text(l.dinerHeadline, style: tt.displaySmall),
                          if (!ordering)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(l.dinerViewOnly, style: tt.bodySmall),
                            ),
                        ]),
                      ),
                    ),
                  ),
                  if (live.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      sliver: SliverToBoxAdapter(child: Reveal(index: 1, child: _Tracker(orders: live))),
                    ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CatBar(
                      child: Container(
                        color: t.bgTop.withValues(alpha: .92),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            for (final c in cats) ...[
                              CountChip(
                                label: c['name'],
                                count: (c['items'] as List).length,
                                selected: _cat == c['id'],
                                onTap: () {
                                  setState(() => _cat = c['id']);
                                  final ctx = _catKeys[c['id']]!.currentContext;
                                  if (ctx != null) {
                                    Scrollable.ensureVisible(ctx, duration: Motion.medium, curve: Motion.ease, alignment: .05);
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                          ]),
                        ),
                      ),
                    ),
                  ),
                  for (final (ci, c) in cats.indexed)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Reveal(
                          index: 2 + ci,
                          child: Glass(
                            key: _catKeys[c['id']],
                            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              Text(c['name'], style: tt.titleLarge),
                              const SizedBox(height: 6),
                              for (final i in (c['items'] as List).cast<Map<String, dynamic>>())
                                _DishRow(
                                  item: i,
                                  qty: _qty[i['id']] ?? 0,
                                  ordering: ordering,
                                  onAdd: () => _change(i['id'], 1),
                                  onRemove: () => _change(i['id'], -1),
                                ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ]),
                if (_count > 0)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _CartBar(
                      count: _count,
                      total: _quote?['total_minor'] as int?,
                      onOpen: () => _openCart(context),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCart(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final note = TextEditingController();
    final clientRef = newClientRef();
    var busy = false;
    final items = {
      for (final c in (_menu!['categories'] as List))
        for (final i in (c['items'] as List)) i['id']: i,
    };
    await showGlassDialog(
      context,
      title: l.yourOrder,
      body: StatefulBuilder(builder: (ctx, set) {
        _quoteListener = () {
          if (ctx.mounted) set(() {});
        };
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final e in _qty.entries.toList())
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                VegMark(veg: items[e.key]['is_veg'] == true),
                const SizedBox(width: 10),
                Expanded(child: Text(items[e.key]['name'])),
                QtyStepper(
                  qty: e.value,
                  onAdd: () => set(() => _change(e.key, 1)),
                  onRemove: () {
                    set(() => _change(e.key, -1));
                    if (_qty.isEmpty) Navigator.of(ctx).pop();
                  },
                ),
              ]),
            ),
          const SizedBox(height: 8),
          TextField(controller: note, decoration: InputDecoration(hintText: l.dinerNoteHint)),
          const SizedBox(height: 12),
          QuoteSummary(quote: _quote),
          const SizedBox(height: 4),
          Text(l.pricesByRestaurant, style: Theme.of(ctx).textTheme.labelSmall),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy || _quote == null
                ? null
                : () async {
                    set(() => busy = true);
                    try {
                      final token = await _ensureSession();
                      await _api.public('POST', '/api/v1/d/orders', headers: {'X-Diner-Token': token}, body: {
                        'items': _lines,
                        if (note.text.trim().isNotEmpty) 'note': note.text.trim(),
                        'client_ref': clientRef,
                      });
                      setState(() {
                        _qty.clear();
                        _quote = null;
                      });
                      await _refreshOrders();
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (mounted) {
                        showDone(this.context, l.orderPlaced);
                        _scroll.animateTo(0, duration: Motion.medium, curve: Motion.ease);
                      }
                    } catch (e) {
                      if (ctx.mounted) showError(ctx, e);
                      set(() => busy = false);
                    }
                  },
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(l.placeOrder),
          ),
        ]);
      }),
    );
    _quoteListener = null;
  }
}

class _CatBar extends SliverPersistentHeaderDelegate {
  _CatBar({required this.child});
  final Widget child;

  @override
  double get minExtent => 62;
  @override
  double get maxExtent => 62;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _CatBar old) => true;
}

class _DishRow extends StatelessWidget {
  const _DishRow({required this.item, required this.qty, required this.ordering, required this.onAdd, required this.onRemove});
  final Map<String, dynamic> item;
  final int qty;
  final bool ordering;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final available = item['is_available'] == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 3), child: VegMark(veg: item['is_veg'] == true)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['name'], style: tt.titleMedium?.copyWith(color: available ? t.ink : t.faint)),
            const SizedBox(height: 2),
            Text(formatInr(item['price_minor']), style: tt.bodyMedium),
            if (item['description'] != null)
              Padding(padding: const EdgeInsets.only(top: 4), child: Text(item['description'], style: tt.bodySmall)),
          ]),
        ),
        const SizedBox(width: 10),
        if (!available)
          StatusChip(icon: Icons.remove_circle_outline, label: l.soldOut, color: t.warn)
        else if (ordering)
          QtyStepper(qty: qty, onAdd: onAdd, onRemove: onRemove),
      ]),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.count, required this.total, required this.onOpen});
  final int count;
  final int? total;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: t.night,
      borderRadius: BorderRadius.circular(Rad.pill),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(Rad.pill),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 14, 14),
          child: Row(children: [
            Text(l.itemsCount(count), style: tt.titleMedium?.copyWith(color: t.onNight)),
            if (total != null) ...[
              Text('  ·  ', style: tt.titleMedium?.copyWith(color: t.nightDim)),
              Text(formatInr(total!), style: tt.titleMedium?.copyWith(color: t.onNight)),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(Rad.pill)),
              child: Text(l.viewOrder, style: tt.labelLarge?.copyWith(color: t.onAccent)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Live order progress: Placed → Confirmed → Preparing → Ready, updated over WebSocket.
class _Tracker extends StatelessWidget {
  const _Tracker({required this.orders});
  final List<Map<String, dynamic>> orders;

  static const steps = ['PLACED', 'CONFIRMED', 'PREPARING', 'READY'];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    return NightPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.yourOrders, style: tt.titleLarge?.copyWith(color: t.onNight)),
        const SizedBox(height: 10),
        for (final o in orders) ...[
          Row(children: [
            Text('#${o['number']}', style: tt.titleMedium?.copyWith(color: t.onNight)),
            const SizedBox(width: 8),
            Expanded(
              child: Text((o['items'] as List).map((i) => '${i['qty']}× ${i['name']}').join(', '),
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: tt.bodySmall?.copyWith(color: t.nightDim)),
            ),
          ]),
          const SizedBox(height: 10),
          _Steps(status: o['status'] == 'ASSIGNED' ? 'CONFIRMED' : o['status']),
          if (o['chef'] != null && o['status'] == 'PREPARING')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.chefPreparing(o['chef']['name']), style: tt.bodySmall?.copyWith(color: t.nightDim)),
            ),
          if (o['status'] == 'READY')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.readyOnItsWay, style: tt.bodyMedium?.copyWith(color: t.accent)),
            ),
          const SizedBox(height: 14),
        ],
      ]),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final idx = _Tracker.steps.indexOf(status);
    return Row(children: [
      for (final (i, s) in _Tracker.steps.indexed) ...[
        Expanded(
          child: Column(children: [
            AnimatedContainer(
              duration: Motion.medium,
              curve: Motion.ease,
              height: 6,
              decoration: BoxDecoration(
                color: i <= idx ? t.accent : t.night2,
                borderRadius: BorderRadius.circular(Rad.pill),
              ),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(orderStatusLook(context, s).$1, size: 13, color: i <= idx ? t.onNight : t.nightDim),
              const SizedBox(width: 4),
              Flexible(
                child: Text(s == 'PLACED' ? AppLocalizations.of(context).stepSent : orderStatusLook(context, s).$2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: i <= idx ? t.onNight : t.nightDim)),
              ),
            ]),
          ]),
        ),
        if (i < _Tracker.steps.length - 1) const SizedBox(width: 6),
      ],
    ]);
  }
}
