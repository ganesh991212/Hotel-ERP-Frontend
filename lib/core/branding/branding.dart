import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';

/// The hotel's printed identity: name, one-line address and logo (sanitised PNG from the server).
class Branding {
  const Branding({required this.name, this.addressLine, this.logo});
  final String name;
  final String? addressLine;
  final Uint8List? logo;
}

final brandingProvider = FutureProvider<Branding?>((ref) async {
  final s = ref.watch(sessionProvider).value;
  if (s == null || s.platform) return null;
  final api = ref.read(apiProvider);
  final b = Map<String, dynamic>.from(await api.get('/api/v1/branding'));
  Uint8List? logo;
  if (b['has_logo'] == true) {
    try {
      logo = await api.getBytes('/api/v1/branding/logo?v=${b['logo_version']}');
    } catch (_) {}
  }
  return Branding(name: b['name'], addressLine: b['address_line'], logo: logo);
});
