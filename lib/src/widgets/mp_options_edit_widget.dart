import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_option_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOptionsEditWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final MPWidgetPositionType positionType;

  const MPOptionsEditWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
    required this.positionType,
  });

  @override
  State<MPOptionsEditWidget> createState() => _MPOptionsEditWidgetState();
}

class _MPOptionsEditWidgetState extends State<MPOptionsEditWidget> {
  late final TH2FileEditController th2FileEditController;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> optionWidgets = [const Text('Options')];

    final mpSelectedElements =
        th2FileEditController.selectionController.selectedElements.values;

    if (mpSelectedElements.length == 1) {
      final THElementType selectedElementType =
          mpSelectedElements.first.originalElementClone.elementType;

      switch (selectedElementType) {
        case THElementType.area:
          optionWidgets.add(const ListTile(title: Text('Area Type')));
        case THElementType.line:
          optionWidgets.add(const ListTile(title: Text('Line Type')));
        case THElementType.straightLineSegment:
          optionWidgets
              .add(const ListTile(title: Text('Straight Line Segment Type')));
        case THElementType.bezierCurveLineSegment:
          optionWidgets.add(
              const ListTile(title: Text('Bezier Curve Line Segment Type')));
        case THElementType.point:
          optionWidgets.add(const ListTile(title: Text('Point Type')));
        case THElementType.scrap:
          optionWidgets.add(const ListTile(title: Text('Scrap Type')));
        default:
          throw Exception('Unknown element type: $selectedElementType');
      }
    }

    final optionsStateMap =
        th2FileEditController.optionEditController.optionStateMap.entries;

    for (final option in optionsStateMap) {
      optionWidgets.add(
        MPOptionWidget(
          type: option.key,
          state: option.value.value,
          th2FileEditController: th2FileEditController,
        ),
      );
    }

    return MPOverlayWindowWidget(
      position: widget.position,
      positionType: widget.positionType,
      overlayWindowType: MPOverlayWindowType.commandOptions,
      th2FileEditController: th2FileEditController,
      child: Material(
        elevation: 8.0,
        child: IntrinsicWidth(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: optionWidgets,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
