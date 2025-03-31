import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';

class MPOverlayWindowBlockWidget extends StatelessWidget {
  final List<Widget> children;
  final MPOverlayWindowBlockType overlayWindowBlockType;
  final EdgeInsetsGeometry? padding;

  const MPOverlayWindowBlockWidget({
    super.key,
    required this.children,
    required this.overlayWindowBlockType,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    late final Color? iconColor;
    late final Color? textColor;
    late final Color? tileColor;
    double elevation = 0;

    switch (overlayWindowBlockType) {
      case MPOverlayWindowBlockType.choices:
        iconColor = colorScheme.onTertiaryFixed;
        textColor = colorScheme.onTertiaryFixed;
        tileColor = colorScheme.tertiaryFixed;
        elevation = mpOverlayWindowBlockElevation;
      case MPOverlayWindowBlockType.choiceSet:
        iconColor = colorScheme.onTertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        tileColor = colorScheme.tertiaryContainer;
      case MPOverlayWindowBlockType.choiceUnset:
        iconColor = colorScheme.onSurfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
        tileColor = colorScheme.surfaceContainer;
        elevation = mpOverlayWindowBlockElevation;
        elevation = mpOverlayWindowBlockElevation;
      case MPOverlayWindowBlockType.main:
        iconColor = colorScheme.onPrimary;
        textColor = colorScheme.onPrimary;
        tileColor = colorScheme.primary;
        elevation = mpOverlayWindowBlockElevation;
      case MPOverlayWindowBlockType.secondary:
        iconColor = colorScheme.onSecondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        tileColor = colorScheme.secondaryContainer;
        elevation = mpOverlayWindowBlockElevation;
      case MPOverlayWindowBlockType.secondarySet:
        iconColor = colorScheme.onSecondaryFixed;
        textColor = colorScheme.onSecondaryFixed;
        tileColor = colorScheme.secondaryFixed;
      case MPOverlayWindowBlockType.secondarySetMixed:
        iconColor = colorScheme.onSecondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        tileColor = colorScheme.secondaryContainer;
      case MPOverlayWindowBlockType.secondarySetUnsupported:
        iconColor = colorScheme.onSecondary;
        textColor = colorScheme.onSecondary;
        tileColor = colorScheme.secondary;
      case MPOverlayWindowBlockType.secondaryUnset:
        iconColor = colorScheme.onSurfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
        tileColor = colorScheme.surfaceContainer;
        elevation = mpOverlayWindowBlockElevation;
    }
    // }

    return Container(
      /// Including the margins below to reserve space to show the shadow
      /// resultant of using elevation > 0.
      margin: const EdgeInsets.only(left: 2, bottom: 7, right: 6),
      child: Material(
        color: tileColor,
        elevation: elevation,
        borderRadius: BorderRadius.circular(
          mpOverlayWindowBlockCornerRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: textColor,
          ),
          child: IconTheme(
            data: IconThemeData(
              color: iconColor,
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
