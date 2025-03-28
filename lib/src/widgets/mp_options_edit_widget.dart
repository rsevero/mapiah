import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/mp_option_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_pla_type_widget.dart';
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

        String? selectedType;

        final AppLocalizations appLocalizations = mpLocator.appLocalizations;

        final List<Widget> optionWidgets = [
          Text(appLocalizations.mpOptionsEditTitle),
        ];
        final TH2FileEditOptionEditController optionEditController =
            th2FileEditController.optionEditController;

        final mpSelectedElements =
            th2FileEditController.selectionController.selectedElements.values;

        if (mpSelectedElements.length == 1) {
          final THElementType selectedElementType =
              mpSelectedElements.first.originalElementClone.elementType;

          switch (selectedElementType) {
            case THElementType.area:
              for (final selectedElement in mpSelectedElements) {
                if ((selectedElement is MPSelectedArea) &&
                    (selectedElement.originalAreaClone.areaType.name !=
                        selectedType)) {
                  if (selectedType == null) {
                    selectedType =
                        selectedElement.originalAreaClone.areaType.name;
                  } else {
                    selectedType = null;
                    break;
                  }
                }
              }

              optionWidgets.add(
                MPPlaTypeWidget(
                    selectedType: selectedType,
                    type: selectedElementType,
                    th2FileEditController: th2FileEditController),
              );
            case THElementType.line:
              for (final selectedElement in mpSelectedElements) {
                if ((selectedElement is MPSelectedLine) &&
                    (selectedElement.originalLineClone.lineType.name !=
                        selectedType)) {
                  if (selectedType == null) {
                    selectedType =
                        selectedElement.originalLineClone.lineType.name;
                  } else {
                    selectedType = null;
                    break;
                  }
                }
              }

              optionWidgets.add(
                MPPlaTypeWidget(
                    selectedType: selectedType,
                    type: selectedElementType,
                    th2FileEditController: th2FileEditController),
              );
            case THElementType.straightLineSegment:
              optionWidgets.add(ListTile(
                title: Text(appLocalizations.thElementStraightLineSegment),
              ));
            case THElementType.bezierCurveLineSegment:
              optionWidgets.add(ListTile(
                title: Text(appLocalizations.thElementBezierCurveLineSegment),
              ));
            case THElementType.point:
              for (final selectedElement in mpSelectedElements) {
                if ((selectedElement is MPSelectedPoint) &&
                    (selectedElement.originalPointClone.pointType.name !=
                        selectedType)) {
                  if (selectedType == null) {
                    selectedType =
                        selectedElement.originalPointClone.pointType.name;
                  } else {
                    selectedType = null;
                    break;
                  }
                }
              }

              optionWidgets.add(
                MPPlaTypeWidget(
                    selectedType: selectedType,
                    type: selectedElementType,
                    th2FileEditController: th2FileEditController),
              );
            case THElementType.scrap:
              optionWidgets.add(ListTile(
                title: Text(appLocalizations.thElementScrap),
              ));
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
          windowType: MPWindowType.commandOptions,
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
