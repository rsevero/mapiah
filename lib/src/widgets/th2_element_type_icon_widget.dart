// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_painter_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/th2_element_type_icon_painter.dart';
import 'package:material_ui/material_ui.dart';

/// The type preview of a point, line or area row of the element tree: its
/// type and subtype drawn as on the canvas, at a fixed scale.
///
/// It rebuilds when the file's structure revision (which type and subtype
/// edits, undo and redo bump) or the visualization method changes; theme
/// colors and the device pixel ratio come from the build context.
class TH2ElementTypeIconWidget extends StatelessWidget {
  final TH2FileEditController controller;
  final int elementMPID;

  const TH2ElementTypeIconWidget({
    super.key,
    required this.controller,
    required this.elementMPID,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return Observer(
      builder: (_) {
        controller.structureRevision;
        mpLocator.mpSettingsController.getTrigger(
          MPSettingID.TH2Edit_VisualizationMethod,
        );

        final TH2ElementTypePreviewKey? previewKey = previewKeyFor(
          element: controller.th2File.tryElementByMPID(elementMPID),
          theme: theme,
          devicePixelRatio: devicePixelRatio,
        );

        if (previewKey == null) {
          return const SizedBox.square(dimension: mpTH2ElementTypeIconSize);
        }

        return CustomPaint(
          size: const Size.square(mpTH2ElementTypeIconSize),
          painter: TH2ElementTypeIconPainter(
            previewKey: previewKey,
            visualController: controller.visualController,
            cache: mpLocator.th2ElementTypePreviewCache,
          ),
        );
      },
    );
  }

  /// The preview key of [element], or `null` when it is not a point, line
  /// or area.
  static TH2ElementTypePreviewKey? previewKeyFor({
    required THElement? element,
    required ThemeData theme,
    required double devicePixelRatio,
  }) {
    final Enum? type = switch (element) {
      THPoint point => point.pointType,
      THLine line => line.lineType,
      THArea area => area.areaType,
      _ => null,
    };

    if ((element == null) || (type == null)) {
      return null;
    }

    final String subtype = (element is THArea)
        ? mpNoSubtypeID
        : (MPCommandOptionAux.getSubtype(element) ?? mpNoSubtypeID);

    return TH2ElementTypePreviewKey(
      kind: element.elementType,
      type: type,
      subtype: subtype,
      visualizationMethod:
          mpLocator.mpSettingsController.tH2EditVisualizationMethod,
      devicePixelRatio: devicePixelRatio,
      outlineColor: theme.colorScheme.outline,
      interiorColor: MPPainterAux.canvasInteriorColor(theme.brightness),
    );
  }
}
