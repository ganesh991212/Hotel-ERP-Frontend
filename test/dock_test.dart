import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/ui/components.dart';
import 'package:material_ui/material_ui.dart';

const _tabs = ['Overview', 'Floor', 'Kitchen', 'Menu', 'Tables', 'Team', 'Expenses'];
const _icons = [
  Icons.dashboard_outlined,
  Icons.table_restaurant_outlined,
  Icons.soup_kitchen_outlined,
  Icons.restaurant_menu,
  Icons.qr_code_2,
  Icons.groups_outlined,
  Icons.receipt_long_outlined,
];

Widget _dock({required double width, bool stacked = false, bool magnify = false, ValueChanged<String>? onSelect}) {
  return MaterialApp(
    theme: buildTheme(Brightness.light),
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: PillTabs<String>(
            items: [for (final t in _tabs) (t, t)],
            icons: _icons,
            stacked: stacked,
            elevated: true,
            magnify: magnify,
            selected: 'Overview',
            onSelect: onSelect ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

double _scaleOf(WidgetTester tester, String label) => tester
    .widget<AnimatedScale>(find.ancestor(of: find.text(label), matching: find.byType(AnimatedScale)).first)
    .scale;

void main() {
  testWidgets('on a phone the dock stays inside the screen and the tabs scroll inside it', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    String? tapped;
    await tester.pumpWidget(_dock(width: 344, stacked: true, onSelect: (v) => tapped = v));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(PillTabs<String>)).width, lessThanOrEqualTo(344));
    expect(tester.getRect(find.byType(PillTabs<String>)).right, lessThanOrEqualTo(360));

    // The last tab starts off-screen; a sideways swipe on the bar brings it into view.
    expect(tester.getRect(find.text('Expenses')).left, greaterThan(360));
    await tester.drag(find.byType(PillTabs<String>), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Expenses')).right, lessThanOrEqualTo(360));
    await tester.tap(find.text('Expenses'));
    expect(tapped, 'Expenses');
  });

  testWidgets('when the tabs fit, the bar is only as wide as its tabs', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_dock(width: 1500));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(PillTabs<String>)).width, lessThan(1500));
  });

  testWidgets('the tab under the mouse grows most, its neighbours less, far tabs not at all', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_dock(width: 1500, magnify: true));
    await tester.pumpAndSettle();
    expect(_scaleOf(tester, 'Menu'), 1);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Menu')));
    await tester.pumpAndSettle();

    final menu = _scaleOf(tester, 'Menu'), kitchen = _scaleOf(tester, 'Kitchen'), overview = _scaleOf(tester, 'Overview');
    expect(menu, closeTo(PillTabs.maxScale, .02));
    expect(kitchen, inExclusiveRange(1.0, menu));
    expect(overview, closeTo(1, .01));

    // Leaving the bar returns every tab to normal size.
    await mouse.moveTo(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(_scaleOf(tester, 'Menu'), 1);
  });
}
