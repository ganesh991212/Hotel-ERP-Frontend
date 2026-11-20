import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/features/floor/table_visit.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('the timer counts from seating; nothing when nobody is seated', () {
    final now = DateTime.utc(2026, 11, 20, 13, 0);
    expect(seatedMinutes({'seated_at': '2026-11-20T12:35:00Z'}, now: now), 25);
    expect(seatedMinutes({'seated_at': null}, now: now), isNull);
  });

  testWidgets('visit states show icon + label', (tester) async {
    Future<void> show(Map t) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Builder(builder: (c) => visitChip(c, t) ?? const Text('none'))),
        ),
      );
    }

    await show({'state': 'CLEANING'});
    expect(find.text('Cleaning'), findsOneWidget);
    expect(find.byIcon(Icons.cleaning_services_outlined), findsOneWidget);
    await show({'state': 'RESERVED', 'hold_note': '8 pm, 4 people'});
    expect(find.text('Reserved · 8 pm, 4 people'), findsOneWidget);
    await show({'state': 'FREE'});
    expect(find.text('none'), findsOneWidget);
  });
}
