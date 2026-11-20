import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/features/hotel/rota.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('each shift state from the server is an icon and words', (tester) async {
    final cases = {
      'UPCOMING': 'Upcoming',
      'WORKING': 'On shift',
      'ON_TIME': 'On time',
      'LATE': 'Late 40 min',
      'NOT_IN': 'Not in · 40 min late',
      'NO_SHOW': 'No-show',
    };
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(children: [
            for (final k in cases.keys) shiftStateChip(context, {'state': k, 'late_minutes': 40}),
          ]),
        ),
      ),
    ));
    for (final label in cases.values) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(Icon), findsNWidgets(cases.length), reason: 'never colour alone');
  });
}
