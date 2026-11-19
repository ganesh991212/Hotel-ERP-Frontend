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
import '../floor/print_actions.dart';

/// Every order, not just open ones: served orders used to vanish with nowhere to look them up or bill them.
final _ordersProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, scope) async {
  final api = ref.read(apiProvider);
  return ((await api.get('/api/v1/orders?scope=$scope')) as List).cast<Map<String, dynamic>>();
});

const _open = {'PLACED', 'CONFIRMED', 'ASSIGNED', 'PREPARING', 'READY'};

enum _Filter { all, open, toBill, served, cancelled }

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  String _scope = 'today';
  _Filter _filter = _Filter.all;

  bool _matches(Map<String, dynamic> o, _Filter f) => switch (f) {
        _Filter.all => true,
        _Filter.open => _open.contains(o['status']),
        _Filter.toBill => o['status'] == 'SERVED' && o['bill_id'] == null,
        _Filter.served => o['status'] == 'SERVED',
        _Filter.cancelled => o['status'] == 'CANCELLED',
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final orders = ref.watch(_ordersProvider(_scope));
    final labels = {
      _Filter.all: l.all,
      _Filter.open: l.openOrders,
      _Filter.toBill: l.billPending,
      _Filter.served: l.statusServed,
      _Filter.cancelled: l.statusCancelled,
    };
    return PageBody(children: [
      Reveal(index: 0, child: PageHeading(l.tabOrders)),
      Reveal(
        index: 1,
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          CountChip(label: l.ordersToday2, count: null, selected: _scope == 'today', onTap: () => setState(() => _scope = 'today')),
          CountChip(label: l.all, count: null, selected: _scope == 'all', onTap: () => setState(() => _scope = 'all')),
        ]),
      ),
      const SizedBox(height: 10),
      orders.when(
        loading: () => const LoadingBlock(),
        error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
        data: (list) {
          final shown = list.where((o) => _matches(o, _filter)).toList();
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final f in _Filter.values)
                CountChip(
                  label: labels[f]!,
                  count: list.where((o) => _matches(o, f)).length,
                  selected: _filter == f,
                  onTap: () => setState(() => _filter = f),
                ),
            ]),
            const SizedBox(height: 12),
            if (shown.isEmpty)
              Glass(child: EmptyState(icon: Icons.receipt_long_outlined, title: l.noOrdersYet))
            else
              Glass(
                child: Column(children: [
                  for (final (i, o) in shown.indexed) ...[
                    if (i > 0) Divider(height: 1, color: context.tokens.hair),
                    _OrderRow(o: o, onChanged: () => ref.invalidate(_ordersProvider(_scope))),
                  ],
                ]),
              ),
          ]);
        },
      ),
    ]);
  }
}

class _OrderRow extends ConsumerWidget {
  const _OrderRow({required this.o, required this.onChanged});
  final Map<String, dynamic> o;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final s = ref.watch(sessionProvider).value!;
    final items = (o['items'] as List).map((i) => '${i['qty']}× ${i['name']}').join(', ');
    final next = nextStepText(context, o, kitchenMode: (s.me['outlet'] as Map?)?['kitchen_mode'] as String?);
    final toBill = o['status'] == 'SERVED' && o['bill_id'] == null && o['table'] != null && s.can('bill.manage');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        isPickupOverdue(o) ? const PickupOverdueChip() : OrderStatusChip(o['status']),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.orderNumberTable(o['number'], o['table']?['label'] ?? '-'), style: tt.titleSmall),
            Text(items, maxLines: 2, overflow: TextOverflow.ellipsis, style: tt.bodySmall),
            const SizedBox(height: 4),
            Wrap(spacing: 10, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(channelIcon(o['channel']), size: 14, color: t.dim),
                const SizedBox(width: 4),
                Text(channelLabel(context, o['channel']), style: tt.labelSmall),
              ]),
              Text(l.minutesAgo(minutesSince(o['created_at'])), style: tt.labelSmall),
              if (o['bill_id'] != null)
                StatusChip(icon: Icons.receipt_long_outlined, label: l.billed, color: t.faint),
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
          if (toBill) ...[
            const SizedBox(height: 6),
            FilledButton.icon(
              onPressed: () async {
                await showBillDialog(context, o['table'] as Map);
                onChanged();
              },
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: Text(l.billNow),
            ),
          ],
        ]),
      ]),
    );
  }
}
