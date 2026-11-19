import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/auth/session.dart';
import 'package:hotel_erp/core/sound/alert_sound.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:hotel_erp/ui/shell.dart';
import 'package:hotel_erp/ui/status.dart';
import 'package:material_ui/material_ui.dart';

Session _staff(List<String> perms, {String mode = 'CHEF_ACCEPT'}) => Session(
      me: {
        'id': 'u1',
        'permissions': perms,
        'outlet': {'id': 'o1', 'kitchen_mode': mode, 'serve_mode': 'SERVER'},
      },
      entitlements: null,
    );

Map<String, dynamic> _order(String status, {Map<String, dynamic> extra = const {}}) =>
    {'id': 'x', 'number': 7, 'status': status, 'on_paper': false, 'chef': null, 'bill_id': null, ...extra};

void main() {
  group('chefs are alerted for confirmed orders (regression: they were silent)', () {
    final chef = _staff(['kitchen.cook']);
    test('a QR order confirmed by staff rings on the chef screen', () {
      final ev = {'type': 'order.confirmed', 'order': _order('CONFIRMED')};
      expect(alertFor(chef, ev), AlertKind.newOrder);
    });
    test('an order nobody picked up in time rings for chefs and admins', () {
      final ev = {'type': 'order.pickup_overdue', 'order': _order('CONFIRMED'), 'minutes': 5};
      expect(alertFor(chef, ev), AlertKind.newOrder);
      expect(alertFor(_staff(['kitchen.manage']), ev), AlertKind.newOrder);
      expect(alertFor(_staff(['order.serve']), ev), isNull, reason: 'waiters are not paged for the kitchen');
    });
  });

  testWidgets('every stage tells staff what happens next', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    final l = AppLocalizations.of(ctx);
    String? next(String status, {String mode = 'CHEF_ACCEPT', Map<String, dynamic> extra = const {}}) =>
        nextStepText(ctx, _order(status, extra: extra), kitchenMode: mode);

    expect(next('PLACED'), l.nextConfirm);
    expect(next('CONFIRMED'), l.nextChefPickup);
    expect(next('CONFIRMED', mode: 'AUTO_ASSIGN'), l.nextFreeChef);
    expect(next('CONFIRMED', mode: 'ADMIN_PRINT'), l.nextPrintKot);
    expect(next('PREPARING', extra: {'chef': {'name': 'Ravi'}}), l.nowCooking('Ravi'));
    expect(next('PREPARING', extra: {'on_paper': true}), l.nowCookingPaper);
    expect(next('READY'), l.nextServe);
    expect(next('SERVED'), l.nextBill, reason: 'served but unpaid: the next step is the bill');
    expect(next('SERVED', extra: {'bill_id': 'b1'}), isNull);
    expect(isPickupOverdue(_order('CONFIRMED', extra: {'pickup_alerted_at': '2026-11-19T10:00:00Z'})), isTrue);
    expect(isPickupOverdue(_order('PREPARING', extra: {'pickup_alerted_at': '2026-11-19T10:00:00Z'})), isFalse);
  });
}
