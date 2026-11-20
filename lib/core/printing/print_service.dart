import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart' show Color;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/tokens.dart';
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

/// Table QR codes, branded like the app: logo + hotel name, one-line address, QR on a mint panel, the table
/// name in a dark pill, then "Powered by". A4: six cut-out cards per page, or one large card for a single
/// table. Roll paper: the same card at receipt width (the printer cuts between tables). Network thermal
/// printers get the server's ESC/POS version (raster logo, inverted table name).
Future<void> printTableQrs(Map<String, dynamic> doc, {required PrintSettings settings}) async {
  final tickets = (doc['tickets'] as List).cast<Map>();
  final b64 = doc['escpos_b64'] as String?;
  if (b64 != null && settings.route == PrintRoute.network && !kIsWeb) {
    await sendRaw(settings.host, settings.port, base64Decode(b64));
    return;
  }
  final name = tickets.length == 1 ? 'QR ${tickets.first['label']}' : 'Table QR codes';
  final format = switch (settings.paper) {
    PaperSize.mm58 => PdfPageFormat.roll57,
    PaperSize.mm80 => PdfPageFormat.roll80,
    PaperSize.a4 => PdfPageFormat.a4,
  };
  final bytes = await buildQrCards(doc, format);
  await Printing.layoutPdf(name: name, format: format, onLayout: (_) async => bytes);
}

PdfColor _pdf(Color c) => PdfColor.fromInt(c.toARGB32());

/// Exposed for tests and previews.
Future<Uint8List> buildQrCards(Map<String, dynamic> doc, PdfPageFormat format, {bool compress = true}) async {
  await _fonts();
  final tickets = (doc['tickets'] as List).cast<Map>();
  final hotel = Map<String, dynamic>.from(doc['hotel'] as Map);
  final powered = Map<String, dynamic>.from(doc['powered_by'] as Map);
  final logoB64 = hotel['logo_b64'] as String?;
  final logo = logoB64 == null ? null : pw.MemoryImage(base64Decode(logoB64));
  final pdf = pw.Document(compress: compress);
  final roll = format.width < PdfPageFormat.a4.width;

  pw.Widget card(Map t, double scale) => _qrCard(
    hotelName: hotel['name'] as String,
    address: hotel['address_line'] as String?,
    logo: logo,
    url: t['url'] as String,
    table: t['label'] as String,
    area: t['area'] as String?,
    poweredBy: powered['name'] as String,
    contact: powered['contact'] as String?,
    scale: scale,
  );

  if (roll) {
    final scale = format.width < PdfPageFormat.roll80.width ? .78 : 1.0;
    for (final t in tickets) {
      pdf.addPage(pw.Page(pageFormat: format, margin: const pw.EdgeInsets.all(6), build: (_) => card(t, scale)));
    }
  } else if (tickets.length == 1) {
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(48),
        build: (_) => pw.Center(child: pw.SizedBox(width: 340, child: card(tickets.first, 1.6))),
      ),
    );
  } else {
    // Four cards per A4 page (2 x 2) in fixed cells: large enough for table tents, and fixed sizes so nothing
    // overflows (the PDF engine silently drops content that does not fit a cell).
    const perPage = 4, gap = 16.0;
    for (var i = 0; i < tickets.length; i += perPage) {
      final page = tickets.sublist(i, (i + perPage).clamp(0, tickets.length));
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          margin: const pw.EdgeInsets.all(24),
          build: (ctx) {
            final w = (ctx.page.pageFormat.availableWidth - gap) / 2;
            final h = (ctx.page.pageFormat.availableHeight - gap) / 2;
            pw.Widget cell(int j) => pw.SizedBox(
              width: w,
              height: h,
              child: j < page.length ? pw.Center(child: card(page[j], 1.12)) : pw.SizedBox(),
            );
            return pw.Column(
              children: [
                pw.Row(
                  children: [
                    cell(0),
                    pw.SizedBox(width: gap),
                    cell(1),
                  ],
                ),
                pw.SizedBox(height: gap),
                pw.Row(
                  children: [
                    cell(2),
                    pw.SizedBox(width: gap),
                    cell(3),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }
  }
  return pdf.save();
}

pw.Widget _qrCard({
  required String hotelName,
  required String? address,
  required pw.MemoryImage? logo,
  required String url,
  required String table,
  required String? area,
  required String poweredBy,
  required String? contact,
  required double scale,
}) {
  final tk = AppTokens.light;
  final initials = hotelName
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
      .join();
  pw.TextStyle display(double size, PdfColor color) =>
      pw.TextStyle(font: _display, fontSize: size * scale, color: color);
  pw.TextStyle body(double size, PdfColor color, {bool bold = false}) =>
      pw.TextStyle(font: bold ? _bold : _regular, fontSize: size * scale, color: color);
  final mark = logo != null
      ? pw.ClipRRect(
          horizontalRadius: 8 * scale,
          verticalRadius: 8 * scale,
          child: pw.Image(logo, width: 30 * scale, height: 30 * scale, fit: pw.BoxFit.contain),
        )
      : pw.Container(
          width: 30 * scale,
          height: 30 * scale,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(color: _pdf(tk.accentSoft), shape: pw.BoxShape.circle),
          child: pw.Text(initials, style: display(12, _pdf(tk.accentDeep))),
        );
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: _pdf(tk.paper),
      borderRadius: pw.BorderRadius.circular(16 * scale),
      border: pw.Border.all(color: _pdf(tk.accentSoft), width: 1.2),
    ),
    child: pw.ClipRRect(
      horizontalRadius: 16 * scale,
      verticalRadius: 16 * scale,
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          // Brand accent strip, like the app's green hero card.
          pw.Container(
            height: 5 * scale,
            decoration: pw.BoxDecoration(gradient: pw.LinearGradient(colors: [_pdf(tk.accent), _pdf(tk.accentDeep)])),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.fromLTRB(12 * scale, 10 * scale, 12 * scale, 10 * scale),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    mark,
                    pw.SizedBox(width: 8 * scale),
                    pw.Flexible(child: pw.Text(hotelName, style: display(15, _pdf(tk.ink)), maxLines: 1)),
                  ],
                ),
                if (address != null && address.isNotEmpty) ...[
                  pw.SizedBox(height: 4 * scale),
                  pw.Text(address, style: body(7, _pdf(tk.dim)), maxLines: 1, textAlign: pw.TextAlign.center),
                ],
                pw.SizedBox(height: 10 * scale),
                // QR on a soft mint panel; modules stay near-black on white so every phone scans it.
                pw.Container(
                  padding: pw.EdgeInsets.all(8 * scale),
                  decoration: pw.BoxDecoration(
                    color: _pdf(tk.bgTop),
                    borderRadius: pw.BorderRadius.circular(14 * scale),
                  ),
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(6 * scale),
                    decoration: pw.BoxDecoration(
                      color: _pdf(tk.paper),
                      borderRadius: pw.BorderRadius.circular(9 * scale),
                    ),
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: url,
                      color: _pdf(tk.paperInk),
                      width: 118 * scale,
                      height: 118 * scale,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10 * scale),
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 5 * scale),
                  // Radius <= half the pill height; larger radii make the PDF engine draw artefacts.
                  decoration: pw.BoxDecoration(
                    color: _pdf(tk.night),
                    borderRadius: pw.BorderRadius.circular(12 * scale),
                  ),
                  child: pw.Text('Table $table', style: display(14, _pdf(tk.onNight))),
                ),
                pw.SizedBox(height: 5 * scale),
                pw.Text(
                  'Scan to order${area != null && area.isNotEmpty ? '  ·  $area' : ''}',
                  style: body(8, _pdf(tk.accentDeep), bold: true),
                ),
                pw.SizedBox(height: 8 * scale),
                pw.Divider(thickness: .5, color: _pdf(tk.accentSoft), borderStyle: pw.BorderStyle.dashed),
                pw.Text(
                  contact == null ? 'Powered by $poweredBy' : 'Powered by $poweredBy  ·  $contact',
                  style: body(6, _pdf(tk.faint)),
                  textAlign: pw.TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Font? _regular, _bold, _display;

Future<void> _fonts() async {
  _regular ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Inter_400Regular.ttf'));
  _bold ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Inter_600SemiBold.ttf'));
  _display ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Outfit_500Medium.ttf'));
}

pw.Font? _telugu, _devanagari;

/// A report (sales, items, GST, P&L...) as an A4 PDF from the server's print blocks: the same figures as the screen.
/// Long reports flow onto more pages; every page has the report name and "Page x of y". Regional item names fall
/// back to the Noto fonts shipped with the app (backend docs/14 "Reports as PDF").
Future<Uint8List> buildReportPdf(Map<String, dynamic> doc, {bool compress = true}) async {
  await _fonts();
  _telugu ??= pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansTelugu_400Regular.ttf'));
  _devanagari ??= pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansDevanagari_400Regular.ttf'));
  final title = doc['title'] as String;
  final pdf = pw.Document(
    compress: compress,
    theme: pw.ThemeData.withFont(base: _regular, bold: _bold, fontFallback: [_telugu!, _devanagari!]),
  );
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      footer: (ctx) => pw.Row(children: [
        pw.Expanded(child: pw.Text(title, style: pw.TextStyle(font: _regular, fontSize: 8))),
        pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: pw.TextStyle(font: _regular, fontSize: 8)),
      ]),
      build: (_) => _render((doc['blocks'] as List).cast<List>(), PdfPageFormat.a4),
    ),
  );
  return pdf.save();
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
    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.all(receipt ? 6 : 36),
        build: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: _render(blocks, format)),
      ),
    );
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
        children.add(
          pw.Center(
            child: pw.Text(b[1], style: st(scale: 1.6, bold: true), textAlign: pw.TextAlign.center),
          ),
        );
      case 'center':
        children.add(
          pw.Center(
            child: pw.Text(b[1], style: st(), textAlign: pw.TextAlign.center),
          ),
        );
      case 'text':
        children.add(pw.Text(b[1], style: st()));
      case 'small': // a reason, an address, a basis line (was silently dropped before)
        children.add(pw.Text(b[1], style: st(scale: .85)));
      case 'bold':
        children.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
            child: pw.Text(b[1], style: st(scale: 1.35, bold: true)),
          ),
        );
      case 'row' || 'total':
        final big = b[0] == 'total';
        children.add(
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  b[1],
                  style: st(scale: big ? 1.3 : 1, bold: big),
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                b[2],
                style: st(scale: big ? 1.3 : 1, bold: big),
              ),
            ],
          ),
        );
      case 'divider':
        children.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Divider(thickness: .6, borderStyle: pw.BorderStyle.dashed),
          ),
        );
      case 'feed':
        children.add(pw.SizedBox(height: base * (b[1] as int)));
      case 'qr':
        final side = receipt ? format.width * .62 : 260.0;
        children.add(
          pw.Center(
            child: pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: b[1], width: side, height: side),
          ),
        );
    }
  }
  return children;
}
