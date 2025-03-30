import 'package:flutter/material.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';

class MPOverlayWindowBlockWidget extends StatelessWidget {
  final List<Widget> children;
  final MPOverlayWindowBlockType overlayWindowBlockType;

  const MPOverlayWindowBlockWidget({
    super.key,
    required this.children,
    required this.overlayWindowBlockType,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    late final Color? iconColor;
    late final Color? textColor;
    late final Color? tileColor;

    // if (isSelected) {
    //   iconColor = null;
    //   textColor = null;
    //   tileColor = null;
    // } else {
    final Color color;
    switch (overlayWindowBlockType) {
      case MPOverlayWindowBlockType.main:
        color = Colors.green;
      case MPOverlayWindowBlockType.secondarySet:
        // mpLocator.mpLog.fine("MPOptionWidget.build() MPOptionStateType.set");
        iconColor = colorScheme.onTertiaryFixed;
        textColor = colorScheme.onTertiaryFixed;
        color = colorScheme.tertiaryFixed;

      case MPOverlayWindowBlockType.secondarySetMixed:
        // mpLocator.mpLog
        //     .fine("MPOptionWidget.build() MPOptionStateType.setMixed");
        iconColor = colorScheme.onTertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        color = colorScheme.tertiaryContainer;
      case MPOverlayWindowBlockType.secondarySetUnsupported:
        // mpLocator.mpLog
        //     .fine("MPOptionWidget.build() MPOptionStateType.setUnsupported");
        iconColor = colorScheme.onTertiary;
        textColor = colorScheme.onTertiary;
        color = colorScheme.tertiary;
      case MPOverlayWindowBlockType.secondaryUnset:
        // mpLocator.mpLog
        //     .fine("MPOptionWidget.build() MPOptionStateType.unset");
        iconColor = colorScheme.onSurfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
        color = colorScheme.surfaceContainer;
    }
    // }

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
