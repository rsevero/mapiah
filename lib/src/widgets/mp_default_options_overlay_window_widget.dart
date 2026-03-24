// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mixins/mp_options_list_builder_mixin.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPDefaultOptionsOverlayWindowWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPDefaultOptionsOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPDefaultOptionsOverlayWindowWidget> createState() =>
      _MPDefaultOptionsOverlayWindowWidgetState();
}

class _MPDefaultOptionsOverlayWindowWidgetState
    extends State<MPDefaultOptionsOverlayWindowWidget>
    with MPOptionsListBuilderMixin<MPDefaultOptionsOverlayWindowWidget> {
  @override
  TH2FileEditController get th2FileEditController =>
      widget.th2FileEditController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerOptionsList;

        final AppLocalizations appLocalizations = mpLocator.appLocalizations;
        final TH2FileEditOptionEditController optionEditController =
            th2FileEditController.optionEditController;
        final THElementType currentElementType =
            optionEditController.defaultOptionsElementType;
        final bool hasDefaultsForCurrentType = th2FileEditController
            .defaultOptionsController
            .hasDefaultsForType(currentElementType);
        final List<Widget> widgets = [];

        // Controls row: Reset button + element-type selector
        MPInteractionAux.addWidgetWithTopSpace(
          widgets,
          MPOverlayWindowBlockWidget(
            overlayWindowBlockType: MPOverlayWindowBlockType.main,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: hasDefaultsForCurrentType ? _onReset : null,
                    child: Text(appLocalizations.mpDefaultOptionsReset),
                  ),
                  const SizedBox(width: mpButtonSpace),
                  SegmentedButton<THElementType>(
                    segments: [
                      ButtonSegment<THElementType>(
                        value: THElementType.point,
                        label: Text(appLocalizations.mpDefaultOptionsPointsTab),
                      ),
                      ButtonSegment<THElementType>(
                        value: THElementType.line,
                        label: Text(appLocalizations.mpDefaultOptionsLinesTab),
                      ),
                      ButtonSegment<THElementType>(
                        value: THElementType.area,
                        label: Text(appLocalizations.mpDefaultOptionsAreasTab),
                      ),
                    ],
                    selected: {currentElementType},
                    onSelectionChanged: (Set<THElementType> selection) {
                      optionEditController.setDefaultOptionsElementType(
                        selection.first,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );

        // Option list
        addOptionsListBlockToWidgets(
          widgets,
          optionEditController.optionStateMap,
        );

        return MPOverlayWindowWidget(
          title: appLocalizations.mpDefaultOptionsTitle,
          overlayWindowType: MPOverlayWindowType.primary,
          outerAnchorPosition: widget.outerAnchorPosition,
          innerAnchorType: widget.innerAnchorType,
          th2FileEditController: th2FileEditController,
          children: widgets,
        );
      },
    );
  }

  void _onReset() {
    final TH2FileEditOptionEditController optionEditController =
        th2FileEditController.optionEditController;

    th2FileEditController.defaultOptionsController.clearForElementType(
      optionEditController.defaultOptionsElementType,
    );
    optionEditController.updateDefaultOptionsStateMap();
  }
}
