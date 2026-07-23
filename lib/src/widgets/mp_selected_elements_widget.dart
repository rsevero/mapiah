// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPSelectedElementsWidget extends StatelessWidget
    with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final TH2File th2File;
  final MPVisualController visualController;

  MPSelectedElementsWidget({
    required super.key,
    required this.th2FileEditController,
  }) : th2File = th2FileEditController.th2File,
       visualController = th2FileEditController.visualController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerAllElements;
        th2FileEditController.redrawTriggerSelectedElements;
        th2FileEditController.redrawTriggerSelectedElementsListChanged;

        final List<CustomPainter> painters = [];
        final Iterable<MPSelectedElement> mpSelectedElements =
            th2FileEditController
                .selectionController
                .mpSelectedElementsLogical
                .values;

        for (final mpSelectedElement in mpSelectedElements) {
          final THElement element = th2File.elementByMPID(
            mpSelectedElement.mpID,
          );

          switch (element) {
            case THPoint _:
              final THPointPaint pointPaint = visualController
                  .getSelectedPointPaint(element);

              painters.add(
                THPointPainter(
                  position: element.position.coordinates,
                  pointPaint: pointPaint,
                  th2FileEditController: th2FileEditController,
                ),
              );
            case THLine _:
              painters.addAll(
                getLinePainters(
                  line: element,
                  isLineSelected: true,
                  showLineDirectionTicks: true,
                  th2FileEditController: th2FileEditController,
                  isFromActiveScrap: true,
                ),
              );
            case THArea _:
              final List<int> areaLineMPIDs = element.getLineMPIDs(th2File);

              for (final int areaLineMPID in areaLineMPIDs) {
                final THLine line = th2File.lineByMPID(areaLineMPID);

                painters.addAll(
                  getLinePainters(
                    line: line,
                    isLineSelected: true,
                    showLineDirectionTicks: false,
                    th2FileEditController: th2FileEditController,
                    isFromActiveScrap: true,
                  ),
                );
              }
          }
        }

        return RepaintBoundary(
          child: CustomPaint(
            painter: THElementsPainter(
              painters: painters,
              th2FileEditController: th2FileEditController,
            ),
            size: th2FileEditController.screenSize,
          ),
        );
      },
    );
  }
}
