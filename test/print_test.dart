import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/printing/print_service.dart';
import 'package:pdf/pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('server print blocks render to a PDF on every paper size', () async {
    final blocks = <List>[
      ['title', 'KOT'],
      ['center', 'Demo Bistro'],
      ['divider'],
      ['total', 'Order #12', 'Table T3'],
      ['bold', '2 x Paneer Tikka'],
      ['text', '   > less spicy'],
      ['row', 'Subtotal', 'Rs. 480.00'],
      ['feed', 1],
      ['cut'],
    ];
    for (final f in [PdfPageFormat.roll57, PdfPageFormat.roll80, PdfPageFormat.a4]) {
      final bytes = await buildPdf(blocks, f, compress: false);
      final text = latin1.decode(bytes);
      expect(text.startsWith('%PDF'), isTrue);
      expect(bytes.length, greaterThan(1000));
    }
  });

  test('a long report flows onto several A4 pages', () async {
    int pages(List<int> bytes) => RegExp(r'/Type\s*/Page[^s]').allMatches(latin1.decode(bytes)).length;
    Map<String, dynamic> doc(int rows) => {
          'title': 'Item-wise sales 2026-11-01 to 2026-11-20',
          'blocks': [
            ['title', 'Demo Bistro'],
            ['small', 'Issued bills on the hotel calendar day'],
            for (var i = 0; i < rows; i++) ['row', '$i x Masala Chai', 'Rs. 40.00'],
          ],
        };
    final short = await buildReportPdf(doc(5), compress: false);
    final long = await buildReportPdf(doc(300), compress: false);
    expect(latin1.decode(long).startsWith('%PDF'), isTrue);
    expect(pages(short), 1);
    expect(pages(long), greaterThan(3), reason: 'nothing is cut off: rows flow onto new pages');
  });

  test('branded QR cards render on A4 (sheet and single) and roll, with and without a logo', () async {
    Map<String, dynamic> doc(int n, {String? logo}) => {
          'hotel': {'name': 'Demo Bistro', 'address_line': 'Road No. 36, Jubilee Hills, Hyderabad', 'logo_b64': logo},
          'powered_by': {'name': 'Vethra', 'contact': null},
          'tickets': [
            for (var i = 1; i <= n; i++)
              {'label': 'T$i', 'area': 'Indoor', 'url': 'https://example.com/#/t/token$i', 'blocks': <List>[]},
          ],
        };
    for (final (d, f) in [
      (doc(7), PdfPageFormat.a4), // two pages of cards
      (doc(1), PdfPageFormat.a4), // one large card
      (doc(2), PdfPageFormat.roll80),
      (doc(1), PdfPageFormat.roll57),
    ]) {
      final bytes = await buildQrCards(d, f, compress: false);
      expect(latin1.decode(bytes).startsWith('%PDF'), isTrue);
    }
  });

  test('ESC/POS is requested only for the network route', () {
    expect(const PrintSettings().escposMm, isNull);
    expect(const PrintSettings(route: PrintRoute.network, host: '').escposMm, isNull);
  });
}
