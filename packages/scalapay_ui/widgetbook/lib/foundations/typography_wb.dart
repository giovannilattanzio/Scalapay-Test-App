import 'package:flutter/material.dart';
import 'package:scalapay_ui/scalapay_ui.dart';

import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Text styles', type: ScalapayTypography)
Widget typographyUseCase(BuildContext context) {
  final t = context.tokens;
  return ListView(
    padding: EdgeInsets.all(t.spacing.s),
    children: [
      for (final entry in t.typography.entries.entries)
        Padding(
          padding: EdgeInsets.only(bottom: t.spacing.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.key}  ·  ${entry.value.fontSize?.toStringAsFixed(0)}px  ·  w${entry.value.fontWeight?.value}',
                style: t.typography.p5.copyWith(color: t.colors.textSecondary),
              ),
              Text(
                'Esplora i prodotti',
                style: entry.value.copyWith(color: t.colors.textPrimary),
              ),
            ],
          ),
        ),
    ],
  );
}
