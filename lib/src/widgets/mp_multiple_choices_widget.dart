import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_single_column_list_overlay_window_content_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPMultipleChoicesWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final THCommandOptionType type;
  final Map<String, String> choices;
  final String selectedChoice;
  final String? defaultChoice;
  final Offset position;
  final MPWidgetPositionType positionType;

  MPMultipleChoicesWidget({
    super.key,
    required this.th2FileEditController,
    required this.type,
    required this.choices,
    required this.selectedChoice,
    this.defaultChoice,
    required this.position,
    required this.positionType,
  });

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      position: position,
      positionType: positionType,
      overlayWindowType: MPOverlayWindowType.optionChoices,
      th2FileEditController: th2FileEditController,
      child: MPSingleColumnListOverlayWindowContentWidget(
        children: choices.entries.map((entry) {
          final String value = entry.key;
          final String label = entry.value;

          return RadioListTile<String>(
            title: Text(label),
            value: value,
            groupValue: selectedChoice,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _onChoiceSelected(context, newValue);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _onChoiceSelected(BuildContext context, String newValue) {
    th2FileEditController.optionEditController.setOptionChoice(type, newValue);
    th2FileEditController.optionEditController.clearCurrentOptionType();
    th2FileEditController.selectionController.updateSelectedElementsClones();
    th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPOverlayWindowType.optionChoices,
      false,
    );
    th2FileEditController.triggerOptionsListRedraw();
  }
}
