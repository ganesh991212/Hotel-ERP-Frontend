import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:hotel_erp/ui/shortcuts.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('plain keys never fire while typing; Alt keys always do', (tester) async {
    var takeaway = 0, held = 0;
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CounterShortcuts(
          bindings: {
            const CharacterActivator('t'): () => takeaway++,
            const SingleActivator(LogicalKeyboardKey.keyH, alt: true): () => held++,
          },
          child: const Column(children: [TextField(key: Key('name'))]),
        ),
      ),
    ));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyT, character: 't');
    expect(takeaway, 1, reason: 'not typing: T opens a takeaway');

    await tester.tap(find.byKey(const Key('name')));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT, character: 't');
    expect(takeaway, 1, reason: 'typing a guest name: T is just a letter');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    expect(held, 1, reason: 'Alt + H works even from a text field');
  });

  testWidgets('? lists the shortcuts', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => CounterShortcuts(
            bindings: {const CharacterActivator('?'): () => showShortcutHelp(context)},
            child: const SizedBox.expand(),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.slash, character: '?');
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    expect(find.text('Ctrl + Enter'), findsOneWidget);
  });
}
