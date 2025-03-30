import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
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
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOptionsEditWidget extends StatefulWidget {
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
  State<MPOptionsEditWidget> createState() => _MPOptionsEditWidgetState();
}

class _MPOptionsEditWidgetState extends State<MPOptionsEditWidget> {
  late final TH2FileEditController th2FileEditController =
      widget.th2FileEditController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerOptionsList;

        final mpSelectedElements =
            th2FileEditController.selectionController.selectedElements.values;

        final AppLocalizations appLocalizations = mpLocator.appLocalizations;
        final List<Widget> widgets = [];
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

          addWithTopSpace(
            widgets,
            MPOverlayWindowBlockWidget(
              children: plaTypeWidgets,
              overlayWindowBlockType: MPOverlayWindowBlockType.main,
            ),
          );
        }

        final optionsStateMap = optionEditController.optionStateMap.entries;

        MPOptionStateType? previousState;
        List<Widget> blockWidgets = [];
        final List<Widget> optionWidgets = [];

        for (final optionEntry in optionsStateMap) {
          final THCommandOptionType optionType = optionEntry.key;
          final MPOptionInfo optionInfo = optionEntry.value;

          if (optionInfo.state != previousState) {
            if (blockWidgets.isNotEmpty) {
              addWithTopSpace(
                optionWidgets,
                MPOverlayWindowBlockWidget(
                  children: blockWidgets,
                  overlayWindowBlockType:
                      getOverlayWindowBlockTypeFromOptionState(previousState),
                ),
              );
              blockWidgets = [];
            }
            previousState = optionInfo.state;
          }
          blockWidgets.add(
            MPOptionWidget(
              optionInfo: optionInfo,
              th2FileEditController: th2FileEditController,
              isSelected: optionType == optionEditController.currentOptionType,
              onOptionSelected: onOptionSelected,
            ),
          );
        }

        if (blockWidgets.isNotEmpty) {
          addWithTopSpace(
            optionWidgets,
            MPOverlayWindowBlockWidget(
              children: blockWidgets,
              overlayWindowBlockType:
                  getOverlayWindowBlockTypeFromOptionState(previousState),
            ),
          );
        }

        if (optionWidgets.isNotEmpty) {
          addWithTopSpace(
            widgets,
            MPOverlayWindowBlockWidget(
              overlayWindowBlockType: MPOverlayWindowBlockType.main,
              children: [
                Padding(
                  padding: const EdgeInsets.all(mpOverlayWindowBlockPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: optionWidgets,
                  ),
                ),
              ],
            ),
          );
        }

        return MPOverlayWindowWidget(
          title: appLocalizations.mpOptionsEditTitle,
          overlayWindowType: MPOverlayWindowType.primary,
          outerAnchorPosition: widget.outerAnchorPosition,
          innerAnchorType: widget.innerAnchorType,
          th2FileEditController: th2FileEditController,
          children: widgets,
        );
      },
    );
  }

  void addWithTopSpace(List<Widget> widgetsList, Widget newWidget) {
    // if (widgetsList.isNotEmpty) {
    widgetsList.add(const SizedBox(height: mpButtonSpace));
    // }
    widgetsList.add(newWidget);
  }

  MPOverlayWindowBlockType getOverlayWindowBlockTypeFromOptionState(
      MPOptionStateType? state) {
    switch (state) {
      case MPOptionStateType.set:
        return MPOverlayWindowBlockType.secondarySet;
      case MPOptionStateType.setMixed:
        return MPOverlayWindowBlockType.secondarySetMixed;
      case MPOptionStateType.setUnsupported:
        return MPOverlayWindowBlockType.secondarySetUnsupported;
      case MPOptionStateType.unset:
        return MPOverlayWindowBlockType.secondaryUnset;
      default:
        throw Exception(
            'previous state should not be null at MPOptionsEditWidget.getOverlayWindowBlockTypeFromOptionState()');
    }
  }

  void onOptionSelected(BuildContext childContext, THCommandOptionType type) {
    Rect? thisBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: context,
      ancestorGlobalKey: th2FileEditController.thFileWidgetKey,
    );

    Rect? childBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: childContext,
      ancestorGlobalKey: th2FileEditController.thFileWidgetKey,
    );

    /// Use the right of this widget and the vertical center of the child (taped
    /// option) widget as the outer anchor position for the option edit window.
    final Offset anchorPosition =
        (thisBoundingBox == null) || (childBoundingBox == null)
            ? th2FileEditController.screenBoundingBox.center
            : Offset(thisBoundingBox.right, childBoundingBox.center.dy);

    th2FileEditController.optionEditController.performToggleOptionShownStatus(
      optionType: type,
      outerAnchorPosition: anchorPosition,
    );
  }
}
