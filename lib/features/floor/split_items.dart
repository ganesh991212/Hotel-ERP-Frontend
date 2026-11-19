import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';

/// Split by items (backend docs/03 "Split by items"): staff say who had what; the server prices, taxes and numbers
/// one GST bill per guest. This screen only counts units (never money) and shows the server's line values.
/// Returns the guest bills, or null if closed without splitting.
Future<List<Map<String, dynamic>>?> showSplitByItems(BuildContext context, String tableId) {
  final l = AppLocalizations.of(context);
  return showGlassDialog<List<Map<String, dynamic>>>(
    context,
    title: l.splitByItems,
    maxWidth: 620,
    body: SplitByItemsPanel(tableId: tableId),
  );
}

const maxGuests = 20;

class SplitByItemsPanel extends ConsumerStatefulWidget {
  const SplitByItemsPanel({super.key, required this.tableId});
  final String tableId;

  @override
  ConsumerState<SplitByItemsPanel> createState() => _SplitByItemsPanelState();
}

class _SplitByItemsPanelState extends ConsumerState<SplitByItemsPanel> {
  List<Map<String, dynamic>>? _lines;
  int _guests = 2;
  final Map<String, List<int>> _units = {}; // key -> units per guest
  final Map<String, Set<int>> _shared = {}; // key -> guest numbers (from 1), when the dish is shared
  bool _busy = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ref.read(apiProvider).get('/api/v1/bills/split-preview?table_id=${widget.tableId}');
      if (!mounted) return;
      setState(() {
        _lines = (p['lines'] as List).cast<Map>().map(Map<String, dynamic>.from).toList();
        _reset();
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Changing the number of guests clears every assignment (they no longer line up with the guests).
  void _reset() {
    _units.clear();
    _shared.clear();
    for (final ln in _lines ?? const <Map<String, dynamic>>[]) {
      _units[ln['key'] as String] = List.filled(_guests, 0);
    }
  }

  void _setGuests(int n) => setState(() {
    _guests = n;
    _reset();
  });

  int _qty(Map ln) => (ln['qty'] as num).toInt();
  int _given(String key) => _units[key]!.fold(0, (a, b) => a + b); // a count of dishes, not money
  bool _isShared(String key) => _shared.containsKey(key);

  bool get _complete {
    final lines = _lines;
    if (lines == null || lines.isEmpty) return false;
    final hasSomething = List.filled(_guests, false);
    for (final ln in lines) {
      final key = ln['key'] as String;
      if (_isShared(key)) {
        if (_shared[key]!.length < 2) return false;
        for (final g in _shared[key]!) {
          hasSomething[g - 1] = true;
        }
      } else {
        if (_given(key) != _qty(ln)) return false;
        for (final (g, n) in _units[key]!.indexed) {
          if (n > 0) hasSomething[g] = true;
        }
      }
    }
    return hasSomething.every((x) => x);
  }

  Future<void> _create({bool includeUnserved = false}) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final r = await ref.read(apiProvider).post('/api/v1/bills/split', {
        'table_id': widget.tableId,
        'guests': _guests,
        'include_unserved': includeUnserved,
        'lines': [
          for (final ln in _lines!)
            if (_isShared(ln['key'] as String))
              {'key': ln['key'], 'shared': (_shared[ln['key']]!.toList()..sort())}
            else
              {'key': ln['key'], 'qty': _units[ln['key']]},
        ],
      });
      final bills = (r['bills'] as List).cast<Map>().map(Map<String, dynamic>.from).toList();
      if (!mounted) return;
      showDone(context, l.splitDone(bills.length));
      Navigator.of(context).pop(bills);
      return;
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'orders_not_served') {
        final ok = await showGlassDialog<bool>(
          context,
          title: l.splitByItems,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.notServedYet((e.details['orders'] as List).join(', #'))),
              DialogActions(primary: l.billAnyway, onPrimary: () => Navigator.of(context).pop(true)),
            ],
          ),
        );
        if (ok == true && mounted) return _create(includeUnserved: true);
      } else {
        showError(context, e);
        if (e.code == 'lines_changed') await _load();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    if (_error != null) return EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, _error!));
    final lines = _lines;
    if (lines == null) return const LoadingBlock(height: 160);
    if (lines.isEmpty) return EmptyState(icon: Icons.receipt_long_outlined, title: l.splitNothing);
    final guests = [for (var g = 1; g <= _guests; g++) g];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.splitByItemsHelp, style: tt.bodySmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Text(l.guestsCount, style: tt.titleSmall)),
            IconButton(
              onPressed: _guests > 2 ? () => _setGuests(_guests - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$_guests', style: tt.titleLarge),
            IconButton(
              onPressed: _guests < maxGuests ? () => _setGuests(_guests + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final ln in lines) ...[
          Divider(height: 18, color: t.hair),
          _lineHeader(context, ln),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final g in guests) _guestChip(context, ln, g)]),
        ],
        const SizedBox(height: 14),
        if (!_complete)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: t.dim),
                const SizedBox(width: 6),
                Expanded(child: Text(l.splitIncomplete, style: tt.bodySmall)),
              ],
            ),
          ),
        FilledButton.icon(
          onPressed: _busy || !_complete ? null : _create,
          icon: const Icon(Icons.alt_route_rounded, size: 18),
          label: Text(l.splitCreate(_guests)),
        ),
      ],
    );
  }

  Widget _lineHeader(BuildContext context, Map<String, dynamic> ln) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final key = ln['key'] as String;
    final left = _qty(ln) - _given(key);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${ln['qty']} × ${ln['name']}', style: tt.titleSmall),
              Text(formatInr((ln['line_total_minor'] as num).toInt()), style: tt.bodySmall),
            ],
          ),
        ),
        if (!_isShared(key) && left > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pending_outlined, size: 14, color: t.warn),
                const SizedBox(width: 3),
                Text(l.splitLeft(left), style: tt.labelMedium?.copyWith(color: t.warn)),
              ],
            ),
          ),
        FilterChip(
          avatar: const Icon(Icons.groups_outlined, size: 16),
          label: Text(l.splitShared),
          selected: _isShared(key),
          onSelected: (on) => setState(() {
            if (on) {
              _shared[key] = {};
              _units[key] = List.filled(_guests, 0);
            } else {
              _shared.remove(key);
            }
          }),
        ),
      ],
    );
  }

  Widget _guestChip(BuildContext context, Map<String, dynamic> ln, int g) {
    final l = AppLocalizations.of(context);
    final key = ln['key'] as String;
    if (_isShared(key)) {
      final on = _shared[key]!.contains(g);
      return FilterChip(
        label: Text(l.guestN(g)),
        selected: on,
        onSelected: (v) => setState(() => v ? _shared[key]!.add(g) : _shared[key]!.remove(g)),
      );
    }
    final n = _units[key]![g - 1];
    final left = _qty(ln) - _given(key);
    return InputChip(
      label: Text(n > 0 ? l.guestUnits(g, n) : l.guestN(g)),
      selected: n > 0,
      showCheckmark: false,
      onPressed: left > 0 ? () => setState(() => _units[key]![g - 1]++) : null,
      onDeleted: n > 0 ? () => setState(() => _units[key]![g - 1]--) : null,
    );
  }
}

/// Every guest bill of a split, with what each still owes (from the server); tap one to open it.
class GuestBillsStrip extends StatelessWidget {
  const GuestBillsStrip({super.key, required this.split, required this.currentId, required this.onOpen});
  final Map split;
  final String currentId;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final bills = (split['bills'] as List).cast<Map>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(l.guestBills),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final b in bills)
              ChoiceChip(
                avatar: Icon(
                  b['status'] == 'PAID'
                      ? Icons.check_circle_outline
                      : b['status'] == 'VOID'
                      ? Icons.cancel_outlined
                      : Icons.pending_outlined,
                  size: 16,
                  color: b['status'] == 'PAID' ? t.ok : (b['status'] == 'VOID' ? t.danger : t.warn),
                ),
                label: Text(
                  '${l.guestN((b['guest_no'] as num).toInt())} · '
                  '${b['status'] == 'ISSUED'
                      ? formatInr((b['due_minor'] as num).toInt())
                      : b['status'] == 'PAID'
                      ? l.statusPaid
                      : l.billCancelled}',
                ),
                selected: b['id'] == currentId,
            showCheckmark: false,
                onSelected: (_) => onOpen(b['id'] as String),
              ),
          ],
        ),
      ],
    );
  }
}
