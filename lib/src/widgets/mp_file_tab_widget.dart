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
        ? theme.colorScheme.primary.withAlpha(25)
        : theme.colorScheme.surfaceContainerLow;
    final Color textColor = isActive
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    final Color borderColor = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: isActive ? 3.0 : 1.0),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
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
              hoverColor: theme.colorScheme.primary.withAlpha(30),
            ),
          ),
        ],
      ),
    );
  }
}
