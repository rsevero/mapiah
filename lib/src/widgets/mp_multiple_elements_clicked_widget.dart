import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPMultipleElementsClickedWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;

  const MPMultipleElementsClickedWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
  });

  @override
  State<MPMultipleElementsClickedWidget> createState() =>
      _MPMultipleElementsClickedWidgetState();
}

class _MPMultipleElementsClickedWidgetState
    extends State<MPMultipleElementsClickedWidget> {
  late final TH2FileEditController th2FileEditController;
  late final TH2FileEditSelectionController selectionController;
  late final AppLocalizations appLocalizations;
  late final THFile thFile;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    selectionController = th2FileEditController.selectionController;
    appLocalizations = mpLocator.appLocalizations;
    thFile = th2FileEditController.thFile;
    selectionController.setMultipleElementsClickedChoice(
      mpMultipleElementsClickedNoneChoiceID,
    );
    selectionController.setMultipleElementsClickedHighlightedMPIDs(null);
  }

  @override
  void dispose() {
    selectionController.setMultipleElementsClickedHighlightedMPIDs(null);
    super.dispose();
  }

  String getLineName(THLine line) {
    final String lineTypeName = (line.lineType == THLineType.unknown)
        ? line.unknownPLAType
        : MPTextToUser.getLineType(line.lineType);
    final String lineName = (line.hasOption(THCommandOptionType.id))
        ? "${appLocalizations.thElementLine} $lineTypeName ${(line.getOption(THCommandOptionType.id) as THIDCommandOption).thID}"
        : "${appLocalizations.thElementLine} $lineTypeName";

    return lineName;
  }

  String getAreaName(THArea area) {
    final String areaTypeName = (area.areaType == THAreaType.unknown)
        ? area.unknownPLAType
        : MPTextToUser.getAreaType(area.areaType);
    final String areaName = (area.hasOption(THCommandOptionType.id))
        ? "${appLocalizations.thElementArea} $areaTypeName ${(area.getOption(THCommandOptionType.id) as THIDCommandOption).thID}"
        : "${appLocalizations.thElementArea} $areaTypeName";

    return areaName;
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, String> options = {};
    final Iterable<THElement> clickedElements =
        selectionController.clickedElements.values;

    if (selectionController.selectionCanBeMultiple) {
      options[mpMultipleElementsClickedAllChoiceID] =
          appLocalizations.mpMultipleElementsClickedAllChoice;
    }

    for (final THElement element in clickedElements) {
      switch (element) {
        case THPoint _:
          final String pointTypeName =
              (element.pointType == THPointType.unknown)
              ? element.unknownPLAType
              : MPTextToUser.getPointType(element.pointType);
          final String pointName = (element.hasOption(THCommandOptionType.id))
              ? "${appLocalizations.thElementPoint} $pointTypeName ${(element.getOption(THCommandOptionType.id) as THIDCommandOption).thID}"
              : "${appLocalizations.thElementPoint} $pointTypeName";
          options[element.mpID] = pointName;
        case THBezierCurveLineSegment _:
        case THStraightLineSegment _:
          final int lineMPID = element.parentMPID;
          final int? areaMPID = thFile.getAreaMPIDByLineMPID(lineMPID);

          if ((areaMPID != null) && (!options.containsKey(areaMPID))) {
            options[areaMPID] = getAreaName(thFile.areaByMPID(areaMPID));
          }

          if (!options.containsKey(lineMPID)) {
            options[lineMPID] = getLineName(thFile.lineByMPID(lineMPID));
          }
        case THLine _:
          final int lineMPID = element.mpID;
          final int? areaMPID = thFile.getAreaMPIDByLineMPID(lineMPID);

          if ((areaMPID != null) && (!options.containsKey(areaMPID))) {
            options[areaMPID] = getAreaName(thFile.areaByMPID(areaMPID));
          }

          if (!options.containsKey(lineMPID)) {
            options[lineMPID] = getLineName(element);
          }
        case THArea _:
          if (!options.containsKey(element.mpID)) {
            options[element.mpID] = getAreaName(
              thFile.areaByMPID(element.mpID),
            );
          }
        default:
          continue;
      }
    }

    return MPOverlayWindowWidget(
      title: appLocalizations.mpMultipleElementsClickedTitle,
      overlayWindowType: MPOverlayWindowType.primary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: MPWidgetPositionType.centerLeft,
      th2FileEditController: th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        MPOverlayWindowBlockWidget(
          overlayWindowBlockType: MPOverlayWindowBlockType.main,
          padding: mpOverlayWindowBlockEdgeInsets,
          children: [
            Builder(
              builder: (blockContext) {
                return RadioGroup(
                  groupValue: selectionController.multipleElementsClickedChoice,
                  onChanged: (int? value) {
                    if (value != null) {
                      _onTapSelectedElement(value);
                    }
                  },
                  child: Column(
                    children: options.entries.map((entry) {
                      final int choiceID = entry.key;
                      final String choiceName = entry.value;

                      return MouseRegion(
                        onEnter: (_) {
                          _onMouseEnter(choiceID);
                        },
                        onExit: (_) {
                          _onMouseExit(choiceID);
                        },
                        child: RadioListTile<int>(
                          key: ValueKey(
                            "MPMultipleElementsClickedWidget|RadioListTile|$choiceID",
                          ),
                          title: Text(
                            choiceName,
                            style: DefaultTextStyle.of(blockContext).style,
                          ),
                          value: choiceID,
                          contentPadding: EdgeInsets.zero,
                          activeColor: IconTheme.of(blockContext).color,
                          dense: true,
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _onTapSelectedElement(int choiceID) {
    selectionController.performMultipleElementsClickedChoosen(choiceID);
  }

  void _onMouseEnter(int choiceID) {
    selectionController.setMultipleElementsClickedHighlightedMPIDs(choiceID);
  }

  void _onMouseExit(int choiceID) {
    selectionController.setMultipleElementsClickedHighlightedMPIDs(null);
  }
}
