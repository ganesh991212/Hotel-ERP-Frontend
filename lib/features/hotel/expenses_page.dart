import 'dart:math' as math;

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

final _monthProvider = NotifierProvider<_Month, DateTime>(_Month.new);

class _Month extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime(DateTime.now().year, DateTime.now().month);
  void shift(int by) => state = DateTime(state.year, state.month + by);
}

String _ym(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

final _expensesProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final m = ref.watch(_monthProvider);
  return Map<String, dynamic>.from(await ref.read(apiProvider).get('/api/v1/expenses?month=${_ym(m)}'));
});
final _expenseCatsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async =>
    ((await ref.read(apiProvider).get('/api/v1/expense-categories')) as List).cast<Map<String, dynamic>>());

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(sessionProvider).value!;
    final month = ref.watch(_monthProvider);
    final data = ref.watch(_expensesProvider);
    final canEdit = s.can('expense.manage');
    return PageBody(children: [
      Reveal(
        index: 0,
        child: PageHeading(l.tabExpenses, actions: [
          Glass(
            strong: true,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                  tooltip: l.previousMonth,
                  onPressed: () => ref.read(_monthProvider.notifier).shift(-1),
                  icon: const Icon(Icons.chevron_left_rounded)),
              Text(DateFormat.yMMMM().format(month), style: Theme.of(context).textTheme.labelLarge),
              IconButton(
                  tooltip: l.nextMonth,
                  onPressed: () => ref.read(_monthProvider.notifier).shift(1),
                  icon: const Icon(Icons.chevron_right_rounded)),
            ]),
          ),
          if (canEdit)
            OutlinedButton.icon(
              onPressed: () async {
                await showGlassDialog(context, title: l.expenseCategories, body: const _CategoryManager());
                ref.invalidate(_expenseCatsProvider);
                ref.invalidate(_expensesProvider);
              },
              icon: const Icon(Icons.category_outlined, size: 18),
              label: Text(l.categories),
            ),
          if (canEdit)
            FilledButton.icon(
              onPressed: () => _edit(context, ref, null),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l.addExpense),
            ),
        ]),
      ),
      data.when(
        loading: () => const LoadingBlock(),
        error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
        data: (d) => _Body(d: d, canEdit: canEdit, onEdit: (e) => _edit(context, ref, e)),
      ),
    ]);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Map<String, dynamic>? e) async {
    final cats = await ref.read(_expenseCatsProvider.future);
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    await showGlassDialog(context, title: e == null ? l.addExpense : l.editExpense, body: _ExpenseForm(cats: cats, expense: e));
    ref.invalidate(_expensesProvider);
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.d, required this.canEdit, required this.onEdit});
  final Map<String, dynamic> d;
  final bool canEdit;
  final void Function(Map<String, dynamic>) onEdit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final cats = (d['by_category'] as List).cast<Map>();
    final items = (d['items'] as List).cast<Map<String, dynamic>>();
    final byDay = (d['by_day'] as List).cast<Map>();

    final summary = Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.spentThisMonth, style: tt.labelMedium),
        const SizedBox(height: 4),
        FittedBox(child: Text(formatInr(d['total_minor'], showPaise: false), style: tt.displayMedium)),
        const SizedBox(height: 16),
        if (cats.isEmpty)
          Text(l.noExpenses, style: tt.bodySmall)
        else
          for (final (i, c) in cats.take(6).indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PillBar(
                label: c['name'],
                text: '${formatInr(c['total_minor'], showPaise: false)} · ${(c['share_bp'] as int) ~/ 100}%',
                style: i == 0 ? BarStyle.night : (i == 1 ? BarStyle.accent : BarStyle.outline),
                fill: (c['share_bp'] as int) / 10000 + .25,
              ),
            ),
      ]),
    );

    final peak = math.max(1, byDay.fold<int>(0, (a, b) => math.max(a, b['total_minor'] as int)));
    final daily = Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CardTitle(l.byDay),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: byDay.isEmpty
              ? Center(child: Text(l.noExpenses, style: tt.bodySmall))
              : CapsuleBars(
                  height: 160,
                  values: [for (final b in byDay) (b['total_minor'] as int) / peak],
                  labels: [for (final b in byDay) '${DateTime.parse(b['date']).day}'],
                ),
        ),
      ]),
    );

    final list = Glass(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: items.isEmpty
          ? EmptyState(icon: Icons.receipt_long_outlined, title: l.noExpenses, body: l.noExpensesBody)
          : Column(children: [
              for (final e in items)
                InkWell(
                  borderRadius: BorderRadius.circular(Rad.tile),
                  onTap: canEdit ? () => onEdit(e) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    child: Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: t.well, borderRadius: BorderRadius.circular(14)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('${DateTime.parse(e['spent_on']).day}', style: tt.titleMedium),
                          Text(DateFormat.MMM().format(DateTime.parse(e['spent_on'])), style: tt.labelSmall),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e['vendor'] ?? e['category'], style: tt.titleSmall),
                          Text(
                            [e['category'], _method(context, e['payment_method']), if (e['note'] != null) e['note']].join(' · '),
                            style: tt.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]),
                      ),
                      Text(formatInr(e['amount_minor']), style: tt.titleMedium),
                    ]),
                  ),
                ),
            ]),
    );

    if (context.isDesktop) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(children: [Reveal(index: 1, child: summary), const SizedBox(height: Gap.m), Reveal(index: 2, child: daily)])),
        const SizedBox(width: Gap.m),
        Expanded(flex: 2, child: Reveal(index: 3, child: list)),
      ]);
    }
    return Column(children: [
      Reveal(index: 1, child: summary),
      const SizedBox(height: Gap.m),
      Reveal(index: 2, child: daily),
      const SizedBox(height: Gap.m),
      Reveal(index: 3, child: list),
    ]);
  }
}

String _method(BuildContext context, String m) {
  final l = AppLocalizations.of(context);
  return switch (m) {
    'CASH' => l.payCash,
    'UPI' => l.payUpi,
    'CARD' => l.payCard,
    _ => l.payBank,
  };
}

class _ExpenseForm extends ConsumerStatefulWidget {
  const _ExpenseForm({required this.cats, this.expense});
  final List<Map<String, dynamic>> cats;
  final Map<String, dynamic>? expense;

  @override
  ConsumerState<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<_ExpenseForm> {
  late final _amount = TextEditingController(text: widget.expense == null ? '' : minorToInput(widget.expense!['amount_minor']));
  late final _vendor = TextEditingController(text: widget.expense?['vendor']);
  late final _note = TextEditingController(text: widget.expense?['note']);
  late String _cat = widget.expense?['category_id'] ?? widget.cats.first['id'];
  late String _method = widget.expense?['payment_method'] ?? 'CASH';
  late DateTime _date = widget.expense == null ? DateTime.now() : DateTime.parse(widget.expense!['spent_on']);
  final _form = GlobalKey<FormState>();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final e = widget.expense;
    return Form(
      key: _form,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(l.amountRupees),
        TextFormField(
          controller: _amount,
          autofocus: e == null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '₹ '),
          validator: (v) => (parseInrToMinor(v ?? '') ?? 0) <= 0 ? l.errAmount : null,
        ),
        FieldLabel(l.category),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in widget.cats)
            CountChip(label: c['name'], count: null, selected: _cat == c['id'], onTap: () => setState(() => _cat = c['id'])),
        ]),
        FieldLabel(l.paidBy),
        ChoiceRow<String>(
          options: [('CASH', l.payCash), ('UPI', l.payUpi), ('CARD', l.payCard), ('BANK', l.payBank)],
          value: _method,
          onChanged: (v) => setState(() => _method = v),
        ),
        FieldLabel(l.date),
        OutlinedButton.icon(
          onPressed: () async {
            final d = await showDatePicker(
                context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)));
            if (d != null) setState(() => _date = d);
          },
          icon: const Icon(Icons.event_outlined, size: 18),
          label: Text(DateFormat.yMMMd().format(_date)),
        ),
        FieldLabel(l.vendorOptional),
        TextFormField(controller: _vendor),
        FieldLabel(l.noteOptional),
        TextFormField(controller: _note),
        Row(children: [
          if (e != null)
            TextButton.icon(
              onPressed: () async {
                final ok = await guard(context, () => ref.read(apiProvider).delete('/api/v1/expenses/${e['id']}'));
                if (ok && context.mounted) Navigator.of(context).pop();
              },
              icon: Icon(Icons.delete_outline, color: context.tokens.danger),
              label: Text(l.delete, style: TextStyle(color: context.tokens.danger)),
            ),
          Expanded(
            child: DialogActions(
              primary: l.save,
              busy: _busy,
              onPrimary: () async {
                if (!_form.currentState!.validate()) return;
                setState(() => _busy = true);
                final body = {
                  'category_id': _cat,
                  'amount_minor': parseInrToMinor(_amount.text),
                  'spent_on': DateFormat('yyyy-MM-dd').format(_date),
                  'payment_method': _method,
                  'vendor': _vendor.text.trim().isEmpty ? null : _vendor.text.trim(),
                  'note': _note.text.trim().isEmpty ? null : _note.text.trim(),
                };
                final api = ref.read(apiProvider);
                final ok = await guard(context,
                    () => e == null ? api.post('/api/v1/expenses', body) : api.patch('/api/v1/expenses/${e['id']}', body));
                if (!mounted) return;
                setState(() => _busy = false);
                if (ok) Navigator.of(this.context).pop();
              },
            ),
          ),
        ]),
      ]),
    );
  }
}


/// Global categories (set by the platform, same for every hotel) plus this hotel's own.
class _CategoryManager extends ConsumerStatefulWidget {
  const _CategoryManager();

  @override
  ConsumerState<_CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends ConsumerState<_CategoryManager> {
  final _name = TextEditingController();

  Future<void> _reload() async => ref.invalidate(_expenseCatsProvider);

  Future<void> _rename(Map c) async {
    final l = AppLocalizations.of(context);
    final ctl = TextEditingController(text: c['name']);
    await showGlassDialog(
      context,
      title: l.renameCategory,
      body: Builder(
        builder: (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(controller: ctl, autofocus: true),
          DialogActions(
            primary: l.save,
            onPrimary: () async {
              final ok = await guard(ctx,
                  () => ref.read(apiProvider).patch('/api/v1/expense-categories/${c['id']}', {'name': ctl.text.trim()}));
              if (ok && ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        ]),
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final cats = ref.watch(_expenseCatsProvider);
    return cats.when(
      loading: () => const LoadingBlock(height: 160),
      error: (e, _) => Text(errorText(context, e)),
      data: (list) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.categoriesHelp, style: tt.bodySmall),
        const SizedBox(height: 10),
        for (final c in list)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              Expanded(child: Text(c['name'], style: tt.bodyMedium)),
              if (c['scope'] == 'GLOBAL')
                StatusChip(icon: Icons.public, label: l.scopeGlobal, color: t.info)
              else ...[
                StatusChip(icon: Icons.storefront_outlined, label: l.scopeHotel, color: t.accentDeep),
                IconButton(tooltip: l.edit, onPressed: () => _rename(c), icon: const Icon(Icons.edit_outlined, size: 18)),
                IconButton(
                  tooltip: l.delete,
                  onPressed: () async {
                    await guard(context, () => ref.read(apiProvider).delete('/api/v1/expense-categories/${c['id']}'));
                    await _reload();
                  },
                  icon: Icon(Icons.delete_outline, size: 18, color: t.danger),
                ),
              ],
            ]),
          ),
        FieldLabel(l.addOwnCategory, help: l.addOwnCategoryHelp),
        Row(children: [
          Expanded(child: TextField(controller: _name)),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              if (_name.text.trim().isEmpty) return;
              final ok = await guard(
                  context, () => ref.read(apiProvider).post('/api/v1/expense-categories', {'name': _name.text.trim()}));
              if (ok) _name.clear();
              await _reload();
            },
            child: Text(l.add),
          ),
        ]),
      ]),
    );
  }
}
