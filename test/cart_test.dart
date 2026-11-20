import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/features/floor/cart.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// A dish as GET /items sends it: two sizes (one sold out shown greyed) and two add-on groups.
final _biryani = <String, dynamic>{
  'id': 'b',
  'name': 'Biryani',
  'price_minor': 28000,
  'is_available': true,
  'variants': [
    {'id': 'h', 'name': 'Half', 'price_minor': 18000, 'is_available': true},
    {'id': 'f', 'name': 'Full', 'price_minor': 28000, 'is_available': true},
    {'id': 'q', 'name': 'Quarter', 'price_minor': 9000, 'is_available': false},
  ],
  'addon_groups': [
    {
      'id': 'x',
      'name': 'Extras',
      'min_select': 0,
      'max_select': 3,
      'addons': [
        {'id': 'r', 'name': 'Raita', 'price_minor': 3000, 'is_available': true},
        {'id': 'c', 'name': 'Cheese', 'price_minor': 4000, 'is_available': true},
      ],
    },
    {
      'id': 'y',
      'name': 'Bread',
      'min_select': 1,
      'max_select': 1,
      'addons': [
        {'id': 'ro', 'name': 'Roti', 'price_minor': 0, 'is_available': true},
        {'id': 'na', 'name': 'Naan', 'price_minor': 0, 'is_available': true},
      ],
    },
  ],
};

void main() {
  test('same dish, size and add-ons share a line; different choices do not', () {
    final cart = Cart();
    final half = CartLine(_biryani, variant: _biryani['variants'][0], addons: {'r': 1}, addonNames: {'r': 'Raita'});
    cart
      ..add(half)
      ..add(CartLine(_biryani, variant: _biryani['variants'][0], addons: {'r': 1}, addonNames: {'r': 'Raita'}))
      ..add(CartLine(_biryani, variant: _biryani['variants'][1]))
      ..add(CartLine({'id': 'chai', 'name': 'Chai'}));
    expect(cart.qtyOf('b'), 3);
    expect(cart.count, 4);
    expect(half.label, 'Biryani (Half) + Raita');
    expect(cart.json, [
      {
        'item_id': 'b',
        'qty': 2,
        'variant_id': 'h',
        'addons': [
          {'addon_id': 'r', 'qty': 1},
        ],
      },
      {'item_id': 'b', 'qty': 1, 'variant_id': 'f'},
      {'item_id': 'chai', 'qty': 1},
    ]);
    cart.removeLastOf('b'); // takes back the latest Biryani (the Full)
    expect(cart.json.map((l) => l['variant_id']), ['h', null]);
  });

  testWidgets('a waiter picks a size and add-ons on one sheet; nothing is pre-selected', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    CartLine? got;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => got = await showItemChoices(context, _biryani),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'fits a phone');

    FilledButton add() =>
        tester.widget<FilledButton>(find.ancestor(of: find.text('Add'), matching: find.byType(FilledButton)));
    expect(add().onPressed, isNull, reason: 'a size must be chosen');
    // The sold-out size is shown but cannot be chosen.
    expect(
      tester
          .widget<ChoiceChip>(find.ancestor(of: find.textContaining('Quarter'), matching: find.byType(ChoiceChip)))
          .onSelected,
      isNull,
    );

    await tester.tap(find.textContaining('Half'));
    await tester.pump();
    expect(add().onPressed, isNull, reason: 'Bread is required (choose 1)');
    await tester.tap(find.text('Roti'));
    await tester.tap(find.textContaining('Raita'));
    await tester.tap(find.textContaining('Cheese'));
    await tester.pump();
    await tester.tap(find.textContaining('Cheese'));
    await tester.pump();
    expect(find.textContaining('2 x Cheese'), findsOneWidget);
    expect(add().onPressed, isNotNull);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(got?.json(1), {
      'item_id': 'b',
      'qty': 1,
      'variant_id': 'h',
      'addons': [
        {'addon_id': 'ro', 'qty': 1},
        {'addon_id': 'r', 'qty': 1},
        {'addon_id': 'c', 'qty': 2},
      ],
    });
    expect(got?.label, 'Biryani (Half) + Roti, Raita, 2 x Cheese');
  });

  testWidgets('a running offer shows as a badge with icon and label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Column(
            children: [
              OfferBadge(
                item: {
                  'offer': {'name': 'Happy hour', 'percent_bp': 2000, 'until': '19:00'},
                },
              ),
              OfferBadge(item: {'offer': null}),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Happy hour −20% till 19:00'), findsOneWidget);
    expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget, reason: 'no badge without an offer');
  });

  test('the kitchen sees every dish in a combo and every add-on, times the quantity', () {
    final line = {
      'qty': 2,
      'components': [
        {'item_id': 'b', 'name': 'Biryani', 'qty': 1},
        {'item_id': 'n', 'name': 'Naan', 'qty': 2},
      ],
      'addons': [
        {'name': 'Lassi', 'qty': 1},
        {'name': 'Cheese', 'qty': 2},
      ],
    };
    expect(orderLineDetails(line), ['2 × Biryani', '4 × Naan', '+ Lassi', '+ 2 × Cheese']);
    expect(orderLineDetails({'qty': 1}), isEmpty);
    expect(comboContents({'components': line['components']}), '1 Biryani + 2 Naan');
  });
}
