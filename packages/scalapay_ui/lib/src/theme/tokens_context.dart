import 'package:flutter/material.dart';

import 'scalapay_tokens.dart';

extension ScalapayTokensContext on BuildContext {
  /// The design tokens of the nearest theme.
  ///
  /// Throws a [FlutterError] if the theme has no [ScalapayTokens], so a missing
  /// `ScalapayTheme` fails loudly instead of falling back to arbitrary values.
  ScalapayTokens get tokens {
    final tokens = Theme.of(this).extension<ScalapayTokens>();
    if (tokens == null) {
      throw FlutterError(
        'ScalapayTokens not found in the current Theme.\n'
        'Wrap the app with ScalapayTheme.light() '
        '(MaterialApp(theme: ScalapayTheme.light())).',
      );
    }
    return tokens;
  }
}
