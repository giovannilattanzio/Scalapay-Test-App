import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Presents [builder]'s content as a modal bottom sheet with the design
/// system's standard sheet presentation: a barrier dimmed with the `overlay`
/// token, `useSafeArea`, scroll support for content taller than the
/// available space, a transparent background so the sheet can draw its own
/// rounded top, and padding that keeps the content above the keyboard.
/// Barrier taps and drags dismiss it with a `null` result.
///
/// Every organism's static `show` (for example
/// [ScalapayFiltersBottomSheet.show], [ScalapaySortBottomSheet.show]) is
/// built on top of this and closes the modal for you. Reach for
/// [showScalapayModalSheet] directly only when the caller must decide for
/// itself whether the modal closes — for instance to keep the sheet open and
/// surface a validation error instead of popping it as soon as a callback
/// returns.
Future<T?> showScalapayModalSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final t = context.tokens;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: t.colors.overlay.withValues(alpha: 0.5),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SingleChildScrollView(child: builder(sheetContext)),
    ),
  );
}
