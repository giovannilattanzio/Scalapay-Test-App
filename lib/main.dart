import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scalapay_test_app/src/config/router/app_router.dart';
import 'package:scalapay_test_app/src/core/core.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupInjector();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('it'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('it'),
      child: const ScalapayApp(),
    ),
  );
}

/// Root widget. `ScalapayProductCard` formats money with `intl` using
/// `Localizations.localeOf(context)`, so the locale `easy_localization`
/// installs here is what decides whether a price reads "85,00 €" or
/// "€85.00".
class ScalapayApp extends StatelessWidget {
  const ScalapayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ScalapayTheme.light(),
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      routerConfig: createRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}
