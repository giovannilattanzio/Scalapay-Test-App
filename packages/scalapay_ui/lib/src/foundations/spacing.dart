/// Spacing scale (Figma Gap/*).
class ScalapaySpacing {
  const ScalapaySpacing({this.xs = 8, this.s = 16});

  final double xs; // Gap/XS
  final double s; // Gap/S

  Map<String, double> get entries => {'xs': xs, 's': s};
}
