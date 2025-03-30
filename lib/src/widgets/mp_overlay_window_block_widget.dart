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
    double elevation = 0;

    final Color color;
    switch (overlayWindowBlockType) {
      case MPOverlayWindowBlockType.choices:
        color = Colors.blue.shade200;
      case MPOverlayWindowBlockType.choiceSet:
        color = Colors.orange.shade200;

      case MPOverlayWindowBlockType.choiceUnset:
        color = Colors.grey.shade300;
        elevation = 3;
      case MPOverlayWindowBlockType.main:
        color = Colors.green;
      case MPOverlayWindowBlockType.secondarySet:
        iconColor = colorScheme.onTertiaryFixed;
        textColor = colorScheme.onTertiaryFixed;
        color = colorScheme.tertiaryFixed;
      case MPOverlayWindowBlockType.secondarySetMixed:
        iconColor = colorScheme.onTertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        color = colorScheme.tertiaryContainer;
      case MPOverlayWindowBlockType.secondarySetUnsupported:
        iconColor = colorScheme.onTertiary;
        textColor = colorScheme.onTertiary;
        color = colorScheme.tertiary;
      case MPOverlayWindowBlockType.secondaryUnset:
        iconColor = colorScheme.onSurfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
        color = colorScheme.surfaceContainer;
        elevation = 3;
    }
    // }

    return Material(
      color: color,
      elevation: elevation,
      borderRadius: BorderRadius.circular(18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
