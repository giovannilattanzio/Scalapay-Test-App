// WCAG 2.x text contrast, computed from the color tokens themselves.
//
// Relative luminance per WCAG: for each sRGB channel value c (0..1, already
// what `Color.r`/`.g`/`.b` expose in this Flutter), linearize it with
// `c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ^ 2.4`, then combine as
// `L = 0.2126R + 0.7152G + 0.0722B`. The contrast ratio of two colors is
// `(L1 + 0.05) / (L2 + 0.05)` with `L1` the lighter of the two luminances.
//
// Every text-on-background pair used in the design system must reach 4.5:1
// (WCAG AA for normal text) unless it is listed in `_knownExceptions`. That
// list is a user decision to keep the current Figma values and raise them
// with design rather than silently changing a token; see the doc comment on
// `ScalapayColors` for the same list. This test:
// - fails, naming the pair and its measured ratio, for any pair below 4.5
//   that is not in `_knownExceptions`;
// - fails if a known exception now reaches 4.5 (so the list cannot go stale
//   silently);
// - fails if a known exception's measured ratio drifts by more than 0.01
//   from the recorded value (the token changed and the exception must be
//   re-evaluated).
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

const double _minimumRatio = 4.5;
const double _tolerance = 0.01;

/// Known, user-approved exceptions below WCAG AA 4.5:1, kept at their Figma
/// values until design revisits them. Keyed by pair name (see `_pairs`).
const Map<String, ({double ratio, String reason})> _knownExceptions = {
  'textSecondary on background': (
    ratio: 3.44,
    reason:
        'Figma value (UI/Grayscale/700), used for secondary texts, hint '
        'and field labels; below AA, kept until design changes it.',
  ),
  'textSecondary on surface': (
    ratio: 3.22,
    reason: 'Same token on the light background.',
  ),
  'error on background': (
    ratio: 4.38,
    reason: 'Placeholder value not in Figma.',
  ),
  'textDisabled on background': (
    ratio: 2.68,
    reason: 'WCAG 1.4.3 exempts text of inactive controls.',
  ),
  'textDisabled on border': (
    ratio: 2.37,
    reason: 'WCAG 1.4.3 exempts text of inactive controls.',
  ),
};

/// Text-on-background pairs to check. Adding a text color token means
/// adding a line here.
List<(String name, Color foreground, Color background)> _pairs(
  ScalapayColors colors,
) => [
  ('textPrimary on background', colors.textPrimary, colors.background),
  ('textPrimary on surface', colors.textPrimary, colors.surface),
  ('textStoreName on background', colors.textStoreName, colors.background),
  ('textInput on background', colors.textInput, colors.background),
  ('primary on background', colors.primary, colors.background),
  ('onPrimary on primary', colors.onPrimary, colors.primary),
  ('textSecondary on background', colors.textSecondary, colors.background),
  ('textSecondary on surface', colors.textSecondary, colors.surface),
  ('error on background', colors.error, colors.background),
  ('textDisabled on background', colors.textDisabled, colors.background),
  ('textDisabled on border', colors.textDisabled, colors.border),
];

double _linearize(double channel) => channel <= 0.03928
    ? channel / 12.92
    : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

double _relativeLuminance(Color color) =>
    0.2126 * _linearize(color.r) +
    0.7152 * _linearize(color.g) +
    0.0722 * _linearize(color.b);

double _contrastRatio(Color a, Color b) {
  final luminanceA = _relativeLuminance(a);
  final luminanceB = _relativeLuminance(b);
  final lighter = math.max(luminanceA, luminanceB);
  final darker = math.min(luminanceA, luminanceB);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Checks every pair for [colors] and returns one failure message per pair
/// that violates the rule above; empty when everything is compliant.
List<String> _checkContrast(ScalapayColors colors) {
  final failures = <String>[];
  for (final (name, foreground, background) in _pairs(colors)) {
    final ratio = _contrastRatio(foreground, background);
    final exception = _knownExceptions[name];
    if (exception == null) {
      if (ratio < _minimumRatio) {
        failures.add(
          '$name has a contrast ratio of ${ratio.toStringAsFixed(2)}:1, '
          'below the WCAG AA minimum of 4.5:1, and is not a documented '
          'exception in _knownExceptions.',
        );
      }
    } else if (ratio >= _minimumRatio) {
      failures.add(
        '$name now reaches a contrast ratio of '
        '${ratio.toStringAsFixed(2)}:1 (>= 4.5:1); remove it from '
        '_knownExceptions.',
      );
    } else if ((ratio - exception.ratio).abs() > _tolerance) {
      failures.add(
        '$name measured ${ratio.toStringAsFixed(2)}:1 but '
        '_knownExceptions records ${exception.ratio.toStringAsFixed(2)}:1; '
        'the token changed, re-evaluate the exception.',
      );
    }
  }
  return failures;
}

void main() {
  test('color tokens meet WCAG AA contrast or are documented exceptions', () {
    final failures = _checkContrast(const ScalapayColors());
    if (failures.isNotEmpty) {
      fail(failures.join('\n'));
    }
  });

  test('reports a regression when a text color drops below 4.5:1', () {
    // Simulates a token regression without touching the real token: swaps
    // `textPrimary` for a low-contrast gray and asserts the checker catches
    // it, naming the pair and its ratio.
    const modified = ScalapayColors(textPrimary: Color(0xFF9E9E9E));
    final failures = _checkContrast(modified);

    expect(
      failures.any(
        (failure) =>
            failure.contains('textPrimary on background') &&
            failure.contains('below the WCAG AA minimum'),
      ),
      isTrue,
      reason:
          'Expected a failure naming "textPrimary on background" with its '
          'ratio. Got:\n${failures.join('\n')}',
    );
  });
}
