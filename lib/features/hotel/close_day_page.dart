import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';

/// Close the day / cash drawer (backend docs/03 "Day close"). The server works out what the drawer should hold
/// and, as the cashier types, whether it is over or short; this screen never does arithmetic on money (rule 1).
enum _Tab { today, history }

int _i(Object? v) => (v as num?)?.toInt() ?? 0;

class CloseDayPage extends ConsumerStatefulWidget {
  const CloseDayPage({super.key});

  @override
  ConsumerState<CloseDayPage> createState() => _CloseDayPageState();
}

class _CloseDayPageState extends ConsumerState<CloseDayPage> {
  _Tab _tab = _Tab.today;
  Map<String, dynamic>? _p; // preview (or saved close)
  Map<String, dynamic>? _history;
  Object? _error;
  final _counted = TextEditingController();
  final _kept = TextEditingController();
  final _opening = TextEditingController();
  final _note = TextEditingController();
  Timer? _debounce;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_counted, _kept, _opening, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _typed => {
    if (parseInrToMinor(_counted.text) case final c?) 'counted_minor': '$c',
    if (parseInrToMinor(_kept.text) case final k?) 'float_kept_minor': '$k',
    if (parseInrToMinor(_opening.text) case final o?) 'opening_float_minor': '$o',
  };

  Future<void> _load() async {
    try {
      final q = Uri(queryParameters: _typed).query;
      final p = Map<String, dynamic>.from(
        await ref.read(apiProvider).get('/api/v1/day-close${q.isEmpty ? '' : '?$q'}'),
      );
      if (mounted) {
        setState(() {
          _p = p;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _loadHistory() async {
    try {
      final h = Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/day-closes'));
      if (mounted) setState(() => _history = h);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _typedChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _load);
    setState(() {});
  }

  Future<void> _close() async {
    final l = AppLocalizations.of(context);
    final counted = parseInrToMinor(_counted.text);
    if (counted == null) return showWarning(context, l.errPriceInvalid);
    final ok = await showGlassDialog<bool>(
      context,
      title: l.closeDayButton,
      body: Builder(
        builder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.closeDayConfirm),
            DialogActions(primary: l.closeDayButton, onPrimary: () => Navigator.of(ctx).pop(true)),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    await guard(context, () async {
      await ref.read(apiProvider).post('/api/v1/day-close', {
        'counted_minor': counted,
        'float_kept_minor': parseInrToMinor(_kept.text) ?? 0,
        if (_p?['carried_float_minor'] == null) 'opening_float_minor': parseInrToMinor(_opening.text) ?? 0,
        if (_note.text.trim().isNotEmpty) 'note': _note.text.trim(),
      });
      await _load();
      _history = null;
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageBody(
      maxWidth: 820,
      children: [
        Reveal(index: 0, child: PageHeading(l.closeDay)),
        Reveal(
          index: 1,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: PillTabs<_Tab>(
              items: [(_Tab.today, l.today), (_Tab.history, l.history)],
              selected: _tab,
              onSelect: (t) {
                setState(() => _tab = t);
                if (t == _Tab.history && _history == null) _loadHistory();
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_error != null)
          Glass(
            child: EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, _error!)),
          )
        else if (_tab == _Tab.today)
          _p == null ? const LoadingBlock() : _today(context, _p!)
        else
          _history == null ? const LoadingBlock() : CloseHistory(h: _history!),
      ],
    );
  }

  Widget _today(BuildContext context, Map<String, dynamic> p) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    if (p['closed'] != null) return Glass(child: ClosedDay(c: Map<String, dynamic>.from(p['closed'] as Map)));
    final check = p['check'] as Map?;
    final unpaid = Map<String, dynamic>.from(p['unpaid_bills'] as Map);
    final firstClose = p['carried_float_minor'] == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Glass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.closeDayHelp, style: tt.bodySmall),
              const SizedBox(height: 10),
              if (firstClose) ...[
                FieldLabel(l.openingFloat),
                TextField(
                  controller: _opening,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(prefixText: '₹ ', hintText: '0'),
                  onChanged: (_) => _typedChanged(),
                ),
              ] else
                MoneyLine(l.openingFloat, _i(p['opening_float_minor'])),
              MoneyLine(l.cashReceived, _i(p['cash_sales_minor'])),
              MoneyLine(l.cashPaidOut, _i(p['cash_paid_out_minor']), minus: true),
              Divider(height: 14, color: t.hair),
              MoneyLine(l.expectedInDrawer, _i(p['expected_minor']), strong: true),
              const SizedBox(height: 6),
              Text(
                '${l.payUpi} ${formatInr(_i(p['upi_minor']))} · ${l.payCard} ${formatInr(_i(p['card_minor']))}',
                style: tt.bodySmall,
              ),
              if (_i(unpaid['count']) > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: t.warn),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(l.unpaidBillsWarning(_i(unpaid['count']), formatInr(_i(unpaid['total_minor'])))),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Glass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(l.countedCash),
              TextField(
                controller: _counted,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(prefixText: '₹ '),
                onChanged: (_) => _typedChanged(),
              ),
              FieldLabel(l.keepForTomorrow),
              TextField(
                controller: _kept,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(prefixText: '₹ ', hintText: '0'),
                onChanged: (_) => _typedChanged(),
              ),
              if (check != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ResultChip(result: check['result'] as String, differenceMinor: _i(check['difference_minor'])),
                    Text(l.toDeposit(formatInr(_i(check['deposit_minor']))), style: tt.bodyMedium),
                  ],
                ),
              ],
              FieldLabel(check != null && check['result'] != 'EXACT' ? l.whyDifferent : l.noteOptional),
              TextField(controller: _note, maxLength: 200),
              FilledButton.icon(
                onPressed: _busy || parseInrToMinor(_counted.text) == null ? null : _close,
                icon: const Icon(Icons.lock_clock_outlined, size: 18),
                label: Text(l.closeDayButton),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Label + server amount. [minus] only prefixes a sign; no arithmetic.
class MoneyLine extends StatelessWidget {
  const MoneyLine(this.label, this.minor, {super.key, this.minus = false, this.strong = false});
  final String label;
  final int minor;
  final bool minus, strong;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final style = strong ? tt.titleMedium : tt.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text('${minus && minor != 0 ? '− ' : ''}${formatInr(minor)}', style: style),
        ],
      ),
    );
  }
}

/// Over / Short / Exact with icon + label (never colour alone). The amount is the server's difference.
class ResultChip extends StatelessWidget {
  const ResultChip({super.key, required this.result, required this.differenceMinor});
  final String result;
  final int differenceMinor;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    // The server's difference is negative when short; show its size with the word "Short" (display only).
    final amount = formatInr(differenceMinor).replaceFirst('−', '');
    return switch (result) {
      'OVER' => StatusChip(icon: Icons.trending_up_rounded, label: l.cashOver(amount), color: t.warn),
      'SHORT' => StatusChip(icon: Icons.trending_down_rounded, label: l.cashShort(amount), color: t.danger),
      _ => StatusChip(icon: Icons.check_circle_outline, label: l.cashExact, color: t.ok),
    };
  }
}

class ClosedDay extends StatelessWidget {
  const ClosedDay({super.key, required this.c});
  final Map<String, dynamic> c;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final at = DateTime.parse(c['closed_at'] as String).toLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat.yMMMEd(Localizations.localeOf(context).toLanguageTag())
                    .format(DateTime.parse(c['date'] as String)),
                style: tt.titleMedium,
              ),
            ),
            ResultChip(result: c['result'] as String, differenceMinor: _i(c['difference_minor'])),
          ],
        ),
        const SizedBox(height: 6),
        MoneyLine(l.openingFloat, _i(c['opening_float_minor'])),
        MoneyLine(l.cashReceived, _i(c['cash_sales_minor'])),
        MoneyLine(l.cashPaidOut, _i(c['cash_paid_out_minor']), minus: true),
        MoneyLine(l.expectedInDrawer, _i(c['expected_minor'])),
        Divider(height: 14, color: t.hair),
        MoneyLine(l.countedCash, _i(c['counted_minor']), strong: true),
        MoneyLine(l.keepForTomorrow, _i(c['float_kept_minor'])),
        Text(l.toDeposit(formatInr(_i(c['deposit_minor']))), style: tt.bodyMedium),
        if (c['note'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('"${c['note']}"', style: tt.bodySmall),
          ),
        if (_i(c['cash_after_close_minor']) > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: t.warn),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l.cashAfterClose(formatInr(_i(c['cash_after_close_minor']))), style: tt.bodySmall),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Text(l.dayClosedBy('${c['closed_by'] ?? ''}', DateFormat.Hm().format(at)), style: tt.labelSmall),
      ],
    );
  }
}

class CloseHistory extends StatelessWidget {
  const CloseHistory({super.key, required this.h});
  final Map<String, dynamic> h;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final closes = (h['closes'] as List).cast<Map>().map(Map<String, dynamic>.from).toList();
    if (closes.isEmpty) {
      return Glass(
        child: EmptyState(icon: Icons.lock_clock_outlined, title: l.noCloses),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Glass(
          child: Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Text(l.netOverShort(formatInr(_i(h['net_difference_minor'])))),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_down_rounded, size: 18, color: _i(h['short_days']) > 0 ? t.danger : t.dim),
                  const SizedBox(width: 4),
                  Text(l.shortDays(_i(h['short_days']))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final c in closes) ...[Glass(child: ClosedDay(c: c)), const SizedBox(height: 10)],
      ],
    );
  }
}
