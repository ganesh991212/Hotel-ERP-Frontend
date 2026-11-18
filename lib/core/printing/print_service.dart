import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'raw_printer.dart';

/// Printing for kitchen tickets (KOT) and bills. Adapted from the CMS app's invoice_generator.dart
/// (same pdf/printing approach and roll/A4 page shapes). The server sends a list of layout *blocks*;
/// we render the same blocks it turns into ESC/POS, so every printer gets the same ticket.
///
/// Two outputs, so it works with every kind of printer:
///  * System dialog (default): PDF through the OS print dialog. Reaches any printer the device has a
///    driver for: USB/Bluetooth/network thermal (with driver), laser, inkjet; Android print services;
///    AirPrint on iPhone/iPad; any printer in the browser. "Save as PDF" too.
///  * Network thermal (Android/iOS only): raw ESC/POS straight to the printer's IP on port 9100. No
///    dialog, prints instantly; best for a kitchen printer on the restaurant Wi-Fi.
enum PaperSize { mm58, mm80, a4 }

enum PrintRoute { system, network }

class PrintSettings {
  const PrintSettings({this.paper = PaperSize.mm80, this.route = PrintRoute.system, this.host = '', this.port = 9100});
  final PaperSize paper;
  final PrintRoute route;
  final String host;
  final int port;

  /// What to ask the server for: ESC/POS width only when we will send raw bytes.
  int? get escposMm => route == PrintRoute.network && rawPrintingSupported && host.isNotEmpty
      ? (paper == PaperSize.mm58 ? 58 : 80)
      : null;

  PrintSettings copyWith({PaperSize? paper, PrintRoute? route, String? host, int? port}) => PrintSettings(
        paper: paper ?? this.paper,
        route: route ?? this.route,
        host: host ?? this.host,
        port: port ?? this.port,
      );

  static Future<PrintSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return PrintSettings(
      paper: PaperSize.values.byName(p.getString('print.paper') ?? 'mm80'),
      route: PrintRoute.values.byName(p.getString('print.route') ?? 'system'),
      host: p.getString('print.host') ?? '',
      port: p.getInt('print.port') ?? 9100,
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('print.paper', paper.name);
    await p.setString('print.route', route.name);
    await p.setString('print.host', host);
    await p.setInt('print.port', port);
  }
}

/// Prints a server print response ({blocks, escpos_b64?}).
Future<void> printDocument(Map<String, dynamic> doc, {required String title, required PrintSettings settings}) async {
  final b64 = doc['escpos_b64'] as String?;
  if (b64 != null && settings.route == PrintRoute.network && !kIsWeb) {
    await sendRaw(settings.host, settings.port, base64Decode(b64));
    return;
  }
  final format = switch (settings.paper) {
    PaperSize.mm58 => PdfPageFormat.roll57,
    PaperSize.mm80 => PdfPageFormat.roll80,
    PaperSize.a4 => PdfPageFormat.a4,
  };
  final bytes = await buildPdf((doc['blocks'] as List).cast<List>(), format);
  await Printing.layoutPdf(name: title, format: format, onLayout: (_) async => bytes);
}

/// Table QR codes. Roll paper (or a network thermal printer): one ticket per table, cut between them.
/// A4: a grid of cut-out cards, six per page, for stickers or table tents.
Future<void> printTableQrs(Map<String, dynamic> doc, {required PrintSettings settings}) async {
  final tickets = (doc['tickets'] as List).cast<Map>();
  final b64 = doc['escpos_b64'] as String?;
  if (b64 != null && settings.route == PrintRoute.network && !kIsWeb) {
    await sendRaw(settings.host, settings.port, base64Decode(b64));
    return;
  }
  final name = tickets.length == 1 ? 'QR ${tickets.first['label']}' : 'Table QR codes';
  if (settings.paper == PaperSize.a4) {
    final bytes = await buildQrSheet(doc['hotel_name'] as String, tickets);
    await Printing.layoutPdf(name: name, format: PdfPageFormat.a4, onLayout: (_) async => bytes);
    return;
  }
  final format = settings.paper == PaperSize.mm58 ? PdfPageFormat.roll57 : PdfPageFormat.roll80;
  final bytes = await buildPdfPages([for (final t in tickets) (t['blocks'] as List).cast<List>()], format);
  await Printing.layoutPdf(name: name, format: format, onLayout: (_) async => bytes);
}

/// A4 sheet: 2 x 3 cards with cut lines, each with hotel, table, QR and instructions.
Future<Uint8List> buildQrSheet(String hotelName, List<Map> tickets, {bool compress = true}) async {
  await _fonts();
  final doc = pw.Document(compress: compress);
  for (var i = 0; i < tickets.length; i += 6) {
    final page = tickets.sublist(i, (i + 6).clamp(0, tickets.length));
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (_) => pw.GridView(
        crossAxisCount: 2,
        childAspectRatio: 1.05,
        children: [
          for (final t in page)
            pw.Container(
              margin: const pw.EdgeInsets.all(6),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey500, width: .6, style: pw.BorderStyle.dashed),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Text(hotelName, style: pw.TextStyle(font: _bold, fontSize: 12)),
                pw.SizedBox(height: 4),
                pw.Text('Table ${t['label']}', style: pw.TextStyle(font: _bold, fontSize: 22)),
                pw.SizedBox(height: 8),
                pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: t['url'] as String, width: 132, height: 132),
                pw.SizedBox(height: 8),
                pw.Text('Scan to order', style: pw.TextStyle(font: _bold, fontSize: 13)),
                pw.Text('Open your phone camera and point it at the code',
                    style: pw.TextStyle(font: _regular, fontSize: 8, color: PdfColors.grey700)),
              ]),
            ),
        ],
      ),
    ));
  }
  return doc.save();
}

pw.Font? _regular, _bold;

Future<void> _fonts() async {
  _regular ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Inter_400Regular.ttf'));
  _bold ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Inter_600SemiBold.ttf'));
}

/// Blocks -> PDF. Exposed for tests (compress: false keeps text searchable, as in the CMS app).
Future<Uint8List> buildPdf(List<List> blocks, PdfPageFormat format, {bool compress = true}) =>
    buildPdfPages([blocks], format, compress: compress);

/// One page per block list (roll printers cut between pages).
Future<Uint8List> buildPdfPages(List<List<List>> pages, PdfPageFormat format, {bool compress = true}) async {
  await _fonts();
  final receipt = format.width < PdfPageFormat.a4.width;
  final doc = pw.Document(compress: compress);
  for (final blocks in pages) {
    doc.addPage(pw.Page(
      pageFormat: format,
      margin: pw.EdgeInsets.all(receipt ? 6 : 36),
      build: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: _render(blocks, format)),
    ));
  }
  return doc.save();
}

List<pw.Widget> _render(List<List> blocks, PdfPageFormat format) {
  final receipt = format.width < PdfPageFormat.a4.width;
  final base = receipt ? (format.width < PdfPageFormat.roll80.width ? 7.5 : 9.0) : 10.5;
  pw.TextStyle st({double scale = 1, bool bold = false}) =>
      pw.TextStyle(font: bold ? _bold : _regular, fontSize: base * scale);
  final children = <pw.Widget>[];
  for (final b in blocks) {
    switch (b[0] as String) {
      case 'title':
        children.add(pw.Center(child: pw.Text(b[1], style: st(scale: 1.6, bold: true), textAlign: pw.TextAlign.center)));
      case 'center':
        children.add(pw.Center(child: pw.Text(b[1], style: st(), textAlign: pw.TextAlign.center)));
      case 'text':
        children.add(pw.Text(b[1], style: st()));
      case 'bold':
        children.add(pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1.5), child: pw.Text(b[1], style: st(scale: 1.35, bold: true))));
      case 'row' || 'total':
        final big = b[0] == 'total';
        children.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: pw.Text(b[1], style: st(scale: big ? 1.3 : 1, bold: big))),
          pw.SizedBox(width: 6),
          pw.Text(b[2], style: st(scale: big ? 1.3 : 1, bold: big)),
        ]));
      case 'divider':
        children.add(pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Divider(thickness: .6, borderStyle: pw.BorderStyle.dashed),
        ));
      case 'feed':
        children.add(pw.SizedBox(height: base * (b[1] as int)));
      case 'qr':
        final side = receipt ? format.width * .62 : 260.0;
        children.add(pw.Center(
          child: pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: b[1], width: side, height: side),
        ));
    }
  }
  return children;
}
