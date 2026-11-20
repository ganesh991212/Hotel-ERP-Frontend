import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/features/floor/bookings_page.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _show(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(380, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('a booking shows guests, table, earlier no-shows and its actions', (tester) async {
    String? status;
    await _show(
      tester,
      BookingRow(
        b: {
          'id': 'b1',
          'kind': 'BOOKING',
          'status': 'BOOKED',
          'name': 'Sharma',
          'phone': '98480 00001',
          'guests': 4,
          'booked_for': '2026-11-20T14:30:00Z',
          'table': {'id': 't1', 'label': 'T4'},
          'note': 'Window seat',
          'no_shows_before': 2,
        },
        onSeat: () {},
        onStatus: (s) => status = s,
      ),
    );
    expect(tester.takeException(), isNull, reason: 'fits a phone');
    expect(find.textContaining('Sharma · 4 guests'), findsOneWidget);
    expect(find.text('2 no-shows before'), findsOneWidget);
    await tester.tap(find.text('No-show'));
    expect(status, 'NO_SHOW');
  });

  testWidgets('a walk-in waiting longer than quoted is flagged', (tester) async {
    await _show(
      tester,
      BookingRow(
        b: {
          'id': 'w1',
          'kind': 'WAITLIST',
          'status': 'WAITING',
          'name': 'Rao',
          'guests': 2,
          'quoted_minutes': 15,
          'waited_minutes': 22,
          'no_shows_before': 0,
        },
        onSeat: () {},
        onStatus: (_) {},
      ),
    );
    expect(find.text('Waiting 22 min (told 15)'), findsOneWidget);
    expect(find.text('No-show'), findsNothing, reason: 'walk-ins are cancelled, not no-shows');
  });
}
