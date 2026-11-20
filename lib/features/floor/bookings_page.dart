import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/session.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';

/// Reservations and the walk-in waitlist (backend docs/03 "Bookings"). One book, entered by staff.
enum _Tab { day, waitlist }

final _bookableTablesProvider = FutureProvider.autoDispose<List<Map>>(
  (ref) async => ((await ref.read(apiProvider).get('/api/v1/tables')) as List).cast<Map>(),
);

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> {
  _Tab _tab = _Tab.day;
  DateTime? _day; // hotel day shown; null = today (server's)
  Map<String, dynamic>? _d;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final q = _day == null ? '' : '?date=${DateFormat('yyyy-MM-dd').format(_day!)}';
      final d = Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/bookings$q'));
      if (mounted) {
        setState(() {
          _d = d;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _act(String id, String path, Map<String, dynamic> body) async {
    await guard(context, () async {
      await ref.read(apiProvider).post('/api/v1/bookings/$id/$path', body);
      await _load();
    });
  }

  /// Seat: the booked table, or pick a free one.
  Future<void> _seat(Map<String, dynamic> b) async {
    final l = AppLocalizations.of(context);
    String? tableId = (b['table'] as Map?)?['id'] as String?;
    if (tableId == null) {
      final tables = ((await ref.read(apiProvider).get('/api/v1/tables')) as List).cast<Map>();
      final free = tables.where(
        (t) => t['status'] == 'ACTIVE' && !{'SEATED', 'OCCUPIED', 'BILL_PENDING'}.contains(t['state']),
      );
      if (!mounted) return;
      tableId = await showGlassDialog<String>(
        context,
        title: l.pickTable,
        body: Builder(
          builder: (ctx) => free.isEmpty
              ? EmptyState(icon: Icons.table_restaurant_outlined, title: l.noFreeTables)
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in free)
                      ActionChip(
                        label: Text('${t['label']}'),
                        onPressed: () => Navigator.of(ctx).pop(t['id'] as String),
                      ),
                  ],
                ),
        ),
      );
      if (tableId == null) return;
    }
    await _act(b['id'] as String, 'seat', {'table_id': tableId});
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _day ?? now,
    );
    if (d != null) {
      setState(() => _day = d);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _d;
    return PageBody(
      maxWidth: 900,
      children: [
        Reveal(
          index: 0,
          child: PageHeading(
            l.bookings,
            actions: [
              OutlinedButton.icon(
                onPressed: () => _form(waitlist: true),
                icon: const Icon(Icons.hourglass_top_rounded, size: 18),
                label: Text(l.addToWaitlist),
              ),
              FilledButton.icon(
                onPressed: () => _form(waitlist: false),
                icon: const Icon(Icons.event_available_rounded, size: 18),
                label: Text(l.newBooking),
              ),
            ],
          ),
        ),
        Reveal(
          index: 1,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PillTabs<_Tab>(
                items: [
                  (
                    _Tab.day,
                    d == null
                        ? l.today
                        : DateFormat.MMMEd(Localizations.localeOf(context).toLanguageTag())
                              .format(DateTime.parse(d['date'])),
                  ),
                  (_Tab.waitlist, '${l.waitlist}${d == null ? '' : ' · ${(d['waitlist'] as List).length}'}'),
                ],
                selected: _tab,
                onSelect: (t) => setState(() => _tab = t),
              ),
              if (_tab == _Tab.day)
                IconButton(tooltip: l.pickDates, onPressed: _pickDay, icon: const Icon(Icons.calendar_month_outlined)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_error != null)
          Glass(
            child: EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, _error!)),
          )
        else if (d == null)
          const LoadingBlock()
        else
          _list(context, d),
      ],
    );
  }

  Widget _list(BuildContext context, Map<String, dynamic> d) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final rows = ((_tab == _Tab.day ? d['bookings'] : d['waitlist']) as List)
        .cast<Map>()
        .map(Map<String, dynamic>.from)
        .toList();
    if (rows.isEmpty) {
      return Glass(
        child: EmptyState(
          icon: _tab == _Tab.day ? Icons.event_available_rounded : Icons.hourglass_empty_rounded,
          title: _tab == _Tab.day ? l.noBookingsDay : l.nobodyWaiting,
        ),
      );
    }
    return Glass(
      child: Column(
        children: [
          for (final (i, b) in rows.indexed) ...[
            if (i > 0) Divider(height: 1, color: t.hair),
            BookingRow(b: b, onSeat: () => _seat(b), onStatus: (s) => _act(b['id'] as String, 'status', {'status': s})),
          ],
        ],
      ),
    );
  }

  Future<void> _form({required bool waitlist}) async {
    final ok = await showGlassDialog<bool>(
      context,
      title: waitlist ? AppLocalizations.of(context).addToWaitlist : AppLocalizations.of(context).newBooking,
      maxWidth: 520,
      body: BookingForm(waitlist: waitlist, avgWait: (_d?['avg_wait_minutes_today'] as num?)?.toInt()),
    );
    if (ok == true) {
      setState(() => _tab = waitlist ? _Tab.waitlist : _Tab.day);
      _load();
    }
  }
}

class BookingRow extends StatelessWidget {
  const BookingRow({super.key, required this.b, required this.onSeat, required this.onStatus});
  final Map<String, dynamic> b;
  final VoidCallback onSeat;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final open = b['status'] == 'BOOKED' || b['status'] == 'WAITING';
    final isBooking = b['kind'] == 'BOOKING';
    final when = isBooking ? DateFormat.jm().format(DateTime.parse(b['booked_for'] as String).toLocal()) : null;
    final waited = (b['waited_minutes'] as num?)?.toInt() ?? 0;
    final quoted = (b['quoted_minutes'] as num?)?.toInt();
    final late = !isBooking && quoted != null && waited > quoted;
    final noShows = (b['no_shows_before'] as num?)?.toInt() ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (when != null) ...[Text(when, style: tt.titleMedium), const SizedBox(width: 10)],
              Expanded(child: Text('${b['name']} · ${l.guestsN((b['guests'] as num).toInt())}', style: tt.titleSmall)),
              if (b['table'] != null) Text(l.tableLabel(b['table']['label'] as String), style: tt.labelLarge),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (b['phone'] != null) Text('${b['phone']}', style: tt.bodySmall),
              if (b['note'] != null) Text('“${b['note']}”', style: tt.bodySmall),
              if (!isBooking && open)
                StatusChip(
                  icon: Icons.timer_outlined,
                  label: quoted != null ? l.waitedOfQuoted(waited, quoted) : l.waitedMin(waited),
                  color: late ? t.warn : t.dim,
                ),
              if (noShows > 0)
                StatusChip(icon: Icons.person_off_outlined, label: l.noShowsBefore(noShows), color: t.warn),
              if (!open)
                StatusChip(
                  icon: switch (b['status']) {
                    'SEATED' => Icons.event_seat_rounded,
                    'NO_SHOW' => Icons.person_off_outlined,
                    _ => Icons.cancel_outlined,
                  },
                  label: switch (b['status']) {
                    'SEATED' => l.bookingStatusSeated,
                    'NO_SHOW' => l.noShow,
                    _ => l.bookingStatusCancelled,
                  },
                  color: b['status'] == 'SEATED' ? t.ok : t.dim,
                ),
            ],
          ),
          if (open)
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onSeat,
                  icon: const Icon(Icons.event_seat_rounded, size: 18),
                  label: Text(l.seat),
                ),
                if (isBooking) TextButton(onPressed: () => onStatus('NO_SHOW'), child: Text(l.noShow)),
                TextButton(onPressed: () => onStatus('CANCELLED'), child: Text(l.cancelBooking)),
              ],
            ),
        ],
      ),
    );
  }
}

class BookingForm extends ConsumerStatefulWidget {
  const BookingForm({super.key, required this.waitlist, this.avgWait});
  final bool waitlist;
  final int? avgWait;

  @override
  ConsumerState<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends ConsumerState<BookingForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();
  final _quote = TextEditingController();
  int _guests = 2;
  DateTime _at = DateTime.now().add(const Duration(hours: 1));
  String? _table;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _note, _quote]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _at,
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    if (t == null) return;
    setState(() => _at = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _save({bool allowOverlap = false}) async {
    final l = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final body = {
      'kind': widget.waitlist ? 'WAITLIST' : 'BOOKING',
      'name': _name.text.trim(),
      if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
      'guests': _guests,
      if (!widget.waitlist) 'booked_for': _at.toUtc().toIso8601String(),
      if (widget.waitlist && int.tryParse(_quote.text.trim()) != null) 'quoted_minutes': int.parse(_quote.text.trim()),
      if (_table != null) 'table_id': _table,
      if (_note.text.trim().isNotEmpty) 'note': _note.text.trim(),
      if (allowOverlap) 'allow_overlap': true,
    };
    try {
      await ref.read(apiProvider).post('/api/v1/bookings', body);
      if (mounted) Navigator.of(context).pop(true);
      return;
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'table_booked') {
        final other = DateFormat.jm().format(DateTime.parse(e.details['booked_for'] as String).toLocal());
        final again = await showGlassDialog<bool>(
          context,
          title: l.newBooking,
          body: Builder(
            builder: (ctx) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.tableBookedWarn('${e.details['name']}', other)),
                DialogActions(primary: l.bookAnyway, onPrimary: () => Navigator.of(ctx).pop(true)),
              ],
            ),
          ),
        );
        if (again == true && mounted) return _save(allowOverlap: true);
      } else {
        showError(context, e);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final tables = ref.watch(_bookableTablesProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(l.name),
        TextField(controller: _name, autofocus: true, textCapitalization: TextCapitalization.words),
        FieldLabel(l.phoneOptional),
        TextField(controller: _phone, keyboardType: TextInputType.phone),
        FieldLabel(l.guestsCountLabel),
        Row(
          children: [
            IconButton(
              onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$_guests', style: tt.titleLarge),
            IconButton(
              onPressed: _guests < 99 ? () => setState(() => _guests++) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        if (!widget.waitlist) ...[
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.schedule_rounded, size: 18),
            label: Text(DateFormat.MMMEd(Localizations.localeOf(context).toLanguageTag()).add_jm().format(_at)),
          ),
          FieldLabel(l.tableOptional),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: Text(l.anyTable),
                selected: _table == null,
                onSelected: (_) => setState(() => _table = null),
              ),
              for (final t in tables.where((t) => t['status'] == 'ACTIVE'))
                ChoiceChip(
                  label: Text('${t['label']}'),
                  selected: _table == t['id'],
                  onSelected: (_) => setState(() => _table = t['id'] as String),
                ),
            ],
          ),
        ] else ...[
          FieldLabel(l.quotedWait),
          TextField(controller: _quote, keyboardType: TextInputType.number),
          if (widget.avgWait != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l.avgWaitToday(widget.avgWait!), style: tt.bodySmall),
            ),
        ],
        FieldLabel(l.noteOptional),
        TextField(controller: _note, maxLength: 200),
        DialogActions(primary: l.save, busy: _busy, onPrimary: _busy ? null : _save),
      ],
    );
  }
}
