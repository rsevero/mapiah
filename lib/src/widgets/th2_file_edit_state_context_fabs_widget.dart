// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs/add_element_panel.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs/empty_selection_panel.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs/image_operation_panel.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs/non_empty_selection_panel.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs/single_line_panel.dart';

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
          final Widget? panel = _panelWidget();

          if (panel == null) {
            return const SizedBox.shrink();
          }

          return Positioned(top: 16, left: 16, child: panel);
        },
      ),
    );
  }

  Widget? _panelWidget() {
    if (th2FileEditController.isInEditSingleLineState) {
      return TH2FileEditSingleLineContextFABsPanel(
        heroPrefix: heroPrefix,
        th2FileEditController: th2FileEditController,
      );
    }

    if (th2FileEditController.isInSelectNonEmptySelectionState ||
        th2FileEditController.isInElementRotateState) {
      return TH2FileEditNonEmptySelectionContextFABsPanel(
        heroPrefix: heroPrefix,
        th2FileEditController: th2FileEditController,
      );
    }

    if (th2FileEditController.isInSelectEmptySelectionState) {
      return TH2FileEditEmptySelectionContextFABsPanel(
        heroPrefix: heroPrefix,
        th2FileEditController: th2FileEditController,
      );
    }

    if (th2FileEditController.isInAddElementState) {
      return TH2FileEditAddElementContextFABsPanel(
        heroPrefix: heroPrefix,
        th2FileEditController: th2FileEditController,
      );
    }

    if (MPTH2FileEditState.isImageOperationType(
      th2FileEditController.stateController.state.type,
    )) {
      return TH2FileEditImageOperationContextFABsPanel(
        heroPrefix: heroPrefix,
        th2FileEditController: th2FileEditController,
      );
    }

    return null;
  }
}
