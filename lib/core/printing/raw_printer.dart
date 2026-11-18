import 'raw_printer_stub.dart' if (dart.library.io) 'raw_printer_io.dart' as impl;

/// Sends raw ESC/POS bytes to a network thermal printer (TCP 9100). Android/iOS/desktop only;
/// browsers cannot open raw sockets, so the web app always prints through the PDF dialog.
bool get rawPrintingSupported => impl.supported;

Future<void> sendRaw(String host, int port, List<int> bytes) => impl.sendRaw(host, port, bytes);
