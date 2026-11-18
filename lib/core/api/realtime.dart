import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_client.dart';

/// Reconnecting WebSocket. Emits decoded events; on reconnect or a seq gap it emits a synthetic
/// `resync` event so screens refetch over REST (docs/07: never silently stale).
class RealtimeChannel {
  RealtimeChannel(this.path, this.token);

  final String path;
  final String Function() token;
  final _out = StreamController<Map<String, dynamic>>.broadcast();
  WebSocketChannel? _ws;
  StreamSubscription? _sub;
  Timer? _retry;
  int _lastSeq = 0;
  int _attempt = 0;
  bool _closed = false;
  bool connected = false;

  Stream<Map<String, dynamic>> get events => _out.stream;

  void connect() {
    if (_closed) return;
    final base = apiBase.replaceFirst(RegExp('^http'), 'ws');
    final sep = path.contains('?') ? '&' : '?';
    try {
      _ws = WebSocketChannel.connect(Uri.parse('$base$path${sep}token=${Uri.encodeQueryComponent(token())}'));
    } catch (_) {
      _schedule();
      return;
    }
    _sub = _ws!.stream.listen((raw) {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      if (msg['type'] == 'hello') {
        final wasReconnect = _attempt > 0 || _lastSeq > 0;
        connected = true;
        _attempt = 0;
        _lastSeq = 0;
        if (wasReconnect) _out.add({'type': 'resync'});
        _out.add({'type': 'connected'});
        return;
      }
      if (msg['type'] == 'ping') return;
      final seq = msg['seq'] as int?;
      if (seq != null) {
        if (_lastSeq > 0 && seq != _lastSeq + 1) _out.add({'type': 'resync'});
        _lastSeq = seq;
      }
      _out.add(msg);
    }, onDone: _onDown, onError: (_) => _onDown());
  }

  void _onDown() {
    if (connected) _out.add({'type': 'disconnected'});
    connected = false;
    _schedule();
  }

  void _schedule() {
    if (_closed) return;
    _retry?.cancel();
    _attempt++;
    final secs = [1, 2, 4, 8, 15][_attempt.clamp(1, 5) - 1];
    _retry = Timer(Duration(seconds: secs), connect);
  }

  void close() {
    _closed = true;
    _retry?.cancel();
    _sub?.cancel();
    _ws?.sink.close();
    _out.close();
  }
}
