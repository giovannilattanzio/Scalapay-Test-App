import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/scalapay_icons.dart';
import '../theme/theme.dart';

/// Icons available in the design system (SVG assets, 24px grid).
enum ScalapayIconData {
  filter(ScalapayIcons.filter),
  order(ScalapayIcons.order),
  search(ScalapayIcons.search),
  close(ScalapayIcons.close);

  const ScalapayIconData(this.asset);

  final String asset;
}

/// A design system icon, tinted with [color] (default: primary text color).
class ScalapayIcon extends StatelessWidget {
  const ScalapayIcon(this.icon, {super.key, this.size = 24, this.color});

  final ScalapayIconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.asset,
      package: ScalapayIcons.package,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        color ?? context.tokens.colors.textPrimary,
        BlendMode.srcIn,
      ),
    );
  }
}
