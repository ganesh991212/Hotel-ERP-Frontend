import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/printing/print_service.dart';
import '../../core/printing/raw_printer.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';

/// Per-device printer setup (each counter tablet or phone can have its own printer).
Future<void> showPrinterDialog(BuildContext context) async {
  final settings = await PrintSettings.load();
  if (!context.mounted) return;
  await showGlassDialog(context, title: AppLocalizations.of(context).printerSetup, body: _PrinterForm(initial: settings));
}

class _PrinterForm extends ConsumerStatefulWidget {
  const _PrinterForm({required this.initial});
  final PrintSettings initial;

  @override
  ConsumerState<_PrinterForm> createState() => _PrinterFormState();
}

class _PrinterFormState extends ConsumerState<_PrinterForm> {
  late PrintSettings _s = widget.initial;
  late final _host = TextEditingController(text: widget.initial.host);
  late final _port = TextEditingController(text: '${widget.initial.port}');

  PrintSettings get _current =>
      _s.copyWith(host: _host.text.trim(), port: int.tryParse(_port.text.trim()) ?? 9100);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      FieldLabel(l.paperSize, help: l.paperSizeHelp),
      ChoiceRow<PaperSize>(
        options: [(PaperSize.mm58, l.paper58), (PaperSize.mm80, l.paper80), (PaperSize.a4, l.paperA4)],
        value: _s.paper,
        onChanged: (v) => setState(() => _s = _s.copyWith(paper: v)),
      ),
      FieldLabel(l.printWith),
      ChoiceRow<PrintRoute>(
        options: [(PrintRoute.system, l.printSystem), (PrintRoute.network, l.printNetwork)],
        value: _s.route,
        onChanged: rawPrintingSupported ? (v) => setState(() => _s = _s.copyWith(route: v)) : null,
      ),
      const SizedBox(height: 6),
      Text(rawPrintingSupported ? (_s.route == PrintRoute.system ? l.printSystemHelp : l.printNetworkHelp) : l.printWebHelp,
          style: tt.bodySmall),
      if (_s.route == PrintRoute.network && rawPrintingSupported) ...[
        Row(children: [
          Expanded(
            flex: 3,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              FieldLabel(l.printerIp),
              TextField(controller: _host, keyboardType: TextInputType.url),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              FieldLabel(l.port),
              TextField(controller: _port, keyboardType: TextInputType.number),
            ]),
          ),
        ]),
      ],
      const SizedBox(height: 14),
      OutlinedButton.icon(
        onPressed: () => guard(context, () => printDocument({
              'blocks': [
                ['title', l.testPrintTitle],
                ['center', l.testPrintBody],
                ['divider'],
                ['row', 'Rs.', '1,234.50'],
                ['feed', 1],
                ['cut'],
              ],
            }, title: l.testPrintTitle, settings: _current)),
        icon: const Icon(Icons.print_outlined, size: 18),
        label: Text(l.testPrint),
      ),
      DialogActions(
        primary: l.save,
        onPrimary: () async {
          await _current.save();
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    ]);
  }
}
