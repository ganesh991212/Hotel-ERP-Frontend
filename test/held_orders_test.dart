import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/features/floor/cart.dart';
import 'package:hotel_erp/features/floor/held_orders.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

final _menu = <Map<String, dynamic>>[
  {
    'id': 'biryani',
    'name': 'Biryani',
    'variants': [
      {'id': 'half', 'name': 'Half', 'is_available': true},
      {'id': 'full', 'name': 'Full', 'is_available': true},
    ],
    'addon_groups': [
      {
        'id': 'g',
        'addons': [
          {'id': 'raita', 'name': 'Raita'},
        ],
      },
    ],
  },
  {'id': 'chai', 'name': 'Chai'},
];

/// A hold as the server lists it: ids to put back, and its quote (names and today's prices).
final _held = <String, dynamic>{
  'id': 'h1',
  'table': null,
  'customer_name': 'Ravi',
  'created_at': '2026-11-20T14:12:00Z',
  'items': [
    {
      'item_id': 'biryani',
      'qty': 2,
      'variant_id': 'full',
      'addons': [
        {'addon_id': 'raita', 'qty': 1},
      ],
    },
    {'item_id': 'chai', 'qty': 3},
    {'item_id': 'gone', 'qty': 1},
  ],
  'quote': {
    'total_minor': 52000,
    'lines': [
      {'name': 'Biryani'},
      {'name': 'Chai'},
      {'name': 'Lassi'},
    ],
  },
  'problem': null,
};

void main() {
  test('a hold goes back into the cart with sizes, add-ons and quantities; removed dishes are named', () {
    final cart = Cart();
    final missing = fillCartFromHeld(cart, _held, _menu);
    expect(missing, ['Lassi']);
    final lines = {for (final (line, n) in cart.entries) line.label: n};
    expect(lines, {'Biryani (Full) + Raita': 2, 'Chai': 3});
    expect(cart.json.first, {
      'item_id': 'biryani',
      'qty': 2,
      'variant_id': 'full',
      'addons': [
        {'addon_id': 'raita', 'qty': 1},
      ],
    });
  });

  test('held orders are listed per table, takeaway apart', () {
    final all = [
      _held,
      {..._held, 'id': 'h2', 'table': {'id': 't1', 'label': 'T1'}},
    ];
    expect(heldFor(all, null).map((h) => h['id']), ['h1']);
    expect(heldFor(all, 't1').map((h) => h['id']), ['h2']);
  });

  testWidgets('a held chip shows time, name and today\'s total, or that it needs changes', (tester) async {
    Map<String, dynamic>? resumed;
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: HeldStrip(
          held: [_held, {..._held, 'id': 'h3', 'customer_name': null, 'quote': null, 'problem': {'code': 'item_unavailable'}}],
          onResume: (h) => resumed = h,
          onDiscard: (_) {},
        ),
      ),
    ));
    expect(find.textContaining('Ravi · ₹520'), findsOneWidget);
    expect(find.textContaining('needs changes'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget, reason: 'icon + words, not colour alone');
    await tester.tap(find.textContaining('Ravi'));
    expect(resumed?['id'], 'h1');
  });
}
