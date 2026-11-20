import 'package:file_picker/file_picker.dart';
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
import '../../ui/status.dart';

/// Sales reports (backend docs/14 "Reports", docs/13 "Reports"). Every number comes from the server, which counts
/// issued bills only; this screen formats them and never adds anything up itself.
const maxReportDays = 92;

enum ReportKind { sales, items, gst, staff }

String _ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  ReportKind _kind = ReportKind.sales;
  DateTime? _today, _from, _to; // the hotel's own days, learned from the server's first answer
  Map<String, dynamic>? _data;
  Object? _error;
  bool _loading = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  String get _range => _from == null ? '' : '?${Uri(queryParameters: {'from': _ymd(_from!), 'to': _ymd(_to!)}).query}';

  Future<void> _load() async {
    final gen = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/reports/${_kind.name}$_range'));
      if (!mounted || gen != _generation) return;
      setState(() {
        _data = d;
        // No dates sent = the hotel's today (its timezone, not the phone's).
        _today ??= DateTime.parse(d['to'] as String);
        _from ??= DateTime.parse(d['from'] as String);
        _to ??= DateTime.parse(d['to'] as String);
      });
    } catch (e) {
      if (mounted && gen == _generation) setState(() => _error = e);
    }
    if (mounted && gen == _generation) setState(() => _loading = false);
  }

  void _setRange(DateTime from, DateTime to) {
    setState(() {
      _from = from;
      _to = to;
    });
    _load();
  }

  Future<void> _pickRange() async {
    final today = _today!;
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 7),
      lastDate: today,
      initialDateRange: DateTimeRange(start: _from!, end: _to!),
    );
    if (r == null || !mounted) return;
    if (r.end.difference(r.start).inDays >= maxReportDays) {
      showWarning(context, AppLocalizations.of(context).errRangeTooLongDays(maxReportDays));
      return;
    }
    _setRange(r.start, r.end);
  }

  Future<void> _download(String kind) async {
    final l = AppLocalizations.of(context);
    await guard(context, () async {
      final bytes = await ref.read(apiProvider).getBytes('/api/v1/reports/$kind.csv$_range');
      final name = '${kind}_${_ymd(_from!)}_${_ymd(_to!)}.csv';
      final saved = await FilePicker.saveFile(fileName: name, bytes: bytes, mimeType: 'text/csv');
      if (saved != null && mounted) showDone(context, l.fileSaved(name));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(sessionProvider).value!;
    final staffAllowed = s.feature('REPORTS_ADVANCED');
    final today = _today;
    final yesterday = today?.subtract(const Duration(days: 1));
    final monthStart = today == null ? null : DateTime(today.year, today.month);
    bool isRange(DateTime? a, DateTime? b) => a != null && _from == a && _to == b;
    final custom =
        today != null && !isRange(today, today) && !isRange(yesterday, yesterday) && !isRange(monthStart, today);
    final fmt = DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag());

    return PageBody(
      children: [
        Reveal(
          index: 0,
          child: PageHeading(
            l.reportsTitle,
            actions: [
              OutlinedButton.icon(
                onPressed: _from == null ? null : () => _download(_kind.name),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(l.downloadCsv),
              ),
              if (_kind == ReportKind.items)
                OutlinedButton.icon(
                  onPressed: _from == null ? null : () => _download('categories'),
                  icon: const Icon(Icons.category_outlined, size: 18),
                  label: Text(l.categoriesCsv),
                ),
              if (_kind == ReportKind.sales)
                OutlinedButton.icon(
                  onPressed: _from == null ? null : () => _download('register'),
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: Text(l.billsRegisterCsv),
                ),
            ],
          ),
        ),
        Reveal(
          index: 1,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: PillTabs<ReportKind>(
                items: [
                  (ReportKind.sales, l.reportSales),
                  (ReportKind.items, l.reportItems),
                  (ReportKind.gst, l.reportGst),
                  if (staffAllowed) (ReportKind.staff, l.reportStaff),
                ],
                selected: _kind,
                onSelect: (k) {
                  setState(() {
                    _kind = k;
                    _data = null;
                  });
                  _load();
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (today != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CountChip(
                label: l.ordersToday2,
                count: null,
                selected: isRange(today, today),
                onTap: () => _setRange(today, today),
              ),
              CountChip(
                label: l.yesterday,
                count: null,
                selected: isRange(yesterday, yesterday),
                onTap: () => _setRange(yesterday!, yesterday),
              ),
              CountChip(
                label: l.thisMonth,
                count: null,
                selected: isRange(monthStart, today) && monthStart != today,
                onTap: () => _setRange(monthStart!, today),
              ),
              CountChip(
                label: custom ? '${fmt.format(_from!)} – ${fmt.format(_to!)}' : l.pickDates,
                count: null,
                selected: custom,
                onTap: _pickRange,
              ),
            ],
          ),
        const SizedBox(height: 12),
        if (_error != null)
          Glass(
            child: EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, _error!)),
          )
        else if (_data == null || _loading && _data!['report'] != _kind.name)
          const LoadingBlock()
        else
          AnimatedOpacity(
            duration: Motion.fast,
            opacity: _loading ? .5 : 1,
            child: switch (_kind) {
              ReportKind.sales => SalesReport(d: _data!),
              ReportKind.items => ItemsReport(d: _data!),
              ReportKind.gst => GstReport(d: _data!),
              ReportKind.staff => StaffReport(d: _data!),
            },
          ),
      ],
    );
  }
}

int _i(Object? v) => (v as num?)?.toInt() ?? 0;

/// "What this report counts" line, so nobody has to guess (the main complaint about other platforms' reports).
class _Basis extends StatelessWidget {
  const _Basis(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 16, color: context.tokens.dim),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
      ],
    ),
  );
}

/// One label / amount line. [minus] shows a deduction without the client doing any arithmetic.
class _Line extends StatelessWidget {
  const _Line(this.label, this.minor, {this.minus = false, this.strong = false, this.sub});
  final String label;
  final int minor;
  final bool minus, strong;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final style = strong ? tt.titleMedium : tt.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: style),
                if (sub != null) Text(sub!, style: tt.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${minus && minor != 0 ? '− ' : ''}${formatInr(minor)}', style: style),
        ],
      ),
    );
  }
}

class _Ladder extends StatelessWidget {
  const _Ladder({required this.r});
  final Map<String, dynamic> r;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hair = Divider(height: 14, color: context.tokens.hair);
    return Column(
      children: [
        _Line(l.ladderGross, _i(r['gross_minor'])),
        _Line(l.ladderDiscount, _i(r['discount_minor']), minus: true),
        hair,
        _Line(l.ladderTaxable, _i(r['taxable_minor'])),
        _Line(l.cgst, _i(r['cgst_minor'])),
        _Line(l.sgst, _i(r['sgst_minor'])),
        if (_i(r['other_tax_minor']) != 0) _Line(l.ladderOtherTax, _i(r['other_tax_minor'])),
        if (_i(r['service_charge_minor']) != 0) _Line(l.serviceCharge, _i(r['service_charge_minor'])),
        if (_i(r['round_off_minor']) != 0) _Line(l.ladderRoundOff, _i(r['round_off_minor'])),
        hair,
        _Line(l.ladderTotal, _i(r['total_minor']), strong: true),
      ],
    );
  }
}

class SalesReport extends StatelessWidget {
  const SalesReport({super.key, required this.d});
  final Map<String, dynamic> d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final tot = Map<String, dynamic>.from(d['totals'] as Map);
    // Days with nothing happening are left off the screen (the CSV keeps every day).
    final days = (d['days'] as List)
        .cast<Map>()
        .map(Map<String, dynamic>.from)
        .where((r) => _i(r['bills']) > 0 || _i(r['received_minor']) > 0 || _i(r['cancelled_bills']) > 0)
        .toList();
    final unbilled = Map<String, dynamic>.from(d['unbilled'] as Map);
    final received = Map<String, dynamic>.from(tot['received'] as Map);
    final wide = context.width >= Breakpoints.desktop;

    final summary = Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Basis(l.basisSales),
          Wrap(
            spacing: 28,
            runSpacing: 12,
            children: [
              BigStat(
                value: formatInr(_i(tot['total_minor']), showPaise: false),
                label: l.repBills(_i(tot['bills'])),
                icon: Icons.receipt_long_outlined,
                compact: true,
              ),
            ],
          ),
          // Covers: guests counted once per visit; the average comes from the server.
          if (_i(tot['covers']) > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                Icon(Icons.groups_outlined, size: 16, color: context.tokens.dim),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${l.coversLine(_i(tot['covers']))} · ${l.avgPerGuest(formatInr(_i(tot['avg_per_cover_minor'])))}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ]),
            ),
          const SizedBox(height: 12),
          _Ladder(r: tot),
        ],
      ),
    );

    final status = Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusChip(
                icon: Icons.check_circle_outline_rounded,
                label: '${l.statusPaid} ${formatInr(_i(tot['paid_minor']))}',
                color: t.ok,
              ),
              StatusChip(
                icon: Icons.hourglass_bottom_rounded,
                label: '${l.billUnpaid} ${formatInr(_i(tot['unpaid_minor']))} · ${l.repBills(_i(tot['unpaid_bills']))}',
                color: t.warn,
              ),
              StatusChip(
                icon: Icons.block_rounded,
                label:
                    '${l.billCancelled} ${formatInr(_i(tot['cancelled_minor']))} · ${l.repBills(_i(tot['cancelled_bills']))}',
                color: t.danger,
              ),
            ],
          ),
          if (_i(tot['replaced_bills']) > 0) ...[
            const SizedBox(height: 8),
            Text(l.repReplaced(_i(tot['replaced_bills'])), style: tt.bodySmall),
          ],
          const SizedBox(height: 16),
          CardTitle(l.repReceived),
          const SizedBox(height: 6),
          for (final m in ['CASH', 'UPI', 'CARD'])
            _Line(payMethodLabel(context, m), _i(received['${m.toLowerCase()}_minor'])),
          Divider(height: 14, color: t.hair),
          _Line(l.total, _i(tot['received_minor']), strong: true),
        ],
      ),
    );

    final warn = _i(unbilled['orders']) == 0
        ? null
        : Glass(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: t.warn),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.repUnbilled(_i(unbilled['orders']), formatInr(_i(unbilled['value_minor']))),
                        style: tt.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(l.repUnbilledHelp, style: tt.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          );

    final byDay = (d['days'] as List).length < 2 || days.isEmpty
        ? null
        : Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle(l.repByDay),
                const SizedBox(height: 6),
                for (final (i, r) in days.indexed) ...[
                  if (i > 0) Divider(height: 1, color: t.hair),
                  _Line(
                    DateFormat.MMMEd(Localizations.localeOf(context).toLanguageTag())
                        .format(DateTime.parse(r['date'] as String)),
                    _i(r['total_minor']),
                    sub: '${l.repBills(_i(r['bills']))} · ${l.repReceived} ${formatInr(_i(r['received_minor']))}',
                  ),
                ],
              ],
            ),
          );

    if (_i(tot['bills']) == 0 && _i(tot['cancelled_bills']) == 0 && warn == null) {
      return Glass(
        child: EmptyState(icon: Icons.bar_chart_rounded, title: l.repNoBills, body: l.basisSales),
      );
    }
    final gap = const SizedBox(height: 12, width: 12);
    if (wide) {
      return Column(
        children: [
          ?warn,
          if (warn != null) gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: summary),
              gap,
              Expanded(
                child: Column(
                  children: [
                    status,
                    if (byDay != null) ...[gap, byDay],
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Column(
      children: [
        ?warn,
        if (warn != null) gap,
        summary,
        gap,
        status,
        if (byDay != null) ...[gap, byDay],
      ],
    );
  }
}

class ItemsReport extends StatelessWidget {
  const ItemsReport({super.key, required this.d});
  final Map<String, dynamic> d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final items = (d['items'] as List).cast<Map>().map(Map<String, dynamic>.from).toList();
    final tot = Map<String, dynamic>.from(d['totals'] as Map);
    if (items.isEmpty) {
      return Glass(
        child: EmptyState(icon: Icons.restaurant_menu, title: l.repNoBills, body: l.basisItems),
      );
    }
    final cats = ((d['categories'] as List?) ?? const []).cast<Map>().map(Map<String, dynamic>.from).toList();
    final itemsCard = Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Basis(l.basisItems),
          for (final (i, it) in items.indexed) ...[
            if (i > 0) Divider(height: 1, color: t.hair),
            _Line(
              it['name'] as String,
              _i(it['taxable_minor']),
              sub: _i(it['discount_minor']) == 0
                  ? l.repSold(_i(it['qty']))
                  : '${l.repSold(_i(it['qty']))} · ${formatInr(_i(it['gross_minor']))} − ${formatInr(_i(it['discount_minor']))}',
            ),
          ],
          Divider(height: 14, color: t.hair),
          _Line(l.ladderTaxable, _i(tot['taxable_minor']), strong: true, sub: l.repSold(_i(tot['qty']))),
        ],
      ),
    );
    if (cats.isEmpty) return itemsCard;
    // Categories come from the same bill lines as the items, so they add up to the same taxable total.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Glass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.repByCategory, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              _Basis(l.basisCategories),
              for (final (i, c) in cats.indexed) ...[
                if (i > 0) Divider(height: 1, color: t.hair),
                _Line(
                  c['category'] == 'Not recorded' ? l.repNotRecorded : c['category'] as String,
                  _i(c['taxable_minor']),
                  sub: l.repCategoryLine(_i(c['items']), '${c['qty']}', '${c['share_pct']}'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Gap.m),
        itemsCard,
      ],
    );
  }
}

class GstReport extends StatelessWidget {
  const GstReport({super.key, required this.d});
  final Map<String, dynamic> d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final rates = (d['by_rate'] as List).cast<Map>().map(Map<String, dynamic>.from).toList();
    final docs = (d['documents'] as List).cast<Map>().map(Map<String, dynamic>.from).toList();
    final tot = Map<String, dynamic>.from(d['totals'] as Map);
    final basis = l.basisGst(d['sac'] as String);
    if (docs.isEmpty) {
      return Glass(
        child: EmptyState(icon: Icons.account_balance_outlined, title: l.repNoBills, body: basis),
      );
    }
    String docName(String type) => switch (type) {
      'TAX_INVOICE' => l.docTaxInvoice,
      'BILL_OF_SUPPLY' => l.docBillOfSupply,
      _ => l.docBill,
    };
    return Column(
      children: [
        Glass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Basis(basis),
              for (final (i, r) in rates.indexed) ...[
                if (i > 0) Divider(height: 1, color: t.hair),
                _Line(
                  l.gstRate(percentLabel(_i(r['rate_bp']))),
                  _i(r['tax_minor']),
                  sub:
                      '${l.ladderTaxable} ${formatInr(_i(r['taxable_minor']))} · ${l.cgst} ${formatInr(_i(r['cgst_minor']))} · '
                      '${l.sgst} ${formatInr(_i(r['sgst_minor']))}',
                ),
              ],
              Divider(height: 14, color: t.hair),
              _Line(l.ladderTaxable, _i(tot['taxable_minor'])),
              _Line(l.cgst, _i(tot['cgst_minor'])),
              _Line(l.sgst, _i(tot['sgst_minor'])),
              _Line(l.total, _i(tot['tax_minor']), strong: true),
              if (_i(d['service_charge_minor']) != 0) _Line(l.serviceCharge, _i(d['service_charge_minor'])),
            ],
          ),
        ),
        // Company (B2B) bills one per line, as GSTR-1 lists them; the rates above include them (B2C is the rest).
        if (((d['b2b'] as List?) ?? const []).isNotEmpty) ...[
          const SizedBox(height: 12),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle(l.gstB2b),
                const SizedBox(height: 6),
                for (final (i, x) in (d['b2b'] as List).cast<Map>().indexed) ...[
                  if (i > 0) Divider(height: 1, color: t.hair),
                  _Line(
                    '${x['invoice_no']} · ${x['buyer_name']}',
                    _i(x['tax_minor']),
                    sub:
                        'GSTIN ${x['buyer_gstin']} · ${l.gstRate(percentLabel(_i(x['rate_bp'])))} · '
                        '${l.ladderTaxable} ${formatInr(_i(x['taxable_minor']))}',
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Glass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardTitle(l.gstDocuments),
              const SizedBox(height: 6),
              for (final x in docs)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${docName(x['doc_type'] as String)} · ${x['fy']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        l.gstDocCounts(
                          x['from_no'] as String,
                          x['to_no'] as String,
                          _i(x['count']),
                          _i(x['cancelled']),
                          _i(x['net']),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class StaffReport extends StatelessWidget {
  const StaffReport({super.key, required this.d});
  final Map<String, dynamic> d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final staff = (d['staff'] as List).cast<Map>().map(Map<String, dynamic>.from).toList();
    if (staff.isEmpty) {
      return Glass(
        child: EmptyState(icon: Icons.groups_2_outlined, title: l.noStaffActivity, body: l.basisStaff),
      );
    }
    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Basis(l.basisStaff),
          for (final (i, p) in staff.indexed) ...[
            if (i > 0) Divider(height: 18, color: t.hair),
            Row(
              children: [
                Avatar(p['name'] as String, size: 32),
                const SizedBox(width: 10),
                Expanded(child: Text(p['name'] as String, style: tt.titleSmall)),
              ],
            ),
            const SizedBox(height: 4),
            _Line(l.repBills(_i(p['bills'])), _i(p['billed_minor'])),
            _Line(
              l.repReceived,
              _i(p['received_minor']),
              sub: [
                for (final m in ['CASH', 'UPI', 'CARD'])
                  if (_i((p['received'] as Map)['${m.toLowerCase()}_minor']) != 0)
                    '${payMethodLabel(context, m)} ${formatInr(_i((p['received'] as Map)['${m.toLowerCase()}_minor']))}',
              ].join(' · '),
            ),
            if (_i(p['discounts']) > 0)
              Text(l.staffDiscounts(_i(p['discounts']), formatInr(_i(p['discount_minor']))), style: tt.bodySmall),
            if (_i(p['cancellations']) > 0)
              Row(
                children: [
                  Icon(Icons.block_rounded, size: 14, color: t.danger),
                  const SizedBox(width: 4),
                  Text(l.staffCancelled(_i(p['cancellations'])), style: tt.bodySmall),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
