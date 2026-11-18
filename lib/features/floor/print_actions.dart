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

Future<void> showBillDialog(BuildContext context, Map table) {
  final l = AppLocalizations.of(context);
  return showGlassDialog(context, title: l.billForTable(table['label']), maxWidth: 520, body: _BillPanel(table: table));
}

class _BillPanel extends ConsumerStatefulWidget {
  const _BillPanel({required this.table});
  final Map table;

  @override
  ConsumerState<_BillPanel> createState() => _BillPanelState();
}

class _BillPanelState extends ConsumerState<_BillPanel> {
  Map<String, dynamic>? _bill;
  bool _loading = true;
  bool _busy = false;
  List? _unserved;

  @override
  void initState() {
    super.initState();
    _loadOpen();
  }

  Future<void> _loadOpen() async {
    try {
      final r = (await ref.read(apiProvider).get('/api/v1/bills?scope=open&table_id=${widget.table['id']}')) as List;
      if (mounted) setState(() => _bill = r.isEmpty ? null : Map<String, dynamic>.from(r.first));
    } catch (e) {
      if (mounted) showError(context, e);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _create({bool includeUnserved = false}) async {
    setState(() => _busy = true);
    try {
      final b = await ref.read(apiProvider).post('/api/v1/bills', {
        'table_id': widget.table['id'],
        'include_unserved': includeUnserved,
      });
      setState(() {
        _bill = Map<String, dynamic>.from(b);
        _unserved = null;
      });
    } on ApiException catch (e) {
      if (e.code == 'orders_not_served') {
        setState(() => _unserved = e.details['orders'] as List?);
      } else if (mounted) {
        showError(context, e);
      }
    }
    if (mounted) setState(() => _busy = false);
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
      await ref.read(apiProvider).post('/api/v1/bills/${_bill!['id']}/void', {
        'reason': reason.text.trim().length < 3 ? l.voidBill : reason.text.trim(),
      });
      setState(() => _bill = null);
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
        ],
      ]);
    }
    final paid = b['status'] == 'PAID';
    Widget row(String a, int v, {bool strong = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Expanded(child: Text(a, style: strong ? tt.titleMedium : tt.bodyMedium)),
            Text(formatInr(v), style: strong ? tt.titleMedium : tt.bodyMedium),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(b['invoice_no'], style: tt.titleLarge)),
        StatusChip(
          icon: paid ? Icons.check_circle_outline : Icons.pending_outlined,
          label: paid ? l.billPaid(b['payment_method']) : l.billUnpaid,
          color: paid ? t.ok : t.warn,
        ),
      ]),
      Text(l.ordersIncluded(b['orders'].join(', #')), style: tt.bodySmall),
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
      if (!paid) ...[
        FieldLabel(l.settlePayment),
        ChoiceRow<String>(
          options: [('CASH', l.payCash), ('UPI', l.payUpi), ('CARD', l.payCard)],
          value: '',
          onChanged: _settle,
        ),
      ],
      if (s.can('bill.void')) ...[
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
