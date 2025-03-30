import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPMultipleChoicesWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Map<String, String> choices;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  MPMultipleChoicesWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.choices,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  Widget build(BuildContext context) {
    final String selectedChoice = optionInfo.state == MPOptionStateType.unset
        ? mpUnsetOptionID
        : (optionInfo.currentChoice ?? '');

    return MPOverlayWindowWidget(
      title: MPTextToUser.getCommandOptionType(optionInfo.type),
      overlayWindowType: MPOverlayWindowType.secondary,
      outerAnchorPosition: outerAnchorPosition,
      innerAnchorType: innerAnchorType,
      th2FileEditController: th2FileEditController,
      children: choices.entries.map((entry) {
        final String value = entry.key;
        final String label = entry.value;

        return RadioListTile<String>(
          title: Row(
            children: [
              Text(label),
              if (value == optionInfo.defaultChoice)
                Padding(
                  padding: const EdgeInsets.only(left: mpButtonSpace),
                  child: Text(
                    '*',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          value: value,
          groupValue: selectedChoice,
          onChanged: (String? newValue) {
            if (newValue != null) {
              _onChoiceSelected(context, newValue);
            }
          },
        );
      }).toList(),
    );
  }

  void _onChoiceSelected(BuildContext context, String newValue) {
    th2FileEditController.userInteractionController
        .prepareSetMultipleOptionChoice(
      optionType: optionInfo.type,
      choice: newValue,
    );
  }
}
