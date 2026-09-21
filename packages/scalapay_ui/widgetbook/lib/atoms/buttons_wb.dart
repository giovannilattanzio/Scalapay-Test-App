import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Primary - enabled', type: ScalapayButton)
Widget buttonPrimaryEnabled(BuildContext context) => Center(
  child: ScalapayButton(
    label: context.knobs.string(
      label: 'Label',
      initialValue: 'Mostra risultati',
    ),
    onPressed: () {},
  ),
);

@widgetbook.UseCase(name: 'Primary - disabled', type: ScalapayButton)
Widget buttonPrimaryDisabled(BuildContext context) => Center(
  child: ScalapayButton(
    label: context.knobs.string(
      label: 'Label',
      initialValue: 'Mostra risultati',
    ),
  ),
);

@widgetbook.UseCase(name: 'Tertiary - enabled', type: ScalapayButton)
Widget buttonTertiaryEnabled(BuildContext context) => Center(
  child: ScalapayButton(
    variant: ScalapayButtonVariant.tertiary,
    label: context.knobs.string(label: 'Label', initialValue: 'Cancella tutto'),
    onPressed: () {},
  ),
);

@widgetbook.UseCase(name: 'Tertiary - disabled', type: ScalapayButton)
Widget buttonTertiaryDisabled(BuildContext context) => Center(
  child: ScalapayButton(
    variant: ScalapayButtonVariant.tertiary,
    label: context.knobs.string(label: 'Label', initialValue: 'Cancella tutto'),
  ),
);

@widgetbook.UseCase(
  name: 'Bottom controls (tertiary + primary)',
  type: ScalapayButton,
)
Widget buttonBottomControls(BuildContext context) => Padding(
  padding: EdgeInsets.all(context.tokens.spacing.s),
  child: Row(
    children: [
      Expanded(
        child: ScalapayButton(
          variant: ScalapayButtonVariant.tertiary,
          label: 'Cancella tutto',
          onPressed: () {},
        ),
      ),
      SizedBox(width: context.tokens.spacing.s),
      Expanded(
        child: ScalapayButton(label: 'Mostra risultati', onPressed: () {}),
      ),
    ],
  ),
);
