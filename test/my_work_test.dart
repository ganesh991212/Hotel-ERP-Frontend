import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/api/api_client.dart';
import 'package:hotel_erp/core/auth/session.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/features/hotel/my_work_page.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:hotel_erp/ui/shell.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

/// A waiter's day as the server reports it (money already summed server-side).
const _serving = {
  'period': 'today',
  'from': '2026-11-19',
  'to': '2026-11-19',
  'sections': [
    {
      'kind': 'serving',
      'orders_served': 14,
      'tables_served': 6,
      'avg_serve_minutes': 2.4,
      'team_avg_serve_minutes': 3.1,
      'orders_taken': 9,
      'orders_taken_minor': 452000,
      'ready_to_serve_now': 2,
    },
  ],
};

void main() {
  testWidgets('a waiter sees their own serving numbers with the team average', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? asked;
    final api = ApiClient(httpClient: MockClient((req) async {
      if (req.url.path.endsWith('/rota/me')) {
        return http.Response(jsonEncode({'shifts': []}), 200, headers: {'content-type': 'application/json'});
      }
      if (req.url.path.endsWith('/attendance/me')) {
        return http.Response(jsonEncode({'clocked_in': false, 'shift': null}), 200,
            headers: {'content-type': 'application/json'});
      }
      asked = req.url.toString();
      return http.Response(jsonEncode(_serving), 200, headers: {'content-type': 'application/json'});
    }));
    await tester.pumpWidget(ProviderScope(
      overrides: [apiProvider.overrideWithValue(api)],
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: MyWorkPage()),
      ),
    ));
    await tester.pumpAndSettle();

    expect(asked, endsWith('/api/v1/dashboard/me?period=today'));
    expect(find.text('Your serving'), findsOneWidget);
    expect(find.text('Your cooking'), findsNothing, reason: 'only the sections the server sends');
    expect(find.text('Clock in'), findsOneWidget, reason: 'everyone clocks in on their own login');
    expect(find.text('14'), findsOneWidget);
    expect(find.text('2.4 min'), findsOneWidget);
    expect(find.text('Team 3.1 min'), findsOneWidget);
    expect(find.text('₹4,520'), findsOneWidget, reason: 'value of orders they took, formatted only');

    await tester.tap(find.text('Last 7 days'));
    await tester.pumpAndSettle();
    expect(asked, endsWith('period=week'));
  });

  testWidgets('staff without the hotel dashboard get their own work as Overview', (tester) async {
    late List<NavTab> waiter, admin;
    Session who(List<String> perms) => Session(me: {'id': 'u', 'permissions': perms}, entitlements: null);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (c) {
        waiter = tabsFor(c, who(['order.view', 'order.serve']));
        admin = tabsFor(c, who(['order.view', 'dashboard.view', 'bill.manage']));
        return const SizedBox();
      }),
    ));
    expect(waiter.first.path, '/h/me');
    // Regression: '/h/menu' starts with '/h/me', so the dock highlighted Overview on the Menu page and the
    // route guard admitted '/h/menu' for anyone who had '/h/me'.
    expect(isUnderTab('/h/menu', '/h/me'), isFalse);
    expect(isUnderTab('/h/me', '/h/me'), isTrue);
    expect(isUnderTab('/h/menu/items', '/h/menu'), isTrue);
    expect(waiter.where((t) => isUnderTab('/h/menu', t.path)), isEmpty, reason: 'no Menu permission, no Menu page');
    expect(admin.first.path, '/h/overview');
    expect(admin.any((t) => t.path == '/h/me'), isFalse);
  });
}
