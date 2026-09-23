import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/scalapay_divider.dart';
import '../widgets/scalapay_radio.dart';
import 'internal/bottom_sheet_frame.dart';
import 'show_modal_sheet.dart';

/// Bottom sheet to sort: a white card with one radio option per choice,
/// separated by dividers, and no footer.
///
/// [options] maps each choice value (of a type chosen by the caller) to its
/// label, and its iteration order is the display order. The option whose value
/// equals [selected] is shown as selected; choosing another one calls
/// [onChanged] with its value. The sheet never closes anything by itself: it
/// only calls [onChanged] and [onClose].
class ScalapaySortBottomSheet<T> extends StatelessWidget {
  const ScalapaySortBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.selected,
    this.onChanged,
    this.onClose,
    this.closeLabel,
  });

  final String title;
  final Map<T, String> options;
  final T? selected;
  final ValueChanged<T>? onChanged;
  final VoidCallback? onClose;

  /// Label announced for the close button. Defaults to
  /// `MaterialLocalizations.of(context).closeButtonTooltip`.
  final String? closeLabel;

  // Measured on the Figma frame (no token): minimum height of each option
  // row (radio area + divider), so a label that wraps at a large text scale
  // grows the row instead of clipping it.
  static const _rowHeight = 64.0;
  // ScalapayDivider is a fixed 1px line, not part of the growable radio area.
  static const _dividerHeight = 1.0;
  // Measured on the Figma frame (no token): card horizontal padding (was s
  // = 16).
  static const _cardHorizontalPadding = 15.0;

  /// Opens the sheet as a modal bottom sheet and returns the chosen value.
  ///
  /// Choosing an option shows it as selected and, after a short delay, closes
  /// the modal and returns its value without calling [onClose]. Choosing
  /// another option during the delay restarts it: the last choice wins. Closing it with the close button, a tap on the backdrop or a
  /// drag down returns `null` and calls [onClose] once.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Map<T, String> options,
    T? selected,
    VoidCallback? onClose,
    String? closeLabel,
  }) async {
    final result = await showScalapayModalSheet<T>(
      context,
      builder: (sheetContext) => _SortModal<T>(
        title: title,
        options: options,
        selected: selected,
        closeLabel: closeLabel,
      ),
    );
    if (result == null) onClose?.call();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final entries = options.entries.toList();
    return BottomSheetFrame(
      title: title,
      onClose: onClose,
      closeLabel: closeLabel,
      child: Padding(
        padding: EdgeInsets.fromLTRB(t.spacing.s, 0, t.spacing.s, t.spacing.s),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.colors.background,
            borderRadius: BorderRadius.circular(t.radius.card),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _cardHorizontalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Column(
                    // Keyed so tests can measure each row on its own; the
                    // key is an implementation detail, not part of the
                    // widget's content.
                    key: ValueKey('sort-option-row-$i'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConstrainedBox(
                        // A minimum, not a fixed height: a label that wraps
                        // to two lines at a large text scale grows the row
                        // instead of clipping it. Every row keeps the same
                        // 64 minimum whether or not it has a divider, so the
                        // last option is not 1px shorter than the others.
                        constraints: BoxConstraints(
                          minHeight:
                              _rowHeight -
                              (i < entries.length - 1 ? _dividerHeight : 0),
                        ),
                        child: Center(
                          heightFactor: 1,
                          child: ScalapayRadio<T>(
                            value: entries[i].key,
                            groupValue: selected,
                            label: entries[i].value,
                            onChanged: (value) => onChanged?.call(value),
                          ),
                        ),
                      ),
                      if (i < entries.length - 1) const ScalapayDivider(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Content of the modal opened by [ScalapaySortBottomSheet.show]: shows the
/// choice as selected and closes the modal after a short delay.
class _SortModal<T> extends StatefulWidget {
  const _SortModal({
    required this.title,
    required this.options,
    required this.selected,
    this.closeLabel,
  });

  final String title;
  final Map<T, String> options;
  final T? selected;
  final String? closeLabel;

  @override
  State<_SortModal<T>> createState() => _SortModalState<T>();
}

class _SortModalState<T> extends State<_SortModal<T>> {
  static const _closeDelay = Duration(milliseconds: 300);

  late T? _selected = widget.selected;
  Timer? _timer;

  void _choose(T value) {
    setState(() => _selected = value);
    _timer?.cancel();
    _timer = Timer(_closeDelay, () {
      if (mounted) Navigator.of(context).pop(value);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScalapaySortBottomSheet<T>(
    title: widget.title,
    options: widget.options,
    selected: _selected,
    onChanged: _choose,
    onClose: () => Navigator.of(context).pop(),
    closeLabel: widget.closeLabel,
  );
}
