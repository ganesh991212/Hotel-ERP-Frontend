import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/features/hotel/reports_page.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

Map<String, dynamic> _row({int bills = 1, int total = 59640}) => {
  'bills': bills,
  'gross_minor': 62000,
  'discount_minor': 6200,
  'taxable_minor': 55800,
  'cgst_minor': 1395,
  'sgst_minor': 1395,
  'other_tax_minor': 0,
  'service_charge_minor': 0,
  'round_off_minor': 0,
  'total_minor': total,
  'paid_minor': total,
  'unpaid_minor': 0,
  'unpaid_bills': 0,
  'cancelled_bills': 1,
  'cancelled_minor': 12600,
  'replaced_bills': 1,
  'received': {'cash_minor': 10000, 'upi_minor': 49640, 'card_minor': 0},
  'received_minor': total,
};

/// A day's sales exactly as the server sends it; the screen must only format these numbers.
final _sales = {
  'report': 'sales',
  'from': '2026-11-18',
  'to': '2026-11-19',
  'timezone': 'Asia/Kolkata',
  'days': [
    {'date': '2026-11-18', ..._row(bills: 0, total: 0)},
    {'date': '2026-11-19', ..._row()},
  ],
  'totals': _row(),
  'unbilled': {'orders': 2, 'value_minor': 16800},
};

final _gst = {
  'report': 'gst',
  'sac': '996331',
  'by_rate': [
    {'rate_bp': 500, 'taxable_minor': 55800, 'cgst_minor': 1395, 'sgst_minor': 1395, 'tax_minor': 2790},
  ],
  'totals': {'taxable_minor': 55800, 'cgst_minor': 1395, 'sgst_minor': 1395, 'tax_minor': 2790},
  'service_charge_minor': 0,
  'documents': [
    {
      'doc_type': 'TAX_INVOICE',
      'fy': '2026-27',
      'from_no': 'A/1',
      'to_no': 'A/3',
      'count': 3,
      'cancelled': 2,
      'net': 1,
    },
  ],
};

Future<void> _show(WidgetTester tester, Widget child, double width) async {
  tester.view.physicalSize = Size(width, 2400);
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
  for (final width in [380.0, 1300.0]) {
    testWidgets('sales report shows the server ladder, states and warning at ${width.toInt()}px', (tester) async {
      await _show(tester, SalesReport(d: _sales), width);
      expect(tester.takeException(), isNull, reason: 'no overflow');
      // Ladder as sent: gross, discount shown as a deduction, taxable, total.
      expect(find.text('₹620'), findsOneWidget);
      expect(find.text('− ₹62'), findsOneWidget);
      expect(find.text('₹558'), findsOneWidget);
      expect(find.text('Bill total'), findsOneWidget);
      // Cancelled and replaced are shown apart from sales, with icon + label (not colour alone).
      expect(find.textContaining('Cancelled ₹126'), findsOneWidget);
      expect(find.byIcon(Icons.block_rounded), findsOneWidget);
      expect(find.textContaining('replaced when more food was added'), findsOneWidget);
      // Money received by method, and the unbilled warning.
      expect(find.text('₹100'), findsOneWidget);
      expect(find.textContaining('Not billed yet: 2 orders, ₹168'), findsOneWidget);
      expect(find.text('By day'), findsOneWidget, reason: 'a range shows one row per day');
    });
  }

  testWidgets('GST summary shows each rate and the documents issued', (tester) async {
    await _show(tester, GstReport(d: _gst), 380);
    expect(tester.takeException(), isNull);
    expect(find.text('GST 5%'), findsOneWidget);
    expect(find.textContaining('SAC 996331'), findsOneWidget);
    expect(find.text('A/1 to A/3: 3 issued, 2 cancelled, 1 net'), findsOneWidget);
  });

  testWidgets('an empty period says so instead of showing zeros', (tester) async {
    final empty = {..._sales, 'days': [], 'totals': _row(bills: 0, total: 0)..['cancelled_bills'] = 0};
    empty['unbilled'] = {'orders': 0, 'value_minor': 0};
    await _show(tester, SalesReport(d: empty), 380);
    expect(find.text('No bills in these dates'), findsOneWidget);
  });
}
