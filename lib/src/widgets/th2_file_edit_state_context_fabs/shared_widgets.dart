// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';

enum TH2FileEditStateContextFABCategory {
  clipboard,
  editTools,
  lineSegmentConversion,
  other,
  selection,
  simplification,
  splitJoinMerge,
}

class TH2FileEditStateContextFABButton extends StatelessWidget {
  final TH2FileEditStateContextFABCategory category;
  final Widget? child;
  final String heroTag;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onPressed;
  final String tooltip;

  const TH2FileEditStateContextFABButton({
    required this.category,
    required this.context,
    required this.heroTag,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.child,
    this.isActive = false,
    super.key,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext buildContext) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isEnabled = onPressed != null;
    final Color categoryBackgroundColor =
        TH2FileEditStateContextFABColors.background(
          colorScheme: colorScheme,
          category: category,
        );
    final Color categoryForegroundColor =
        TH2FileEditStateContextFABColors.foreground(
          colorScheme: colorScheme,
          category: category,
        );

    return Padding(
      padding: const EdgeInsets.only(left: mpButtonSpace),
      child: FloatingActionButton(
        heroTag: heroTag,
        mini: true,
        tooltip: tooltip,
        onPressed: onPressed,
        backgroundColor: isActive
            ? colorScheme.primary
            : (isEnabled
                  ? categoryBackgroundColor
                  : colorScheme.surfaceContainerLowest),
        foregroundColor: isActive
            ? colorScheme.onPrimary
            : (isEnabled
                  ? categoryForegroundColor
                  : colorScheme.surfaceContainerHighest),
        elevation: isActive ? 0 : (isEnabled ? 6.0 : 3.0),
        child: child ?? Icon(icon, size: mpFloatingStateActionZoomIconSize),
      ),
    );
  }
}

class TH2FileEditStateContextFABCategoryRow extends StatelessWidget {
  final List<Widget> buttons;

  const TH2FileEditStateContextFABCategoryRow({
    required this.buttons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons,
        ),
        const SizedBox(height: mpButtonSpace),
      ],
    );
  }
}

class TH2FileEditSimplificationFABRow extends StatelessWidget {
  final String heroPrefix;
  final bool isEnabled;
  final bool isInteractiveButtonActive;
  final void Function(MPButtonType buttonType) onButtonPressed;
  final VoidCallback? onPressedInteractiveSimplification;

  const TH2FileEditSimplificationFABRow({
    required this.heroPrefix,
    required this.isEnabled,
    required this.isInteractiveButtonActive,
    required this.onButtonPressed,
    required this.onPressedInteractiveSimplification,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return TH2FileEditStateContextFABCategoryRow(
      buttons: <Widget>[
        TH2FileEditStateContextFABButton(
          context: context,
          heroTag: '${heroPrefix}_ctx_simplify_lines',
          onPressed: isEnabled
              ? () => onButtonPressed(MPButtonType.simplifyLines)
              : null,
          category: TH2FileEditStateContextFABCategory.simplification,
          icon: Icons.auto_fix_normal,
          tooltip: appLocalizations.th2FileEditPageSimplifyLines,
        ),
        TH2FileEditStateContextFABButton(
          context: context,
          heroTag: '${heroPrefix}_ctx_simplify_lines_straight',
          onPressed: isEnabled
              ? () => onButtonPressed(MPButtonType.simplifyLinesForcingStraight)
              : null,
          category: TH2FileEditStateContextFABCategory.simplification,
          icon: Icons.straighten,
          tooltip: appLocalizations.th2FileEditPageSimplifyLinesForcingStraight,
        ),
        TH2FileEditStateContextFABButton(
          context: context,
          heroTag: '${heroPrefix}_ctx_simplify_lines_bezier',
          onPressed: isEnabled
              ? () => onButtonPressed(MPButtonType.simplifyLinesForcingBezier)
              : null,
          category: TH2FileEditStateContextFABCategory.simplification,
          icon: Icons.gesture,
          tooltip: appLocalizations.th2FileEditPageSimplifyLinesForcingBezier,
        ),
        TH2FileEditStateContextFABButton(
          context: context,
          heroTag: '${heroPrefix}_ctx_simplify_lines_interactive',
          onPressed: onPressedInteractiveSimplification,
          category: TH2FileEditStateContextFABCategory.simplification,
          icon: Icons.tune,
          tooltip: appLocalizations.th2FileEditPageInteractiveSimplifyLines,
          isActive: isInteractiveButtonActive,
        ),
      ],
    );
  }
}

class TH2FileEditLineSegmentConversionFABRow extends StatelessWidget {
  final String heroPrefix;
  final bool isEnabled;
  final void Function(MPButtonType buttonType) onButtonPressed;

  const TH2FileEditLineSegmentConversionFABRow({
    required this.heroPrefix,
    required this.isEnabled,
    required this.onButtonPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return TH2FileEditStateContextFABCategoryRow(
      buttons: <Widget>[
        TH2FileEditStateContextFABButton(
          context: context,
          heroTag: '${heroPrefix}_ctx_convert_line_segments_straight',
          onPressed: isEnabled
              ? () =>
                    onButtonPressed(MPButtonType.convertLineSegmentsToStraight)
              : null,
          category: TH2FileEditStateContextFABCategory.lineSegmentConversion,
          icon: Icons.linear_scale,
          tooltip:
              appLocalizations.th2FileEditPageConvertLineSegmentsToStraight,
        ),
        TH2FileEditStateContextFABButton(
          context: context,
          heroTag: '${heroPrefix}_ctx_convert_line_segments_bezier',
          onPressed: isEnabled
              ? () => onButtonPressed(MPButtonType.convertLineSegmentsToBezier)
              : null,
          category: TH2FileEditStateContextFABCategory.lineSegmentConversion,
          icon: Icons.draw,
          tooltip: appLocalizations.th2FileEditPageConvertLineSegmentsToBezier,
        ),
      ],
    );
  }
}

class TH2FileEditVerticalFlipFABIcon extends StatelessWidget {
  const TH2FileEditVerticalFlipFABIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: Icon(Icons.flip, size: mpFloatingStateActionZoomIconSize),
    );
  }
}

class TH2FileEditStateContextFABColors {
  static Color background({
    required ColorScheme colorScheme,
    required TH2FileEditStateContextFABCategory category,
  }) {
    switch (category) {
      case TH2FileEditStateContextFABCategory.selection:
        return colorScheme.tertiaryContainer;
      case TH2FileEditStateContextFABCategory.simplification:
        return colorScheme.primaryContainer;
      case TH2FileEditStateContextFABCategory.lineSegmentConversion:
        return colorScheme.tertiaryFixedDim;
      case TH2FileEditStateContextFABCategory.editTools:
        return colorScheme.secondaryContainer;
      case TH2FileEditStateContextFABCategory.splitJoinMerge:
        return colorScheme.surfaceContainerHigh;
      case TH2FileEditStateContextFABCategory.other:
        return colorScheme.surfaceContainerHighest;
      case TH2FileEditStateContextFABCategory.clipboard:
        return colorScheme.tertiaryFixed;
    }
  }

  static Color foreground({
    required ColorScheme colorScheme,
    required TH2FileEditStateContextFABCategory category,
  }) {
    switch (category) {
      case TH2FileEditStateContextFABCategory.selection:
        return colorScheme.onTertiaryContainer;
      case TH2FileEditStateContextFABCategory.simplification:
        return colorScheme.onPrimaryContainer;
      case TH2FileEditStateContextFABCategory.lineSegmentConversion:
        return colorScheme.onTertiaryContainer;
      case TH2FileEditStateContextFABCategory.editTools:
        return colorScheme.onSecondaryContainer;
      case TH2FileEditStateContextFABCategory.splitJoinMerge:
        return colorScheme.onSurface;
      case TH2FileEditStateContextFABCategory.other:
        return colorScheme.onSurfaceVariant;
      case TH2FileEditStateContextFABCategory.clipboard:
        return colorScheme.onTertiaryFixed;
    }
  }
}
