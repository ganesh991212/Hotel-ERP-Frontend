import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../theme/tokens.dart';

/// Display language per device (staff share tablets, so it is not tied to the account). Printing stays in
/// English on purpose (thermal printers have no Indic fonts; see Backend docs/07).
///
/// Telugu and Devanagari fonts are loaded only when chosen, so English sessions never download them
/// (same idea as GigBridge's lazy regional fonts). Families are referenced as theme fallbacks.
const scriptFonts = {
  'te': ('NotoSansTelugu', ['assets/fonts/NotoSansTelugu_400Regular.ttf', 'assets/fonts/NotoSansTelugu_600SemiBold.ttf']),
  'hi': (
    'NotoSansDevanagari',
    ['assets/fonts/NotoSansDevanagari_400Regular.ttf', 'assets/fonts/NotoSansDevanagari_600SemiBold.ttf'],
  ),
};
const fallbackFamilies = ['NotoSansTelugu', 'NotoSansDevanagari'];

final _loaded = <String>{};

Future<void> ensureScriptFont(String languageCode) async {
  final spec = scriptFonts[languageCode];
  if (spec == null || _loaded.contains(languageCode)) return;
  final loader = FontLoader(spec.$1);
  for (final path in spec.$2) {
    loader.addFont(rootBundle.load(path));
  }
  await loader.load();
  _loaded.add(languageCode);
}

class LocaleController extends Notifier<Locale?> {
  static const _key = 'app.locale';

  @override
  Locale? build() {
    _restore();
    return null; // follow the device until a choice is restored
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString(_key);
    if (code != null) {
      await set(Locale(code), persist: false);
      return;
    }
    // No choice yet: follow the device, but make sure its script font is loaded first.
    final device = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (scriptFonts.containsKey(device)) await set(Locale(device), persist: false);
  }

  Future<void> set(Locale? locale, {bool persist = true}) async {
    final code = locale?.languageCode ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    await ensureScriptFont(code); // load glyphs before switching, so no frame shows empty boxes
    // Dates (month and weekday names) follow the display language too.
    await initializeDateFormatting(code);
    Intl.defaultLocale = code;
    state = locale;
    if (persist) {
      final p = await SharedPreferences.getInstance();
      locale == null ? await p.remove(_key) : await p.setString(_key, locale.languageCode);
    }
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);

/// Globe button with the three languages, written in their own script.
class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key, this.compact = true});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;
    final t = context.tokens;
    return PopupMenuButton<String>(
      tooltip: l.language,
      position: PopupMenuPosition.under,
      color: t.solid,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (code) => ref.read(localeProvider.notifier).set(Locale(code)),
      itemBuilder: (_) => [
        for (final (code, name) in [('en', l.langEn), ('te', l.langTe), ('hi', l.langHi)])
          CheckedPopupMenuItem(value: code, checked: code == current, child: Text(name)),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: t.cardStrong,
          borderRadius: BorderRadius.circular(Rad.pill),
          border: Border.all(color: t.hair),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.translate_rounded, size: 18, color: t.ink),
          if (!compact) ...[
            const SizedBox(width: 6),
            Text(switch (current) { 'te' => l.langTe, 'hi' => l.langHi, _ => l.langEn },
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ]),
      ),
    );
  }
}
