// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/mp_modal_overlay_widget.dart';
import 'package:mapiah/src/widgets/mp_search_select_dialog_widget.dart';
import 'package:mapiah/src/widgets/th_file_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_action_buttons_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_bottom_status_bar_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_last_used_pla_buttons_widget.dart';

enum _StateContextFABCategory {
  clipboard,
  editTools,
  lineSegmentConversion,
  other,
  selection,
  simplification,
  splitJoinMerge,
}

class TH2FileEditBodyWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Future<TH2FileEditControllerCreateResult> loadFuture;

  const TH2FileEditBodyWidget({
    required this.th2FileEditController,
    required this.loadFuture,
    super.key,
  });

  @override
  State<TH2FileEditBodyWidget> createState() => _TH2FileEditBodyWidgetState();
}

class _TH2FileEditBodyWidgetState extends State<TH2FileEditBodyWidget> {
  late final TH2FileEditController th2FileEditController;
  late AppLocalizations appLocalizations;
  late ColorScheme colorScheme;

  bool isSelectMode = false;
  bool enableSelectedButton = false;

  @override
  void initState() {
    super.initState();

    th2FileEditController = widget.th2FileEditController;
    appLocalizations = mpLocator.appLocalizations;
  }

  @override
  Widget build(BuildContext context) {
    final String heroPrefix = th2FileEditController.th2FileMPID.toString();

    appLocalizations = mpLocator.appLocalizations;
    colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: FutureBuilder<TH2FileEditControllerCreateResult>(
            future: widget.loadFuture,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<TH2FileEditControllerCreateResult> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text(
                        appLocalizations.th2FileEditPageLoadingFile(
                          th2FileEditController.currentScrapName,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final List<String> errorMessages = snapshot.data!.errors;

                    if (snapshot.data!.isSuccessful) {
                      if (mpDebugMousePosition) {
                        return MouseRegion(
                          onHover: (event) => th2FileEditController
                              .performSetMousePosition(event.localPosition),
                          child: Stack(
                            children: [
                              TH2FileWidget(
                                key: th2FileEditController
                                    .getTH2FileWidgetGlobalKey(),
                                th2FileEditController: th2FileEditController,
                              ),
                              TH2FileEditLastUsedPLAButtonsWidget(
                                th2FileEditController: th2FileEditController,
                              ),
                              _stateActionButtons(heroPrefix),
                              TH2FileEditActionButtonsWidget(
                                heroPrefix: heroPrefix,
                                th2FileEditController: th2FileEditController,
                              ),
                              _stateContextFABs(heroPrefix),
                            ],
                          ),
                        );
                      } else {
                        return Stack(
                          children: [
                            TH2FileWidget(
                              key: th2FileEditController
                                  .getTH2FileWidgetGlobalKey(),
                              th2FileEditController: th2FileEditController,
                            ),
                            TH2FileEditLastUsedPLAButtonsWidget(
                              th2FileEditController: th2FileEditController,
                            ),
                            _stateActionButtons(heroPrefix),
                            TH2FileEditActionButtonsWidget(
                              heroPrefix: heroPrefix,
                              th2FileEditController: th2FileEditController,
                            ),
                            _stateContextFABs(heroPrefix),
                          ],
                        );
                      }
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MPErrorDialog(
                              errorMessages: errorMessages,
                              filename: th2FileEditController.th2File.filename,
                            );
                          },
                        ).then((_) {
                          th2FileEditController.close();
                        });
                      });

                      return Container();
                    }
                  } else {
                    throw Exception(
                      'Unexpected snapshot state: ${snapshot.connectionState}',
                    );
                  }
                },
          ),
        ),
        TH2FileEditBottomStatusBarWidget(
          th2FileEditController: th2FileEditController,
        ),
      ],
    );
  }

  void _onDefaultOptionsButtonPressed() {
    th2FileEditController.optionEditController
        .showDefaultOptionsOverlayWindow();
  }

  void onRemovePressed() {
    th2FileEditController.overlayWindowController.clearOverlayWindows();
    th2FileEditController.stateController.onButtonPressed(MPButtonType.remove);
  }

  void onRedoPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.redo);
  }

  void onUndoPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.undo);
  }

  Widget _stateContextFABs(String heroPrefix) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          th2FileEditController.isInteractiveLineSimplificationDialogOpen,
      builder: (context, isDialogOpen, child) => Observer(
        builder: (_) {
          final List<Widget> buttonRows = [];

          if (th2FileEditController.isInEditSingleLineState) {
            buttonRows.addAll(_editSingleLineContextFABs(heroPrefix));
          } else if (th2FileEditController.isInSelectNonEmptySelectionState ||
              th2FileEditController.isInElementRotateState) {
            buttonRows.addAll(_selectNonEmptySelectionContextFABs(heroPrefix));
          } else if (th2FileEditController.isInSelectEmptySelectionState) {
            buttonRows.addAll(_selectEmptySelectionContextFABs(heroPrefix));
          } else if (th2FileEditController.isInAddElementState) {
            buttonRows.addAll(_addElementContextFABs(heroPrefix));
          } else if (MPTH2FileEditState.isImageOperationType(
            th2FileEditController.stateController.state.type,
          )) {
            buttonRows.addAll(_imageOperationContextFABs(heroPrefix));
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

  Widget _stateContextFABButton({
    required String heroTag,
    required VoidCallback? onPressed,
    required IconData icon,
    required String tooltip,
    required _StateContextFABCategory category,
    bool isActive = false,
    Widget? child,
  }) {
    final bool isEnabled = onPressed != null;
    final Color categoryBackgroundColor = _getStateContextFABCategoryColor(
      category,
    );
    final Color categoryForegroundColor =
        _getStateContextFABCategoryForegroundColor(category);

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
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons,
        ),
        const SizedBox(height: mpButtonSpace),
      ],
    );
  }

  Color _getStateContextFABCategoryColor(_StateContextFABCategory category) {
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

  Color _getStateContextFABCategoryForegroundColor(
    _StateContextFABCategory category,
  ) {
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

  List<Widget> _editSingleLineContextFABs(String heroPrefix) {
    final bool allEndPointsSelected =
        th2FileEditController.areAllEndPointsSelected;
    final bool hasSelectedEndPoints =
        th2FileEditController.hasSelectedEndPoints;
    final bool hasSelectedNonStartEndPoints =
        th2FileEditController.hasSelectedNonStartEndPoints;
    final bool isInteractiveLineSimplificationDialogOpen =
        th2FileEditController.isInteractiveLineSimplificationDialogOpen.value;

    return [
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_select_all_end_points',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.selectAllEndPoints),
            category: _StateContextFABCategory.selection,
            icon: allEndPointsSelected ? Icons.deselect : Icons.select_all,
            tooltip: allEndPointsSelected
                ? appLocalizations.th2FileEditPageDeselectAllEndPoints
                : appLocalizations.th2FileEditPageSelectAllEndPoints,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_simplify_lines',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.simplifyLines),
            category: _StateContextFABCategory.simplification,
            icon: Icons.auto_fix_normal,
            tooltip: appLocalizations.th2FileEditPageSimplifyLines,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_simplify_lines_straight',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.simplifyLinesForcingStraight),
            category: _StateContextFABCategory.simplification,
            icon: Icons.straighten,
            tooltip:
                appLocalizations.th2FileEditPageSimplifyLinesForcingStraight,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_simplify_lines_bezier',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.simplifyLinesForcingBezier),
            category: _StateContextFABCategory.simplification,
            icon: Icons.gesture,
            tooltip: appLocalizations.th2FileEditPageSimplifyLinesForcingBezier,
          ),
          _stateContextFABButton(
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
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_convert_line_segments_straight',
            onPressed: hasSelectedNonStartEndPoints
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.convertLineSegmentsToStraight,
                  )
                : null,
            category: _StateContextFABCategory.lineSegmentConversion,
            icon: Icons.linear_scale,
            tooltip:
                appLocalizations.th2FileEditPageConvertLineSegmentsToStraight,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_convert_line_segments_bezier',
            onPressed: hasSelectedNonStartEndPoints
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.convertLineSegmentsToBezier,
                  )
                : null,
            category: _StateContextFABCategory.lineSegmentConversion,
            icon: Icons.draw,
            tooltip:
                appLocalizations.th2FileEditPageConvertLineSegmentsToBezier,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_open_option_window',
            onPressed: hasSelectedEndPoints
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.openOptionWindow,
                  )
                : null,
            category: _StateContextFABCategory.editTools,
            icon: Icons.tune,
            tooltip: appLocalizations.th2FileEditPageOpenOptionWindow,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_reverse_line',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.reverseLine),
            category: _StateContextFABCategory.editTools,
            icon: Icons.compare_arrows,
            tooltip: appLocalizations.th2FileEditPageReverseLine,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_smooth_line_segments',
            onPressed: hasSelectedEndPoints
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.smoothLineSegments,
                  )
                : null,
            category: _StateContextFABCategory.editTools,
            icon: Icons.blur_on,
            tooltip: appLocalizations.th2FileEditPageSmoothLineSegments,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_split_line',
            onPressed: hasSelectedEndPoints
                ? () => th2FileEditController.stateController.onButtonPressed(
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

  List<Widget> _selectNonEmptySelectionContextFABs(String heroPrefix) {
    final bool allElementsSelected =
        th2FileEditController.areAllElementsSelected;
    final bool hasSelectedLines = th2FileEditController.hasSelectedLines;
    final bool isInteractiveLineSimplificationDialogOpen =
        th2FileEditController.isInteractiveLineSimplificationDialogOpen.value;
    final bool isElementTransformsEnabled = th2FileEditController
        .moveScaleRotateElementController
        .isElementTransformsEnabled;

    return [
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_select_all_elements',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.selectAllElements),
            category: _StateContextFABCategory.selection,
            icon: allElementsSelected ? Icons.deselect : Icons.select_all,
            tooltip: allElementsSelected
                ? appLocalizations.th2FileEditPageDeselectAllElements
                : appLocalizations.th2FileEditPageSelectAllElements,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_simplify_lines',
            onPressed: hasSelectedLines
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.simplifyLines,
                  )
                : null,
            category: _StateContextFABCategory.simplification,
            icon: Icons.auto_fix_normal,
            tooltip: appLocalizations.th2FileEditPageSimplifyLines,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_simplify_lines_straight',
            onPressed: hasSelectedLines
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.simplifyLinesForcingStraight,
                  )
                : null,
            category: _StateContextFABCategory.simplification,
            icon: Icons.straighten,
            tooltip:
                appLocalizations.th2FileEditPageSimplifyLinesForcingStraight,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_simplify_lines_bezier',
            onPressed: hasSelectedLines
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.simplifyLinesForcingBezier,
                  )
                : null,
            category: _StateContextFABCategory.simplification,
            icon: Icons.gesture,
            tooltip: appLocalizations.th2FileEditPageSimplifyLinesForcingBezier,
          ),
          _stateContextFABButton(
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
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_convert_line_segments_straight',
            onPressed: hasSelectedLines
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.convertLineSegmentsToStraight,
                  )
                : null,
            category: _StateContextFABCategory.lineSegmentConversion,
            icon: Icons.linear_scale,
            tooltip:
                appLocalizations.th2FileEditPageConvertLineSegmentsToStraight,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_convert_line_segments_bezier',
            onPressed: hasSelectedLines
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.convertLineSegmentsToBezier,
                  )
                : null,
            category: _StateContextFABCategory.lineSegmentConversion,
            icon: Icons.draw,
            tooltip:
                appLocalizations.th2FileEditPageConvertLineSegmentsToBezier,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_open_option_window',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.openOptionWindow),
            category: _StateContextFABCategory.editTools,
            icon: Icons.tune,
            tooltip: appLocalizations.th2FileEditPageOpenOptionWindow,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_reverse_line',
            onPressed: hasSelectedLines
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.reverseLine,
                  )
                : null,
            category: _StateContextFABCategory.editTools,
            icon: Icons.compare_arrows,
            tooltip: appLocalizations.th2FileEditPageReverseLine,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_smooth_line_segments',
            onPressed: hasSelectedLines
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.smoothLineSegments,
                  )
                : null,
            category: _StateContextFABCategory.editTools,
            icon: Icons.blur_on,
            tooltip: appLocalizations.th2FileEditPageSmoothLineSegments,
          ),
          _stateContextFABButton(
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
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_split_lines_at_crossings',
            onPressed: th2FileEditController.hasAtLeastTwoSelectedLines
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.splitLinesAtCrossings,
                  )
                : null,
            category: _StateContextFABCategory.splitJoinMerge,
            icon: Icons.call_split,
            tooltip: appLocalizations.th2FileEditPageSplitLinesAtCrossings,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_join_lines_at_coinciding_extremities',
            onPressed: th2FileEditController.hasAtLeastTwoSelectedLines
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.joinLinesAtCoincidingExtremities,
                  )
                : null,
            category: _StateContextFABCategory.splitJoinMerge,
            icon: Icons.merge,
            tooltip: appLocalizations
                .th2FileEditPageJoinLinesAtCoincidingExtremities,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_merge_areas',
            onPressed: th2FileEditController.canMergeAreas
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.mergeAreas,
                  )
                : null,
            category: _StateContextFABCategory.splitJoinMerge,
            icon: Icons.join_inner,
            tooltip: appLocalizations.th2FileEditPageMergeAreas,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_copy_elements',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.copyElements),
            category: _StateContextFABCategory.clipboard,
            icon: Icons.content_copy,
            tooltip: appLocalizations.th2FileEditPageCopyElements,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_cut_elements',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.cutElements),
            category: _StateContextFABCategory.clipboard,
            icon: Icons.content_cut,
            tooltip: appLocalizations.th2FileEditPageCutElements,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_paste_elements',
            onPressed: th2FileEditController.hasClipboardContent
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.pasteElements,
                  )
                : null,
            category: _StateContextFABCategory.clipboard,
            icon: Icons.content_paste,
            tooltip: appLocalizations.th2FileEditPagePasteElements,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_duplicate_elements',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.duplicateElements),
            category: _StateContextFABCategory.clipboard,
            icon: Icons.copy_all,
            tooltip: appLocalizations.th2FileEditPageDuplicateElements,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
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

  List<Widget> _addElementContextFABs(String heroPrefix) {
    return [
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_select_all_elements',
            onPressed: th2FileEditController.enableSelectButton
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.selectAllElements,
                  )
                : null,
            category: _StateContextFABCategory.selection,
            icon: Icons.select_all,
            tooltip: appLocalizations.th2FileEditPageSelectAllElements,
          ),
        ],
      ),
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_paste_elements',
            onPressed: th2FileEditController.hasClipboardContent
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.pasteElements,
                  )
                : null,
            category: _StateContextFABCategory.clipboard,
            icon: Icons.content_paste,
            tooltip: appLocalizations.th2FileEditPagePasteElements,
          ),
        ],
      ),
    ];
  }

  List<Widget> _imageOperationContextFABs(String heroPrefix) {
    return [
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_flip_image_horizontally',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.flipImageHorizontally),
            category: _StateContextFABCategory.editTools,
            icon: Icons.flip,
            tooltip: appLocalizations.th2FileEditPageFlipImageHorizontally,
          ),
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_flip_image_vertically',
            onPressed: () => th2FileEditController.stateController
                .onButtonPressed(MPButtonType.flipImageVertically),
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

  List<Widget> _selectEmptySelectionContextFABs(String heroPrefix) {
    final bool allElementsSelected =
        th2FileEditController.areAllElementsSelected;
    final bool hasSelectableElements = th2FileEditController.enableSelectButton;

    return [
      _stateContextFABCategoryRow(
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_select_all_elements',
            onPressed: hasSelectableElements
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.selectAllElements,
                  )
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
        buttons: [
          _stateContextFABButton(
            heroTag: '${heroPrefix}_ctx_paste_elements',
            onPressed: th2FileEditController.hasClipboardContent
                ? () => th2FileEditController.stateController.onButtonPressed(
                    MPButtonType.pasteElements,
                  )
                : null,
            category: _StateContextFABCategory.clipboard,
            icon: Icons.content_paste,
            tooltip: appLocalizations.th2FileEditPagePasteElements,
          ),
        ],
      ),
    ];
  }

  Widget _stateActionButtons(String heroPrefix) {
    return Observer(
      builder: (_) {
        final bool hasUndo = th2FileEditController.hasUndo;
        final bool hasRedo = th2FileEditController.hasRedo;
        final bool enableRemoveButton =
            th2FileEditController.enableRemoveButton;
        final bool showSnapButton = th2FileEditController.showSnapButton;
        final bool isSomeSnapTargetActive =
            th2FileEditController.snapController.isSomeSnapTargetActive;
        final bool isDefaultOptionsShown = th2FileEditController
            .overlayWindowController
            .showDefaultOptionsOverlayWindow;
        final bool hasAnyDefaultOptions =
            th2FileEditController.defaultOptionsController.hasAnyDefaults;

        th2FileEditController.redrawSnapTargetsWindow;

        return Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              FloatingActionButton(
                heroTag: '${heroPrefix}_search_select',
                mini: true,
                tooltip: appLocalizations.th2FileEditPageSearchSelectButton,
                onPressed: () {
                  th2FileEditController.overlayWindowController
                      .clearOverlayWindows();
                  MPModalOverlayWidget.show(
                    context: context,
                    childBuilder: (VoidCallback onPressedClose) =>
                        MPSearchSelectDialogWidget(
                          th2FileEditController: th2FileEditController,
                          onPressedClose: onPressedClose,
                        ),
                  );
                },
                child: const Icon(Icons.search),
              ),
              if (showSnapButton) ...[
                SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  key:
                      th2FileEditController
                          .overlayWindowController
                          .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType
                          .snapTargetsButton]!,
                  heroTag: '${heroPrefix}_snap',
                  mini: true,
                  tooltip: appLocalizations.th2FileEditPageSnapButton,
                  onPressed: () {
                    th2FileEditController.overlayWindowController
                        .clearOverlayWindows(
                          except: {MPWindowType.snapTargets},
                        );
                    th2FileEditController.overlayWindowController
                        .toggleOverlayWindow(MPWindowType.snapTargets);
                    th2FileEditController.triggerSnapTargetsWindowRedraw();
                  },
                  backgroundColor: isSomeSnapTargetActive
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: isSomeSnapTargetActive
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  elevation: isSomeSnapTargetActive ? 6.0 : 3.0,
                  child: Image.asset(
                    'assets/icons/snap-tool.png',
                    width: mpFloatingStateActionZoomIconSize,
                    height: mpFloatingStateActionZoomIconSize,
                    color: isSomeSnapTargetActive
                        ? null
                        : colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
              SizedBox(width: mpButtonSpace),
              FloatingActionButton(
                heroTag: '${heroPrefix}_default_options',
                mini: true,
                tooltip: appLocalizations.mpDefaultOptionsToolbarTooltip,
                onPressed: _onDefaultOptionsButtonPressed,
                backgroundColor: isDefaultOptionsShown
                    ? (hasAnyDefaultOptions
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerLowest)
                    : (hasAnyDefaultOptions
                          ? null
                          : colorScheme.surfaceContainerLowest),
                foregroundColor: isDefaultOptionsShown
                    ? (hasAnyDefaultOptions
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.surfaceContainerHighest)
                    : (hasAnyDefaultOptions
                          ? null
                          : colorScheme.surfaceContainerHighest),
                elevation: isDefaultOptionsShown
                    ? 1.0
                    : (hasAnyDefaultOptions ? 6.0 : 3.0),
                child: const Icon(Icons.auto_fix_high),
              ),
              if (th2FileEditController.showRemoveButton) ...[
                SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  heroTag: '${heroPrefix}_remove',
                  mini: true,
                  tooltip: appLocalizations.th2FileEditPageRemoveButton,
                  backgroundColor: enableRemoveButton
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: enableRemoveButton
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  onPressed: enableRemoveButton ? onRemovePressed : null,
                  elevation: enableRemoveButton ? 6.0 : 3.0,
                  child: const Icon(Icons.delete_outlined),
                ),
              ],
              if (th2FileEditController.showUndoRedoButtons) ...[
                SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  heroTag: '${heroPrefix}_undo',
                  mini: true,
                  tooltip: hasUndo
                      ? th2FileEditController.undoDescription
                      : appLocalizations.th2FileEditPageNoUndoAvailable,
                  backgroundColor: hasUndo
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: hasUndo
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  onPressed: hasUndo ? onUndoPressed : null,
                  elevation: hasUndo ? 6.0 : 3.0,
                  child: const Icon(Icons.undo),
                ),
                SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  heroTag: '${heroPrefix}_redo',
                  mini: true,
                  tooltip: hasRedo
                      ? th2FileEditController.redoDescription
                      : appLocalizations.th2FileEditPageNoRedoAvailable,
                  backgroundColor: hasRedo
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: hasRedo
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  onPressed: hasRedo ? onRedoPressed : null,
                  elevation: hasRedo ? 6.0 : 3.0,
                  child: const Icon(Icons.redo),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
