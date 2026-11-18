import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/session.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';

final tablesAdminProvider = liveProvider<List<Map<String, dynamic>>>(
    (api) async => ((await api.get('/api/v1/tables')) as List).cast<Map<String, dynamic>>());

class TablesPage extends ConsumerWidget {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(tablesAdminProvider);
    return PageBody(children: [
      Reveal(
        index: 0,
        child: PageHeading(l.tabTables, actions: [
          OutlinedButton.icon(
            onPressed: () => data.whenData((list) => _qrSheet(context, list)),
            icon: const Icon(Icons.print_outlined, size: 18),
            label: Text(l.qrSheet),
          ),
          FilledButton.icon(
            onPressed: () => _addTable(context, ref),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l.addTable),
          ),
        ]),
      ),
      data.when(
        loading: () => const LoadingBlock(),
        error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
        data: (list) => list.isEmpty
            ? Glass(child: EmptyState(icon: Icons.qr_code_2_rounded, title: l.noTables, body: l.noTablesBody))
            : LayoutBuilder(builder: (context, c) {
                final cols = (c.maxWidth / 250).floor().clamp(1, 6);
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: .78,
                  children: [
                    for (final (i, t) in list.indexed) Reveal(index: 1 + i.clamp(0, 10), child: _QrCard(table: t)),
                  ],
                );
              }),
      ),
    ]);
  }

  Future<void> _addTable(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final label = TextEditingController();
    final area = TextEditingController();
    var seats = 4;
    await showGlassDialog(
      context,
      title: l.addTable,
      body: StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FieldLabel(l.tableName, help: l.tableNameHelp),
          TextField(controller: label, autofocus: true),
          FieldLabel(l.areaOptional),
          TextField(controller: area),
          FieldLabel(l.seatsLabel),
          ChoiceRow<int>(
            options: [for (final n in [2, 4, 6, 8]) (n, '$n')],
            value: seats,
            onChanged: (v) => set(() => seats = v),
          ),
          DialogActions(
            primary: l.save,
            onPrimary: () async {
              final ok = await guard(ctx, () => ref.read(apiProvider).post('/api/v1/tables', {
                    'label': label.text.trim(),
                    if (area.text.trim().isNotEmpty) 'area': area.text.trim(),
                    'seats': seats,
                  }));
              if (ok && ctx.mounted) {
                ref.invalidate(tablesAdminProvider);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ]),
      ),
    );
  }

  void _qrSheet(BuildContext context, List<Map<String, dynamic>> list) {
    final l = AppLocalizations.of(context);
    showGlassDialog(
      context,
      title: l.qrSheet,
      maxWidth: 900,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.qrSheetHelp, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        Wrap(spacing: 16, runSpacing: 16, children: [
          for (final t in list)
            Container(
              width: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: context.tokens.paper, borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                QrImageView(data: absoluteLink(t['qr_url']), size: 150, backgroundColor: context.tokens.paper),
                Text(t['label'], style: Theme.of(context).textTheme.titleLarge?.copyWith(color: context.tokens.paperInk)),
                Text(l.scanToOrder, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.tokens.paperInk.withValues(alpha: .6))),
              ]),
            ),
        ]),
      ]),
    );
  }
}

class _QrCard extends ConsumerWidget {
  const _QrCard({required this.table});
  final Map<String, dynamic> table;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final active = table['status'] == 'ACTIVE';
    return Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(table['label'], style: tt.headlineSmall)),
          PopupMenuButton<String>(
            tooltip: l.more,
            color: t.solid,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (v) => _action(context, ref, v),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'copy', child: Text(l.copyLink)),
              PopupMenuItem(value: 'open', child: Text(l.openDinerView)),
              PopupMenuItem(value: 'rotate', child: Text(l.rotateQr)),
              PopupMenuItem(value: 'toggle', child: Text(active ? l.deactivate : l.activate)),
            ],
          ),
        ]),
        Text([table['area'], l.seats(table['seats'])].whereType<String>().join(' · '), style: tt.labelMedium),
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: context.tokens.paper, borderRadius: BorderRadius.circular(Rad.tile)),
            padding: const EdgeInsets.all(10),
            child: Opacity(
              opacity: active ? 1 : .35,
              child: QrImageView(data: absoluteLink(table['qr_url']), backgroundColor: context.tokens.paper),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          if (active)
            StatusChip(icon: Icons.qr_code_2_rounded, label: l.qrActive, color: t.ok)
          else
            StatusChip(icon: Icons.block, label: l.inactive, color: t.faint),
          const Spacer(),
          if ((table['open_orders'] as int? ?? 0) > 0)
            StatusChip(icon: Icons.restaurant_rounded, label: l.openOrdersCount(table['open_orders']), color: t.accent),
        ]),
      ]),
    );
  }

  Future<void> _action(BuildContext context, WidgetRef ref, String v) async {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    switch (v) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: absoluteLink(table['qr_url'])));
        if (context.mounted) showDone(context, l.linkCopied);
      case 'open':
        await launchUrl(Uri.parse(absoluteLink(table['qr_url'])), webOnlyWindowName: '_blank');
      case 'rotate':
        final ok = await guard(context, () => api.post('/api/v1/tables/${table['id']}/rotate-qr'));
        if (ok && context.mounted) showDone(context, l.qrRotated);
      case 'toggle':
        await guard(context,
            () => api.patch('/api/v1/tables/${table['id']}', {'status': table['status'] == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}));
    }
    ref.invalidate(tablesAdminProvider);
  }
}
