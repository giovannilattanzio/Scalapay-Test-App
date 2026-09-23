import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'scalapay_icon.dart';

/// Search input with a round primary action button. Submitting (button or
/// keyboard) calls [onSubmitted] with the current text.
class ScalapaySearchField extends StatelessWidget {
  const ScalapaySearchField({
    super.key,
    this.controller,
    this.hint,
    this.onSubmitted,
    this.actionLabel,
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onSubmitted;

  /// Semantics label of the action button. Defaults to the current
  /// [MaterialLocalizations.searchFieldLabel] (localized).
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return _SearchFieldBody(
      controller: controller,
      hint: hint,
      onSubmitted: onSubmitted,
      actionLabel: actionLabel,
      tokens: t,
    );
  }
}

class _SearchFieldBody extends StatefulWidget {
  const _SearchFieldBody({
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    required this.actionLabel,
    required this.tokens,
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onSubmitted;
  final String? actionLabel;
  final ScalapayTokens tokens;

  @override
  State<_SearchFieldBody> createState() => _SearchFieldBodyState();
}

class _SearchFieldBodyState extends State<_SearchFieldBody> {
  TextEditingController? _own;

  TextEditingController get _controller =>
      widget.controller ?? (_own ??= TextEditingController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  void _submit() => widget.onSubmitted?.call(_controller.text);

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    return Container(
      // A fixed height would clip the text at large text scales; a minimum
      // keeps the 55 look at scale 1 while letting the field grow with it.
      constraints: const BoxConstraints(minHeight: 55),
      decoration: ShapeDecoration(
        color: t.colors.background,
        shape: StadiumBorder(side: BorderSide(color: t.colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 5, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onSubmitted,
              style: t.typography.p3Medium.copyWith(
                color: t.colors.textPrimary,
              ),
              cursorColor: t.colors.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: t.typography.p3Medium.copyWith(
                  color: t.colors.textSecondary,
                ),
                // isCollapsed sizes the decorator to the text alone (no
                // padding, no InputDecorator minimum). At the P3 Medium text
                // style that natural height is 20, so this symmetric padding
                // (measured, no matching token) brings the field's own
                // tappable/semantics box up to the 44 minimum (Apple HIG /
                // WCAG 2.5.5) while keeping the text centered where it was;
                // the extra space is absorbed inside the still-55-tall pill.
                // An explicit contentPadding is honored even with
                // isCollapsed, unlike a bare `constraints`, which only grows
                // the box after layout and leaves the text off-center.
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Semantics(
            button: true,
            label:
                widget.actionLabel ??
                MaterialLocalizations.of(context).searchFieldLabel,
            onTap: _submit,
            excludeSemantics: true,
            child: Material(
              color: t.colors.primary,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _submit,
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Center(
                    child: ScalapayIcon(
                      ScalapayIconData.search,
                      color: t.colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
