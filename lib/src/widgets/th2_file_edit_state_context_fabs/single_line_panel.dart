// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs/shared_widgets.dart';

class TH2FileEditSingleLineContextFABsPanel extends StatelessWidget {
  final String heroPrefix;
  final TH2FileEditController th2FileEditController;

  const TH2FileEditSingleLineContextFABsPanel({
    required this.heroPrefix,
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final bool allEndPointsSelected =
        th2FileEditController.areAllEndPointsSelected;
    final bool hasSelectedEndPoints =
        th2FileEditController.hasSelectedEndPoints;
    final bool hasSelectedNonStartEndPoints =
        th2FileEditController.hasSelectedNonStartEndPoints;
    final bool isInteractiveLineSimplificationDialogOpen =
        th2FileEditController.isInteractiveLineSimplificationDialogOpen.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_select_all_end_points',
              onPressed: () =>
                  _onButtonPressed(MPButtonType.selectAllEndPoints),
              category: TH2FileEditStateContextFABCategory.selection,
              icon: allEndPointsSelected ? Icons.deselect : Icons.select_all,
              tooltip: allEndPointsSelected
                  ? appLocalizations.th2FileEditPageDeselectAllEndPoints
                  : appLocalizations.th2FileEditPageSelectAllEndPoints,
            ),
          ],
        ),
        TH2FileEditSimplificationFABRow(
          heroPrefix: heroPrefix,
          isEnabled: true,
          isInteractiveButtonActive: isInteractiveLineSimplificationDialogOpen,
          onButtonPressed: _onButtonPressed,
          onPressedInteractiveSimplification: () {
            th2FileEditController.openInteractiveLineSimplificationDialog();
          },
        ),
        TH2FileEditLineSegmentConversionFABRow(
          heroPrefix: heroPrefix,
          isEnabled: hasSelectedNonStartEndPoints,
          onButtonPressed: _onButtonPressed,
        ),
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_open_option_window',
              onPressed: hasSelectedEndPoints
                  ? () => _onButtonPressed(MPButtonType.openOptionWindow)
                  : null,
              category: TH2FileEditStateContextFABCategory.editTools,
              icon: Icons.tune,
              tooltip: appLocalizations.th2FileEditPageOpenOptionWindow,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_reverse_line',
              onPressed: () => _onButtonPressed(MPButtonType.reverseLine),
              category: TH2FileEditStateContextFABCategory.editTools,
              icon: Icons.compare_arrows,
              tooltip: appLocalizations.th2FileEditPageReverseLine,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_smooth_line_segments',
              onPressed: hasSelectedEndPoints
                  ? () => _onButtonPressed(MPButtonType.smoothLineSegments)
                  : null,
              category: TH2FileEditStateContextFABCategory.editTools,
              icon: Icons.blur_on,
              tooltip: appLocalizations.th2FileEditPageSmoothLineSegments,
            ),
          ],
        ),
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_split_line',
              onPressed: hasSelectedEndPoints
                  ? () => _onButtonPressed(
                      MPButtonType.splitLineAtSelectedEndPoints,
                    )
                  : null,
              category: TH2FileEditStateContextFABCategory.splitJoinMerge,
              icon: Icons.call_split,
              tooltip:
                  appLocalizations.th2FileEditPageSplitLineAtSelectedEndPoints,
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
