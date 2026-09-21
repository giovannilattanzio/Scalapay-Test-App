import 'package:flutter/painting.dart';

/// Text styles from the Figma "Mobile" scale, in Poppins (bundled asset).
///
/// Styles carry no color: apply one from `ScalapayColors` (or let the theme
/// text theme do it).
class ScalapayTypography {
  const ScalapayTypography({
    this.h2 = const TextStyle(
      fontFamily: _family,
      package: _package,
      fontSize: 25,
      height: 30 / 25,
      fontWeight: FontWeight.w600,
    ),
    this.p1 = const TextStyle(
      fontFamily: _family,
      package: _package,
      fontSize: 15,
      height: 1.6,
      fontWeight: FontWeight.w600,
    ),
    // Same metrics as `button` by coincidence, not by design: a product price
    // line is not a button, so it gets its own token instead of aliasing it.
    this.p2 = const TextStyle(
      fontFamily: _family,
      package: _package,
      fontSize: 14,
      height: 21 / 14,
      fontWeight: FontWeight.w600,
    ),
    this.p2Medium = const TextStyle(
      fontFamily: _family,
      package: _package,
      fontSize: 14,
      height: 22.4 / 14,
      fontWeight: FontWeight.w500,
    ),
    this.p3 = const TextStyle(
      fontFamily: _family,
      package: _package,
      fontSize: 13,
      height: 20 / 13,
      fontWeight: FontWeight.w600,
    ),
    this.p3Medium = const TextStyle(
      fontFamily: _family,
      package: _package,
      fontSize: 13,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
    this.p4 = const TextStyle(
      fontFamily: _family,
      package: _package,
      fontSize: 12,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
    this.p5 = const TextStyle(
      fontFamily: _family,
      package: _package,
      fontSize: 11,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
    this.p5Semibold = const TextStyle(
      fontFamily: _family,
      package: _package,
      fontSize: 11,
      height: 1.5,
      fontWeight: FontWeight.w600,
    ),
    this.button = const TextStyle(
      fontFamily: _family,
      package: _package,
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w600,
    ),
  });

  static const _family = 'Poppins';
  static const _package = 'scalapay_ui';

  final TextStyle h2; // Mobile/H2/600 - Semibold, 25 / 30
  final TextStyle p1; // Mobile/P1/600 - Semibold, 15
  final TextStyle p2; // Mobile/P2/600 - Semibold, 14 / 21
  final TextStyle p2Medium; // Mobile/P2/500 - Medium, 14 / 22.4
  final TextStyle p3; // Mobile/P3/600 - Semibold, 13 / 20
  final TextStyle p3Medium; // Mobile/P3/500 - Medium, 13
  final TextStyle p4; // Mobile/P4/500 - Medium, 12
  final TextStyle p5; // Mobile/P5/500 - Medium, 11
  final TextStyle p5Semibold; // Mobile/P5/600 - Semibold, 11
  final TextStyle button; // Buttons/Medium/Not-underlined/Lowercase, 14

  ScalapayTypography lerp(ScalapayTypography other, double t) =>
      ScalapayTypography(
        h2: TextStyle.lerp(h2, other.h2, t)!,
        p1: TextStyle.lerp(p1, other.p1, t)!,
        p2: TextStyle.lerp(p2, other.p2, t)!,
        p2Medium: TextStyle.lerp(p2Medium, other.p2Medium, t)!,
        p3: TextStyle.lerp(p3, other.p3, t)!,
        p3Medium: TextStyle.lerp(p3Medium, other.p3Medium, t)!,
        p4: TextStyle.lerp(p4, other.p4, t)!,
        p5: TextStyle.lerp(p5, other.p5, t)!,
        p5Semibold: TextStyle.lerp(p5Semibold, other.p5Semibold, t)!,
        button: TextStyle.lerp(button, other.button, t)!,
      );

  Map<String, TextStyle> get entries => {
    'h2': h2,
    'p1': p1,
    'p2': p2,
    'p2Medium': p2Medium,
    'p3': p3,
    'p3Medium': p3Medium,
    'p4': p4,
    'p5': p5,
    'p5Semibold': p5Semibold,
    'button': button,
  };
}
