/// Corner radii (Figma Corner-radius/*).
///
/// `image`, `card` and `sheet` have the same value today but are separate
/// tokens because their roles differ, so each can change on its own.
class ScalapayRadius {
  const ScalapayRadius({
    this.child = 10,
    this.image = 20,
    this.card = 20,
    this.sheet = 20,
  });

  final double child; // Corner-radius/Child
  final double image; // Radius of image areas (product card)
  final double card; // Radius of white cards (filters and sort sheets)
  final double sheet; // Radius of the top corners of bottom sheets

  Map<String, double> get entries => {
    'child': child,
    'image': image,
    'card': card,
    'sheet': sheet,
  };
}
