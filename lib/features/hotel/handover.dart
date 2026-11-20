import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import 'close_day_page.dart';

/// Cash handover between shifts (backend docs/03 "Cash handover", docs/14). A **blind** count: the expected cash is
/// only shown after the count is saved, and the count can't be changed afterwards. Figures come from the server.
Future<void> showHandover(BuildContext context, WidgetRef ref, {VoidCallback? onDone}) async {
  final l = AppLocalizations.of(context);
  final api = ref.read(apiProvider);
  late final Map<String, dynamic> start;
  late final List<Map<String, dynamic>> staff;
  final ok = await guard(context, () async {
    start = Map<String, dynamic>.from(await api.get('/api/v1/handover'));
    staff = ((await api.get('/api/v1/users')) as List).cast<Map<String, dynamic>>();
  });
  if (!ok || !context.mounted) return;
  if (start['day_closed'] == true) return showWarning(context, l.errAlreadyClosed);
  final me = ref.read(sessionProvider).value!.me['id'];
  final others = staff.where((u) => u['id'] != me).toList();
  String? to = others.isEmpty ? null : others.first['id'] as String;
  final counted = TextEditingController();
  final opening = TextEditingController();
  final go = await showGlassDialog<bool>(
    context,
    title: l.handover,
    body: StatefulBuilder(
      builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.handoverHelp, style: Theme.of(ctx).textTheme.bodySmall),
        if (start['needs_opening_float'] == true) ...[
          FieldLabel(l.openingFloat),
          TextField(controller: opening, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '₹ ')),
        ],
        FieldLabel(l.cashInDrawerNow),
        TextField(
          controller: counted,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '₹ '),
        ),
        FieldLabel(l.handingOverTo),
        DropdownButtonFormField<String>(
          initialValue: to,
          items: [for (final u in others) DropdownMenuItem(value: u['id'] as String, child: Text(u['name'] as String))],
          onChanged: (v) => set(() => to = v),
        ),
        DialogActions(primary: l.saveCount, onPrimary: () => Navigator.of(ctx).pop(true)),
      ]),
    ),
  );
  final c = parseInrToMinor(counted.text);
  if (go != true || c == null || to == null || !context.mounted) return;
  Map<String, dynamic>? saved;
  await guard(context, () async {
    saved = Map<String, dynamic>.from(await api.post('/api/v1/handover', {
      'counted_minor': c,
      'taken_by': to,
      if (start['needs_opening_float'] == true) 'opening_float_minor': parseInrToMinor(opening.text) ?? 0,
    }));
  });
  if (saved == null || !context.mounted) return;
  // Now (and only now) the expected cash and the over / short.
  final note = TextEditingController();
  final off = saved!['result'] != 'EXACT';
  final addNote = await showGlassDialog<bool>(
    context,
    title: l.handoverSaved,
    body: Builder(
      builder: (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MoneyLine(l.expectedInDrawer, (saved!['expected_minor'] as num).toInt()),
        MoneyLine(l.countedCash, (saved!['counted_minor'] as num).toInt(), strong: true),
        const SizedBox(height: 6),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ResultChip(result: saved!['result'] as String, differenceMinor: (saved!['difference_minor'] as num).toInt()),
        ),
        if (off) ...[
          FieldLabel(l.whyOverShort),
          TextField(controller: note, maxLength: 200, decoration: const InputDecoration(counterText: '')),
        ],
        DialogActions(primary: off ? l.saveNote : l.done, onPrimary: () => Navigator.of(ctx).pop(true)),
      ]),
    ),
  );
  if (off && addNote == true && note.text.trim().length >= 3 && context.mounted) {
    await guard(context, () => api.post('/api/v1/handover/${saved!['id']}/note', {'note': note.text.trim()}));
  }
  onDone?.call();
}

/// Today's handovers, each with its own over / short.
class HandoversList extends StatelessWidget {
  const HandoversList({super.key, required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    if (items.isEmpty) return const SizedBox.shrink();
    final time = DateFormat.jm(Localizations.localeOf(context).toLanguageTag());
    return Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardTitle(l.handoversToday),
        for (final h in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    l.handoverLine(time.format(DateTime.parse(h['at'] as String).toLocal()), '${h['handed_by']}', '${h['taken_by']}'),
                    style: tt.bodyMedium,
                  ),
                  Text(l.countedOf(formatInr((h['counted_minor'] as num).toInt()), formatInr((h['expected_minor'] as num).toInt())),
                      style: tt.bodySmall),
                  if (h['note'] != null) Text('${h['note']}', style: tt.bodySmall),
                ]),
              ),
              ResultChip(result: h['result'] as String, differenceMinor: (h['difference_minor'] as num).toInt()),
            ]),
          ),
      ]),
    );
  }
}
