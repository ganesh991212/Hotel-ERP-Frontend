import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';
import '../floor/floor_page.dart' show VegMark, menuDataProvider;
import '../floor/cart.dart' show OfferBadge, comboContents;
import 'menu_options.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  String _cat = '';
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(sessionProvider).value!;
    final data = ref.watch(menuDataProvider);
    final canEdit = s.can('menu.manage');
    return PageBody(children: [
      Reveal(
        index: 0,
        child: PageHeading(l.tabMenu, actions: [
          SizedBox(
            width: context.isPhone ? double.infinity : 280,
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.searchMenu),
            ),
          ),
          if (canEdit)
            OutlinedButton.icon(
              onPressed: () => showPriceRulesDialog(context),
              icon: const Icon(Icons.local_offer_outlined, size: 18),
              label: Text(l.happyHour),
            ),
          if (canEdit)
            OutlinedButton.icon(
              onPressed: () => showAddonGroupsDialog(context),
              icon: const Icon(Icons.playlist_add_rounded, size: 18),
              label: Text(l.addonGroups),
            ),
          if (canEdit)
            OutlinedButton.icon(
              onPressed: () => showCategoryForm(context, null),
              icon: const Icon(Icons.create_new_folder_outlined, size: 18),
              label: Text(l.addCategory),
            ),
          if (canEdit)
            FilledButton.icon(
              onPressed: () => data.whenData((d) => _itemDialog(context, d.$1, null)),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l.addItem),
            ),
        ]),
      ),
      data.when(
        loading: () => const LoadingBlock(),
        error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
        data: (d) {
          final (cats, items) = d;
          final q = _search.text.trim().toLowerCase();
          final shown = items
              .where((i) => _cat.isEmpty || i['category_id'] == _cat)
              .where((i) => q.isEmpty || (i['name'] as String).toLowerCase().contains(q))
              .toList();
          final catName = {for (final c in cats) c['id']: c['name']};
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Reveal(
              index: 1,
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                CountChip(label: l.all, count: items.length, selected: _cat.isEmpty, onTap: () => setState(() => _cat = '')),
                for (final c in cats)
                  CountChip(
                    label: c['name'],
                    count: items.where((i) => i['category_id'] == c['id']).length,
                    selected: _cat == c['id'],
                    onTap: () => setState(() => _cat = c['id']),
                  ),
                // Rename the selected category and set its serving hours.
                if (canEdit && _cat.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => showCategoryForm(context, cats.firstWhere((c) => c['id'] == _cat)),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l.editCategory),
                  ),
              ]),
            ),
            const SizedBox(height: 16),
            Reveal(
              index: 2,
              child: Glass(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: cats.isEmpty
                    ? EmptyState(icon: Icons.restaurant_menu, title: l.menuEmpty, body: l.menuEmptyBody)
                    : shown.isEmpty
                        ? EmptyState(icon: Icons.search_off_rounded, title: l.noMatches)
                        : Column(children: [
                            if (!context.isPhone) _HeaderRow(),
                            for (final i in shown)
                              _ItemRow(
                                item: i,
                                category: catName[i['category_id']] ?? '',
                                canEdit: canEdit,
                                onEdit: () => _itemDialog(context, cats, i),
                              ),
                          ]),
              ),
            ),
          ]);
        },
      ),
    ]);
  }

  Future<void> _itemDialog(BuildContext context, List<Map<String, dynamic>> cats, Map<String, dynamic>? item) async {
    final l = AppLocalizations.of(context);
    if (cats.isEmpty) {
      showDone(context, l.addCategoryFirst);
      return;
    }
    await showGlassDialog(context,
        title: item == null ? l.addItem : l.editItem, body: _ItemForm(cats: cats, item: item));
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final st = Theme.of(context).textTheme.labelMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(flex: 4, child: Text(l.name, style: st)),
        Expanded(flex: 2, child: Text(l.category, style: st)),
        Expanded(flex: 2, child: Text(l.price, style: st)),
        Expanded(flex: 2, child: Text(l.prepTime, style: st)),
        Expanded(flex: 2, child: Text(l.availability, style: st)),
        const SizedBox(width: 48),
      ]),
    );
  }
}

class _ItemRow extends ConsumerWidget {
  const _ItemRow({required this.item, required this.category, required this.canEdit, required this.onEdit});
  final Map<String, dynamic> item;
  final String category;
  final bool canEdit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final available = item['is_available'] == true;
    final toggle = Row(mainAxisSize: MainAxisSize.min, children: [
      Switch(
        value: available,
        onChanged: (v) => guard(context, () async {
          await ref.read(apiProvider).post('/api/v1/items/${item['id']}/availability', {'is_available': v});
          ref.invalidate(menuDataProvider);
        }),
      ),
      const SizedBox(width: 4),
      Flexible(
        child: StatusChip(
          icon: available ? Icons.check_circle_outline : Icons.remove_circle_outline,
          label: available ? l.available : l.soldOut,
          color: available ? t.ok : t.warn,
        ),
      ),
    ]);
    final name = Row(children: [
      VegMark(veg: item['is_veg'] == true),
      const SizedBox(width: 10),
      Expanded(child: Text(item['name'], style: tt.titleSmall, overflow: TextOverflow.ellipsis)),
    ]);
    final edit = canEdit
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(tooltip: l.edit, onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 18)),
            PopupMenuButton<int>(
              tooltip: '${l.sizes} / ${l.addons}',
              icon: const Icon(Icons.more_vert_rounded, size: 18),
              onSelected: (v) => switch (v) {
                0 => showSizesDialog(context, item),
                1 => showItemAddonsDialog(context, item),
                _ => showComboDialog(context, item),
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 0, child: Text(l.sizes)),
                PopupMenuItem(value: 1, child: Text(l.addons)),
                PopupMenuItem(value: 2, child: Text(l.combo)),
              ],
            ),
          ])
        : const SizedBox(width: 48);
    // With sizes, show each size's price (from the server) instead of the single price.
    final variants = (item['variants'] as List?) ?? const [];
    final price = variants.isEmpty
        ? formatInr(item['price_minor'])
        : variants.map((v) => '${v['name']} ${formatInr(v['price_minor'])}').join(' / ');
    final groups = (item['addon_groups'] as List?) ?? const [];
    final extras = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (comboContents(item).isNotEmpty) Text('${l.combo}: ${comboContents(item)}', style: tt.labelSmall),
      OfferBadge(item: item),
      if (variants.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: SizeAvailabilityChips(item: item)),
      if (groups.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${l.addons}: ${groups.map((g) => g['name']).join(', ')}', style: tt.labelSmall),
        ),
    ]);
    final row = context.isPhone
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: name), edit]),
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Text('$category · $price · ${l.minutesShort(item['est_prep_minutes'])}',
                    style: tt.bodySmall),
              ),
              Padding(padding: const EdgeInsets.only(left: 26), child: extras),
              Padding(padding: const EdgeInsets.only(left: 18), child: toggle),
            ]),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [name, extras])),
              Expanded(flex: 2, child: Text(category, style: tt.bodyMedium)),
              Expanded(flex: 2, child: Text(price, style: tt.bodyMedium)),
              Expanded(flex: 2, child: Text(l.minutesShort(item['est_prep_minutes']), style: tt.bodyMedium)),
              Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: toggle)),
              edit,
            ]),
          );
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: t.line))),
      child: row,
    );
  }
}

class _ItemForm extends ConsumerStatefulWidget {
  const _ItemForm({required this.cats, required this.item});
  final List<Map<String, dynamic>> cats;
  final Map<String, dynamic>? item;

  @override
  ConsumerState<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends ConsumerState<_ItemForm> {
  late final _name = TextEditingController(text: widget.item?['name']);
  late final _desc = TextEditingController(text: widget.item?['description']);
  late final _price = TextEditingController(text: widget.item == null ? '' : minorToInput(widget.item!['price_minor']));
  late String _cat = widget.item?['category_id'] ?? widget.cats.first['id'];
  late bool _veg = widget.item?['is_veg'] ?? true;
  late int _prep = widget.item?['est_prep_minutes'] ?? 10;
  final _form = GlobalKey<FormState>();
  bool _busy = false;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final body = {
      'category_id': _cat,
      'name': _name.text.trim(),
      'description': _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      'is_veg': _veg,
      'price_minor': parseInrToMinor(_price.text),
      'est_prep_minutes': _prep,
    };
    final api = ref.read(apiProvider);
    final ok = await guard(context, () async {
      if (widget.item == null) {
        await api.post('/api/v1/items', body);
      } else {
        await api.patch('/api/v1/items/${widget.item!['id']}', body);
      }
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ref.invalidate(menuDataProvider);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Form(
      key: _form,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(l.name),
        TextFormField(controller: _name, validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null),
        FieldLabel(l.category),
        DropdownButtonFormField<String>(
          initialValue: _cat,
          items: [for (final c in widget.cats) DropdownMenuItem(value: c['id'] as String, child: Text(c['name']))],
          onChanged: (v) => setState(() => _cat = v!),
        ),
        FieldLabel(l.priceRupees, help: l.priceHelp),
        TextFormField(
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => parseInrToMinor(v ?? '') == null ? l.errAmount : null,
          decoration: const InputDecoration(prefixText: '₹ '),
        ),
        FieldLabel(l.prepTime),
        ChoiceRow<int>(
          options: [for (final m in [5, 10, 15, 20, 30]) (m, l.minutesShort(m))],
          value: _prep,
          onChanged: (v) => setState(() => _prep = v),
        ),
        FieldLabel(l.type),
        ChoiceRow<bool>(options: [(true, l.veg), (false, l.nonVeg)], value: _veg, onChanged: (v) => setState(() => _veg = v)),
        FieldLabel(l.descriptionOptional),
        TextFormField(controller: _desc, maxLines: 2),
        DialogActions(primary: l.save, onPrimary: _save, busy: _busy),
      ]),
    );
  }
}
