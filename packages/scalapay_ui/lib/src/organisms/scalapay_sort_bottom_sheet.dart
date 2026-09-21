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
  });

  final String title;
  final Map<T, String> options;
  final T? selected;
  final ValueChanged<T>? onChanged;
  final VoidCallback? onClose;

  // Measured on the Figma frame (no token): height of each option row.
  static const _rowHeight = 64.0;
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
  }) async {
    final result = await showScalapayModalSheet<T>(
      context,
      builder: (sheetContext) =>
          _SortModal<T>(title: title, options: options, selected: selected),
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
                  SizedBox(
                    height: _rowHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Center(
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
  });

  final String title;
  final Map<T, String> options;
  final T? selected;

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
  );
}
