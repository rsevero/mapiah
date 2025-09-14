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
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
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

        final Iterable<MPSelectedElement> mpSelectedElements =
            th2FileEditController
                .selectionController
                .mpSelectedElementsLogical
                .values;
        final AppLocalizations appLocalizations = mpLocator.appLocalizations;
        final List<Widget> widgets = [];
        final TH2FileEditOptionEditController optionEditController =
            th2FileEditController.optionEditController;

        String? selectedAreaPLAType;
        String? selectedLinePLAType;
        String? selectedPointPLAType;
        String? selectedAreaSubtype;
        String? selectedLineSubtype;
        String? selectedPointSubtype;
        int countPoints = 0;
        int countLines = 0;
        int countAreas = 0;
        THArea? singleSelectedArea;

        for (final mpSelectedElement in mpSelectedElements) {
          switch (mpSelectedElement) {
            case MPSelectedArea _:
              if (mpSelectedElement.originalAreaClone.plaType !=
                  selectedAreaPLAType) {
                if ((selectedAreaPLAType == null) && (countAreas == 0)) {
                  selectedAreaPLAType =
                      mpSelectedElement.originalAreaClone.plaType;
                } else {
                  selectedAreaPLAType = null;
                }
              }

              final String? areaSubtype = MPCommandOptionAux.getSubtype(
                mpSelectedElement.originalAreaClone,
              );

              if (countAreas == 0) {
                selectedAreaSubtype = areaSubtype;
                singleSelectedArea = mpSelectedElement.originalAreaClone;
              } else if (selectedAreaSubtype != areaSubtype) {
                selectedAreaSubtype = null;
                singleSelectedArea = null;
              }

              countAreas++;
            case MPSelectedLine _:
              if (mpSelectedElement.originalLineClone.plaType !=
                  selectedLinePLAType) {
                if ((selectedLinePLAType == null) && (countLines == 0)) {
                  selectedLinePLAType =
                      mpSelectedElement.originalLineClone.plaType;
                } else {
                  selectedLinePLAType = null;
                }
              }

              final String? lineSubtype = MPCommandOptionAux.getSubtype(
                mpSelectedElement.originalLineClone,
              );

              if (countLines == 0) {
                selectedLineSubtype = lineSubtype;
              } else if (selectedLineSubtype != lineSubtype) {
                selectedLineSubtype = null;
              }

              countLines++;
            case MPSelectedPoint _:
              if (mpSelectedElement.originalPointClone.plaType !=
                  selectedPointPLAType) {
                if ((selectedPointPLAType == null) && (countPoints == 0)) {
                  selectedPointPLAType =
                      mpSelectedElement.originalPointClone.plaType;
                } else {
                  selectedPointPLAType = null;
                  break;
                }
              }

              final String? pointSubtype = MPCommandOptionAux.getSubtype(
                mpSelectedElement.originalPointClone,
              );

              if (countPoints == 0) {
                selectedPointSubtype = pointSubtype;
              } else if (selectedPointSubtype != pointSubtype) {
                selectedPointSubtype = null;
              }

              countPoints++;
            default:
              throw Exception(
                'Unsupported element type: $mpSelectedElement in MPOptionsEditWidget',
              );
          }
        }

        if ((countAreas > 0) || (countLines > 0) || (countPoints > 0)) {
          final List<Widget> plaTypeWidgets = [];

          if (countPoints > 0) {
            String? pointTypeAsString;

            if (selectedPointPLAType == null) {
              pointTypeAsString = null;
            } else {
              if (THPointType.hasPointType(selectedPointPLAType)) {
                final THPointType pointType = THPointType.values.byName(
                  selectedPointPLAType,
                );

                pointTypeAsString = MPTextToUser.getPointType(pointType);
              } else {
                pointTypeAsString = selectedPointPLAType;
              }

              if (selectedPointSubtype != null) {
                pointTypeAsString =
                    '$pointTypeAsString:${MPTextToUser.getSubtypeAsString(selectedPointSubtype)}';
              }
            }

            plaTypeWidgets.add(
              MPPLATypeWidget(
                selectedPLAType: selectedPointPLAType,
                selectedPLATypeToUser: pointTypeAsString,
                elementType: THElementType.point,
                th2FileEditController: th2FileEditController,
              ),
            );
          }

          if (countLines > 0) {
            String? lineTypeAsString;

            if (selectedLinePLAType == null) {
              lineTypeAsString = null;
            } else {
              if (THLineType.hasLineType(selectedLinePLAType)) {
                final THLineType lineType = THLineType.values.byName(
                  selectedLinePLAType,
                );

                lineTypeAsString = MPTextToUser.getLineType(lineType);
              } else {
                lineTypeAsString = selectedLinePLAType;
              }

              if (selectedLineSubtype != null) {
                lineTypeAsString =
                    '$lineTypeAsString:${MPTextToUser.getSubtypeAsString(selectedLineSubtype)}';
              }
            }

            plaTypeWidgets.add(
              MPPLATypeWidget(
                selectedPLAType: selectedLinePLAType,
                selectedPLATypeToUser: lineTypeAsString,
                elementType: THElementType.line,
                th2FileEditController: th2FileEditController,
              ),
            );
          }

          if (countAreas > 0) {
            String? areaTypeAsString;

            if (selectedAreaPLAType == null) {
              areaTypeAsString = null;
            } else {
              if (THAreaType.hasAreaType(selectedAreaPLAType)) {
                final THAreaType areaType = THAreaType.values.byName(
                  selectedAreaPLAType,
                );

                areaTypeAsString = MPTextToUser.getAreaType(areaType);
              } else {
                areaTypeAsString = selectedAreaPLAType;
              }

              if (selectedAreaSubtype != null) {
                areaTypeAsString =
                    '$areaTypeAsString:${MPTextToUser.getSubtypeAsString(selectedAreaSubtype)}';
              }
            }

            if ((countAreas == 1) && (singleSelectedArea != null)) {
              final THFile thFile = th2FileEditController.thFile;
              final List<THAreaBorderTHID> areaBorders = [];

              for (final childMPID in singleSelectedArea.childrenMPIDs) {
                final THElement element = thFile.elementByMPID(childMPID);
                if (element is THAreaBorderTHID) {
                  areaBorders.add(element);
                }
              }

              // Build rows for each border with delete icon.
              final List<Widget> areaBorderWidgets = areaBorders.map((border) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          border.thID,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: mpLocator
                            .appLocalizations
                            .mpCommandDescriptionRemoveAreaBorderTHID,
                        onPressed: () {
                          th2FileEditController.execute(
                            MPRemoveAreaBorderTHIDCommand(
                              areaBorderTHIDMPID: border.mpID,
                              th2FileEditController: th2FileEditController,
                            ),
                          );
                          th2FileEditController.triggerAllElementsRedraw();
                        },
                      ),
                    ],
                  ),
                );
              }).toList();

              areaBorderWidgets.add(
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      // TODO(mapiah): Implement adding an existing line as a border to this area.
                      // Proposed workflow:
                      // 1. Close this options window (optional).
                      // 2. Enter a transient state where user clicks a line.
                      // 3. If line lacks an id, generate one (like in AddArea state).
                      // 4. Create THAreaBorderTHID(parentMPID: area.mpID, thID: lineTHID) and execute MPAddAreaBorderTHIDCommand.
                      // 5. Return to previous selection state and reopen this window.
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add area border'),
                  ),
                ),
              );

              MPInteractionAux.addWidgetWithTopSpace(
                widgets,
                MPOverlayWindowBlockWidget(
                  title: 'Area borders',
                  overlayWindowBlockType: MPOverlayWindowBlockType.secondary,
                  padding: mpOverlayWindowBlockEdgeInsets,
                  children: areaBorderWidgets,
                ),
              );
            }

            plaTypeWidgets.add(
              MPPLATypeWidget(
                selectedPLAType: selectedAreaPLAType,
                selectedPLATypeToUser: areaTypeAsString,
                elementType: THElementType.area,
                th2FileEditController: th2FileEditController,
              ),
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

        final Iterable<MapEntry<THCommandOptionType, MPOptionInfo>>
        optionsStateMap = optionEditController.optionStateMap.entries;

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
