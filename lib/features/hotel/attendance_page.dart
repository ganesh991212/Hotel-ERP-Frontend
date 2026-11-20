import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';
import 'rota.dart';

/// Attendance (backend docs/03 "Attendance", docs/14): clock in / out on your own login; managers see everyone,
/// with missed clock-outs flagged (never closed by the system) and corrections that need a reason.
final attendanceMeProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) async => Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/attendance/me')),
);

/// "1 h 05 m" from whole minutes (a count of time, not money).
String hoursLabel(AppLocalizations l, int minutes) => l.hoursMinutes(minutes ~/ 60, (minutes % 60).toString().padLeft(2, '0'));

/// Clock in / Clock out, for whoever is signed in.
class ClockButton extends ConsumerWidget {
  const ClockButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final me = ref.watch(attendanceMeProvider).value;
    if (me == null) return const SizedBox.shrink();
    final inNow = me['clocked_in'] == true;
    Future<void> tap() async {
      final ok = await guard(
        context,
        () => ref.read(apiProvider).post('/api/v1/attendance/${inNow ? 'clock-out' : 'clock-in'}', const {}),
      );
      ref.invalidate(attendanceMeProvider);
      if (ok && context.mounted) showDone(context, inNow ? l.clockedOut : l.clockedIn);
    }

    final since = inNow ? DateTime.parse(me['shift']['clock_in_at'] as String).toLocal() : null;
    return inNow
        ? OutlinedButton.icon(
            onPressed: tap,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(l.clockOutSince(DateFormat.jm(Localizations.localeOf(context).toLanguageTag()).format(since!))),
          )
        : FilledButton.icon(onPressed: tap, icon: const Icon(Icons.login_rounded, size: 18), label: Text(l.clockIn));
  }
}

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  int _days = 1; // today, or the last 7 days
  String _view = 'attendance'; // or 'rota'
  Map<String, dynamic>? _data;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      // The server's "today" is the hotel's; for a week, ask from 6 days before the hotel's today.
      var q = '';
      if (_days > 1 && _data != null) {
        final to = DateTime.parse(_data!['to'] as String);
        q = '?from=${DateFormat('yyyy-MM-dd').format(to.subtract(Duration(days: _days - 1)))}';
      }
      final d = Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/attendance$q'));
      if (mounted) setState(() => (_data = d, _error = null));
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _fix(Map<String, dynamic> shift) async {
    final l = AppLocalizations.of(context);
    final inAt = DateTime.parse(shift['clock_in_at'] as String).toLocal();
    var outAt = shift['clock_out_at'] == null ? null : DateTime.parse(shift['clock_out_at'] as String).toLocal();
    final reason = TextEditingController();
    final fmt = DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag()).add_jm();
    final ok = await showGlassDialog<bool>(
      context,
      title: l.fixShift(shift['user']['name'] as String),
      body: StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.clockedInAt(fmt.format(inAt))),
          const SizedBox(height: 8),
          FieldLabel(l.clockOutTime),
          OutlinedButton.icon(
            icon: const Icon(Icons.schedule_rounded, size: 18),
            label: Text(outAt == null ? l.pickTime : fmt.format(outAt!)),
            onPressed: () async {
              final base = outAt ?? inAt.add(const Duration(hours: 8));
              final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(base));
              if (t == null) return;
              // Same day as clock-in, or the next day for a shift past midnight.
              var pick = DateTime(inAt.year, inAt.month, inAt.day, t.hour, t.minute);
              if (!pick.isAfter(inAt)) pick = pick.add(const Duration(days: 1));
              set(() => outAt = pick);
            },
          ),
          FieldLabel(l.fixReason),
          TextField(controller: reason, maxLength: 200, decoration: const InputDecoration(counterText: '')),
          Text(l.fixShiftHelp, style: Theme.of(ctx).textTheme.bodySmall),
          DialogActions(primary: l.saveFix, onPrimary: () => Navigator.of(ctx).pop(true)),
        ]),
      ),
    );
    if (ok != true || outAt == null || !mounted) return;
    await guard(
      context,
      () => ref.read(apiProvider).post('/api/v1/attendance/${shift['id']}/fix', {
        'clock_out_at': outAt!.toUtc().toIso8601String(),
        'reason': reason.text.trim(),
      }),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final d = _data;
    final fmt = DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag()).add_jm();
    return PageBody(children: [
      Reveal(
        index: 0,
        child: PageHeading(l.attendance, actions: [
          PillTabs<String>(
            items: [('attendance', l.attendance), ('rota', l.rota)],
            selected: _view,
            onSelect: (v) => setState(() => _view = v),
          ),
          const ClockButton(),
        ]),
      ),
      if (_view == 'rota') const RotaView() else ...[
      Wrap(spacing: 8, children: [
        for (final (n, label) in [(1, l.periodToday), (7, l.lastDays(7))])
          CountChip(
            label: label,
            count: null,
            selected: _days == n,
            onTap: () {
              setState(() => _days = n);
              _load();
            },
          ),
      ]),
      const SizedBox(height: Gap.m),
      if (_error != null)
        Glass(child: EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, _error!)))
      else if (d == null)
        const LoadingBlock()
      else if ((d['shifts'] as List).isEmpty)
        Glass(child: EmptyState(icon: Icons.badge_outlined, title: l.noShifts, body: l.attendanceHelp))
      else ...[
        Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CardTitle(l.people),
            for (final p in (d['people'] as List).cast<Map>())
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Avatar(p['name'] as String, size: 32),
                title: Text(p['name'] as String),
                subtitle: Text(l.attendanceLine(p['days'] as int, hoursLabel(l, p['minutes'] as int))),
                trailing: (p['missing_clock_outs'] as int) > 0
                    ? StatusChip(icon: Icons.warning_amber_rounded, label: l.noClockOut, color: t.warn)
                    : null,
              ),
          ]),
        ),
        const SizedBox(height: Gap.m),
        Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CardTitle(l.shifts),
            for (final s in (d['shifts'] as List).cast<Map<String, dynamic>>())
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s['user']['name'] as String),
                subtitle: Text([
                  '${fmt.format(DateTime.parse(s['clock_in_at'] as String).toLocal())} → '
                      '${s['clock_out_at'] == null ? '…' : fmt.format(DateTime.parse(s['clock_out_at'] as String).toLocal())}',
                  if (s['corrected'] == true) l.correctedBecause('${s['correction_reason']}'),
                ].join('\n')),
                trailing: Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  if (s['missing_clock_out'] == true)
                    StatusChip(icon: Icons.warning_amber_rounded, label: l.noClockOut, color: t.warn)
                  else if (s['open'] == true)
                    StatusChip(icon: Icons.timelapse_rounded, label: l.onShiftNow, color: t.ok)
                  else
                    Text(hoursLabel(l, s['minutes'] as int), style: tt.labelLarge),
                  IconButton(
                    tooltip: l.fixShiftShort,
                    onPressed: () => _fix(s),
                    icon: Icon(Icons.edit_outlined, size: 18, color: t.dim),
                  ),
                ]),
              ),
          ]),
        ),
      ],
      ],
    ]);
  }
}
