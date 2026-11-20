import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import 'cart.dart';

/// Hold / resume (backend docs/03 "Hold / resume"): a cart saved on the server, not an order. The list is re-priced
/// by the server every time; a hold whose dish is gone or sold out comes with a `problem` instead of a quote.
final heldOrdersProvider = liveProvider<List<Map<String, dynamic>>>(
  (api) async => ((await api.get('/api/v1/held-orders')) as List).cast<Map>().map(Map<String, dynamic>.from).toList(),
  poll: const Duration(seconds: 30),
);

/// Holds for one table, or the takeaway / counter holds when [tableId] is null.
List<Map<String, dynamic>> heldFor(List<Map<String, dynamic>> all, String? tableId) =>
    all.where((h) => (h['table'] as Map?)?['id'] == tableId).toList();

/// Puts a hold's lines back into [cart] using today's menu. Returns the names of dishes no longer on the menu
/// (they are left out; the server's quote decides the price of everything else).
List<String> fillCartFromHeld(Cart cart, Map<String, dynamic> held, List<Map<String, dynamic>> menuItems) {
  final byId = {for (final i in menuItems) i['id'] as String: i};
  final priced = ((held['quote'] as Map?)?['lines'] as List?)?.cast<Map>() ?? const [];
  final missing = <String>[];
  for (final (n, raw) in ((held['items'] as List?) ?? const []).cast<Map>().indexed) {
    final item = byId[raw['item_id']];
    if (item == null) {
      missing.add(n < priced.length ? '${priced[n]['name']}' : '?');
      continue;
    }
    final variants = ((item['variants'] as List?) ?? const []).cast<Map>();
    final variant = variants.where((v) => v['id'] == raw['variant_id']).firstOrNull;
    final picks = <String, int>{
      for (final a in ((raw['addons'] as List?) ?? const []).cast<Map>()) a['addon_id'] as String: (a['qty'] as num).toInt(),
    };
    final names = <String, String>{};
    for (final g in ((item['addon_groups'] as List?) ?? const []).cast<Map>()) {
      for (final a in ((g['addons'] as List?) ?? const []).cast<Map>()) {
        names[a['id'] as String] = a['name'] as String;
      }
    }
    cart.put(CartLine(item, variant: variant, addons: picks, addonNames: names), (raw['qty'] as num).toInt());
  }
  return missing;
}

/// "Held 7:42 pm · Ravi · ₹520" chips: tap to resume, the cross to discard. Oldest first.
class HeldStrip extends StatelessWidget {
  const HeldStrip({super.key, required this.held, required this.onResume, required this.onDiscard});
  final List<Map<String, dynamic>> held;
  final void Function(Map<String, dynamic>) onResume;
  final void Function(Map<String, dynamic>) onDiscard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final time = DateFormat.jm(Localizations.localeOf(context).toLanguageTag());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.heldOrders, style: tt.titleSmall),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final h in held)
          InputChip(
            avatar: Icon(h['problem'] != null ? Icons.warning_amber_rounded : Icons.pause_circle_outline_rounded,
                size: 18, color: h['problem'] != null ? t.warn : t.dim),
            label: Text([
              l.heldAt(time.format(DateTime.parse(h['created_at'] as String).toLocal())),
              if (h['customer_name'] != null) '${h['customer_name']}',
              if (h['quote'] != null)
                formatInr(((h['quote'] as Map)['total_minor'] as num).toInt())
              else
                l.heldNeedsChanges,
            ].join(' · ')),
            tooltip: l.resumeHeld,
            onPressed: () => onResume(h),
            deleteIcon: const Icon(Icons.close_rounded, size: 16),
            deleteButtonTooltipMessage: l.discardHeld,
            onDeleted: () => onDiscard(h),
          ),
      ]),
    ]);
  }
}
