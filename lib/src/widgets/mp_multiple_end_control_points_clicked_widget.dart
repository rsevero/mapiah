import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPMultipleEndControlPointsClickedWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;

  const MPMultipleEndControlPointsClickedWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
  });

  @override
  State<MPMultipleEndControlPointsClickedWidget> createState() =>
      _MPMultipleEndControlPointsClickedWidgetState();
}

class _MPMultipleEndControlPointsClickedWidgetState
    extends State<MPMultipleEndControlPointsClickedWidget> {
  late final TH2FileEditController th2FileEditController;
  late final TH2FileEditSelectionController selectionController;
  late final List<MPSelectableEndControlPoint> clickedEndControlPoints;
  late final AppLocalizations appLocalizations;
  late final THFile thFile;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    selectionController = th2FileEditController.selectionController;
    clickedEndControlPoints = selectionController.clickedEndControlPoints;
    appLocalizations = mpLocator.appLocalizations;
    thFile = th2FileEditController.thFile;
    selectionController.setMultipleEndControlPointsClickedChoice(
      MPMultipleEndControlPointsClickedChoice(
        type: MPMultipleEndControlPointsClickedType.none,
      ),
    );
    selectionController.setMultipleEndControlPointsClickedHighlightedChoice(
      MPMultipleEndControlPointsClickedChoice(
        type: MPMultipleEndControlPointsClickedType.none,
      ),
    );
  }

  @override
  void dispose() {
    selectionController.setMultipleEndControlPointsClickedHighlightedChoice(
      MPMultipleEndControlPointsClickedChoice(
        type: MPMultipleEndControlPointsClickedType.none,
      ),
    );
    super.dispose();
  }

  String getEndControlPointName(MPSelectableEndControlPoint endControlPoint) {
    final THElement element = endControlPoint.element;
    String pointName = '';

    switch (element) {
      case THBezierCurveLineSegment _:
        pointName = appLocalizations.thElementBezierCurveLineSegment;
      case THStraightLineSegment _:
        pointName = appLocalizations.thElementStraightLineSegment;
      default:
        return pointName;
    }

    switch (endControlPoint.type) {
      case MPEndControlPointType.controlPoint1:
        pointName +=
            ' ${appLocalizations.mpMultipleEndControlPointsControlPoint1}';
      case MPEndControlPointType.controlPoint2:
        pointName +=
            ' ${appLocalizations.mpMultipleEndControlPointsControlPoint2}';
      case MPEndControlPointType.endPointBezierCurve:
      case MPEndControlPointType.endPointStraight:
        pointName += ' ${appLocalizations.mpMultipleEndControlPointsEndPoint}';
    }

    return pointName;
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, String> options = {};

    if (selectionController.selectionCanBeMultiple) {
      options[0] = appLocalizations.mpMultipleElementsClickedAllChoice;
    }

    int index = 1;
    for (final MPSelectableEndControlPoint clickedEndControlPoint
        in clickedEndControlPoints) {
      switch (clickedEndControlPoint.type) {
        case MPEndControlPointType.controlPoint1:
        case MPEndControlPointType.controlPoint2:
          options[index] = getEndControlPointName(clickedEndControlPoint);
        case MPEndControlPointType.endPointBezierCurve:
        case MPEndControlPointType.endPointStraight:
          options[index] = getEndControlPointName(clickedEndControlPoint);
      }
      index++;
    }

    return MPOverlayWindowWidget(
      title: appLocalizations.mpMultipleEndControlPointsClickedTitle,
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
                  groupValue: mpMultipleElementsClickedNoneChoiceID,
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
    selectionController.performMultipleEndControlPointsClickedChoosen(
      choiceID == mpMultipleElementsClickedAllChoiceID
          ? MPMultipleEndControlPointsClickedChoice(
              type: MPMultipleEndControlPointsClickedType.all,
            )
          : MPMultipleEndControlPointsClickedChoice(
              type: MPMultipleEndControlPointsClickedType.single,
              endControlPoint: clickedEndControlPoints[choiceID - 1],
            ),
    );
  }

  void _onMouseEnter(int choiceID) {
    selectionController.setMultipleEndControlPointsClickedHighlightedChoice(
      choiceID == mpMultipleElementsClickedAllChoiceID
          ? MPMultipleEndControlPointsClickedChoice(
              type: MPMultipleEndControlPointsClickedType.all,
            )
          : MPMultipleEndControlPointsClickedChoice(
              type: MPMultipleEndControlPointsClickedType.single,
              endControlPoint: clickedEndControlPoints[choiceID - 1],
            ),
    );
  }

  void _onMouseExit(int choiceID) {
    selectionController.setMultipleEndControlPointsClickedHighlightedChoice(
      MPMultipleEndControlPointsClickedChoice(
        type: MPMultipleEndControlPointsClickedType.none,
      ),
    );
  }
}
