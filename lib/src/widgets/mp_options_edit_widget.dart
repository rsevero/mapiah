import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/mp_option_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_pla_type_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOptionsEditWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPOptionsEditWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerOptionsList;

        final mpSelectedElements =
            th2FileEditController.selectionController.selectedElements.values;

        final AppLocalizations appLocalizations = mpLocator.appLocalizations;
        final List<Widget> optionWidgets = [];
        final TH2FileEditOptionEditController optionEditController =
            th2FileEditController.optionEditController;

        bool hasArea = false;
        bool hasLine = false;
        bool hasPoint = false;
        THAreaType? selectedAreaPLAType;
        THLineType? selectedLinePLAType;
        THPointType? selectedPointPLAType;

        for (final mpSelectedElement in mpSelectedElements) {
          switch (mpSelectedElement) {
            case MPSelectedArea _:
              if (mpSelectedElement.originalAreaClone.areaType !=
                  selectedAreaPLAType) {
                if ((selectedAreaPLAType == null) && !hasArea) {
                  selectedAreaPLAType =
                      mpSelectedElement.originalAreaClone.areaType;
                } else {
                  selectedAreaPLAType = null;
                }
              }
              hasArea = true;
            case MPSelectedLine _:
              if (mpSelectedElement.originalLineClone.lineType !=
                  selectedLinePLAType) {
                if ((selectedLinePLAType == null) && !hasLine) {
                  selectedLinePLAType =
                      mpSelectedElement.originalLineClone.lineType;
                } else {
                  selectedLinePLAType = null;
                }
              }
              hasLine = true;
            case MPSelectedPoint _:
              if (mpSelectedElement.originalPointClone.pointType !=
                  selectedPointPLAType) {
                if ((selectedPointPLAType == null) && !hasPoint) {
                  selectedPointPLAType =
                      mpSelectedElement.originalPointClone.pointType;
                } else {
                  selectedPointPLAType = null;
                  break;
                }
              }
              hasPoint = true;
            default:
              throw Exception(
                  'Unsupported element type: $mpSelectedElement in MPOptionsEditWidget');
          }
        }

        if (hasArea || hasLine || hasPoint) {
          final List<Widget> plaTypeWidgets = [];

          if (hasArea) {
            plaTypeWidgets.add(
              MPPLATypeWidget(
                  selectedPLAType: selectedAreaPLAType?.name,
                  selectedPLATypeToUser: selectedAreaPLAType != null
                      ? MPTextToUser.getAreaType(selectedAreaPLAType)
                      : null,
                  type: THElementType.area,
                  th2FileEditController: th2FileEditController),
            );
          }

          if (hasLine) {
            plaTypeWidgets.add(
              MPPLATypeWidget(
                  selectedPLAType: selectedLinePLAType?.name,
                  selectedPLATypeToUser: selectedLinePLAType != null
                      ? MPTextToUser.getLineType(selectedLinePLAType)
                      : null,
                  type: THElementType.line,
                  th2FileEditController: th2FileEditController),
            );
          }
          if (hasPoint) {
            plaTypeWidgets.add(
              MPPLATypeWidget(
                  selectedPLAType: selectedPointPLAType?.name,
                  selectedPLATypeToUser: selectedPointPLAType != null
                      ? MPTextToUser.getPointType(selectedPointPLAType)
                      : null,
                  type: THElementType.point,
                  th2FileEditController: th2FileEditController),
            );

            optionWidgets.add(
              MPOverlayWindowBlockWidget(
                children: plaTypeWidgets,
              ),
            );
          }

          final optionsStateMap = optionEditController.optionStateMap.entries;

          for (final option in optionsStateMap) {
            final THCommandOptionType optionType = option.key;

            optionWidgets.add(
              MPOptionWidget(
                optionType: optionType,
                optionState: option.value.value.state,
                th2FileEditController: th2FileEditController,
                isSelected:
                    optionType == optionEditController.currentOptionType,
              ),
            );
          }
        }

        return MPOverlayWindowWidget(
          title: appLocalizations.mpOptionsEditTitle,
          overlayWindowType: MPOverlayWindowType.primary,
          outerAnchorPosition: outerAnchorPosition,
          innerAnchorType: innerAnchorType,
          th2FileEditController: th2FileEditController,
          children: optionWidgets,
        );
      },
    );
  }
}
