/// Target times on the kitchen screen (backend docs/14 "Target time"). The server fixes each line's due time when
/// the order is placed; the screen only compares it with the clock.
enum DueState { onTime, dueNow, delayed }

/// Minutes left (on time / due now) or minutes over (delayed). Null when there is no due time.
(DueState, int)? dueState(String? dueAt, DateTime now) {
  final due = dueAt == null ? null : DateTime.tryParse(dueAt);
  if (due == null) return null;
  final secs = due.toUtc().difference(now.toUtc()).inSeconds;
  if (secs < 0) return (DueState.delayed, (-secs / 60).ceil());
  final left = secs ~/ 60;
  return left < 2 ? (DueState.dueNow, left) : (DueState.onTime, left);
}

/// With a station picked, the card is due when that station's slowest dish is (the bar's chai is due long before
/// the kitchen's biryani). ISO strings in UTC compare correctly as text only when formatted alike, so parse them.
String? latestDue(Iterable<Map> items) {
  DateTime? best;
  String? raw;
  for (final it in items) {
    final d = DateTime.tryParse('${it['due_at']}');
    if (d != null && (best == null || d.isAfter(best))) {
      best = d;
      raw = it['due_at'] as String;
    }
  }
  return raw;
}
