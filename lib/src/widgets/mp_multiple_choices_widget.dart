import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';

class MPMultipleChoicesWidget extends StatelessWidget {
  final THCommandOptionType type;
  final Map<String, String> choices;
  final String selectedChoice;
  final String? defaultChoice;

  MPMultipleChoicesWidget({
    super.key,
    required this.type,
    required this.choices,
    required this.selectedChoice,
    this.defaultChoice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  void _onChoiceSelected(BuildContext context, String newValue) {
    // Handle the logic for when a choice is selected
    print('Selected choice: $newValue');
    // You can add additional logic here, such as updating state or calling a callback
  }
}
