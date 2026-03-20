// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPDialogBottomWidget extends StatelessWidget {
  final Widget child;

  const MPDialogBottomWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Divider(height: 1),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.35,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(mpOverlayWindowCornerRadius),
              bottomRight: Radius.circular(mpOverlayWindowCornerRadius),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: child,
          ),
        ),
      ],
    );
  }
}
