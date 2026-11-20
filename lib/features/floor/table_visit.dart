import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';

/// Table visits (backend docs/03 "Table visits"): seat with guests, the timer, Cleaning / Reserved.

/// Minutes since the visit started (time, not money). Null when nobody is seated.
int? seatedMinutes(Map table, {DateTime? now}) {
  final at = table['seated_at'];
  if (at is! String) return null;
  return (now ?? DateTime.now()).toUtc().difference(DateTime.parse(at).toUtc()).inMinutes.clamp(0, 99999);
}

/// "4 guests · 25 min" under a busy table.
class SeatedLine extends StatelessWidget {
  const SeatedLine({super.key, required this.table});
  final Map table;

  @override
  Widget build(BuildContext context) {
    final minutes = seatedMinutes(table);
    if (minutes == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final g = table['guests'];
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 14, color: context.tokens.dim),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            g is num ? l.guestsAndTime(l.guestsN(g.toInt()), minutes) : '$minutes min',
            style: Theme.of(context).textTheme.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Chip for the visit states the order chips don't cover (icon + label, never colour alone).
Widget? visitChip(BuildContext context, Map table) {
  final l = AppLocalizations.of(context);
  final t = context.tokens;
  return switch (table['state']) {
    'SEATED' => StatusChip(icon: Icons.event_seat_rounded, label: l.seated, color: t.info),
    'CLEANING' => StatusChip(icon: Icons.cleaning_services_outlined, label: l.cleaning, color: t.warn),
    'RESERVED' => StatusChip(
      icon: Icons.bookmark_outline,
      label: table['hold_note'] != null ? '${l.reserved} · ${table['hold_note']}' : l.reserved,
      color: t.accent,
    ),
    _ => null,
  };
}

/// The visit actions at the top of a table's sheet; [onChanged] refreshes the floor.
class TableVisitActions extends ConsumerStatefulWidget {
  const TableVisitActions({super.key, required this.table, required this.onChanged});
  final Map<String, dynamic> table;
  final VoidCallback onChanged;

  @override
  ConsumerState<TableVisitActions> createState() => _TableVisitActionsState();
}

class _TableVisitActionsState extends ConsumerState<TableVisitActions> {
  late Map<String, dynamic> _t = widget.table;

  Future<void> _post(String path, Map<String, dynamic> body) async {
    await guard(context, () async {
      final r = await ref.read(apiProvider).post('/api/v1/tables/${_t['id']}/$path', body);
      if (mounted) setState(() => _t = {..._t, ...Map<String, dynamic>.from(r)});
      widget.onChanged();
    });
  }

  Future<void> _seat() async {
    final l = AppLocalizations.of(context);
    var n = (_t['guests'] as num?)?.toInt() ?? 2;
    final ok = await showGlassDialog<bool>(
      context,
      title: l.guestsCountLabel,
      body: StatefulBuilder(
        builder: (ctx, set) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: n > 1 ? () => set(() => n--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$n', style: Theme.of(ctx).textTheme.displaySmall),
                IconButton(onPressed: n < 99 ? () => set(() => n++) : null, icon: const Icon(Icons.add_circle_outline)),
              ],
            ),
            DialogActions(primary: l.seatGuests, onPrimary: () => Navigator.of(ctx).pop(true)),
          ],
        ),
      ),
    );
    if (ok == true) await _post('seat', {'guests': n});
  }

  Future<void> _reserve() async {
    final l = AppLocalizations.of(context);
    final note = TextEditingController();
    final ok = await showGlassDialog<bool>(
      context,
      title: l.reserve,
      body: Builder(
        builder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: note,
              maxLength: 80,
              decoration: InputDecoration(hintText: l.reserveNoteHint),
            ),
            DialogActions(primary: l.reserve, onPrimary: () => Navigator.of(ctx).pop(true)),
          ],
        ),
      ),
    );
    if (ok == true) await _post('hold', {'state': 'RESERVED', 'note': note.text.trim()});
    note.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = _t['state'] as String?;
    final buttons = <Widget>[
      if (state == 'FREE' || state == 'RESERVED')
        FilledButton.tonalIcon(
          onPressed: _seat,
          icon: const Icon(Icons.event_seat_rounded, size: 18),
          label: Text(l.seatGuests),
        ),
      if (state == 'FREE')
        OutlinedButton.icon(
          onPressed: _reserve,
          icon: const Icon(Icons.bookmark_outline, size: 18),
          label: Text(l.reserve),
        ),
      if (state == 'RESERVED')
        TextButton(onPressed: () => _post('hold', {'state': 'FREE'}), child: Text(l.cancelReservation)),
      if (state == 'CLEANING')
        FilledButton.tonalIcon(
          onPressed: () => _post('hold', {'state': 'FREE'}),
          icon: const Icon(Icons.cleaning_services_outlined, size: 18),
          label: Text(l.markClean),
        ),
      if (state == 'SEATED' || state == 'OCCUPIED' || state == 'BILL_PENDING')
        OutlinedButton.icon(
          onPressed: _seat,
          icon: const Icon(Icons.groups_outlined, size: 18),
          label: Text(l.changeGuests),
        ),
      if (state == 'SEATED') TextButton(onPressed: () => _post('hold', {'state': 'FREE'}), child: Text(l.guestsLeft)),
    ];
    final chip = visitChip(context, _t);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ?chip,
          SeatedLine(table: _t),
          ...buttons,
        ],
      ),
    );
  }
}
