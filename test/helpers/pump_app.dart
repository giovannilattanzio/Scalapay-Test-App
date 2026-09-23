import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_test_app/src/presentation/presentation.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads the real `assets/translations/<language>.json` straight off disk
/// with `dart:io`, the same way `test/localization/translations_test.dart`
/// already does successfully. `rootBundle` (the normal asset channel) was
/// observed to hang on every `testWidgets` after the first one in a file;
/// plain `dart:io` does not have that problem, and — unlike a hand-copied
/// translations map — it cannot drift from the files it reads, so a changed
/// string is exercised by these tests exactly as the app would show it.
class _FileAssetLoader extends AssetLoader {
  const _FileAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final raw = File('$path/${locale.languageCode}.json').readAsStringSync();
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}

/// Pumps [child] wrapped exactly like the real app: `EasyLocalization` (Italian
/// and English, Italian fallback, translations matching `assets/translations`)
/// inside a `MaterialApp` themed with `ScalapayTheme.light()`, optionally with
/// [cubit] provided through a `BlocProvider<CatalogCubit>`.
///
/// Every widget test in the catalog feature must go through this helper
/// instead of repeating the setup: getting `easy_localization` initialised
/// correctly for `flutter test` (binding, mock locale storage, an asset
/// loader that reads the real translation files without hanging) is easy to
/// get subtly wrong per call site.
///
/// [surfaceSize] and [textScaleFactor] reproduce the widths (320/375/900) and
/// the raised system font size the design spec is measured against, without
/// each test repeating the `tester.view` boilerplate. [surfaceSize] is
/// always a logical size: it is what the widget tree lays out against,
/// regardless of [devicePixelRatio]. [textScaler], when given, is used
/// instead of `TextScaler.linear(textScaleFactor)` — for example
/// [AndroidNonLinearTextScaler], which reproduces Android 14+'s non-linear
/// font scale curve that `TextScaler.linear` cannot.
/// [devicePixelRatio] reproduces a device's physical-to-logical pixel ratio
/// (for example to assert on `cacheWidth`/`ResizeImage` values) without
/// changing the logical layout: it only changes how many physical pixels
/// back [surfaceSize]. Defaults to 1 to keep every existing test unchanged.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  CatalogCubit? cubit,
  Size surfaceSize = const Size(375, 812),
  double textScaleFactor = 1,
  TextScaler? textScaler,
  double devicePixelRatio = 1,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // easy_localization persists the chosen locale through shared_preferences;
  // without a mock store, `flutter test` has no real platform implementation
  // to answer that channel and `ensureInitialized` hangs forever instead of
  // failing loudly, so every test gets an in-memory store instead.
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();

  final view = tester.view;
  // `view.physicalSize` is in physical pixels, so it must scale with
  // `devicePixelRatio` for `surfaceSize` to stay the logical size the
  // widget tree lays out against.
  view.physicalSize = surfaceSize * devicePixelRatio;
  view.devicePixelRatio = devicePixelRatio;
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);

  final content = cubit == null
      ? child
      : BlocProvider<CatalogCubit>.value(value: cubit, child: child);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('it'), Locale('en')],
      // Forced rather than left to the device locale, so the assertions on
      // Italian copy in these tests do not depend on the host machine's
      // locale.
      startLocale: const Locale('it'),
      path: 'assets/translations',
      fallbackLocale: const Locale('it'),
      assetLoader: const _FileAssetLoader(),
      saveLocale: false,
      child: Builder(
        builder: (context) => MaterialApp(
          theme: ScalapayTheme.light(),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          builder: (context, materialChild) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: textScaler ?? TextScaler.linear(textScaleFactor),
            ),
            child: materialChild!,
          ),
          home: Scaffold(body: content),
        ),
      ),
    ),
  );
  // Not `pumpAndSettle()`: a loading state renders an indeterminate
  // `CircularProgressIndicator`, whose animation never stops, which would
  // make `pumpAndSettle()` time out instead of returning. A handful of plain
  // pumps is enough to flush the translation load without waiting for every
  // animation to finish; a test that itself triggers a transition it needs
  // fully settled (for example opening a bottom sheet) calls
  // `tester.pumpAndSettle()` again on its own.
  for (var i = 0; i < 5; i++) {
    await tester.pump();
  }
}
