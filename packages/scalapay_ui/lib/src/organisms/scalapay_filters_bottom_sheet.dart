import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/scalapay_button.dart';
import '../widgets/scalapay_text_field.dart';
import 'internal/bottom_sheet_frame.dart';
import 'internal/decimal_input_formatter.dart';
import 'show_modal_sheet.dart';

/// Bottom sheet to filter by price: a white card with a price title and two
/// writable fields (minimum and maximum), and a footer with a tertiary "clear"
/// button and a primary "apply" button.
///
/// Every text comes from the caller. The values are read, set and cleared
/// through [minController] and [maxController]; the sheet does not validate,
/// parse or format them. A button without a callback is disabled. The sheet
/// never closes anything by itself: it only calls [onClose], [onClear] and
/// [onApply].
class ScalapayFiltersBottomSheet extends StatelessWidget {
  const ScalapayFiltersBottomSheet({
    super.key,
    required this.title,
    required this.priceTitle,
    required this.minLabel,
    required this.maxLabel,
    required this.clearLabel,
    required this.applyLabel,
    this.minController,
    this.maxController,
    this.priceError,
    this.onClose,
    this.onClear,
    this.onApply,
  });

  final String title;
  final String priceTitle;
  final String minLabel;
  final String maxLabel;
  final String clearLabel;
  final String applyLabel;
  final TextEditingController? minController;
  final TextEditingController? maxController;

  /// Message shown once below the two price fields, styled like a field
  /// error. It is a single message, not one per field, because an inverted
  /// range is a property of the pair of values, not of either one alone.
  /// The sheet never computes it: the caller validates, this only displays.
  final String? priceError;
  final VoidCallback? onClose;
  final VoidCallback? onClear;
  final VoidCallback? onApply;

  /// Opens the sheet as a modal bottom sheet.
  ///
  /// Closing it with the close button, a tap on the backdrop or a drag down
  /// calls [onClose] once. The apply button calls [onApply] and then closes the
  /// modal without calling [onClose]; the clear button calls [onClear] and
  /// leaves it open.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String priceTitle,
    required String minLabel,
    required String maxLabel,
    required String clearLabel,
    required String applyLabel,
    TextEditingController? minController,
    TextEditingController? maxController,
    String? priceError,
    VoidCallback? onClose,
    VoidCallback? onClear,
    VoidCallback? onApply,
  }) async {
    var applied = false;
    await showScalapayModalSheet<void>(
      context,
      builder: (sheetContext) => ScalapayFiltersBottomSheet(
        title: title,
        priceTitle: priceTitle,
        minLabel: minLabel,
        maxLabel: maxLabel,
        clearLabel: clearLabel,
        applyLabel: applyLabel,
        minController: minController,
        maxController: maxController,
        priceError: priceError,
        onClose: () => Navigator.of(sheetContext).pop(),
        onClear: onClear,
        onApply: onApply == null
            ? null
            : () {
                applied = true;
                onApply();
                Navigator.of(sheetContext).pop();
              },
      ),
    );
    if (!applied) onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return BottomSheetFrame(
      title: title,
      onClose: onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: t.spacing.s),
            child: _PriceCard(
              title: priceTitle,
              minLabel: minLabel,
              maxLabel: maxLabel,
              minController: minController,
              maxController: maxController,
              error: priceError,
            ),
          ),
          SizedBox(height: t.spacing.xs / 2),
          Padding(
            padding: EdgeInsets.all(t.spacing.s),
            child: Row(
              children: [
                Expanded(
                  child: ScalapayButton(
                    variant: ScalapayButtonVariant.tertiary,
                    label: clearLabel,
                    onPressed: onClear,
                  ),
                ),
                SizedBox(width: t.spacing.xs),
                Expanded(
                  child: ScalapayButton(label: applyLabel, onPressed: onApply),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.title,
    required this.minLabel,
    required this.maxLabel,
    required this.minController,
    required this.maxController,
    required this.error,
  });

  final String title;
  final String minLabel;
  final String maxLabel;
  final TextEditingController? minController;
  final TextEditingController? maxController;
  final String? error;

  // Measured on the Figma frame (no token): width of the dash between fields.
  static const _dashWidth = 11.0;
  static const _keyboard = TextInputType.numberWithOptions(decimal: true);
  static const _formatters = [DecimalInputFormatter()];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.background,
        borderRadius: BorderRadius.circular(t.radius.card),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.spacing.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: t.typography.p3Medium.copyWith(
                color: t.colors.textPrimary,
              ),
            ),
            SizedBox(height: t.spacing.s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ScalapayTextField(
                    label: minLabel,
                    controller: minController,
                    keyboardType: _keyboard,
                    inputFormatters: _formatters,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: t.spacing.xs),
                  child: SizedBox(
                    width: _dashWidth,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: t.colors.textDisabled,
                        borderRadius: BorderRadius.circular(0.5),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ScalapayTextField(
                    label: maxLabel,
                    controller: maxController,
                    keyboardType: _keyboard,
                    inputFormatters: _formatters,
                  ),
                ),
              ],
            ),
            if (error != null) ...[
              SizedBox(height: t.spacing.xs),
              Text(
                error!,
                style: t.typography.p5.copyWith(color: t.colors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
