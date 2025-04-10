import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
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
  }

  String getLineName(THLine line) {
    final String lineName = (line.hasOption(THCommandOptionType.id))
        ? "${appLocalizations.thElementLine} ${line.plaType} ${(line.optionByType(THCommandOptionType.id) as THIDCommandOption).thID}"
        : "${appLocalizations.thElementLine} ${line.plaType}";

    return lineName;
  }

  String getAreaName(THArea area) {
    final String areaName = (area.hasOption(THCommandOptionType.id))
        ? "${appLocalizations.thElementArea} ${area.plaType} ${(area.optionByType(THCommandOptionType.id) as THIDCommandOption).thID}"
        : "${appLocalizations.thElementArea} ${area.plaType}";

    return areaName;
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, String> options = {
      mpMultipleElementsClickedAllChoiceID:
          appLocalizations.mpMultipleElementsClickedAllChoice,
    };
    final clickedElements = selectionController.clickedElements;

    for (final THElement element in clickedElements) {
      switch (element) {
        case THPoint _:
          final String pointName = (element.hasOption(THCommandOptionType.id))
              ? "${appLocalizations.thElementPoint} ${element.plaType} ${(element.optionByType(THCommandOptionType.id) as THIDCommandOption).thID}"
              : "${appLocalizations.thElementPoint} ${element.plaType}";
          options[element.mpID] = pointName;
        case THBezierCurveLineSegment _:
        case THStraightLineSegment _:
          final int lineMPID = element.parentMPID;
          final int? areaMPID = thFile.getAreaMPIDByLineMPID(lineMPID);

          if ((areaMPID != null) && (!options.containsKey(areaMPID))) {
            options[areaMPID] = getAreaName(thFile.areaByMPID(areaMPID));
          }

          if (!options.containsKey(lineMPID)) {
            options[lineMPID] = getLineName(
              thFile.lineByMPID(
                lineMPID,
              ),
            );
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
              thFile.areaByMPID(
                element.mpID,
              ),
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
      innerAnchorType: MPWidgetPositionType.leftCenter,
      th2FileEditController: th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        MPOverlayWindowBlockWidget(
          overlayWindowBlockType: MPOverlayWindowBlockType.main,
          padding: mpOverlayWindowBlockEdgeInsets,
          children: [
            Builder(builder: (blockContext) {
              return Column(
                children: options.entries.map(
                  (entry) {
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
                        title: Text(
                          choiceName,
                          style: DefaultTextStyle.of(blockContext).style,
                        ),
                        value: choiceID,
                        groupValue:
                            selectionController.multipleElementsClickedChoice,
                        contentPadding: EdgeInsets.zero,
                        activeColor: IconTheme.of(blockContext).color,
                        dense: true,
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                        onChanged: (int? value) {
                          if (value != null) {
                            _onTapSelectedElement(value);
                          }
                        },
                      ),
                    );
                  },
                ).toList(),
              );
            }),
          ],
        ),
      ],
    );
  }

  void _onTapSelectedElement(int choiceID) {
    selectionController.performMultipleElementsClickedChoosen(
      choiceID,
    );
  }

  void _onMouseEnter(int choiceID) {
    selectionController.setMultipleElementsClickedHighlightedMPIDs(choiceID);
  }

  void _onMouseExit(int choiceID) {
    selectionController.setMultipleElementsClickedHighlightedMPIDs(null);
  }
}
