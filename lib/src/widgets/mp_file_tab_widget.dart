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
        ? theme.colorScheme.primary.withAlpha(51)
        : theme.colorScheme.surface;
    final Color textColor = isActive
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withAlpha(153);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: isActive
              ? BorderSide(color: theme.colorScheme.primary, width: 2.0)
              : BorderSide(color: theme.dividerColor, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: mpButtonSpace),
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
                style: TextStyle(color: textColor),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: mpTabCloseIconSize,
            constraints: const BoxConstraints(
              minWidth: mpTabCloseIconSize + 8.0,
              minHeight: mpTabCloseIconSize + 8.0,
            ),
            padding: const EdgeInsets.all(4.0),
            onPressed: onClose,
            tooltip: mpLocator.appLocalizations.th2FileTabsPageCloseTabTooltip,
          ),
        ],
      ),
    );
  }
}
