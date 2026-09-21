import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../widgets/scalapay_icon.dart';

/// Frame shared by the bottom sheet organisms: surface with rounded top
/// corners, a handle, a centered title and a close button, followed by
/// [child]. Internal: not exported by the package barrel.
///
/// [child] gets no padding, each sheet lays out its own content. The frame
/// takes the width its parent offers and the height of its content, plus the
/// bottom system inset (for example the home indicator) added below [child]
/// so its last row never sits under it.
class BottomSheetFrame extends StatelessWidget {
  const BottomSheetFrame({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;

  // Measured on the Figma frame (no token for these).
  static const _headerHeight = 91.0;
  static const _handleWidth = 45.0;
  static const _handleHeight = 5.0;
  static const _handleTop = 7.0;
  static const _titleTop = 26.0;
  static const _titleSide = 40.0;
  static const _closeWidth = 58.0;
  static const _closeHeight = 65.0;
  static const _closeIconSize = 32.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // showModalBottomSheet's useSafeArea only insets the top and sides, so the
    // sheet still reaches the physical bottom edge; the keyboard inset is
    // handled separately by showScalapayModalSheet via viewInsets, so
    // viewPadding (not padding, which zeroes out under the keyboard) is the
    // one MediaQuery value that stays stable while typing.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(t.radius.sheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _headerHeight,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: _handleTop),
                    child: SizedBox(
                      width: _handleWidth,
                      height: _handleHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: t.colors.textDisabled.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(
                            _handleHeight / 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: _titleTop,
                  left: _titleSide,
                  right: _titleSide,
                  bottom: 0,
                  child: Center(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: t.typography.p1.copyWith(
                          color: t.colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  width: _closeWidth,
                  height: _closeHeight,
                  child: Semantics(
                    button: true,
                    child: InkResponse(
                      onTap: onClose,
                      child: Center(
                        child: ScalapayIcon(
                          ScalapayIconData.close,
                          size: _closeIconSize,
                          color: t.colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: child,
          ),
        ],
      ),
    );
  }
}
