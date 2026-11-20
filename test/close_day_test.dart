import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/features/hotel/close_day_page.dart';
import 'package:hotel_erp/features/hotel/handover.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// A saved close as the server sends it (every amount is the server's).
final _close = {
  'date': '2026-11-20',
  'opening_float_minor': 50000,
  'cash_sales_minor': 30000,
  'cash_paid_out_minor': 2000,
  'expected_minor': 78000,
  'counted_minor': 77000,
  'difference_minor': -1000,
  'result': 'SHORT',
  'float_kept_minor': 50000,
  'deposit_minor': 27000,
  'upi_minor': 12000,
  'card_minor': 0,
  'note': 'Change given twice',
  'closed_by': 'Asha',
  'closed_at': '2026-11-20T16:00:00Z',
  'cash_after_close_minor': 6300,
};

Future<void> _show(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(380, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a closed day shows the ladder, the shortfall with icon + label, and late cash', (tester) async {
    await _show(tester, ClosedDay(c: _close));
    expect(tester.takeException(), isNull, reason: 'fits a phone');
    expect(find.text('Short ₹10'), findsOneWidget);
    expect(find.byIcon(Icons.trending_down_rounded), findsOneWidget);
    expect(find.text('₹780'), findsOneWidget, reason: 'expected, as the server sent it');
    expect(find.text('To the bank: ₹270'), findsOneWidget);
    expect(find.text('Cash taken after closing: ₹63'), findsOneWidget);
    expect(find.text('"Change given twice"'), findsOneWidget);
  });

  testWidgets('history sums come from the server', (tester) async {
    await _show(
      tester,
      CloseHistory(
        h: {
          'closes': [_close],
          'net_difference_minor': -1000,
          'short_days': 1,
          'over_days': 0,
        },
      ),
    );
    expect(find.text('1 short day'), findsOneWidget);
    expect(find.text('Net over/short: −₹10'), findsOneWidget);
  });

  testWidgets('each handover shows who, when and its own over / short from the server', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: HandoversList(items: [
          {'at': '2026-11-20T09:30:00Z', 'handed_by': 'Asha', 'taken_by': 'Kiran', 'counted_minor': 95000,
            'expected_minor': 100000, 'difference_minor': -5000, 'result': 'SHORT', 'note': 'Gave change twice'},
          {'at': '2026-11-20T15:30:00Z', 'handed_by': 'Kiran', 'taken_by': 'Asha', 'counted_minor': 120000,
            'expected_minor': 120000, 'difference_minor': 0, 'result': 'EXACT', 'note': null},
        ]),
      ),
    ));
    expect(find.text('Shift handovers today'), findsOneWidget);
    expect(find.textContaining('Asha → Kiran'), findsOneWidget);
    expect(find.text('Counted ₹950 of ₹1,000 expected'), findsOneWidget);
    expect(find.text('Gave change twice'), findsOneWidget);
    expect(find.text('Short ₹50'), findsOneWidget);
    expect(find.text('Exact'), findsOneWidget);
  });
}
