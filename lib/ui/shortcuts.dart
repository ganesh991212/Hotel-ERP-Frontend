import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'components.dart';

/// Counter-PC keyboard shortcuts (backend docs/14 "Keyboard shortcuts"). Keys the browser leaves alone; no F-keys,
/// no Ctrl+P. Plain keys (no Ctrl / Alt) never fire while a text field has focus, so typing a name is safe.
class CounterShortcuts extends StatelessWidget {
  const CounterShortcuts({super.key, required this.bindings, required this.child, this.autofocus = true});
  final Map<ShortcutActivator, VoidCallback> bindings;
  final Widget child;
  final bool autofocus;

  /// Whether the user is typing in a text field right now.
  static bool typing() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return false;
    if (ctx.widget is EditableText) return true;
    return ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  static bool _plain(ShortcutActivator a) => switch (a) {
    SingleActivator(:final control, :final alt, :final meta) => !control && !alt && !meta,
    CharacterActivator(:final control, :final alt, :final meta) => !control && !alt && !meta,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        for (final e in bindings.entries)
          e.key: () {
            if (_plain(e.key) && typing()) return;
            e.value();
          },
      },
      child: Focus(autofocus: autofocus, child: child),
    );
  }
}

/// The shortcut list (opened with "?"), so nobody needs a printed sheet.
Future<void> showShortcutHelp(BuildContext context) {
  final l = AppLocalizations.of(context);
  final rows = [
    ('/', l.keySearch),
    ('Enter', l.keyAddTop),
    ('Ctrl + Enter', l.keySend),
    ('Alt + H', l.keyHold),
    ('T', l.keyTakeaway),
    ('Alt + P', l.keyPrint),
    ('Alt + C / U / K', l.keyPay),
    ('?', l.keyHelp),
  ];
  return showGlassDialog(
    context,
    title: l.keyboardShortcuts,
    body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final (k, what) in rows)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            SizedBox(width: 130, child: Text(k, style: Theme.of(context).textTheme.labelLarge)),
            Expanded(child: Text(what)),
          ]),
        ),
    ]),
  );
}
