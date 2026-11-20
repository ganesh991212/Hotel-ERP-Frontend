import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/features/kitchen/due.dart';
import 'package:hotel_erp/features/kitchen/station_filter.dart';

void main() {
  final now = DateTime.utc(2026, 11, 20, 13, 0);
  String at(int minutes) => now.add(Duration(minutes: minutes)).toIso8601String();

  test('on time, due now, delayed', () {
    expect(dueState(at(6), now), (DueState.onTime, 6));
    expect(dueState(at(1), now), (DueState.dueNow, 1));
    expect(dueState(at(0), now), (DueState.dueNow, 0));
    expect(dueState(now.subtract(const Duration(seconds: 30)).toIso8601String(), now), (DueState.delayed, 1));
    expect(dueState(at(-3), now), (DueState.delayed, 3));
    expect(dueState(null, now), isNull, reason: 'older orders without a due time show no flag');
  });

  test('a station sees its own dishes due time, not the slowest dish of the whole order', () {
    final order = {
      'id': 'o1',
      'due_at': at(20),
      'items': [
        {'name': 'Biryani', 'due_at': at(20), 'station': null},
        {'name': 'Chai', 'due_at': at(4), 'station': {'id': 'bar', 'name': 'Bar'}},
      ],
    };
    final board = {'up_for_grabs': [order], 'ready': [], 'on_paper': [], 'chefs': []};
    final bar = filterBoard(board, 'Bar');
    expect((bar['up_for_grabs'] as List).single['due_at'], at(4));
    final all = filterBoard(board, null);
    expect((all['up_for_grabs'] as List).single['due_at'], at(20));
  });
}
