import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
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
  late final AppLocalizations appLocalizations;
  late final THFile thFile;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    appLocalizations = mpLocator.appLocalizations;
    thFile = th2FileEditController.thFile;
    th2FileEditController.selectionController.setMultipleElementsClickedChoice(
      mpMultipleElementsClickedNoneChoiceID,
    );
  }

  String getLineName(THLine line) {
    final String lineName = (line.hasOption(THCommandOptionType.id))
        ? "${appLocalizations.thElementLine} ${line.plaType} ${(line.optionByType(THCommandOptionType.id) as THIDCommandOption).thID} (${line.mpID})"
        : "${appLocalizations.thElementLine} ${line.plaType} (${line.mpID})";

    return lineName;
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, String> options = {
      mpMultipleElementsClickedAllChoiceID:
          appLocalizations.mpMultipleElementsClickedAllChoice,
    };
    final clickedElements =
        th2FileEditController.selectionController.clickedElements;

    for (final THElement element in clickedElements) {
      switch (element) {
        case THPoint _:
          final String pointName = (element.hasOption(THCommandOptionType.id))
              ? "${appLocalizations.thElementPoint} ${element.plaType} ${(element.optionByType(THCommandOptionType.id) as THIDCommandOption).thID} (${element.mpID})"
              : "${appLocalizations.thElementPoint} ${element.plaType} (${element.mpID})";
          options[element.mpID] = pointName;
        case THBezierCurveLineSegment _:
        case THStraightLineSegment _:
          final int lineMPID = element.parentMPID;

          if (!options.containsKey(lineMPID)) {
            options[lineMPID] = getLineName(
              thFile.lineByMPID(
                lineMPID,
              ),
            );
          }
        case THLine _:
          final int lineMPID = element.mpID;

          if (!options.containsKey(lineMPID)) {
            options[lineMPID] = getLineName(element);
          }
        case THArea _:
          final String areaName = (element.hasOption(THCommandOptionType.id))
              ? "${appLocalizations.thElementArea} ${element.plaType} ${(element.optionByType(THCommandOptionType.id) as THIDCommandOption).thID} (${element.mpID})"
              : "${appLocalizations.thElementArea} ${element.plaType} (${element.mpID})";
          options[element.mpID] = areaName;
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
        Observer(
          builder: (_) {
            return MPOverlayWindowBlockWidget(
              overlayWindowBlockType: MPOverlayWindowBlockType.main,
              padding: mpOverlayWindowBlockEdgeInsets,
              children: [
                Builder(builder: (blockContext) {
                  return Column(
                    children: options.entries.map(
                      (entry) {
                        final int choiceID = entry.key;
                        final String choiceName = entry.value;

                        return RadioListTile<int>(
                          title: Text(
                            choiceName,
                            style: DefaultTextStyle.of(blockContext).style,
                          ),
                          value: choiceID,
                          groupValue: th2FileEditController.selectionController
                              .multipleElementsClickedChoice,
                          contentPadding: EdgeInsets.zero,
                          activeColor: IconTheme.of(blockContext).color,
                          dense: true,
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          onChanged: (int? value) {
                            if (value != null) {
                              _onTapSelectedElement(value);
                            }
                          },
                        );
                      },
                    ).toList(),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  void _onTapSelectedElement(int choiceID) {
    th2FileEditController.selectionController
        .performMultipleElementsClickedChoosen(
      choiceID,
    );
  }
}
