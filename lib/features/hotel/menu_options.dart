import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../floor/floor_page.dart' show menuDataProvider;

/// Menu editor for sizes (half/full) and add-on groups (backend docs/03 "Variants and add-ons").
/// Prices typed here are parsed to integer paise (no floats) and stored by the server.

List<Map<String, dynamic>> _maps(Object? v) =>
    ((v as List?) ?? const []).cast<Map>().map(Map<String, dynamic>.from).toList();

/// One editable row: name + price (+ id when it already exists, + availability).
class _Row {
  _Row({this.id, String name = '', int? priceMinor, this.available = true})
    : name = TextEditingController(text: name),
      price = TextEditingController(text: priceMinor == null ? '' : minorToInput(priceMinor));
  final String? id;
  final TextEditingController name;
  final TextEditingController price;
  bool available;

  void dispose() {
    name.dispose();
    price.dispose();
  }
}

Widget _rowEditor(BuildContext context, _Row r, String nameHint, VoidCallback onRemove, VoidCallback onChanged) {
  final l = AppLocalizations.of(context);
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: r.name,
            decoration: InputDecoration(hintText: nameHint),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: r.price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(prefixText: '₹ ', hintText: l.price),
          ),
        ),
        Tooltip(
          message: r.available ? l.available : l.soldOut,
          child: Switch(
            value: r.available,
            onChanged: (v) {
              r.available = v;
              onChanged();
            },
          ),
        ),
        IconButton(tooltip: l.delete, onPressed: onRemove, icon: const Icon(Icons.close_rounded, size: 18)),
      ],
    ),
  );
}

/// Parses every row; returns null (after telling the user) if a name is empty or a price is not valid.
List<Map<String, dynamic>>? _rowsJson(BuildContext context, List<_Row> rows) {
  final l = AppLocalizations.of(context);
  final out = <Map<String, dynamic>>[];
  for (final r in rows) {
    final p = r.price.text.trim().isEmpty ? 0 : parseInrToMinor(r.price.text);
    if (r.name.text.trim().isEmpty || p == null) {
      showWarning(context, l.errPriceInvalid);
      return null;
    }
    out.add({if (r.id != null) 'id': r.id, 'name': r.name.text.trim(), 'price_minor': p, 'is_available': r.available});
  }
  return out;
}

// ---------- sizes ----------

Future<void> showSizesDialog(BuildContext context, Map<String, dynamic> item) => showGlassDialog(
  context,
  title: '${AppLocalizations.of(context).sizes} · ${item['name']}',
  maxWidth: 560,
  body: _SizesForm(item: item),
);

class _SizesForm extends ConsumerStatefulWidget {
  const _SizesForm({required this.item});
  final Map<String, dynamic> item;

  @override
  ConsumerState<_SizesForm> createState() => _SizesFormState();
}

class _SizesFormState extends ConsumerState<_SizesForm> {
  late final List<_Row> _rows = [
    for (final v in _maps(widget.item['variants']))
      _Row(
        id: v['id'],
        name: v['name'],
        priceMinor: (v['price_minor'] as num).toInt(),
        available: v['is_available'] == true,
      ),
  ];
  bool _busy = false;

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final rows = _rowsJson(context, _rows);
    if (rows == null) return;
    if (rows.length == 1) return showWarning(context, l.errSizesCount);
    setState(() => _busy = true);
    final ok = await guard(context, () async {
      await ref.read(apiProvider).put('/api/v1/items/${widget.item['id']}/variants', {'variants': rows});
      ref.invalidate(menuDataProvider);
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop();
      showDone(context, l.saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.sizesHelp, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        for (final r in _rows)
          _rowEditor(context, r, l.sizeNameHint, () => setState(() => _rows.remove(r)), () => setState(() {})),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: _rows.length >= 10 ? null : () => setState(() => _rows.add(_Row())),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l.addSize),
          ),
        ),
        DialogActions(primary: l.save, busy: _busy, onPrimary: _busy ? null : _save),
      ],
    );
  }
}

// ---------- add-on groups ----------

final addonGroupsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async => _maps(await ref.read(apiProvider).get('/api/v1/addon-groups')),
);

Future<void> showAddonGroupsDialog(BuildContext context) =>
    showGlassDialog(context, title: AppLocalizations.of(context).addonGroups, maxWidth: 600, body: const _GroupsList());

class _GroupsList extends ConsumerWidget {
  const _GroupsList();

  String _rule(AppLocalizations l, Map g) {
    final min = (g['min_select'] as num).toInt(), max = (g['max_select'] as num).toInt();
    if (min == max) return l.pickExactly(max);
    if (min == 0) return l.pickUpTo(max);
    return l.pickBetween(min, max);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Map g) async {
    final l = AppLocalizations.of(context);
    final ok = await showGlassDialog<bool>(
      context,
      title: l.delete,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.deleteGroupConfirm(g['name'] as String)),
          DialogActions(primary: l.delete, onPrimary: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await guard(context, () async {
      await ref.read(apiProvider).delete('/api/v1/addon-groups/${g['id']}');
      ref.invalidate(addonGroupsProvider);
      ref.invalidate(menuDataProvider);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final groups = ref.watch(addonGroupsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.addonGroupsHelp, style: tt.bodySmall),
        const SizedBox(height: 10),
        groups.when(
          loading: () => const LoadingBlock(height: 120),
          error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
          data: (gs) => Column(
            children: [
              for (final g in gs)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: t.line)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${g['name']} · ${_rule(l, g)}', style: tt.titleSmall),
                            Text(
                              _maps(g['addons'])
                                  .map((a) => '${a['name']} ${formatInr((a['price_minor'] as num).toInt())}')
                                  .join(', '),
                              style: tt.bodySmall,
                            ),
                            // Where it is used, so changing or deleting it is never a surprise.
                            Text(
                              (g['used_by'] as List).isEmpty
                                  ? l.notUsedYet
                                  : l.usedBy((g['used_by'] as List).join(', ')),
                              style: tt.labelSmall?.copyWith(color: t.dim),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l.edit,
                        onPressed: () => showGroupForm(context, g),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                      ),
                      IconButton(
                        tooltip: l.delete,
                        onPressed: () => _delete(context, ref, g),
                        icon: Icon(Icons.delete_outline, size: 18, color: t.danger),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: () => showGroupForm(context, null),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l.newGroup),
          ),
        ),
      ],
    );
  }
}

Future<void> showGroupForm(BuildContext context, Map<String, dynamic>? group) => showGlassDialog(
  context,
  title: group == null ? AppLocalizations.of(context).newGroup : group['name'] as String,
  maxWidth: 560,
  body: _GroupForm(group: group),
);

class _GroupForm extends ConsumerStatefulWidget {
  const _GroupForm({this.group});
  final Map<String, dynamic>? group;

  @override
  ConsumerState<_GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends ConsumerState<_GroupForm> {
  late final _name = TextEditingController(text: widget.group?['name'] as String? ?? '');
  late int _min = (widget.group?['min_select'] as num?)?.toInt() ?? 0;
  late int _max = (widget.group?['max_select'] as num?)?.toInt() ?? 1;
  late final List<_Row> _rows = [
    for (final a in _maps(widget.group?['addons']))
      _Row(
        id: a['id'],
        name: a['name'],
        priceMinor: (a['price_minor'] as num).toInt(),
        available: a['is_available'] == true,
      ),
    if (widget.group == null) _Row(),
  ];
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final rows = _rowsJson(context, _rows);
    if (rows == null || rows.isEmpty || _name.text.trim().isEmpty) {
      if (rows != null) showWarning(context, l.errPriceInvalid);
      return;
    }
    setState(() => _busy = true);
    final body = {'name': _name.text.trim(), 'min_select': _min, 'max_select': _max, 'addons': rows};
    final ok = await guard(context, () async {
      final api = ref.read(apiProvider);
      widget.group == null
          ? await api.post('/api/v1/addon-groups', body)
          : await api.put('/api/v1/addon-groups/${widget.group!['id']}', body);
      ref.invalidate(addonGroupsProvider);
      ref.invalidate(menuDataProvider);
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop();
      showDone(context, l.saved);
    }
  }

  Widget _stepper(String label, int value, int min, int max, ValueChanged<int> set) => Row(
    children: [
      Expanded(child: Text(label)),
      IconButton(onPressed: value > min ? () => set(value - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
      Text('$value', style: Theme.of(context).textTheme.titleMedium),
      IconButton(onPressed: value < max ? () => set(value + 1) : null, icon: const Icon(Icons.add_circle_outline)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(l.name),
        TextField(
          controller: _name,
          decoration: InputDecoration(hintText: l.groupNameHint),
        ),
        const SizedBox(height: 8),
        // Changing one limit keeps the other consistent (min never above max).
        _stepper(
          l.minPicks,
          _min,
          0,
          20,
          (v) => setState(() {
            _min = v;
            if (_max < v) _max = v;
          }),
        ),
        _stepper(
          l.maxPicks,
          _max,
          1,
          20,
          (v) => setState(() {
            _max = v;
            if (_min > v) _min = v;
          }),
        ),
        const SizedBox(height: 8),
        FieldLabel(l.addons),
        for (final r in _rows)
          _rowEditor(context, r, l.addonNameHint, () => setState(() => _rows.remove(r)), () => setState(() {})),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: _rows.length >= 30 ? null : () => setState(() => _rows.add(_Row())),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l.addAddon),
          ),
        ),
        DialogActions(primary: l.save, busy: _busy, onPrimary: _busy ? null : _save),
      ],
    );
  }
}

// ---------- which groups a dish offers ----------

Future<void> showItemAddonsDialog(BuildContext context, Map<String, dynamic> item) => showGlassDialog(
  context,
  title: '${AppLocalizations.of(context).addons} · ${item['name']}',
  maxWidth: 520,
  body: _ItemGroups(item: item),
);

class _ItemGroups extends ConsumerStatefulWidget {
  const _ItemGroups({required this.item});
  final Map<String, dynamic> item;

  @override
  ConsumerState<_ItemGroups> createState() => _ItemGroupsState();
}

class _ItemGroupsState extends ConsumerState<_ItemGroups> {
  late final List<String> _selected = [for (final g in _maps(widget.item['addon_groups'])) g['id'] as String];
  bool _busy = false;

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final ok = await guard(context, () async {
      await ref.read(apiProvider).put('/api/v1/items/${widget.item['id']}/addon-groups', {'group_ids': _selected});
      ref.invalidate(menuDataProvider);
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop();
      showDone(context, l.saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final groups = ref.watch(addonGroupsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.addonsForItem(widget.item['name'] as String), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
        groups.when(
          loading: () => const LoadingBlock(height: 100),
          error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
          data: (gs) => gs.isEmpty
              ? EmptyState(
                  icon: Icons.playlist_add_rounded,
                  title: l.noAddonGroups,
                  action: OutlinedButton(onPressed: () => showAddonGroupsDialog(context), child: Text(l.addonGroups)),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final g in gs)
                      FilterChip(
                        label: Text(g['name'] as String),
                        selected: _selected.contains(g['id']),
                        onSelected: (on) =>
                            setState(() => on ? _selected.add(g['id'] as String) : _selected.remove(g['id'])),
                      ),
                  ],
                ),
        ),
        DialogActions(primary: l.save, busy: _busy, onPrimary: _busy ? null : _save),
      ],
    );
  }
}

/// Kitchen staff mark one size sold out (half finished, full still on) without opening the editor.
class SizeAvailabilityChips extends ConsumerWidget {
  const SizeAvailabilityChips({super.key, required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final variants = _maps(item['variants']);
    if (variants.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final v in variants)
          FilterChip(
            avatar: Icon(
              v['is_available'] == true ? Icons.check_circle_outline : Icons.remove_circle_outline,
              size: 16,
            ),
            label: Text('${v['name']} · ${v['is_available'] == true ? l.available : l.soldOut}'),
            selected: v['is_available'] == true,
            showCheckmark: false,
            onSelected: (on) => guard(context, () async {
              await ref.read(apiProvider).post('/api/v1/variants/${v['id']}/availability', {'is_available': on});
              ref.invalidate(menuDataProvider);
            }),
          ),
      ],
    );
  }
}

// ---------- happy hour ----------

final priceRulesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async => _maps(await ref.read(apiProvider).get('/api/v1/price-rules')),
);

/// Monday = bit 0 ... Sunday = bit 6, as the server stores it.
List<String> _dayNames(BuildContext context) {
  final f = DateFormat.E(Localizations.localeOf(context).toLanguageTag());
  return [for (var d = 0; d < 7; d++) f.format(DateTime(2026, 11, 16 + d))]; // 16 Nov 2026 is a Monday
}

String _daysText(BuildContext context, int mask) {
  if (mask == 127) return AppLocalizations.of(context).everyDay;
  final names = _dayNames(context);
  return [
    for (var d = 0; d < 7; d++)
      if (mask & (1 << d) != 0) names[d],
  ].join(', ');
}

Future<void> showPriceRulesDialog(BuildContext context) =>
    showGlassDialog(context, title: AppLocalizations.of(context).happyHour, maxWidth: 600, body: const _RulesList());

class _RulesList extends ConsumerWidget {
  const _RulesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final rules = ref.watch(priceRulesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.happyHourHelp, style: tt.bodySmall),
        const SizedBox(height: 10),
        rules.when(
          loading: () => const LoadingBlock(height: 100),
          error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
          data: (rs) => rs.isEmpty
              ? EmptyState(icon: Icons.local_offer_outlined, title: l.noOffers)
              : Column(
                  children: [
                    for (final r in rs)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: t.line)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r['name'] as String, style: tt.titleSmall),
                                  Text(
                                    l.offerSummary(
                                      percentLabel((r['percent_bp'] as num).toInt()),
                                      _daysText(context, (r['days'] as num).toInt()),
                                      r['start_time'],
                                      r['end_time'],
                                    ),
                                    style: tt.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            // Switch off without deleting (icon + label, not colour alone).
                            StatusChip(
                              icon: r['is_active'] == true ? Icons.check_circle_outline : Icons.pause_circle_outline,
                              label: r['is_active'] == true ? l.offerOn : l.off,
                              color: r['is_active'] == true ? t.ok : t.dim,
                            ),
                            IconButton(
                              tooltip: l.edit,
                              onPressed: () => showRuleForm(context, r),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                            ),
                            IconButton(
                              tooltip: l.delete,
                              onPressed: () => guard(context, () async {
                                await ref.read(apiProvider).delete('/api/v1/price-rules/${r['id']}');
                                ref.invalidate(priceRulesProvider);
                                ref.invalidate(menuDataProvider);
                              }),
                              icon: Icon(Icons.delete_outline, size: 18, color: t.danger),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: () => showRuleForm(context, null),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l.newOffer),
          ),
        ),
      ],
    );
  }
}

Future<void> showRuleForm(BuildContext context, Map<String, dynamic>? rule) => showGlassDialog(
  context,
  title: rule == null ? AppLocalizations.of(context).newOffer : rule['name'] as String,
  maxWidth: 560,
  body: _RuleForm(rule: rule),
);

class _RuleForm extends ConsumerStatefulWidget {
  const _RuleForm({this.rule});
  final Map<String, dynamic>? rule;

  @override
  ConsumerState<_RuleForm> createState() => _RuleFormState();
}

class _RuleFormState extends ConsumerState<_RuleForm> {
  late final _name = TextEditingController(text: widget.rule?['name'] as String? ?? '');
  late final _percent = TextEditingController(
    text: widget.rule == null ? '' : percentLabel((widget.rule!['percent_bp'] as num).toInt()).replaceAll('%', ''),
  );
  late int _days = (widget.rule?['days'] as num?)?.toInt() ?? 127;
  late TimeOfDay _from = _parse(widget.rule?['start_time'] as String? ?? '17:00');
  late TimeOfDay _to = _parse(widget.rule?['end_time'] as String? ?? '19:00');
  late final Set<String> _cats = {...((widget.rule?['category_ids'] as List?) ?? const []).cast<String>()};
  late bool _active = widget.rule?['is_active'] as bool? ?? true;
  bool _busy = false;

  static TimeOfDay _parse(String s) => TimeOfDay(hour: int.parse(s.split(':')[0]), minute: int.parse(s.split(':')[1]));
  static String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _name.dispose();
    _percent.dispose();
    super.dispose();
  }

  Future<void> _pick(bool start) async {
    final t = await showTimePicker(context: context, initialTime: start ? _from : _to);
    if (t != null) setState(() => start ? _from = t : _to = t);
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final bp = parsePercentToBp(_percent.text);
    if (_name.text.trim().isEmpty || bp == null || bp < 1 || bp > 9000) return showWarning(context, l.errBadPercent);
    if (_fmt(_from) == _fmt(_to)) return showWarning(context, l.errSameTimes);
    setState(() => _busy = true);
    final body = {
      'name': _name.text.trim(),
      'percent_bp': bp,
      'days': _days,
      'start_time': _fmt(_from),
      'end_time': _fmt(_to),
      'category_ids': _cats.isEmpty ? null : _cats.toList(),
      'is_active': _active,
    };
    final ok = await guard(context, () async {
      final api = ref.read(apiProvider);
      widget.rule == null
          ? await api.post('/api/v1/price-rules', body)
          : await api.put('/api/v1/price-rules/${widget.rule!['id']}', body);
      ref.invalidate(priceRulesProvider);
      ref.invalidate(menuDataProvider);
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop();
      showDone(context, l.saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final names = _dayNames(context);
    final cats = ref.watch(menuDataProvider).value?.$1 ?? const <Map<String, dynamic>>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(l.name),
        TextField(
          controller: _name,
          decoration: InputDecoration(hintText: l.offerNameHint),
        ),
        FieldLabel(l.percentOff),
        TextField(
          controller: _percent,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: '%', hintText: '20'),
        ),
        FieldLabel(l.days),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var d = 0; d < 7; d++)
              FilterChip(
                label: Text(names[d]),
                selected: _days & (1 << d) != 0,
                // At least one day stays selected (the server needs 1..127).
                onSelected: (on) => setState(() {
                  final next = on ? _days | (1 << d) : _days & ~(1 << d);
                  if (next != 0) _days = next;
                }),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(true),
                icon: const Icon(Icons.schedule_rounded, size: 18),
                label: Text('${l.fromTime} ${_fmt(_from)}'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(false),
                icon: const Icon(Icons.schedule_rounded, size: 18),
                label: Text('${l.toTime} ${_fmt(_to)}'),
              ),
            ),
          ],
        ),
        FieldLabel(l.appliesTo),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            FilterChip(label: Text(l.wholeMenu), selected: _cats.isEmpty, onSelected: (_) => setState(_cats.clear)),
            for (final c in cats)
              FilterChip(
                label: Text(c['name'] as String),
                selected: _cats.contains(c['id']),
                onSelected: (on) => setState(() => on ? _cats.add(c['id'] as String) : _cats.remove(c['id'])),
              ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _active,
          onChanged: (v) => setState(() => _active = v),
          title: Text(l.offerOn),
        ),
        DialogActions(primary: l.save, busy: _busy, onPrimary: _busy ? null : _save),
      ],
    );
  }
}
