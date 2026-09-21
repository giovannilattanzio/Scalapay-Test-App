/// Asset paths of the design system SVG icons.
///
/// The paths are relative to this package: load them with
/// `SvgPicture.asset(ScalapayIcons.filter, package: ScalapayIcons.package)`,
/// or use `ScalapayIcon(ScalapayIconData.filter)`, which already does.
abstract final class ScalapayIcons {
  /// Package that owns the assets, to pass as the `package` argument.
  static const package = 'scalapay_ui';

  static const filter = 'assets/icons/filter.svg';
  static const order = 'assets/icons/order.svg';
  static const search = 'assets/icons/search.svg';
  static const close = 'assets/icons/close.svg';

  /// Every icon path, in declaration order.
  static const all = [filter, order, search, close];
}
