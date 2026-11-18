import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/auth/session.dart';
import 'core/push/push_service.dart';
import 'core/router.dart';
import 'core/theme/theme.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(ProviderScope(
    overrides: [pushReleaseProvider.overrideWith((ref) => () => ref.read(pushServiceProvider).unregister())],
    child: const HotelErpApp(),
  ));
}

class HotelErpApp extends ConsumerWidget {
  const HotelErpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(pushBootstrapProvider);
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
