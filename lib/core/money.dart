/// Formats server-computed paise for display. Never computes money (rule 1): no division,
/// no floats; the integer is split as a string and grouped Indian-style (12,34,567.89).
String formatInr(int minor, {bool showPaise = true}) {
  final negative = minor < 0;
  final digits = (negative ? -minor : minor).toString().padLeft(3, '0');
  final rupees = digits.substring(0, digits.length - 2);
  final paise = digits.substring(digits.length - 2);
  final grouped = _groupIndian(rupees);
  final body = showPaise && paise != '00' ? '$grouped.$paise' : grouped;
  return '${negative ? '−' : ''}₹$body';
}

/// Compact form for big dashboard numerals: ₹1.2L, ₹3.4Cr. Uses string slicing only.
String formatInrCompact(int minor) {
  final rupees = (minor < 0 ? -minor : minor).toString().padLeft(3, '0');
  final whole = rupees.substring(0, rupees.length - 2);
  final sign = minor < 0 ? '−' : '';
  String cut(int places, String suffix) {
    final head = whole.substring(0, whole.length - places);
    final dec = whole.substring(whole.length - places, whole.length - places + 1);
    return '$sign₹$head${dec == '0' ? '' : '.$dec'}$suffix';
  }

  if (whole.length > 7) return cut(7, 'Cr');
  if (whole.length > 5) return cut(5, 'L');
  return '$sign₹${_groupIndian(whole)}';
}

String _groupIndian(String s) {
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

/// Parses a rupee amount typed by staff (expense entry, menu price) into paise without floats.
/// Returns null when invalid. This is input parsing, not money arithmetic.
int? parseInrToMinor(String input) {
  final s = input.trim().replaceAll(',', '').replaceAll('₹', '');
  final m = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(s);
  if (m == null) return null;
  final paise = (m.group(2) ?? '').padRight(2, '0');
  return int.parse('${m.group(1)}$paise');
}

/// Inverse of [parseInrToMinor] for pre-filling edit fields.
String minorToInput(int minor) {
  final d = minor.toString().padLeft(3, '0');
  final paise = d.substring(d.length - 2);
  final rupees = d.substring(0, d.length - 2);
  return paise == '00' ? rupees : '$rupees.$paise';
}

/// Basis points as a percent label: 1000 -> "10%", 1250 -> "12.5%". Integer maths only.
String percentLabel(int bp) {
  final whole = bp ~/ 100, frac = bp % 100;
  if (frac == 0) return '$whole%';
  final f = frac.toString().padLeft(2, '0').replaceFirst(RegExp(r'0$'), '');
  return '$whole.$f%';
}

/// "10" or "12.5" (up to two decimals) -> basis points; null if not a percent between 0.01 and 100.
int? parsePercentToBp(String input) {
  final m = RegExp(r'^\s*(\d{1,3})(?:\.(\d{1,2}))?\s*%?\s*$').firstMatch(input);
  if (m == null) return null;
  final bp = int.parse(m.group(1)!) * 100 + int.parse((m.group(2) ?? '0').padRight(2, '0'));
  return bp >= 1 && bp <= 10000 ? bp : null;
}
