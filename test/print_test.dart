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

  test('ESC/POS is requested only for the network route', () {
    expect(const PrintSettings().escposMm, isNull);
    expect(const PrintSettings(route: PrintRoute.network, host: '').escposMm, isNull);
  });
}
