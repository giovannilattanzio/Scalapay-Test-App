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
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return _SearchFieldBody(
      controller: controller,
      hint: hint,
      onSubmitted: onSubmitted,
      tokens: t,
    );
  }
}

class _SearchFieldBody extends StatefulWidget {
  const _SearchFieldBody({
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    required this.tokens,
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onSubmitted;
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
      height: 55,
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
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Search',
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
