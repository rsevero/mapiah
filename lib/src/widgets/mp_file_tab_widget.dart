// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:path/path.dart' as p;

class MPFileTabWidget extends StatelessWidget {
  final String filename;
  final bool isActive;
  final VoidCallback onClose;

  const MPFileTabWidget({
    required this.filename,
    required this.isActive,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String basename = p.basename(filename);
    final Color backgroundColor = isActive
        ? theme.colorScheme.primary.withAlpha(80)
        : theme.colorScheme.surfaceContainerLow;
    final Color textColor = isActive
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(30),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: mpTabLabelMaxWidth),
            child: Tooltip(
              message: filename,
              child: Text(
                basename,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: isActive ? 14.0 : 13.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          SizedBox(
            width: mpTabCloseIconSize + 8.0,
            height: mpTabCloseIconSize + 8.0,
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: mpTabCloseIconSize,
                color: textColor,
              ),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(2.0),
              onPressed: onClose,
              tooltip:
                  mpLocator.appLocalizations.th2FileTabsPageCloseTabTooltip,
              hoverColor: theme.colorScheme.primary.withAlpha(20),
            ),
          ),
        ],
      ),
    );
  }
}
