import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Spacing', type: ScalapaySpacing)
Widget spacingUseCase(BuildContext context) {
  final t = context.tokens;
  return ListView(
    padding: EdgeInsets.all(t.spacing.s),
    children: [
      for (final entry in t.spacing.entries.entries)
        Padding(
          padding: EdgeInsets.only(bottom: t.spacing.xs),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  '${entry.key} = ${entry.value.toStringAsFixed(0)}',
                  style: t.typography.p3Medium,
                ),
              ),
              Container(
                width: entry.value,
                height: 24,
                color: t.colors.primary,
              ),
            ],
          ),
        ),
    ],
  );
}

@widgetbook.UseCase(name: 'Radius', type: ScalapayRadius)
Widget radiusUseCase(BuildContext context) {
  final t = context.tokens;
  return ListView(
    padding: EdgeInsets.all(t.spacing.s),
    children: [
      for (final entry in t.radius.entries.entries)
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '${entry.key} = ${entry.value.toStringAsFixed(0)}',
                style: t.typography.p3Medium,
              ),
            ),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: t.colors.surface,
                border: Border.all(color: t.colors.border),
                borderRadius: BorderRadius.circular(entry.value),
              ),
            ),
          ],
        ),
    ],
  );
}
