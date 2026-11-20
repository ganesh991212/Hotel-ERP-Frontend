import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/session.dart';
import '../../l10n/app_localizations.dart';

/// Kitchen stations on the kitchen screen (backend docs/03 "Kitchen stations"): a device can show only its station's
/// dishes. Display only: the order is still accepted and marked ready by its chef.

/// Filter key for dishes without a station (the main kitchen).
const mainKitchenKey = '__main__';

String stationKey(Map item) => ((item['station'] as Map?)?['name'] as String?) ?? mainKitchenKey;

/// The board with only [station]'s dishes on each order; orders left with none are dropped. Null = everything.
Map<String, dynamic> filterBoard(Map<String, dynamic> board, String? station) {
  if (station == null) return board;
  List<Map<String, dynamic>> orders(Object? list) => [
    for (final o in ((list as List?) ?? const []).cast<Map>())
      if ((o['items'] as List).cast<Map>().where((it) => stationKey(it) == station).toList() case final items
          when items.isNotEmpty)
        {...Map<String, dynamic>.from(o), 'items': items},
  ];
  return {
    ...board,
    'up_for_grabs': orders(board['up_for_grabs']),
    'ready': orders(board['ready']),
    'on_paper': orders(board['on_paper']),
    'chefs': [
      for (final c in ((board['chefs'] as List?) ?? const []).cast<Map>())
        {...Map<String, dynamic>.from(c), 'queue': orders(c['queue'])},
    ],
  };
}

/// This device's station, remembered across reloads (a bar tablet stays on Bar).
final kitchenStationProvider = NotifierProvider<KitchenStation, String?>(KitchenStation.new);

class KitchenStation extends Notifier<String?> {
  static const _key = 'kitchen.station';

  @override
  String? build() {
    SharedPreferences.getInstance().then((p) {
      final saved = p.getString(_key);
      if (saved != null && saved != state) state = saved;
    });
    return null;
  }

  Future<void> set(String? station) async {
    state = station;
    final p = await SharedPreferences.getInstance();
    station == null ? await p.remove(_key) : await p.setString(_key, station);
  }
}

final stationsListProvider = FutureProvider.autoDispose<List<Map>>(
  (ref) async => ((await ref.read(apiProvider).get('/api/v1/stations')) as List).cast<Map>(),
);

/// "All stations · Kitchen · Bar · Tandoor" chips; hidden while the hotel has no stations.
class StationPicker extends ConsumerWidget {
  const StationPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stations = ref.watch(stationsListProvider).value ?? const [];
    if (stations.isEmpty) return const SizedBox.shrink();
    final current = ref.watch(kitchenStationProvider);
    final options = <(String?, String)>[
      (null, l.allStations),
      (mainKitchenKey, l.mainKitchen),
      for (final s in stations) (s['name'] as String, s['name'] as String),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (key, label) in options)
          ChoiceChip(
            avatar: const Icon(Icons.soup_kitchen_outlined, size: 16),
            label: Text(label),
            selected: current == key,
            onSelected: (_) => ref.read(kitchenStationProvider.notifier).set(key),
          ),
      ],
    );
  }
}
