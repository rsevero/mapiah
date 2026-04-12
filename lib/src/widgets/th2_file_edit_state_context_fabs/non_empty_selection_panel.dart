// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs/shared_widgets.dart';

class TH2FileEditNonEmptySelectionContextFABsPanel extends StatelessWidget {
  final String heroPrefix;
  final TH2FileEditController th2FileEditController;

  const TH2FileEditNonEmptySelectionContextFABsPanel({
    required this.heroPrefix,
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final bool allElementsSelected =
        th2FileEditController.areAllElementsSelected;
    final bool hasSelectedLines = th2FileEditController.hasSelectedLines;
    final bool isInteractiveLineSimplificationDialogOpen =
        th2FileEditController.isInteractiveLineSimplificationDialogOpen.value;
    final bool isElementTransformsEnabled = th2FileEditController
        .moveScaleRotateElementController
        .isElementTransformsEnabled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_select_all_elements',
              onPressed: () => _onButtonPressed(MPButtonType.selectAllElements),
              category: TH2FileEditStateContextFABCategory.selection,
              icon: allElementsSelected ? Icons.deselect : Icons.select_all,
              tooltip: allElementsSelected
                  ? appLocalizations.th2FileEditPageDeselectAllElements
                  : appLocalizations.th2FileEditPageSelectAllElements,
            ),
          ],
        ),
        TH2FileEditSimplificationFABRow(
          heroPrefix: heroPrefix,
          isEnabled: hasSelectedLines,
          isInteractiveButtonActive: isInteractiveLineSimplificationDialogOpen,
          onButtonPressed: _onButtonPressed,
          onPressedInteractiveSimplification: hasSelectedLines
              ? () {
                  th2FileEditController
                      .openInteractiveLineSimplificationDialog();
                }
              : null,
        ),
        TH2FileEditLineSegmentConversionFABRow(
          heroPrefix: heroPrefix,
          isEnabled: hasSelectedLines,
          onButtonPressed: _onButtonPressed,
        ),
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_open_option_window',
              onPressed: () => _onButtonPressed(MPButtonType.openOptionWindow),
              category: TH2FileEditStateContextFABCategory.editTools,
              icon: Icons.tune,
              tooltip: appLocalizations.th2FileEditPageOpenOptionWindow,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_reverse_line',
              onPressed: hasSelectedLines
                  ? () => _onButtonPressed(MPButtonType.reverseLine)
                  : null,
              category: TH2FileEditStateContextFABCategory.editTools,
              icon: Icons.compare_arrows,
              tooltip: appLocalizations.th2FileEditPageReverseLine,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_smooth_line_segments',
              onPressed: hasSelectedLines
                  ? () => _onButtonPressed(MPButtonType.smoothLineSegments)
                  : null,
              category: TH2FileEditStateContextFABCategory.editTools,
              icon: Icons.blur_on,
              tooltip: appLocalizations.th2FileEditPageSmoothLineSegments,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_flip_elements_horizontally',
              onPressed: isElementTransformsEnabled
                  ? () => th2FileEditController.moveScaleRotateElementController
                        .flipSelectedElementsHorizontally()
                  : null,
              category: TH2FileEditStateContextFABCategory.editTools,
              icon: Icons.flip,
              tooltip: appLocalizations.th2FileEditPageFlipElementsHorizontally,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_flip_elements_vertically',
              onPressed: isElementTransformsEnabled
                  ? () => th2FileEditController.moveScaleRotateElementController
                        .flipSelectedElementsVertically()
                  : null,
              category: TH2FileEditStateContextFABCategory.editTools,
              icon: Icons.flip_camera_android,
              child: const TH2FileEditVerticalFlipFABIcon(),
              tooltip: appLocalizations.th2FileEditPageFlipElementsVertically,
            ),
          ],
        ),
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_split_lines_at_crossings',
              onPressed: th2FileEditController.hasAtLeastTwoSelectedLines
                  ? () => _onButtonPressed(MPButtonType.splitLinesAtCrossings)
                  : null,
              category: TH2FileEditStateContextFABCategory.splitJoinMerge,
              icon: Icons.call_split,
              tooltip: appLocalizations.th2FileEditPageSplitLinesAtCrossings,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_join_lines_at_coinciding_extremities',
              onPressed: th2FileEditController.hasAtLeastTwoSelectedLines
                  ? () => _onButtonPressed(
                      MPButtonType.joinLinesAtCoincidingExtremities,
                    )
                  : null,
              category: TH2FileEditStateContextFABCategory.splitJoinMerge,
              icon: Icons.merge,
              tooltip: appLocalizations
                  .th2FileEditPageJoinLinesAtCoincidingExtremities,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_merge_areas',
              onPressed: th2FileEditController.canMergeAreas
                  ? () => _onButtonPressed(MPButtonType.mergeAreas)
                  : null,
              category: TH2FileEditStateContextFABCategory.splitJoinMerge,
              icon: Icons.join_inner,
              tooltip: appLocalizations.th2FileEditPageMergeAreas,
            ),
          ],
        ),
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_copy_elements',
              onPressed: () => _onButtonPressed(MPButtonType.copyElements),
              category: TH2FileEditStateContextFABCategory.clipboard,
              icon: Icons.content_copy,
              tooltip: appLocalizations.th2FileEditPageCopyElements,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_cut_elements',
              onPressed: () => _onButtonPressed(MPButtonType.cutElements),
              category: TH2FileEditStateContextFABCategory.clipboard,
              icon: Icons.content_cut,
              tooltip: appLocalizations.th2FileEditPageCutElements,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_paste_elements',
              onPressed: th2FileEditController.hasClipboardContent
                  ? () => _onButtonPressed(MPButtonType.pasteElements)
                  : null,
              category: TH2FileEditStateContextFABCategory.clipboard,
              icon: Icons.content_paste,
              tooltip: appLocalizations.th2FileEditPagePasteElements,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_duplicate_elements',
              onPressed: () => _onButtonPressed(MPButtonType.duplicateElements),
              category: TH2FileEditStateContextFABCategory.clipboard,
              icon: Icons.copy_all,
              tooltip: appLocalizations.th2FileEditPageDuplicateElements,
            ),
          ],
        ),
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_create_map_connection_lines',
              onPressed: null,
              category: TH2FileEditStateContextFABCategory.other,
              icon: Icons.add_link,
              tooltip: appLocalizations.th2FileEditPageCreateMapConnectionLines,
            ),
          ],
        ),
      ],
    );
  }

  void _onButtonPressed(MPButtonType buttonType) {
    th2FileEditController.stateController.onButtonPressed(buttonType);
  }
}
