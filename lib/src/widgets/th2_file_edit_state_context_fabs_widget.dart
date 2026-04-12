// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';

enum _StateContextFABCategory {
  clipboard,
  editTools,
  lineSegmentConversion,
  other,
  selection,
  simplification,
  splitJoinMerge,
}

class TH2FileEditStateContextFABsWidget extends StatelessWidget {
  final String heroPrefix;
  final TH2FileEditController th2FileEditController;

  const TH2FileEditStateContextFABsWidget({
    required this.heroPrefix,
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          th2FileEditController.isInteractiveLineSimplificationDialogOpen,
      builder: (context, isDialogOpen, child) => Observer(
        builder: (_) {
          final List<Widget> buttonRows = [];

          if (th2FileEditController.isInEditSingleLineState) {
            buttonRows.addAll(_editSingleLineContextFABs(context));
          } else if (th2FileEditController.isInSelectNonEmptySelectionState ||
              th2FileEditController.isInElementRotateState) {
            buttonRows.addAll(_selectNonEmptySelectionContextFABs(context));
          } else if (th2FileEditController.isInSelectEmptySelectionState) {
            buttonRows.addAll(_selectEmptySelectionContextFABs(context));
          } else if (th2FileEditController.isInAddElementState) {
            buttonRows.addAll(_addElementContextFABs(context));
          } else if (MPTH2FileEditState.isImageOperationType(
            th2FileEditController.stateController.state.type,
          )) {
            buttonRows.addAll(_imageOperationContextFABs(context));
          }

          if (buttonRows.isEmpty) {
            return const SizedBox.shrink();
          }

          return Positioned(
            top: 16,
            left: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buttonRows,
            ),
          );
        },
      ),
    );
  }

  List<Widget> _addElementContextFABs(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return <Widget>[
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_select_all_elements',
            onPressed: th2FileEditController.enableSelectButton
                ? () => _onButtonPressed(MPButtonType.selectAllElements)
                : null,
            category: _StateContextFABCategory.selection,
            icon: Icons.select_all,
            tooltip: appLocalizations.th2FileEditPageSelectAllElements,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_paste_elements',
            onPressed: th2FileEditController.hasClipboardContent
                ? () => _onButtonPressed(MPButtonType.pasteElements)
                : null,
            category: _StateContextFABCategory.clipboard,
            icon: Icons.content_paste,
            tooltip: appLocalizations.th2FileEditPagePasteElements,
          ),
        ],
      ),
    ];
  }

  List<Widget> _editSingleLineContextFABs(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final bool allEndPointsSelected =
        th2FileEditController.areAllEndPointsSelected;
    final bool hasSelectedEndPoints =
        th2FileEditController.hasSelectedEndPoints;
    final bool hasSelectedNonStartEndPoints =
        th2FileEditController.hasSelectedNonStartEndPoints;
    final bool isInteractiveLineSimplificationDialogOpen =
        th2FileEditController.isInteractiveLineSimplificationDialogOpen.value;

    return <Widget>[
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_select_all_end_points',
            onPressed: () => _onButtonPressed(MPButtonType.selectAllEndPoints),
            category: _StateContextFABCategory.selection,
            icon: allEndPointsSelected ? Icons.deselect : Icons.select_all,
            tooltip: allEndPointsSelected
                ? appLocalizations.th2FileEditPageDeselectAllEndPoints
                : appLocalizations.th2FileEditPageSelectAllEndPoints,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_simplify_lines',
            onPressed: () => _onButtonPressed(MPButtonType.simplifyLines),
            category: _StateContextFABCategory.simplification,
            icon: Icons.auto_fix_normal,
            tooltip: appLocalizations.th2FileEditPageSimplifyLines,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_simplify_lines_straight',
            onPressed: () =>
                _onButtonPressed(MPButtonType.simplifyLinesForcingStraight),
            category: _StateContextFABCategory.simplification,
            icon: Icons.straighten,
            tooltip:
                appLocalizations.th2FileEditPageSimplifyLinesForcingStraight,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_simplify_lines_bezier',
            onPressed: () =>
                _onButtonPressed(MPButtonType.simplifyLinesForcingBezier),
            category: _StateContextFABCategory.simplification,
            icon: Icons.gesture,
            tooltip: appLocalizations.th2FileEditPageSimplifyLinesForcingBezier,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_simplify_lines_interactive',
            onPressed: () {
              th2FileEditController.openInteractiveLineSimplificationDialog();
            },
            category: _StateContextFABCategory.simplification,
            icon: Icons.tune,
            tooltip: appLocalizations.th2FileEditPageInteractiveSimplifyLines,
            isActive: isInteractiveLineSimplificationDialogOpen,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_convert_line_segments_straight',
            onPressed: hasSelectedNonStartEndPoints
                ? () => _onButtonPressed(
                    MPButtonType.convertLineSegmentsToStraight,
                  )
                : null,
            category: _StateContextFABCategory.lineSegmentConversion,
            icon: Icons.linear_scale,
            tooltip:
                appLocalizations.th2FileEditPageConvertLineSegmentsToStraight,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_convert_line_segments_bezier',
            onPressed: hasSelectedNonStartEndPoints
                ? () =>
                      _onButtonPressed(MPButtonType.convertLineSegmentsToBezier)
                : null,
            category: _StateContextFABCategory.lineSegmentConversion,
            icon: Icons.draw,
            tooltip:
                appLocalizations.th2FileEditPageConvertLineSegmentsToBezier,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_open_option_window',
            onPressed: hasSelectedEndPoints
                ? () => _onButtonPressed(MPButtonType.openOptionWindow)
                : null,
            category: _StateContextFABCategory.editTools,
            icon: Icons.tune,
            tooltip: appLocalizations.th2FileEditPageOpenOptionWindow,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_reverse_line',
            onPressed: () => _onButtonPressed(MPButtonType.reverseLine),
            category: _StateContextFABCategory.editTools,
            icon: Icons.compare_arrows,
            tooltip: appLocalizations.th2FileEditPageReverseLine,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_smooth_line_segments',
            onPressed: hasSelectedEndPoints
                ? () => _onButtonPressed(MPButtonType.smoothLineSegments)
                : null,
            category: _StateContextFABCategory.editTools,
            icon: Icons.blur_on,
            tooltip: appLocalizations.th2FileEditPageSmoothLineSegments,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_split_line',
            onPressed: hasSelectedEndPoints
                ? () => _onButtonPressed(
                    MPButtonType.splitLineAtSelectedEndPoints,
                  )
                : null,
            category: _StateContextFABCategory.splitJoinMerge,
            icon: Icons.call_split,
            tooltip:
                appLocalizations.th2FileEditPageSplitLineAtSelectedEndPoints,
          ),
        ],
      ),
    ];
  }

  List<Widget> _imageOperationContextFABs(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return <Widget>[
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_flip_image_horizontally',
            onPressed: () =>
                _onButtonPressed(MPButtonType.flipImageHorizontally),
            category: _StateContextFABCategory.editTools,
            icon: Icons.flip,
            tooltip: appLocalizations.th2FileEditPageFlipImageHorizontally,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_flip_image_vertically',
            onPressed: () => _onButtonPressed(MPButtonType.flipImageVertically),
            category: _StateContextFABCategory.editTools,
            icon: Icons.flip_camera_android,
            child: RotatedBox(
              quarterTurns: 1,
              child: Icon(Icons.flip, size: mpFloatingStateActionZoomIconSize),
            ),
            tooltip: appLocalizations.th2FileEditPageFlipImageVertically,
          ),
        ],
      ),
    ];
  }

  List<Widget> _selectEmptySelectionContextFABs(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final bool allElementsSelected =
        th2FileEditController.areAllElementsSelected;
    final bool hasSelectableElements = th2FileEditController.enableSelectButton;

    return <Widget>[
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_select_all_elements',
            onPressed: hasSelectableElements
                ? () => _onButtonPressed(MPButtonType.selectAllElements)
                : null,
            category: _StateContextFABCategory.selection,
            icon: allElementsSelected ? Icons.deselect : Icons.select_all,
            tooltip: allElementsSelected
                ? appLocalizations.th2FileEditPageDeselectAllElements
                : appLocalizations.th2FileEditPageSelectAllElements,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_paste_elements',
            onPressed: th2FileEditController.hasClipboardContent
                ? () => _onButtonPressed(MPButtonType.pasteElements)
                : null,
            category: _StateContextFABCategory.clipboard,
            icon: Icons.content_paste,
            tooltip: appLocalizations.th2FileEditPagePasteElements,
          ),
        ],
      ),
    ];
  }

  List<Widget> _selectNonEmptySelectionContextFABs(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final bool allElementsSelected =
        th2FileEditController.areAllElementsSelected;
    final bool hasSelectedLines = th2FileEditController.hasSelectedLines;
    final bool isInteractiveLineSimplificationDialogOpen =
        th2FileEditController.isInteractiveLineSimplificationDialogOpen.value;
    final bool isElementTransformsEnabled = th2FileEditController
        .moveScaleRotateElementController
        .isElementTransformsEnabled;

    return <Widget>[
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_select_all_elements',
            onPressed: () => _onButtonPressed(MPButtonType.selectAllElements),
            category: _StateContextFABCategory.selection,
            icon: allElementsSelected ? Icons.deselect : Icons.select_all,
            tooltip: allElementsSelected
                ? appLocalizations.th2FileEditPageDeselectAllElements
                : appLocalizations.th2FileEditPageSelectAllElements,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_simplify_lines',
            onPressed: hasSelectedLines
                ? () => _onButtonPressed(MPButtonType.simplifyLines)
                : null,
            category: _StateContextFABCategory.simplification,
            icon: Icons.auto_fix_normal,
            tooltip: appLocalizations.th2FileEditPageSimplifyLines,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_simplify_lines_straight',
            onPressed: hasSelectedLines
                ? () => _onButtonPressed(
                    MPButtonType.simplifyLinesForcingStraight,
                  )
                : null,
            category: _StateContextFABCategory.simplification,
            icon: Icons.straighten,
            tooltip:
                appLocalizations.th2FileEditPageSimplifyLinesForcingStraight,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_simplify_lines_bezier',
            onPressed: hasSelectedLines
                ? () =>
                      _onButtonPressed(MPButtonType.simplifyLinesForcingBezier)
                : null,
            category: _StateContextFABCategory.simplification,
            icon: Icons.gesture,
            tooltip: appLocalizations.th2FileEditPageSimplifyLinesForcingBezier,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_simplify_lines_interactive',
            onPressed: hasSelectedLines
                ? () {
                    th2FileEditController
                        .openInteractiveLineSimplificationDialog();
                  }
                : null,
            category: _StateContextFABCategory.simplification,
            icon: Icons.tune,
            tooltip: appLocalizations.th2FileEditPageInteractiveSimplifyLines,
            isActive: isInteractiveLineSimplificationDialogOpen,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_convert_line_segments_straight',
            onPressed: hasSelectedLines
                ? () => _onButtonPressed(
                    MPButtonType.convertLineSegmentsToStraight,
                  )
                : null,
            category: _StateContextFABCategory.lineSegmentConversion,
            icon: Icons.linear_scale,
            tooltip:
                appLocalizations.th2FileEditPageConvertLineSegmentsToStraight,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_convert_line_segments_bezier',
            onPressed: hasSelectedLines
                ? () =>
                      _onButtonPressed(MPButtonType.convertLineSegmentsToBezier)
                : null,
            category: _StateContextFABCategory.lineSegmentConversion,
            icon: Icons.draw,
            tooltip:
                appLocalizations.th2FileEditPageConvertLineSegmentsToBezier,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_open_option_window',
            onPressed: () => _onButtonPressed(MPButtonType.openOptionWindow),
            category: _StateContextFABCategory.editTools,
            icon: Icons.tune,
            tooltip: appLocalizations.th2FileEditPageOpenOptionWindow,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_reverse_line',
            onPressed: hasSelectedLines
                ? () => _onButtonPressed(MPButtonType.reverseLine)
                : null,
            category: _StateContextFABCategory.editTools,
            icon: Icons.compare_arrows,
            tooltip: appLocalizations.th2FileEditPageReverseLine,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_smooth_line_segments',
            onPressed: hasSelectedLines
                ? () => _onButtonPressed(MPButtonType.smoothLineSegments)
                : null,
            category: _StateContextFABCategory.editTools,
            icon: Icons.blur_on,
            tooltip: appLocalizations.th2FileEditPageSmoothLineSegments,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_flip_elements_horizontally',
            onPressed: isElementTransformsEnabled
                ? () => th2FileEditController.moveScaleRotateElementController
                      .flipSelectedElementsHorizontally()
                : null,
            category: _StateContextFABCategory.editTools,
            icon: Icons.flip,
            tooltip: appLocalizations.th2FileEditPageFlipElementsHorizontally,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_flip_elements_vertically',
            onPressed: isElementTransformsEnabled
                ? () => th2FileEditController.moveScaleRotateElementController
                      .flipSelectedElementsVertically()
                : null,
            category: _StateContextFABCategory.editTools,
            icon: Icons.flip_camera_android,
            child: RotatedBox(
              quarterTurns: 1,
              child: Icon(Icons.flip, size: mpFloatingStateActionZoomIconSize),
            ),
            tooltip: appLocalizations.th2FileEditPageFlipElementsVertically,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_split_lines_at_crossings',
            onPressed: th2FileEditController.hasAtLeastTwoSelectedLines
                ? () => _onButtonPressed(MPButtonType.splitLinesAtCrossings)
                : null,
            category: _StateContextFABCategory.splitJoinMerge,
            icon: Icons.call_split,
            tooltip: appLocalizations.th2FileEditPageSplitLinesAtCrossings,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_join_lines_at_coinciding_extremities',
            onPressed: th2FileEditController.hasAtLeastTwoSelectedLines
                ? () => _onButtonPressed(
                    MPButtonType.joinLinesAtCoincidingExtremities,
                  )
                : null,
            category: _StateContextFABCategory.splitJoinMerge,
            icon: Icons.merge,
            tooltip: appLocalizations
                .th2FileEditPageJoinLinesAtCoincidingExtremities,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_merge_areas',
            onPressed: th2FileEditController.canMergeAreas
                ? () => _onButtonPressed(MPButtonType.mergeAreas)
                : null,
            category: _StateContextFABCategory.splitJoinMerge,
            icon: Icons.join_inner,
            tooltip: appLocalizations.th2FileEditPageMergeAreas,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_copy_elements',
            onPressed: () => _onButtonPressed(MPButtonType.copyElements),
            category: _StateContextFABCategory.clipboard,
            icon: Icons.content_copy,
            tooltip: appLocalizations.th2FileEditPageCopyElements,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_cut_elements',
            onPressed: () => _onButtonPressed(MPButtonType.cutElements),
            category: _StateContextFABCategory.clipboard,
            icon: Icons.content_cut,
            tooltip: appLocalizations.th2FileEditPageCutElements,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_paste_elements',
            onPressed: th2FileEditController.hasClipboardContent
                ? () => _onButtonPressed(MPButtonType.pasteElements)
                : null,
            category: _StateContextFABCategory.clipboard,
            icon: Icons.content_paste,
            tooltip: appLocalizations.th2FileEditPagePasteElements,
          ),
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_duplicate_elements',
            onPressed: () => _onButtonPressed(MPButtonType.duplicateElements),
            category: _StateContextFABCategory.clipboard,
            icon: Icons.copy_all,
            tooltip: appLocalizations.th2FileEditPageDuplicateElements,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: <Widget>[
          _stateContextFABButton(
            context: context,
            heroTag: '${heroPrefix}_ctx_create_map_connection_lines',
            onPressed: null,
            category: _StateContextFABCategory.other,
            icon: Icons.add_link,
            tooltip: appLocalizations.th2FileEditPageCreateMapConnectionLines,
          ),
        ],
      ),
    ];
  }

  Widget _stateContextFABButton({
    required BuildContext context,
    required String heroTag,
    required VoidCallback? onPressed,
    required IconData icon,
    required String tooltip,
    required _StateContextFABCategory category,
    bool isActive = false,
    Widget? child,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isEnabled = onPressed != null;
    final Color categoryBackgroundColor = _getStateContextFABCategoryColor(
      colorScheme: colorScheme,
      category: category,
    );
    final Color categoryForegroundColor =
        _getStateContextFABCategoryForegroundColor(
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

  Widget _stateContextFABCategoryRow({required List<Widget> buttons}) {
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

  Color _getStateContextFABCategoryColor({
    required ColorScheme colorScheme,
    required _StateContextFABCategory category,
  }) {
    switch (category) {
      case _StateContextFABCategory.selection:
        return colorScheme.tertiaryContainer;
      case _StateContextFABCategory.simplification:
        return colorScheme.primaryContainer;
      case _StateContextFABCategory.lineSegmentConversion:
        return colorScheme.tertiaryFixedDim;
      case _StateContextFABCategory.editTools:
        return colorScheme.secondaryContainer;
      case _StateContextFABCategory.splitJoinMerge:
        return colorScheme.surfaceContainerHigh;
      case _StateContextFABCategory.other:
        return colorScheme.surfaceContainerHighest;
      case _StateContextFABCategory.clipboard:
        return colorScheme.tertiaryFixed;
    }
  }

  Color _getStateContextFABCategoryForegroundColor({
    required ColorScheme colorScheme,
    required _StateContextFABCategory category,
  }) {
    switch (category) {
      case _StateContextFABCategory.selection:
        return colorScheme.onTertiaryContainer;
      case _StateContextFABCategory.simplification:
        return colorScheme.onPrimaryContainer;
      case _StateContextFABCategory.lineSegmentConversion:
        return colorScheme.onTertiaryContainer;
      case _StateContextFABCategory.editTools:
        return colorScheme.onSecondaryContainer;
      case _StateContextFABCategory.splitJoinMerge:
        return colorScheme.onSurface;
      case _StateContextFABCategory.other:
        return colorScheme.onSurfaceVariant;
      case _StateContextFABCategory.clipboard:
        return colorScheme.onTertiaryFixed;
    }
  }

  void _onButtonPressed(MPButtonType buttonType) {
    th2FileEditController.stateController.onButtonPressed(buttonType);
  }
}
