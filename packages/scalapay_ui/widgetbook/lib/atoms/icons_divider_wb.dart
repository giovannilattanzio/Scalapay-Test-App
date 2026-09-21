import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All icons', type: ScalapayIcon)
Widget iconsAll(BuildContext context) {
  final size = context.knobs.double.slider(
    label: 'Size',
    initialValue: 24,
    min: 16,
    max: 64,
  );
  final t = context.tokens;
  return Center(
    child: Wrap(
      spacing: t.spacing.s,
      runSpacing: t.spacing.s,
      children: [
        for (final icon in ScalapayIconData.values)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScalapayIcon(icon, size: size),
              Text(
                icon.name,
                style: t.typography.p5.copyWith(color: t.colors.textSecondary),
              ),
            ],
          ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Tinted', type: ScalapayIcon)
Widget iconTinted(BuildContext context) {
  final t = context.tokens;
  return Center(
    child: ScalapayIcon(
      ScalapayIconData.search,
      size: 48,
      color: t.colors.primary,
    ),
  );
}

@widgetbook.UseCase(name: 'Default', type: ScalapayDivider)
Widget dividerDefault(BuildContext context) => Padding(
  padding: EdgeInsets.all(context.tokens.spacing.s),
  child: const Center(child: ScalapayDivider()),
);
