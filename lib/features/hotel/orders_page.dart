import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';
import '../../ui/status.dart';
import '../floor/print_actions.dart';

/// Orders and the bills register. Lists grow every day, so they load one date range at a time (hotel-local days,
/// up to 31), 50 rows per page, with a search box; nothing older is fetched until someone asks for it.
const _pageSize = 50;
const _open = {'PLACED', 'CONFIRMED', 'ASSIGNED', 'PREPARING', 'READY'};

enum _View { orders, bills }

enum _OrderFilter { all, open, served, cancelled }

enum _BillFilter { all, unpaid, paid, cancelled }

/// Tables whose food is served but not paid: one Bill button per table (one bill per visit).
final _tablesToBillProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final list = ((await ref.read(apiProvider).get('/api/v1/tables')) as List).cast<Map<String, dynamic>>();
  return list.where((t) => t['state'] == 'BILL_PENDING').toList();
});

/// The hotel's own "today" (its timezone, not the phone's), from the server.
final _hotelTodayProvider = FutureProvider.autoDispose<DateTime>((ref) async {
  final me = await ref.read(apiProvider).get('/api/v1/dashboard/me?period=today');
  return DateTime.parse(me['to'] as String);
});

String _ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  _View _view = _View.orders;
  _OrderFilter _orderFilter = _OrderFilter.all;
  _BillFilter _billFilter = _BillFilter.all;
  DateTime? _from, _to; // null until the hotel's today is known
  final _search = TextEditingController();
  Timer? _debounce;

  final List<Map<String, dynamic>> _rows = [];
  bool _loading = false, _hasMore = false;
  Object? _error;
  int _generation = 0; // ignores answers to requests that a newer filter has superseded

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  String _query(int offset) {
    final p = <String, String>{
      'scope': 'all',
      'from': _ymd(_from!),
      'to': _ymd(_to!),
      'limit': '$_pageSize',
      'offset': '$offset',
      if (_search.text.trim().isNotEmpty) 'q': _search.text.trim(),
      if (_view == _View.bills && _billFilter != _BillFilter.all)
        'status': switch (_billFilter) {
          _BillFilter.unpaid => 'ISSUED',
          _BillFilter.paid => 'PAID',
          _ => 'VOID',
        },
    };
    final path = _view == _View.orders ? '/api/v1/orders' : '/api/v1/bills';
    return '$path?${Uri(queryParameters: p).query}';
  }

  Future<void> _load({bool more = false}) async {
    if (_from == null) return;
    final gen = more ? _generation : ++_generation;
    setState(() {
      _loading = true;
      _error = null;
      if (!more) _rows.clear();
    });
    try {
      final page = ((await ref.read(apiProvider).get(_query(more ? _rows.length : 0))) as List).cast<Map<String, dynamic>>();
      if (!mounted || gen != _generation) return;
      setState(() {
        _rows.addAll(page);
        _hasMore = page.length == _pageSize;
      });
    } catch (e) {
      if (mounted && gen == _generation) setState(() => _error = e);
    }
    if (mounted && gen == _generation) setState(() => _loading = false);
  }

  void _setRange(DateTime from, DateTime to) {
    setState(() {
      _from = from;
      _to = to;
    });
    _load();
  }

  Future<void> _pickRange(DateTime today) async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 7),
      lastDate: today,
      initialDateRange: DateTimeRange(start: _from!, end: _to!),
    );
    if (r == null || !mounted) return;
    if (r.end.difference(r.start).inDays > 30) {
      showWarning(context, AppLocalizations.of(context).errRangeTooLong);
      return;
    }
    _setRange(r.start, r.end);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final today = ref.watch(_hotelTodayProvider).value;
    if (today != null && _from == null) {
      _from = _to = today;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
    final yesterday = today?.subtract(const Duration(days: 1));
    bool isDay(DateTime? d) => d != null && _from == d && _to == d;
    final custom = today != null && !isDay(today) && !isDay(yesterday);
    final fmt = DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag());

    return PageBody(children: [
      Reveal(index: 0, child: PageHeading(l.tabOrders)),
      Reveal(
        index: 1,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: PillTabs<_View>(
            items: [(_View.orders, l.viewOrders), (_View.bills, l.viewBills)],
            selected: _view,
            onSelect: (v) {
              setState(() => _view = v);
              _load();
            },
          ),
        ),
      ),
      const SizedBox(height: 12),
      if (today != null)
        Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          CountChip(label: l.ordersToday2, count: null, selected: isDay(today), onTap: () => _setRange(today, today)),
          CountChip(label: l.yesterday, count: null, selected: isDay(yesterday), onTap: () => _setRange(yesterday!, yesterday)),
          CountChip(
            label: custom ? '${fmt.format(_from!)} – ${fmt.format(_to!)}' : l.pickDates,
            count: null,
            selected: custom,
            onTap: () => _pickRange(today),
          ),
        ]),
      const SizedBox(height: 10),
      TextField(
        controller: _search,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: _view == _View.orders ? l.searchOrdersHint : l.searchBillsHint,
        ),
        onChanged: (_) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 350), _load);
        },
      ),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        if (_view == _View.orders)
          for (final (f, label) in [
            (_OrderFilter.all, l.all),
            (_OrderFilter.open, l.openOrders),
            (_OrderFilter.served, l.statusServed),
            (_OrderFilter.cancelled, l.statusCancelled),
          ])
            CountChip(label: label, count: null, selected: _orderFilter == f, onTap: () => setState(() => _orderFilter = f))
        else
          for (final (f, label) in [
            (_BillFilter.all, l.all),
            (_BillFilter.unpaid, l.billUnpaid),
            (_BillFilter.paid, l.statusPaid),
            (_BillFilter.cancelled, l.billCancelled),
          ])
            CountChip(
              label: label,
              count: null,
              selected: _billFilter == f,
              onTap: () {
                setState(() => _billFilter = f);
                _load();
              },
            ),
      ]),
      const SizedBox(height: 12),
      if (_view == _View.orders && isDay(today)) const _TablesToBill(),
      if (_error != null)
        EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, _error!))
      else if (_rows.isEmpty && _loading)
        const LoadingBlock()
      else ...[
        _list(context),
        if (_hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: OutlinedButton(
                onPressed: _loading ? null : () => _load(more: true),
                child: _loading
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: t.dim))
                    : Text(l.loadMore),
              ),
            ),
          ),
      ],
    ]);
  }

  Widget _list(BuildContext context) {
    final l = AppLocalizations.of(context);
    final shown = _view == _View.bills
        ? _rows
        : _rows.where((o) => switch (_orderFilter) {
              _OrderFilter.all => true,
              _OrderFilter.open => _open.contains(o['status']),
              _OrderFilter.served => o['status'] == 'SERVED',
              _OrderFilter.cancelled => o['status'] == 'CANCELLED',
            }).toList();
    if (shown.isEmpty) {
      return Glass(
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: _view == _View.orders ? l.noOrdersYet : l.noBillsYet,
        ),
      );
    }
    return Glass(
      child: Column(children: [
        for (final (i, r) in shown.indexed) ...[
          if (i > 0) Divider(height: 1, color: context.tokens.hair),
          _view == _View.orders ? _OrderRow(o: r) : _BillRow(b: r, onChanged: _load),
        ],
      ]),
    );
  }
}

class _TablesToBill extends ConsumerWidget {
  const _TablesToBill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final s = ref.watch(sessionProvider).value;
    final tables = ref.watch(_tablesToBillProvider).value ?? const [];
    if (s == null || tables.isEmpty || !s.can('bill.manage')) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          CardTitle(l.tablesToBill, trailing: Text('${tables.length}', style: tt.titleLarge)),
          const SizedBox(height: 8),
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (final t in tables)
              FilledButton.icon(
                onPressed: () async {
                  await showBillDialog(context, t);
                  ref.invalidate(_tablesToBillProvider);
                },
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: Text('${l.tableLabel(t['label'])} · ${formatInr(t['unbilled_total_minor'] ?? 0, showPaise: false)}'),
              ),
          ]),
        ]),
      ),
    );
  }
}

class _OrderRow extends ConsumerWidget {
  const _OrderRow({required this.o});
  final Map<String, dynamic> o;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final s = ref.watch(sessionProvider).value;
    if (s == null) return const SizedBox.shrink();
    final items = (o['items'] as List).map((i) => '${i['qty']}× ${i['name']}').join(', ');
    final next = nextStepText(context, o, kitchenMode: (s.me['outlet'] as Map?)?['kitchen_mode'] as String?);
    final billed = o['bill_id'] != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        isPickupOverdue(o) ? const PickupOverdueChip() : OrderStatusChip(o['status']),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(orderTitle(context, o), style: tt.titleSmall),
            Text(items, maxLines: 2, overflow: TextOverflow.ellipsis, style: tt.bodySmall),
            const SizedBox(height: 4),
            Wrap(spacing: 10, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(channelIcon(o['channel']), size: 14, color: t.dim),
                const SizedBox(width: 4),
                Text(channelLabel(context, o['channel']), style: tt.labelSmall),
              ]),
              Text(l.minutesAgo(minutesSince(o['created_at'])), style: tt.labelSmall),
            ]),
            if (next != null) ...[
              const SizedBox(height: 4),
              Text(next, style: tt.labelMedium?.copyWith(color: t.accentDeep)),
            ],
          ]),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(formatInr(o['total_minor'] ?? 0), style: tt.titleSmall),
          // Billing happens per table (Tables to bill), never per order; billed orders link to their bill.
          if (billed && s.can('bill.manage'))
            TextButton.icon(
              onPressed: () => showBillById(context, ref, o['bill_id'] as String),
              icon: const Icon(Icons.receipt_long_outlined, size: 16),
              label: Text(l.openBill),
            ),
        ]),
      ]),
    );
  }
}

class _BillRow extends ConsumerWidget {
  const _BillRow({required this.b, required this.onChanged});
  final Map<String, dynamic> b;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final status = b['status'] as String;
    final chip = switch (status) {
      'PAID' => StatusChip(icon: Icons.check_circle_outline, label: l.billPaid(payMethodLabel(context, b['payment_method'])), color: t.ok),
      'VOID' => StatusChip(icon: Icons.cancel_outlined, label: l.billCancelled, color: t.danger),
      _ => StatusChip(icon: Icons.pending_outlined, label: l.billUnpaid, color: t.warn),
    };
    return InkWell(
      onTap: () async {
        await showBillById(context, ref, b['id'] as String);
        onChanged();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b['invoice_no'], style: tt.titleSmall),
              const SizedBox(height: 2),
              Text(
                '${l.tableLabel(b['table_label'] ?? '-')} · ${l.minutesAgo(minutesSince(b['created_at']))}',
                style: tt.labelSmall,
              ),
              if (status == 'VOID' && b['void_reason'] != null)
                Text(b['void_reason'], maxLines: 2, overflow: TextOverflow.ellipsis, style: tt.labelSmall?.copyWith(color: t.danger)),
              const SizedBox(height: 6),
              chip,
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(formatInr(b['total_minor'] ?? 0), style: tt.titleSmall),
            if ((b['print_count'] ?? 0) > 0)
              Text(l.printedTimes(b['print_count'] as int), style: tt.labelSmall),
          ]),
        ]),
      ),
    );
  }
}
