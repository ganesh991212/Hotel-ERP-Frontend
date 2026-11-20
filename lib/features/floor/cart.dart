import 'package:material_ui/material_ui.dart';

import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';

/// Sizes and add-ons on the order screens (backend docs/03 "Variants and add-ons"). The client only records what was
/// chosen (ids and counts); the server prices it (rule 4) and the totals shown come from its quote.

List<Map<String, dynamic>> _maps(Object? v) =>
    ((v as List?) ?? const []).cast<Map>().map(Map<String, dynamic>.from).toList();

/// Whether ordering this dish needs the choice sheet first.
bool needsChoices(Map item) => _maps(item['variants']).isNotEmpty || _maps(item['addon_groups']).isNotEmpty;

class CartLine {
  CartLine(this.item, {this.variant, Map<String, int>? addons, Map<String, String>? addonNames})
    : addons = Map.unmodifiable(addons ?? const {}),
      addonNames = Map.unmodifiable(addonNames ?? const {});

  final Map item;
  final Map? variant;

  /// Add-on id -> picks per unit ("2 x Cheese").
  final Map<String, int> addons;
  final Map<String, String> addonNames;

  String get itemId => item['id'] as String;

  /// Same dish, size and add-ons = same line (its quantity goes up).
  String get key {
    final a = (addons.keys.toList()..sort()).map((k) => '$k:${addons[k]}').join(',');
    return '$itemId|${variant?['id'] ?? ''}|$a';
  }

  /// "Biryani (Half) + Raita, 2 x Cheese" (names only; prices come from the server).
  String get label {
    final base = variant == null ? '${item['name']}' : '${item['name']} (${variant!['name']})';
    if (addons.isEmpty) return base;
    final parts = addons.entries.map((e) => e.value > 1 ? '${e.value} x ${addonNames[e.key]}' : '${addonNames[e.key]}');
    return '$base + ${parts.join(', ')}';
  }

  Map<String, dynamic> json(int qty) => {
    'item_id': itemId,
    'qty': qty,
    if (variant != null) 'variant_id': variant!['id'],
    if (addons.isNotEmpty)
      'addons': [
        for (final e in addons.entries) {'addon_id': e.key, 'qty': e.value},
      ],
  };
}

/// Lines in the order they were added (so "−" on a dish takes back the latest one).
class Cart {
  final Map<String, CartLine> _lines = {};
  final Map<String, int> _qty = {};

  bool get isEmpty => _qty.isEmpty;
  int get count => _qty.values.fold(0, (a, b) => a + b);
  Iterable<(CartLine, int)> get entries => _lines.entries.map((e) => (e.value, _qty[e.key]!));
  List<Map<String, dynamic>> get json => [for (final (line, q) in entries) line.json(q)];

  int qtyOf(String itemId) => _lines.entries.where((e) => e.value.itemId == itemId).fold(0, (a, e) => a + _qty[e.key]!);

  void add(CartLine line) {
    _lines.putIfAbsent(line.key, () => line);
    _qty[line.key] = ((_qty[line.key] ?? 0) + 1).clamp(1, 20);
  }

  void change(String key, int delta) {
    final v = (_qty[key] ?? 0) + delta;
    if (v <= 0) {
      _qty.remove(key);
      _lines.remove(key);
    } else {
      _qty[key] = v.clamp(1, 20);
    }
  }

  void removeLastOf(String itemId) {
    final key = _lines.keys.lastWhere((k) => _lines[k]!.itemId == itemId, orElse: () => '');
    if (key.isNotEmpty) change(key, -1);
  }

  void clear() {
    _lines.clear();
    _qty.clear();
  }
}

/// Size and add-ons for one dish, on one sheet (no prompt after prompt). Returns null if closed.
Future<CartLine?> showItemChoices(BuildContext context, Map item) => showGlassDialog<CartLine>(
  context,
  title: item['name'] as String,
  body: _ChoicesSheet(item: item),
);

class _ChoicesSheet extends StatefulWidget {
  const _ChoicesSheet({required this.item});
  final Map item;

  @override
  State<_ChoicesSheet> createState() => _ChoicesSheetState();
}

class _ChoicesSheetState extends State<_ChoicesSheet> {
  Map<String, dynamic>? _variant;
  final Map<String, int> _picks = {}; // add-on id -> picks

  List<Map<String, dynamic>> get _variants => _maps(widget.item['variants']);
  List<Map<String, dynamic>> get _groups => _maps(widget.item['addon_groups']);

  int _picked(Map g) => _maps(g['addons']).fold(0, (a, x) => a + (_picks[x['id']] ?? 0)); // a count, not money

  bool get _ok =>
      (_variants.isEmpty || _variant != null) &&
      _groups.every((g) => _picked(g) >= (g['min_select'] as num) && _picked(g) <= (g['max_select'] as num));

  String _rule(AppLocalizations l, Map g) {
    final min = (g['min_select'] as num).toInt(), max = (g['max_select'] as num).toInt();
    if (min == max) return l.pickExactly(max);
    if (min == 0) return l.pickUpTo(max);
    return l.pickBetween(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_variants.isNotEmpty) ...[
          FieldLabel(l.chooseSize),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in _variants)
                ChoiceChip(
                  label: Text('${v['name']} · ${formatInr((v['price_minor'] as num).toInt())}'),
                  selected: _variant?['id'] == v['id'],
                  // Sold-out sizes stay visible for staff, greyed and not selectable.
                  onSelected: v['is_available'] == true ? (_) => setState(() => _variant = v) : null,
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        for (final g in _groups) ...[
          Row(
            children: [
              Expanded(child: Text(g['name'] as String, style: tt.titleSmall)),
              Text(_rule(l, g), style: tt.labelMedium?.copyWith(color: t.dim)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final a in _maps(g['addons'])) _addonChip(g, a)]),
          const SizedBox(height: 12),
        ],
        FilledButton.icon(
          onPressed: _ok
              ? () => Navigator.of(context).pop(
                  CartLine(
                    widget.item,
                    variant: _variant,
                    addons: {
                      for (final e in _picks.entries)
                        if (e.value > 0) e.key: e.value,
                    },
                    addonNames: {
                      for (final g in _groups)
                        for (final a in _maps(g['addons'])) a['id'] as String: a['name'] as String,
                    },
                  ),
                )
              : null,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(l.addToOrder),
        ),
      ],
    );
  }

  Widget _addonChip(Map g, Map<String, dynamic> a) {
    final id = a['id'] as String;
    final n = _picks[id] ?? 0;
    final max = (g['max_select'] as num).toInt();
    final price = (a['price_minor'] as num).toInt();
    final name = price > 0 ? '${a['name']} · ${formatInr(price)}' : '${a['name']}';
    final available = a['is_available'] == true;
    if (max == 1) {
      // "Choose one": picking another replaces it.
      return ChoiceChip(
        label: Text(name),
        selected: n > 0,
        onSelected: available
            ? (on) => setState(() {
                for (final x in _maps(g['addons'])) {
                  _picks.remove(x['id']);
                }
                if (on) _picks[id] = 1;
              })
            : null,
      );
    }
    final room = _picked(g) < max;
    return InputChip(
      label: Text(n > 1 ? '$n x $name' : name),
      selected: n > 0,
      showCheckmark: n == 1,
      onPressed: available && room ? () => setState(() => _picks[id] = n + 1) : null,
      onDeleted: n > 0 ? () => setState(() => n == 1 ? _picks.remove(id) : _picks[id] = n - 1) : null,
    );
  }
}

/// The price text for a dish in a list: each size's price ("Half ₹180 / Full ₹340") when it has sizes, else its
/// price. Display only; the server's quote prices the order.
String listPrice(Map item) {
  final sizes = _maps(item['variants']).where((v) => v['is_available'] == true).toList();
  if (sizes.isEmpty) return formatInr((item['price_minor'] as num).toInt());
  return sizes.map((v) => '${v['name']} ${formatInr((v['price_minor'] as num).toInt())}').join(' / ');
}

/// "Happy hour −20% till 19:00" while an offer runs for the dish (from the server; the price is the quote's).
class OfferBadge extends StatelessWidget {
  const OfferBadge({super.key, required this.item});
  final Map item;

  @override
  Widget build(BuildContext context) {
    final o = item['offer'];
    if (o is! Map) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: StatusChip(
        icon: Icons.local_offer_outlined,
        label: l.offerBadge(o['name'] as String, percentLabel((o['percent_bp'] as num).toInt()), o['until'] as String),
        color: context.tokens.accent,
      ),
    );
  }
}
