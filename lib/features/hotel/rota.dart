import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';

/// Shift rota (backend docs/03 "Shift rota", docs/14). The server matches each planned shift with the person's own
/// clock-in and says Upcoming / Working / On time / Late / Not in / No-show; this only shows it (icon + words).
final myRotaProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final d = await ref.read(apiProvider).get('/api/v1/rota/me');
  return ((d as Map)['shifts'] as List).cast<Map>().map(Map<String, dynamic>.from).toList();
});

final _staffProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async => ((await ref.read(apiProvider).get('/api/v1/users')) as List).cast<Map<String, dynamic>>(),
);

String _hm(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// The state chip for a planned shift.
Widget shiftStateChip(BuildContext context, Map s) {
  final l = AppLocalizations.of(context);
  final t = context.tokens;
  final late = (s['late_minutes'] as num?)?.toInt() ?? 0;
  final (IconData icon, String label, Color color) = switch (s['state']) {
    'WORKING' => (Icons.timelapse_rounded, l.onShiftNow, t.ok),
    'ON_TIME' => (Icons.check_circle_outline, l.shiftOnTime, t.ok),
    'LATE' => (Icons.schedule_rounded, l.shiftLate(late), t.warn),
    'NOT_IN' => (Icons.warning_amber_rounded, l.shiftNotIn(late), t.danger),
    'NO_SHOW' => (Icons.person_off_outlined, l.shiftNoShow, t.danger),
    _ => (Icons.event_outlined, l.shiftUpcoming, t.info),
  };
  return StatusChip(icon: icon, label: label, color: color);
}

class RotaView extends ConsumerStatefulWidget {
  const RotaView({super.key});

  @override
  ConsumerState<RotaView> createState() => _RotaViewState();
}

class _RotaViewState extends ConsumerState<RotaView> {
  Map<String, dynamic>? _data;
  Object? _error;
  DateTime? _from; // first day shown; the server's "today" by default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  String _ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _load() async {
    try {
      final q = _from == null ? '' : '?from=${_ymd(_from!)}';
      final d = Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/rota$q'));
      if (mounted) setState(() => (_data = d, _error = null, _from = DateTime.parse(d['from'] as String)));
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _shift(int days) {
    setState(() => _from = _from!.add(Duration(days: days)));
    _load();
  }

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final staff = await ref.read(_staffProvider.future);
    if (!mounted) return;
    String? who = staff.isEmpty ? null : staff.first['id'] as String;
    var day = _from!;
    var start = const TimeOfDay(hour: 9, minute: 0);
    var end = const TimeOfDay(hour: 17, minute: 0);
    final note = TextEditingController();
    final loc = Localizations.localeOf(context).toLanguageTag();
    final ok = await showGlassDialog<bool>(
      context,
      title: l.addShift,
      body: StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FieldLabel(l.person),
          DropdownButtonFormField<String>(
            initialValue: who,
            items: [for (final u in staff) DropdownMenuItem(value: u['id'] as String, child: Text(u['name'] as String))],
            onChanged: (v) => set(() => who = v),
          ),
          FieldLabel(l.day),
          OutlinedButton(
            onPressed: () async {
              final d = await showDatePicker(
                context: ctx,
                firstDate: _from!.subtract(const Duration(days: 30)),
                lastDate: _from!.add(const Duration(days: 60)),
                initialDate: day,
              );
              if (d != null) set(() => day = d);
            },
            child: Text(DateFormat.MMMEd(loc).format(day)),
          ),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                FieldLabel(l.shiftStart),
                OutlinedButton(
                  onPressed: () async {
                    final t = await showTimePicker(context: ctx, initialTime: start);
                    if (t != null) set(() => start = t);
                  },
                  child: Text(start.format(ctx)),
                ),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                FieldLabel(l.shiftEnd),
                OutlinedButton(
                  onPressed: () async {
                    final t = await showTimePicker(context: ctx, initialTime: end);
                    if (t != null) set(() => end = t);
                  },
                  child: Text(end.format(ctx)),
                ),
              ]),
            ),
          ]),
          if (end.hour * 60 + end.minute <= start.hour * 60 + start.minute)
            Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.shiftOvernight, style: Theme.of(ctx).textTheme.bodySmall)),
          FieldLabel(l.noteOptional),
          TextField(controller: note, maxLength: 80, decoration: const InputDecoration(counterText: '')),
          DialogActions(primary: l.addShift, onPrimary: who == null ? null : () => Navigator.of(ctx).pop(true)),
        ]),
      ),
    );
    if (ok != true || who == null || !mounted) return;
    await guard(
      context,
      () => ref.read(apiProvider).post('/api/v1/rota', {
        'user_id': who,
        'day': _ymd(day),
        'start': _hm(start),
        'end': _hm(end),
        if (note.text.trim().isNotEmpty) 'note': note.text.trim(),
      }),
    );
    _load();
  }

  Future<void> _copyLastWeek() async {
    final l = AppLocalizations.of(context);
    await guard(context, () async {
      final r = await ref.read(apiProvider).post('/api/v1/rota/copy-week', {
        'week_start': _ymd(_from!.subtract(const Duration(days: 7))),
      });
      if (mounted) showDone(context, l.weekCopied((r['copied'] as num).toInt(), (r['skipped'] as num).toInt()));
    });
    _load();
  }

  Future<void> _remove(Map s) async {
    await guard(context, () => ref.read(apiProvider).delete('/api/v1/rota/${s['id']}'));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final d = _data;
    if (_error != null) return Glass(child: EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, _error!)));
    if (d == null) return const LoadingBlock();
    final loc = Localizations.localeOf(context).toLanguageTag();
    final shifts = (d['shifts'] as List).cast<Map<String, dynamic>>();
    final days = [for (var i = 0; i < 7; i++) _from!.add(Duration(days: i))];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        IconButton(tooltip: l.previousWeek, onPressed: () => _shift(-7), icon: const Icon(Icons.chevron_left_rounded)),
        Text('${DateFormat.MMMd(loc).format(days.first)} – ${DateFormat.MMMd(loc).format(days.last)}', style: tt.titleMedium),
        IconButton(tooltip: l.nextWeek, onPressed: () => _shift(7), icon: const Icon(Icons.chevron_right_rounded)),
        FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add_rounded, size: 18), label: Text(l.addShift)),
        OutlinedButton.icon(
          onPressed: _copyLastWeek,
          icon: const Icon(Icons.copy_all_rounded, size: 18),
          label: Text(l.copyLastWeek),
        ),
      ]),
      const SizedBox(height: Gap.m),
      for (final day in days) ...[
        Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(DateFormat.MMMEd(loc).format(day), style: tt.titleSmall),
            if (!shifts.any((s) => s['day'] == _ymd(day)))
              Text(l.noShiftsPlanned, style: tt.bodySmall)
            else
              for (final s in shifts.where((s) => s['day'] == _ymd(day)))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s['user']['name'] as String),
                  subtitle: Text([
                    '${s['start']} – ${s['end']}${s['overnight'] == true ? ' (+1)' : ''}',
                    if (s['note'] != null) '${s['note']}',
                  ].join(' · ')),
                  trailing: Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    shiftStateChip(context, s),
                    IconButton(
                      tooltip: l.removeShift,
                      onPressed: () => _remove(s),
                      icon: Icon(Icons.close_rounded, size: 18, color: t.dim),
                    ),
                  ]),
                ),
          ]),
        ),
        const SizedBox(height: 10),
      ],
    ]);
  }
}

/// "My next shifts" on My work.
class MyShiftsCard extends ConsumerWidget {
  const MyShiftsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final shifts = ref.watch(myRotaProvider).value ?? const [];
    if (shifts.isEmpty) return const SizedBox.shrink();
    final loc = Localizations.localeOf(context).toLanguageTag();
    return Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardTitle(l.myNextShifts),
        for (final s in shifts.take(5))
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(DateFormat.MMMEd(loc).format(DateTime.parse(s['day'] as String))),
            subtitle: Text('${s['start']} – ${s['end']}${s['overnight'] == true ? ' (+1)' : ''}'),
            trailing: shiftStateChip(context, s),
          ),
      ]),
    );
  }
}
