// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/widgets/mp_option_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';

/// Shared logic for option list display used by both
/// [MPOptionsEditOverlayWindowWidget] and [MPDefaultOptionsOverlayWindowWidget].
mixin MPOptionsListBuilderMixin<T extends StatefulWidget> on State<T> {
  TH2FileEditController get th2FileEditController;

  /// Builds a [MPOverlayWindowBlockWidget] containing one [MPOptionWidget]
  /// per entry in [optionStateMap], or null when the map is empty.
  Widget? buildOptionsListBlock(
    Map<THCommandOptionType, MPOptionInfo> optionStateMap,
  ) {
    final TH2FileEditOptionEditController optionEditController =
        th2FileEditController.optionEditController;
    final List<Widget> blockWidgets = [];

    for (final MapEntry<THCommandOptionType, MPOptionInfo> entry
        in optionStateMap.entries) {
      blockWidgets.add(
        MPOptionWidget(
          optionInfo: entry.value,
          th2FileEditController: th2FileEditController,
          isSelected: entry.key == optionEditController.currentOptionType,
          onOptionSelected: onOptionSelected,
        ),
      );
    }

    if (blockWidgets.isEmpty) {
      return null;
    }

    return MPOverlayWindowBlockWidget(
      children: blockWidgets,
      overlayWindowBlockType: MPOverlayWindowBlockType.secondary,
    );
  }

  /// Positions the option-choices sub-overlay at the right edge of this widget
  /// and the vertical centre of the tapped option widget, then calls
  /// [TH2FileEditOptionEditController.performToggleOptionShownStatus].
  void onOptionSelected(BuildContext childContext, THCommandOptionType type) {
    final Rect? thisBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: context,
      ancestorGlobalKey: th2FileEditController.getTH2FileWidgetGlobalKey(),
    );
    final Rect? childBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: childContext,
      ancestorGlobalKey: th2FileEditController.getTH2FileWidgetGlobalKey(),
    );
    final Offset outerAnchorPosition =
        (thisBoundingBox == null) || (childBoundingBox == null)
        ? th2FileEditController.screenBoundingBox.center
        : Offset(thisBoundingBox.right, childBoundingBox.center.dy);

    th2FileEditController.optionEditController.performToggleOptionShownStatus(
      optionType: type,
      outerAnchorPosition: outerAnchorPosition,
    );
  }

  void addOptionsListBlockToWidgets(
    List<Widget> widgets,
    Map<THCommandOptionType, MPOptionInfo> optionStateMap,
  ) {
    final Widget? block = buildOptionsListBlock(optionStateMap);

    if (block != null) {
      MPInteractionAux.addWidgetWithTopSpace(widgets, block);
    }
  }
}
