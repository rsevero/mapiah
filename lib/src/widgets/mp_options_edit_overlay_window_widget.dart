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
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/mp_option_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_pla_type_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

/// A widget representing an overlay window for editing options of selected
/// elements.
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
        final ColorScheme colorScheme = Theme.of(context).colorScheme;

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

        for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
          switch (mpSelectedElement) {
            case MPSelectedArea _:
              if (mpSelectedElement.originalAreaClone.areaType.name !=
                  selectedAreaPLAType) {
                if ((selectedAreaPLAType == null) && (countAreas == 0)) {
                  selectedAreaPLAType =
                      mpSelectedElement.originalAreaClone.areaType.name;
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
              if (mpSelectedElement.originalLineClone.lineType.name !=
                  selectedLinePLAType) {
                if ((selectedLinePLAType == null) && (countLines == 0)) {
                  selectedLinePLAType =
                      mpSelectedElement.originalLineClone.lineType.name;
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
              if (mpSelectedElement.originalPointClone.pointType.name !=
                  selectedPointPLAType) {
                if ((selectedPointPLAType == null) && (countPoints == 0)) {
                  selectedPointPLAType =
                      mpSelectedElement.originalPointClone.pointType.name;
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

        if ((countPoints > 0) || (countLines > 0) || (countAreas > 0)) {
          final List<Widget> plaTypeWidgets = [];

          if (countPoints > 0) {
            String? pointTypeSubtypeAsString;
            String? pointTypeSubtypeID;

            if (selectedPointPLAType != null) {
              pointTypeSubtypeID = MPCommandOptionAux.getPLATypeAndSubtypeID(
                plaType: selectedPointPLAType,
                plaSubtype: selectedPointSubtype ?? '',
              );
              pointTypeSubtypeAsString =
                  MPTextToUser.getPointTypeSubtypeFromTypeSubtypeID(
                    pointTypeSubtypeID,
                  );
            }

            plaTypeWidgets.add(
              MPPLATypeWidget(
                selectedPLAType: pointTypeSubtypeID,
                selectedPLATypeToUser: pointTypeSubtypeAsString,
                elementType: THElementType.point,
                th2FileEditController: th2FileEditController,
              ),
            );
          }

          if (countLines > 0) {
            String? lineTypeSubtypeAsString;
            String? lineTypeSubtypeID;

            if (selectedLinePLAType != null) {
              lineTypeSubtypeID = MPCommandOptionAux.getPLATypeAndSubtypeID(
                plaType: selectedLinePLAType,
                plaSubtype: selectedLineSubtype ?? '',
              );
              lineTypeSubtypeAsString =
                  MPTextToUser.getLineTypeSubtypeFromTypeSubtypeID(
                    lineTypeSubtypeID,
                  );
            }

            plaTypeWidgets.add(
              MPPLATypeWidget(
                selectedPLAType: lineTypeSubtypeID,
                selectedPLATypeToUser: lineTypeSubtypeAsString,
                elementType: THElementType.line,
                th2FileEditController: th2FileEditController,
              ),
            );
          }

          if (countAreas > 0) {
            String? areaTypeSubtypeAsString;
            String? areaTypeSubtypeID;

            if (selectedAreaPLAType != null) {
              areaTypeSubtypeID = MPCommandOptionAux.getPLATypeAndSubtypeID(
                plaType: selectedAreaPLAType,
                plaSubtype: selectedAreaSubtype ?? '',
              );
              areaTypeSubtypeAsString =
                  MPTextToUser.getAreaTypeSubtypeFromTypeSubtypeID(
                    areaTypeSubtypeID,
                  );
            }

            if ((countAreas == 1) && (singleSelectedArea != null)) {
              final THFile thFile = th2FileEditController.thFile;
              final List<THAreaBorderTHID> areaBorders = singleSelectedArea
                  .getAreaBorderTHIDs(thFile);

              // Build rows for each border with delete icon.
              final List<Widget> areaBorderWidgets = areaBorders
                  .map<Widget>(
                    (border) => Padding(
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
                            onPressed: () =>
                                onRemoveAreaBorderTHIDPressed(border.mpID),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList();

              areaBorderWidgets.add(
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    label: Text(appLocalizations.mpAreaBordersAddButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          mpDefaultButtonRadius,
                        ),
                      ),
                    ),
                    onPressed: () => onAddLineToAreaButtonPressed(),
                  ),
                ),
              );

              MPInteractionAux.addWidgetWithTopSpace(
                widgets,
                MPOverlayWindowBlockWidget(
                  title: appLocalizations.mpAreaBordersPanelTitle,
                  overlayWindowBlockType: MPOverlayWindowBlockType.secondary,
                  padding: mpOverlayWindowBlockEdgeInsets,
                  children: areaBorderWidgets,
                ),
              );
            }

            plaTypeWidgets.add(
              MPPLATypeWidget(
                selectedPLAType: areaTypeSubtypeID,
                selectedPLATypeToUser: areaTypeSubtypeAsString,
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
      ancestorGlobalKey: th2FileEditController.getTHFileWidgetGlobalKey(),
    );

    Rect? childBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: childContext,
      ancestorGlobalKey: th2FileEditController.getTHFileWidgetGlobalKey(),
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

  void onRemoveAreaBorderTHIDPressed(int areaBorderTHIDMPID) {
    th2FileEditController.userInteractionController.prepareRemoveAreaBorderTHID(
      areaBorderTHIDMPID,
    );
  }

  void onAddLineToAreaButtonPressed() {
    th2FileEditController.userInteractionController.prepareAddAreaBorderTHID();
  }
}
