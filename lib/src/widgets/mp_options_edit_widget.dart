import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_option_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_single_column_list_overlay_window_content_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOptionsEditWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final MPWidgetPositionType positionType;
  final double maxHeight;

  const MPOptionsEditWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
    required this.positionType,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerOptionsList;

        final List<Widget> optionWidgets = [const Text('Options')];
        final TH2FileEditOptionEditController optionEditController =
            th2FileEditController.optionEditController;

        final mpSelectedElements =
            th2FileEditController.selectionController.selectedElements.values;

        if (mpSelectedElements.length == 1) {
          final THElementType selectedElementType =
              mpSelectedElements.first.originalElementClone.elementType;

          switch (selectedElementType) {
            case THElementType.area:
              optionWidgets.add(const ListTile(title: Text('Area Type')));
            case THElementType.line:
              optionWidgets.add(const ListTile(title: Text('Line Type')));
            case THElementType.straightLineSegment:
              optionWidgets.add(
                  const ListTile(title: Text('Straight Line Segment Type')));
            case THElementType.bezierCurveLineSegment:
              optionWidgets.add(const ListTile(
                  title: Text('Bezier Curve Line Segment Type')));
            case THElementType.point:
              optionWidgets.add(const ListTile(title: Text('Point Type')));
            case THElementType.scrap:
              optionWidgets.add(const ListTile(title: Text('Scrap Type')));
            default:
              throw Exception('Unknown element type: $selectedElementType');
          }
        }

        final optionsStateMap = optionEditController.optionStateMap.entries;

        for (final option in optionsStateMap) {
          final THCommandOptionType optionType = option.key;

          optionWidgets.add(
            MPOptionWidget(
              type: optionType,
              state: option.value.value.state,
              th2FileEditController: th2FileEditController,
              isSelected: optionType == optionEditController.currentOptionType,
            ),
          );
        }

        return MPOverlayWindowWidget(
          position: position,
          positionType: positionType,
          overlayWindowType: MPOverlayWindowType.commandOptions,
          th2FileEditController: th2FileEditController,
          child: MPSingleColumnListOverlayWindowContentWidget(
            maxHeight: maxHeight,
            children: optionWidgets,
          ),
        );
      },
    );
  }
}
