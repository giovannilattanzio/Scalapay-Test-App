import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A radio option with a label. Selected when [value] equals [groupValue];
/// tapping an unselected option calls [onChanged] with [value].
class ScalapayRadio<T> extends StatelessWidget {
  const ScalapayRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  final T value;
  final T? groupValue;
  final String label;
  final ValueChanged<T> onChanged;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: _selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: _selected ? null : () => onChanged(value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selected
                        ? t.colors.primary
                        : t.colors.primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: _selected
                    ? Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: t.colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(width: 10, height: 10),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: t.spacing.xs + 4),
              Expanded(
                child: Text(
                  label,
                  style: t.typography.p3Medium.copyWith(
                    color: t.colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
