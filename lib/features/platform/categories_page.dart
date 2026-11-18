import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';

final _globalCatsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async =>
    ((await ref.read(apiProvider).get('/api/v1/platform/expense-categories')) as List).cast<Map<String, dynamic>>());

/// Global expense categories: every hotel sees these; hotels add their own on top.
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final data = ref.watch(_globalCatsProvider);
    return PageBody(maxWidth: 820, children: [
      Reveal(index: 0, child: PageHeading(l.expenseCategories)),
      Reveal(
        index: 1,
        child: Glass(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.globalCategoriesHelp, style: tt.bodySmall),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _name, decoration: InputDecoration(hintText: l.newGlobalCategory))),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () async {
                  if (_name.text.trim().isEmpty) return;
                  final ok = await guard(context,
                      () => ref.read(apiProvider).post('/api/v1/platform/expense-categories', {'name': _name.text.trim()}));
                  if (ok) {
                    _name.clear();
                    if (context.mounted) showDone(context, l.globalCategoryAdded);
                  }
                  ref.invalidate(_globalCatsProvider);
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l.add),
              ),
            ]),
            const SizedBox(height: 12),
            data.when(
              loading: () => const LoadingBlock(height: 120),
              error: (e, _) => Text(errorText(context, e)),
              data: (list) => Column(children: [
                for (final c in list)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(children: [
                      Icon(Icons.public, size: 18, color: c['is_active'] == true ? t.info : t.faint),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(c['name'],
                            style: tt.bodyMedium?.copyWith(color: c['is_active'] == true ? t.ink : t.faint)),
                      ),
                      Text(l.usedTimes(c['used'] as int), style: tt.labelSmall),
                      const SizedBox(width: 8),
                      Switch(
                        value: c['is_active'] == true,
                        onChanged: (v) async {
                          await guard(context, () => ref
                              .read(apiProvider)
                              .patch('/api/v1/platform/expense-categories/${c['id']}', {'is_active': v}));
                          ref.invalidate(_globalCatsProvider);
                        },
                      ),
                    ]),
                  ),
              ]),
            ),
          ]),
        ),
      ),
    ]);
  }
}
