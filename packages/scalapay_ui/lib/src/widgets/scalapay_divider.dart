import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A 1px horizontal divider using the border token.
class ScalapayDivider extends StatelessWidget {
  const ScalapayDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.tokens.colors.border,
    );
  }
}
