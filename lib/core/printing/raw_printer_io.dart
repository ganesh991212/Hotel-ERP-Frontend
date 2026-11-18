import 'dart:io';

const supported = true;

Future<void> sendRaw(String host, int port, List<int> bytes) async {
  final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
  try {
    socket.add(bytes);
    await socket.flush();
  } finally {
    await socket.close();
  }
}
