const supported = false;

Future<void> sendRaw(String host, int port, List<int> bytes) =>
    Future.error(UnsupportedError('Raw printing is not available in the browser'));
