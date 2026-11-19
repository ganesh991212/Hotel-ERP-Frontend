import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/api/api_client.dart';
import 'package:hotel_erp/core/auth/session.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/features/hotel/orders_page.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

class _Admin extends SessionController {
  @override
  Future<Session?> build() async => Session(
        me: {
          'id': 'u1',
          'permissions': ['order.view', 'bill.manage', 'bill.void'],
          'outlet': {'kitchen_mode': 'CHEF_ACCEPT'},
        },
        entitlements: null,
      );
}

Map<String, dynamic> _order(int n) => {
      'id': 'o$n',
      'number': n,
      'status': 'SERVED',
      'channel': 'WAITER',
      'table': {'id': 't1', 'label': 'N3'},
      'items': [
        {'qty': 1, 'name': 'Naan'},
      ],
      'total_minor': 6000,
      'bill_id': 'b1',
      'created_at': '2026-11-20T10:00:00Z',
      'on_paper': false,
    };

void main() {
  testWidgets('orders load by hotel day, 50 a page, with search and a bills register', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final asked = <Uri>[];
    final api = ApiClient(httpClient: MockClient((req) async {
      asked.add(req.url);
      final p = req.url.path, q = req.url.queryParameters;
      Object body = const [];
      if (p.endsWith('/dashboard/me')) body = {'from': '2026-11-20', 'to': '2026-11-20', 'sections': []};
      if (p.endsWith('/tables')) {
        body = [
          {'id': 't1', 'label': 'N3', 'state': 'BILL_PENDING', 'unbilled_total_minor': 56000},
          {'id': 't2', 'label': 'N4', 'state': 'FREE', 'unbilled_total_minor': 0},
        ];
      }
      if (p.endsWith('/orders')) {
        final offset = int.parse(q['offset'] ?? '0');
        body = [for (var i = 0; i < (offset == 0 ? 50 : 3); i++) _order(200 - offset - i)];
      }
      if (p.endsWith('/bills')) body = const [];
      return http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
    }));
    await tester.pumpWidget(ProviderScope(
      overrides: [apiProvider.overrideWithValue(api), sessionProvider.overrideWith(_Admin.new)],
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: OrdersPage()),
      ),
    ));
    await tester.pumpAndSettle();

    Uri last(String suffix) => asked.lastWhere((u) => u.path.endsWith(suffix));
    final first = last('/orders');
    expect(first.queryParameters['from'], '2026-11-20', reason: "the hotel's today, from the server");
    expect(first.queryParameters['to'], '2026-11-20');
    expect(first.queryParameters['limit'], '50');
    expect(first.queryParameters['offset'], '0');

    // One Bill button per table that owes money (one bill per visit), none per order.
    expect(find.text('Table N3 · ₹560'), findsOneWidget);
    expect(find.text('Table N4 · ₹0'), findsNothing);

    final page = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;
    await tester.scrollUntilVisible(find.text('Load more'), 400, scrollable: page);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(last('/orders').queryParameters['offset'], '50');
    expect(find.text('Load more'), findsNothing, reason: 'last page was short');

    await tester.drag(page, const Offset(0, 6000));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '#187');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(last('/orders').queryParameters['q'], '#187');
    expect(last('/orders').queryParameters['offset'], '0', reason: 'a new search starts from the first page');

    await tester.tap(find.text('Bills'));
    await tester.pumpAndSettle();
    expect(last('/bills').queryParameters['from'], '2026-11-20');
    await tester.tap(find.text('Unpaid'));
    await tester.pumpAndSettle();
    expect(last('/bills').queryParameters['status'], 'ISSUED');
    expect(find.text('No bills in this period'), findsOneWidget);
  });
}
