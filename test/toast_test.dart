import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/theme/theme.dart';
import 'package:hotel_erp/l10n/app_localizations.dart';
import 'package:hotel_erp/ui/components.dart';
import 'package:hotel_erp/ui/feedback.dart';
import 'package:material_ui/material_ui.dart';

/// A page with a button that opens a glass dialog; the dialog's Save button reports success.
Widget _app() => MaterialApp(
      theme: buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showGlassDialog<void>(
                context,
                title: 'Settings',
                body: Builder(
                  builder: (dialogContext) =>
                      TextButton(onPressed: () => showDone(dialogContext, 'Saved'), child: const Text('Save')),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('a message shown from a dialog sits above the dialog and its blur', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Saved'), findsOneWidget);
    // Tapping the message reaches the message itself, not the dialog's barrier: the dialog stays open.
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget, reason: 'dialog must still be open');
    expect(find.text('Saved'), findsNothing, reason: 'tap dismisses the message');
  });

  testWidgets('messages disappear on their own and a new one replaces the old', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
  });
}
