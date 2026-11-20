import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/printing/print_service.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/status.dart';
import 'split_items.dart';

/// Prints a KOT. With [sendToKitchen] a waiting order moves to the paper path (leaves the chefs' board).
Future<void> printKot(BuildContext context, WidgetRef ref, Map order, {required bool sendToKitchen}) async {
  final l = AppLocalizations.of(context);
  await guard(context, () async {
    final settings = await PrintSettings.load();
    final r = Map<String, dynamic>.from(await ref.read(apiProvider).post('/api/v1/orders/${order['id']}/kot', {
      'send_to_kitchen': sendToKitchen,
      'paper_mm': settings.escposMm,
    }));
    await printDocument(r, title: 'KOT ${order['number']}', settings: settings);
    if (context.mounted) showDone(context, sendToKitchen && order['status'] == 'CONFIRMED' ? l.kotSentOnPaper : l.kotPrinted);
  });
}

/// Asks whether a waiting order should go to the kitchen on paper, then prints.
Future<void> printKotFlow(BuildContext context, WidgetRef ref, Map order) async {
  final l = AppLocalizations.of(context);
  if (order['status'] != 'CONFIRMED') return printKot(context, ref, order, sendToKitchen: false);
  await showGlassDialog(
    context,
    title: l.printKotTitle(order['number']),
    body: Builder(
      builder: (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.printKotExplain, style: Theme.of(ctx).textTheme.bodyMedium),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(ctx).pop();
            printKot(context, ref, order, sendToKitchen: true);
          },
          icon: const Icon(Icons.receipt_long_outlined, size: 18),
          label: Text(l.printAndSend),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            printKot(context, ref, order, sendToKitchen: false);
          },
          child: Text(l.printCopyOnly),
        ),
      ]),
    ),
  );
}

/// The table's bill for this visit: create it, update it when the guest ordered more, print, settle.
Future<void> showBillDialog(BuildContext context, Map table) {
  final l = AppLocalizations.of(context);
  return showGlassDialog(context, title: l.billForTable(table['label']), maxWidth: 520, body: _BillPanel(table: table));
}

/// A takeaway order's own bill (no table visit).
Future<void> showOrderBillDialog(BuildContext context, Map order) {
  final l = AppLocalizations.of(context);
  return showGlassDialog(
    context,
    title: l.billForOrder(orderTitle(context, order)),
    maxWidth: 520,
    body: _BillPanel(table: const {}, order: order),
  );
}

/// One specific bill from the register (paid or cancelled included): view and print again.
Future<void> showBillById(BuildContext context, WidgetRef ref, String billId) async {
  try {
    final b = Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/bills/$billId'));
    if (!context.mounted) return;
    await showGlassDialog(
      context,
      title: b['invoice_no'] as String,
      maxWidth: 520,
      body: _BillPanel(table: {'id': b['table_id'], 'label': b['table_label']}, initial: b),
    );
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

class _BillPanel extends ConsumerStatefulWidget {
  const _BillPanel({required this.table, this.initial, this.order});
  final Map table;

  /// Billing one takeaway order instead of a table visit.
  final Map? order;

  /// Opened from the bills register: show this bill as it is, without looking up the table's open bill.
  final Map<String, dynamic>? initial;

  @override
  ConsumerState<_BillPanel> createState() => _BillPanelState();
}

class _BillPanelState extends ConsumerState<_BillPanel> {
  Map<String, dynamic>? _bill;
  bool _loading = true;
  bool _busy = false;
  List? _unserved;

  /// Orders at this table not on any bill yet. With an unpaid bill open, these are what the guest ordered after
  /// it was issued: offer "Update bill" so the visit still ends with one bill.
  int _newOrders = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _bill = widget.initial;
      _loading = false;
    } else if (widget.order != null) {
      _loadForOrder();
    } else {
      _loadOpen();
    }
  }

  Future<void> _loadForOrder() async {
    final billId = widget.order!['bill_id'];
    try {
      if (billId != null) {
        final b = await ref.read(apiProvider).get('/api/v1/bills/$billId');
        if (mounted) setState(() => _bill = Map<String, dynamic>.from(b));
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadOpen() async {
    try {
      final api = ref.read(apiProvider);
      final r = (await api.get('/api/v1/bills?scope=open&table_id=${widget.table['id']}')) as List;
      final orders = (await api.get('/api/v1/orders?scope=attention&table_id=${widget.table['id']}')) as List;
      if (mounted) {
        setState(() {
          _bill = r.isEmpty ? null : Map<String, dynamic>.from(r.first);
          _newOrders = orders.where((o) => o['bill_id'] == null && o['status'] != 'PLACED').length;
        });
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _create({bool includeUnserved = false}) async {
    setState(() => _busy = true);
    try {
      final b = await ref.read(apiProvider).post('/api/v1/bills', {
        if (widget.order != null) 'order_id': widget.order!['id'] else 'table_id': widget.table['id'],
        'include_unserved': includeUnserved,
      });
      final replaced = (b['replaced_invoice_nos'] as List?)?.cast<String>() ?? const [];
      setState(() {
        _bill = Map<String, dynamic>.from(b);
        _unserved = null;
        _newOrders = 0;
      });
      if (replaced.isNotEmpty && mounted) {
        showDone(context, AppLocalizations.of(context).billReplaced(replaced.join(', '), b['invoice_no'] as String));
      }
    } on ApiException catch (e) {
      if (e.code == 'orders_not_served') {
        setState(() => _unserved = e.details['orders'] as List?);
      } else if (mounted) {
        showError(context, e);
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  /// One GST bill per guest (the server cancels this table's ordinary unpaid bill, if any).
  Future<void> _splitItems() async {
    final tableId = (widget.table['id'] ?? _bill?['table_id']) as String;
    final bills = await showSplitByItems(context, tableId);
    if (bills == null || bills.isEmpty || !mounted) return;
    setState(() {
      _bill = bills.first;
      _newOrders = 0;
      _unserved = null;
    });
  }

  Future<void> _openBill(String id) async {
    await guard(context, () async {
      final b = Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/bills/$id'));
      if (mounted) setState(() => _bill = b);
    });
  }

  Future<void> _print() async {
    final l = AppLocalizations.of(context);
    await guard(context, () async {
      final settings = await PrintSettings.load();
      final r = Map<String, dynamic>.from(await ref
          .read(apiProvider)
          .post('/api/v1/bills/${_bill!['id']}/print', {'paper_mm': settings.escposMm}));
      setState(() => _bill = r);
      await printDocument(r, title: r['invoice_no'], settings: settings);
      if (mounted) showDone(context, l.billPrinted);
    });
  }

  /// Discount on the bill shown: the server re-issues it (cancelled old bill, new number) with tax recalculated.
  Future<void> _discount() async {
    final l = AppLocalizations.of(context);
    final s = ref.read(sessionProvider).value!;
    final limit = (s.me['max_discount_bp'] as num?)?.toInt() ?? 0;
    final value = TextEditingController();
    final reason = TextEditingController();
    var byPercent = true;
    final ok = await showGlassDialog<bool>(
      context,
      title: l.addDiscount,
      body: StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ChoiceRow<bool>(
            options: [(true, l.discountByPercent), (false, l.discountByAmount)],
            value: byPercent,
            onChanged: (v) => set(() => byPercent = v),
          ),
          FieldLabel(l.discountValue, help: l.discountLimit(percentLabel(limit))),
          TextField(
            controller: value,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(suffixText: byPercent ? '%' : '₹'),
          ),
          FieldLabel(l.discountReason),
          TextField(controller: reason, maxLength: 200, decoration: const InputDecoration(counterText: '')),
          Text(l.discountHelp, style: Theme.of(ctx).textTheme.bodySmall),
          DialogActions(primary: l.addDiscount, onPrimary: () => Navigator.of(ctx).pop(true)),
        ]),
      ),
    );
    if (ok != true || !mounted) return;
    final bp = byPercent ? parsePercentToBp(value.text) : null;
    final amount = byPercent ? null : parseInrToMinor(value.text);
    if ((bp == null && amount == null) || (amount != null && amount <= 0) || reason.text.trim().length < 3) {
      showError(context, ApiException(400, 'bad_discount', ''));
      return;
    }
    setState(() => _busy = true);
    await guard(context, () async {
      final b = await ref.read(apiProvider).post('/api/v1/bills', {
        if (widget.order != null) 'order_id': widget.order!['id'] else 'table_id': _bill!['table_id'] ?? widget.table['id'],
        'include_unserved': true, // the bill being discounted already covers these orders
        'discount': {if (bp != null) 'percent_bp': bp else 'amount_minor': amount, 'reason': reason.text.trim()},
      });
      setState(() => _bill = Map<String, dynamic>.from(b));
      final replaced = (b['replaced_invoice_nos'] as List?)?.cast<String>() ?? const [];
      if (replaced.isNotEmpty && mounted) showDone(context, l.billReplaced(replaced.join(', '), b['invoice_no'] as String));
    });
    if (mounted) setState(() => _busy = false);
  }

  /// One part of the payment; the server marks the bill paid when nothing is due.
  Future<void> _payPart({int? prefillMinor}) async {
    final l = AppLocalizations.of(context);
    final amount = TextEditingController(text: prefillMinor == null ? '' : minorToInput(prefillMinor));
    final ref_ = TextEditingController();
    var method = 'CASH';
    final ok = await showGlassDialog<bool>(
      context,
      title: l.payPart,
      body: StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ChoiceRow<String>(
            options: [('CASH', l.payCash), ('UPI', l.payUpi), ('CARD', l.payCard)],
            value: method,
            onChanged: (v) => set(() => method = v),
          ),
          FieldLabel(l.amountReceived),
          TextField(
            controller: amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '₹ '),
          ),
          FieldLabel(l.paymentRef),
          TextField(controller: ref_, maxLength: 60, decoration: const InputDecoration(counterText: '')),
          DialogActions(primary: l.payPart, onPrimary: () => Navigator.of(ctx).pop(true)),
        ]),
      ),
    );
    if (ok != true || !mounted) return;
    final minor = parseInrToMinor(amount.text);
    if (minor == null || minor <= 0) return;
    setState(() => _busy = true);
    await guard(context, () async {
      final r = await ref.read(apiProvider).post('/api/v1/bills/${_bill!['id']}/payments', {
        'method': method,
        'amount_minor': minor,
        if (ref_.text.trim().isNotEmpty) 'reference': ref_.text.trim(),
      });
      setState(() => _bill = Map<String, dynamic>.from(r));
    });
    if (mounted) setState(() => _busy = false);
  }

  /// Equal shares of what is due (computed by the server); tapping a share records it as a part.
  Future<void> _split() async {
    final l = AppLocalizations.of(context);
    var parts = 2;
    List<int>? shares;
    await showGlassDialog<void>(
      context,
      title: l.splitEqually,
      body: StatefulBuilder(builder: (ctx, set) {
        Future<void> load() async {
          final r = await ref.read(apiProvider).get('/api/v1/bills/${_bill!['id']}/split?parts=$parts');
          set(() => shares = ((r['shares_minor'] as List).cast<num>()).map((e) => e.toInt()).toList());
        }

        if (shares == null) load();
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FieldLabel(l.howManyGuests),
          ChoiceRow<int>(
            options: [for (final n in const [2, 3, 4, 5, 6, 8, 10]) (n, '$n')],
            value: parts,
            onChanged: (v) {
              set(() {
                parts = v;
                shares = null;
              });
            },
          ),
          const SizedBox(height: 10),
          if (shares == null)
            const LoadingBlock(height: 60)
          else
            for (final (i, s) in shares!.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Expanded(child: Text(l.guestShare(i + 1, formatInr(s)))),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _payPart(prefillMinor: s);
                    },
                    child: Text(l.payThisShare),
                  ),
                ]),
              ),
        ]);
      }),
    );
  }

  Future<void> _removePayment(String paymentId) async {
    await guard(context, () async {
      final r = await ref.read(apiProvider).delete('/api/v1/bills/${_bill!['id']}/payments/$paymentId');
      setState(() => _bill = Map<String, dynamic>.from(r));
    });
  }

  Future<void> _settle(String method) async {
    await guard(context, () async {
      final r = await ref.read(apiProvider).post('/api/v1/bills/${_bill!['id']}/settle', {'method': method});
      setState(() => _bill = Map<String, dynamic>.from(r));
    });
  }

  Future<void> _void() async {
    final l = AppLocalizations.of(context);
    final reason = TextEditingController();
    final ok = await showGlassDialog<bool>(
      context,
      title: l.voidBill,
      body: Builder(
        builder: (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FieldLabel(l.reason, help: l.reasonAuditedHelp),
          TextField(controller: reason, autofocus: true),
          DialogActions(primary: l.voidBill, onPrimary: () => Navigator.of(ctx).pop(true)),
        ]),
      ),
    );
    if (ok != true || !mounted) return;
    await guard(context, () async {
      final r = await ref.read(apiProvider).post('/api/v1/bills/${_bill!['id']}/void', {
        'reason': reason.text.trim().length < 3 ? l.voidBill : reason.text.trim(),
      });
      // From the register: show it as cancelled. From the table: back to "create bill" for this visit.
      setState(() => _bill = widget.initial != null ? Map<String, dynamic>.from(r) : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final s = ref.watch(sessionProvider).value!;
    if (_loading) return const LoadingBlock(height: 160);
    final b = _bill;
    if (b == null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.billExplain, style: tt.bodyMedium),
        if (_unserved != null) ...[
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.warning_amber_rounded, color: t.warn),
            const SizedBox(width: 8),
            Expanded(child: Text(l.notServedYet(_unserved!.join(', #')))),
          ]),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: _busy ? null : () => _create(includeUnserved: true), child: Text(l.billAnyway)),
        ] else ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _create,
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: Text(l.createBill),
          ),
          if (widget.order == null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _splitItems,
              icon: const Icon(Icons.alt_route_rounded, size: 18),
              label: Text(l.splitByItems),
            ),
          ],
        ],
      ]);
    }
    final paid = b['status'] == 'PAID';
    final cancelled = b['status'] == 'VOID';
    final update = (!paid && !cancelled && _newOrders > 0)
        ? Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: t.warn.withValues(alpha: .12), borderRadius: BorderRadius.circular(Rad.tile)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Icon(Icons.add_circle_outline, color: t.warn),
                const SizedBox(width: 8),
                Expanded(child: Text(l.newOrdersSinceBill(_newOrders), style: tt.titleSmall)),
              ]),
              Text(l.updateBillHelp, style: tt.bodySmall),
              if (_unserved != null) ...[
                const SizedBox(height: 8),
                Text(l.notServedYet(_unserved!.join(', #'))),
                const SizedBox(height: 6),
                OutlinedButton(onPressed: _busy ? null : () => _create(includeUnserved: true), child: Text(l.billAnyway)),
              ] else ...[
                const SizedBox(height: 8),
                FilledButton(onPressed: _busy ? null : _create, child: Text(l.updateBill)),
              ],
            ]),
          )
        : null;
    // `minus` only adds a sign to the displayed text; the client never does arithmetic on money (rule 1).
    Widget row(String a, int v, {bool strong = false, bool minus = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Expanded(child: Text(a, style: strong ? tt.titleMedium : tt.bodyMedium)),
            Text('${minus ? '− ' : ''}${formatInr(v)}', style: strong ? tt.titleMedium : tt.bodyMedium),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ?update,
      Row(children: [
        Expanded(child: Text(b['invoice_no'], style: tt.titleLarge)),
        cancelled
            ? StatusChip(icon: Icons.cancel_outlined, label: l.billCancelled, color: t.danger)
            : StatusChip(
                icon: paid ? Icons.check_circle_outline : Icons.pending_outlined,
                label: paid ? l.billPaid(payMethodLabel(context, b['payment_method'])) : l.billUnpaid,
                color: paid ? t.ok : t.warn,
              ),
      ]),
      if (b['split'] != null)
        Text(l.guestNofM((b['split']['guest_no'] as num).toInt(), (b['split']['guest_count'] as num).toInt()),
            style: tt.titleSmall),
      if (cancelled && b['void_reason'] != null) Text(b['void_reason'], style: tt.bodySmall?.copyWith(color: t.danger)),
      Text(l.ordersIncluded(b['orders'].join(', #')), style: tt.bodySmall),
      if (b['split'] != null) ...[
        const SizedBox(height: 6),
        GuestBillsStrip(split: b['split'] as Map, currentId: b['id'] as String, onOpen: _openBill),
      ],
      const SizedBox(height: 10),
      for (final ln in (b['lines'] as List))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Expanded(child: Text('${ln['qty']} × ${ln['name']}')),
            Text(formatInr(ln['line_total_minor'])),
          ]),
        ),
      Divider(color: t.line),
      row(l.subtotal, b['subtotal_minor']),
      if ((b['discount_minor'] ?? 0) as int > 0) ...[
        row('${l.discount}${b['discount_reason'] != null ? ' · ${b['discount_reason']}' : ''}', b['discount_minor'] as int,
            minus: true),
        row(l.taxableValue, b['taxable_minor'] as int),
      ],
      if ((b['cgst_minor'] as int) > 0) row(l.cgst, b['cgst_minor']),
      if ((b['sgst_minor'] as int) > 0) row(l.sgst, b['sgst_minor']),
      if ((b['service_charge_minor'] as int) > 0) row(l.serviceCharge, b['service_charge_minor']),
      row(l.total, b['total_minor'], strong: true),
      const SizedBox(height: 14),
      FilledButton.icon(
        onPressed: _print,
        icon: const Icon(Icons.print_outlined, size: 18),
        label: Text((b['print_count'] as int) > 0 ? l.printDuplicate : l.printBill),
      ),
      // Guest bills of a split are not discounted (yet): the discount would not follow the guest's items.
      if (!paid && !cancelled && b['split'] == null && ((s.me['max_discount_bp'] as num?)?.toInt() ?? 0) > 0)
        TextButton.icon(
          onPressed: _busy ? null : _discount,
          icon: const Icon(Icons.percent_rounded, size: 18),
          label: Text(l.addDiscount),
        ),
      // Parts paid so far (removable until the bill is paid) and what is still due. Amounts come from the server.
      for (final p in (b['payments'] as List? ?? const []))
        Row(children: [
          Icon(Icons.check_circle_outline, size: 16, color: t.ok),
          const SizedBox(width: 6),
          Expanded(child: Text('${payMethodLabel(context, p['method'])}${p['reference'] != null ? ' · ${p['reference']}' : ''}')),
          Text(formatInr(p['amount_minor'] as int)),
          if (!paid && !cancelled)
            IconButton(
              tooltip: l.removePayment,
              visualDensity: VisualDensity.compact,
              onPressed: _busy ? null : () => _removePayment(p['id'] as String),
              icon: Icon(Icons.close_rounded, size: 18, color: t.dim),
            ),
        ]),
      if (!paid && !cancelled && ((b['paid_minor'] ?? 0) as int) > 0) ...[
        row(l.paidSoFar, b['paid_minor'] as int),
        row(l.dueNow, b['due_minor'] as int, strong: true),
      ],
      if (!paid && !cancelled) ...[
        FieldLabel(l.payWholeDue),
        ChoiceRow<String>(
          options: [('CASH', l.payCash), ('UPI', l.payUpi), ('CARD', l.payCard)],
          value: '',
          onChanged: _settle,
        ),
        Wrap(spacing: 8, children: [
          TextButton.icon(
            onPressed: _busy ? null : () => _payPart(),
            icon: const Icon(Icons.call_split_rounded, size: 18),
            label: Text(l.payPart),
          ),
          TextButton.icon(
            onPressed: _busy ? null : _split,
            icon: const Icon(Icons.groups_outlined, size: 18),
            label: Text(l.splitEqually),
          ),
          // A guest bill each, by what they had: only before any money is taken on the table's one bill.
          if (b['table_id'] != null &&
              b['split'] == null &&
              ((b['paid_minor'] ?? 0) as int) == 0 &&
              ((b['discount_minor'] ?? 0) as int) == 0)
            TextButton.icon(
              onPressed: _busy ? null : _splitItems,
              icon: const Icon(Icons.alt_route_rounded, size: 18),
              label: Text(l.splitByItems),
            ),
        ]),
      ],
      if (s.can('bill.void') && !cancelled) ...[
        const SizedBox(height: 8),
        TextButton(onPressed: _void, child: Text(l.voidBill, style: TextStyle(color: t.danger))),
      ],
    ]);
  }
}

/// Small print icon used on order rows and tickets.
class KotPrintButton extends ConsumerWidget {
  const KotPrintButton({super.key, required this.order});
  final Map order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider).value!;
    if (!s.can('kot.print')) return const SizedBox.shrink();
    return IconButton(
      tooltip: AppLocalizations.of(context).printKot,
      icon: Icon(Icons.print_outlined, size: 18, color: context.tokens.ink),
      onPressed: () => printKotFlow(context, ref, order),
    );
  }
}

/// "Mark ready" for paper-path orders (staff, not chefs).
class MarkReadyButton extends ConsumerWidget {
  const MarkReadyButton({super.key, required this.order, this.onDone});
  final Map order;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider).value!;
    if (order['on_paper'] != true || order['status'] != 'PREPARING' || !s.canAny(['order.serve', 'kitchen.manage'])) {
      return const SizedBox.shrink();
    }
    return FilledButton(
      onPressed: () => guard(context, () async {
        await ref.read(apiProvider).post('/api/v1/orders/${order['id']}/mark-ready');
        onDone?.call();
      }),
      child: Text(AppLocalizations.of(context).markReady),
    );
  }
}

String orderLine(Map o) => (o['items'] as List).map((i) => '${i['qty']}× ${i['name']}').join(', ');

Widget paperChip(BuildContext context) => StatusChip(
    icon: Icons.receipt_long_outlined, label: AppLocalizations.of(context).onPaper, color: context.tokens.info);
