import 'package:flutter/widgets.dart';

/// Reproduces the shape of Android 14+'s (API 34) non-linear system font
/// scale curve at a 200% setting, by linear interpolation over its (sp, dp)
/// control points. Real Android 14+ devices hand Flutter exactly this kind
/// of `TextScaler` — not `TextScaler.linear` — once the system font size is
/// raised: small font sizes end up close to 2x, while large ones are barely
/// touched at all. `TextScaler.linear(2.0)`, used everywhere else in this
/// test suite, cannot reproduce that shape, which is exactly what let
/// `CatalogProductGrid` pass a layout length (170, 220) into
/// `textScaler.scale` undetected: on a linear scaler that mistake merely
/// doubles the value like everything else; on this curve a value that large
/// is past the table and comes back almost unscaled, while the card's own
/// 12-14px text still roughly doubles — the overflow only a non-linear
/// scaler catches.
///
/// The table below is approximate, taken from the shape of Android's public
/// `FontScaleConverterFactory` entries for its 200% curve. The exact numbers
/// are not load-bearing for this app; only the shape is: small fonts
/// (8-14sp) scale close to 2x, larger ones progressively less, and anything
/// at or past 100sp is left unscaled (`dp == sp`).
class AndroidNonLinearTextScaler extends TextScaler {
  const AndroidNonLinearTextScaler();

  // (sp, dp) control points of the curve, sp ascending.
  static const _table = <({double sp, double dp})>[
    (sp: 8, dp: 16),
    (sp: 10, dp: 20),
    (sp: 12, dp: 24),
    (sp: 14, dp: 28),
    (sp: 18, dp: 36),
    (sp: 20, dp: 40),
    (sp: 24, dp: 48),
    (sp: 30, dp: 60),
    (sp: 100, dp: 100),
  ];

  @override
  double scale(double fontSize) {
    assert(fontSize >= 0);
    assert(fontSize.isFinite);

    final firstSp = _table.first.sp;
    if (fontSize <= firstSp) {
      // Below the table's first point: the curve keeps scaling linearly by
      // the same ~2x its smallest entries already show (8 -> 16, 10 -> 20).
      return fontSize * 2;
    }

    final lastSp = _table.last.sp;
    if (fontSize >= lastSp) {
      // At or past the table's last point: identity, dp == sp.
      return fontSize;
    }

    for (var i = 0; i < _table.length - 1; i++) {
      final (sp: x1, dp: y1) = _table[i];
      final (sp: x2, dp: y2) = _table[i + 1];
      if (fontSize >= x1 && fontSize <= x2) {
        final t = (fontSize - x1) / (x2 - x1);
        return y1 + t * (y2 - y1);
      }
    }

    // Unreachable: every fontSize is covered by the two boundary checks
    // above or by one of the segments in the loop.
    return fontSize;
  }

  // Required by `TextScaler`; this scaler is non-linear, so no single ratio
  // describes it. 2.0 names the setting this curve reproduces (Android's
  // 200% system font size), the closest thing to a faithful nominal value.
  @Deprecated(
    'Use of textScaleFactor was deprecated in preparation for the upcoming '
    'nonlinear text scaling support. This feature was deprecated after '
    'v3.12.0-2.0.pre.',
  )
  @override
  double get textScaleFactor => 2.0;

  @override
  TextScaler clamp({
    double minScaleFactor = 0,
    double maxScaleFactor = double.infinity,
  }) {
    if (minScaleFactor == 0 && maxScaleFactor == double.infinity) return this;
    // Clamping a non-linear curve to a single scale factor range no longer
    // describes a curve at all, so this falls back to a plain linear scaler
    // (at the same nominal 2.0) clamped the normal way, rather than
    // pretending a clamped-but-still-non-linear scaler exists.
    return const TextScaler.linear(2.0)
        .clamp(minScaleFactor: minScaleFactor, maxScaleFactor: maxScaleFactor);
  }

  @override
  bool operator ==(Object other) => other is AndroidNonLinearTextScaler;

  @override
  int get hashCode => runtimeType.hashCode;
}
