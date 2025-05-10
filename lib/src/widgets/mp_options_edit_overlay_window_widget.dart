import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
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
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOptionsEditOverlayWindowWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPOptionsEditOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPOptionsEditOverlayWindowWidget> createState() =>
      _MPOptionsEditOverlayWindowWidgetState();
}

class _MPOptionsEditOverlayWindowWidgetState
    extends State<MPOptionsEditOverlayWindowWidget> {
  late final TH2FileEditController th2FileEditController =
      widget.th2FileEditController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerOptionsList;

        final mpSelectedElements = th2FileEditController
            .selectionController.mpSelectedElementsLogical.values;

        final AppLocalizations appLocalizations = mpLocator.appLocalizations;
        final List<Widget> widgets = [];
        final TH2FileEditOptionEditController optionEditController =
            th2FileEditController.optionEditController;

        optionEditController.optionsEditForLineSegments = false;

        bool hasArea = false;
        bool hasLine = false;
        bool hasPoint = false;
        THAreaType? selectedAreaPLAType;
        THLineType? selectedLinePLAType;
        THPointType? selectedPointPLAType;
        String? selectedAreaSubtype;
        String? selectedLineSubtype;
        String? selectedPointSubtype;
        bool firstArea = true;
        bool firstLine = true;
        bool firstPoint = true;

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

              final String? areaSubtype = MPCommandOptionAux.getSubtype(
                mpSelectedElement.originalAreaClone,
              );

              if (firstArea) {
                firstArea = false;
                selectedAreaSubtype = areaSubtype;
              } else if (selectedAreaSubtype != areaSubtype) {
                selectedAreaSubtype = null;
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

              final String? lineSubtype = MPCommandOptionAux.getSubtype(
                mpSelectedElement.originalLineClone,
              );

              if (firstLine) {
                firstLine = false;
                selectedLineSubtype = lineSubtype;
              } else if (selectedLineSubtype != lineSubtype) {
                selectedLineSubtype = null;
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

              final String? pointSubtype = MPCommandOptionAux.getSubtype(
                mpSelectedElement.originalPointClone,
              );

              if (firstPoint) {
                firstPoint = false;
                selectedPointSubtype = pointSubtype;
              } else if (selectedPointSubtype != pointSubtype) {
                selectedPointSubtype = null;
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
            String? pointType;

            if (selectedPointPLAType == null) {
              pointType = null;
            } else {
              pointType = MPTextToUser.getPointType(selectedPointPLAType);

              if (selectedPointSubtype != null) {
                pointType =
                    '$pointType:${MPTextToUser.getSubtypeAsString(selectedPointSubtype)}';
              }
            }

            plaTypeWidgets.add(
              MPPLATypeWidget(
                  selectedPLAType: selectedPointPLAType?.name,
                  selectedPLATypeToUser: pointType,
                  type: THElementType.point,
                  th2FileEditController: th2FileEditController),
            );
          }

          if (hasLine) {
            String? lineType;

            if (selectedLinePLAType == null) {
              lineType = null;
            } else {
              lineType = MPTextToUser.getLineType(selectedLinePLAType);

              if (selectedLineSubtype != null) {
                lineType =
                    '$lineType:${MPTextToUser.getSubtypeAsString(selectedLineSubtype)}';
              }
            }

            plaTypeWidgets.add(
              MPPLATypeWidget(
                  selectedPLAType: selectedLinePLAType?.name,
                  selectedPLATypeToUser: lineType,
                  type: THElementType.line,
                  th2FileEditController: th2FileEditController),
            );
          }

          if (hasArea) {
            String? areaType;

            if (selectedAreaPLAType == null) {
              areaType = null;
            } else {
              areaType = MPTextToUser.getAreaType(selectedAreaPLAType);

              if (selectedAreaSubtype != null) {
                areaType =
                    '$areaType:${MPTextToUser.getSubtypeAsString(selectedAreaSubtype)}';
              }
            }

            plaTypeWidgets.add(
              MPPLATypeWidget(
                  selectedPLAType: selectedAreaPLAType?.name,
                  selectedPLATypeToUser: areaType,
                  type: THElementType.area,
                  th2FileEditController: th2FileEditController),
            );
          }

          MPInteractionAux.addWidgetWithTopSpace(
            widgets,
            MPOverlayWindowBlockWidget(
              children: plaTypeWidgets,
              overlayWindowBlockType: MPOverlayWindowBlockType.main,
            ),
          );
        }

        final optionsStateMap = optionEditController.optionStateMap.entries;

        List<Widget> blockWidgets = [];

        for (final optionEntry in optionsStateMap) {
          final THCommandOptionType optionType = optionEntry.key;
          final MPOptionInfo optionInfo = optionEntry.value;

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
          MPInteractionAux.addWidgetWithTopSpace(
            widgets,
            MPOverlayWindowBlockWidget(
              children: blockWidgets,
              overlayWindowBlockType: MPOverlayWindowBlockType.secondary,
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
    final Offset outerAnchorPosition =
        (thisBoundingBox == null) || (childBoundingBox == null)
            ? th2FileEditController.screenBoundingBox.center
            : Offset(thisBoundingBox.right, childBoundingBox.center.dy);

    th2FileEditController.optionEditController.performToggleOptionShownStatus(
      optionType: type,
      outerAnchorPosition: outerAnchorPosition,
    );
  }
}
