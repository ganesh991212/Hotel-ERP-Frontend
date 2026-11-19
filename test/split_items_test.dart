import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/api/api_client.dart';
import 'package:hotel_erp/core/auth/session.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/features/floor/split_items.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

const _preview = {
  'table_id': 't1',
  'lines': [
    {
      'key': 'Chai|4000|500',
      'name': 'Chai',
      'qty': 1,
      'unit_price_minor': 4000,
      'tax_rate_bp': 500,
      'line_total_minor': 4000,
    },
    {
      'key': 'Naan|6000|500',
      'name': 'Naan',
      'qty': 2,
      'unit_price_minor': 6000,
      'tax_rate_bp': 500,
      'line_total_minor': 12000,
    },
  ],
  'unserved': [],
  'open_bill': null,
  'open_bill_paid_minor': 0,
};

Map<String, dynamic> _bill(int g) => {
  'id': 'b$g',
  'invoice_no': 'INV/$g',
  'split': {'guest_no': g, 'guest_count': 2},
};

void main() {
  testWidgets('staff give out every dish, then the server issues one bill per guest', (tester) async {
    tester.view.physicalSize = const Size(390, 1400); // phone
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Map<String, dynamic>? sent;
    final api = ApiClient(
      httpClient: MockClient((req) async {
        if (req.method == 'POST') {
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'bills': [_bill(1), _bill(2)],
              'replaced_invoice_nos': [],
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(jsonEncode(_preview), 200, headers: {'content-type': 'application/json'});
      }),
    );
    List<Map<String, dynamic>>? result;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiProvider.overrideWithValue(api)],
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => result = await showSplitByItems(context, 't1'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'fits a phone');

    FilledButton create() => tester.widget<FilledButton>(
      find.ancestor(of: find.text('Create 2 bills'), matching: find.byType(FilledButton)),
    );
    expect(create().onPressed, isNull, reason: 'nothing given out yet');
    expect(find.text('2 left'), findsOneWidget);

    // Naan: one each (tap Guest 1, then Guest 2 on the Naan row: the second set of guest chips).
    await tester.tap(find.text('Guest 1').at(1));
    await tester.pump();
    await tester.tap(find.text('Guest 2').at(1));
    await tester.pump();
    expect(find.text('Guest 1 · 1'), findsOneWidget);
    expect(find.text('2 left'), findsNothing);
    // Chai: shared by both.
    await tester.tap(find.text('Shared').first);
    await tester.pump();
    await tester.tap(find.text('Guest 1').first);
    await tester.pump();
    expect(create().onPressed, isNull, reason: 'a share needs two guests');
    await tester.tap(find.text('Guest 2').first);
    await tester.pump();
    expect(create().onPressed, isNotNull);

    await tester.tap(find.text('Create 2 bills'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(sent, {
      'table_id': 't1',
      'guests': 2,
      'include_unserved': false,
      'lines': [
        {
          'key': 'Chai|4000|500',
          'shared': [1, 2],
        },
        {
          'key': 'Naan|6000|500',
          'qty': [1, 1],
        },
      ],
    });
    expect(result?.map((b) => b['invoice_no']), ['INV/1', 'INV/2']);
  });
}
