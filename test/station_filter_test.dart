import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/features/kitchen/station_filter.dart';

void main() {
  final board = <String, dynamic>{
    'up_for_grabs': [
      {
        'number': 1,
        'items': [
          {'name': 'Biryani', 'station': null},
          {
            'name': 'Chai',
            'station': {'name': 'Bar'},
          },
        ],
      },
      {
        'number': 2,
        'items': [
          {
            'name': 'Naan',
            'station': {'name': 'Tandoor'},
          },
        ],
      },
    ],
    'ready': [],
    'on_paper': [],
    'chefs': [
      {
        'name': 'Ravi',
        'queue': [
          {
            'number': 3,
            'items': [
              {
                'name': 'Lassi',
                'station': {'name': 'Bar'},
              },
            ],
          },
        ],
      },
    ],
    'kitchen_mode': 'CHEF_ACCEPT',
  };

  test('a station sees only its dishes; orders with none of them are hidden', () {
    final bar = filterBoard(board, 'Bar');
    expect((bar['up_for_grabs'] as List).map((o) => o['number']), [1]);
    expect(((bar['up_for_grabs'] as List).first['items'] as List).map((i) => i['name']), ['Chai']);
    expect(((bar['chefs'] as List).first['queue'] as List).map((o) => o['number']), [3]);
    expect(bar['kitchen_mode'], 'CHEF_ACCEPT', reason: 'the rest of the board is untouched');
  });

  test('dishes without a station are the main kitchen; null shows everything', () {
    final main = filterBoard(board, mainKitchenKey);
    expect(((main['up_for_grabs'] as List).single['items'] as List).map((i) => i['name']), ['Biryani']);
    expect(identical(filterBoard(board, null), board), isTrue);
  });
}
