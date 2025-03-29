import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class MPPLATypeOptionWidget extends StatelessWidget {
  final String value;
  final String label;
  final String groupValue;
  final bool isSelected;
  final TH2FileEditController th2FileEditController;

  MPPLATypeOptionWidget({
    super.key,
    required this.value,
    required this.label,
    required this.groupValue,
    required this.isSelected,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      value: value,
      groupValue: groupValue,
      title: Text(label),
      onChanged: (String? newValue) {
        if (newValue != null) {
          (newValue) => _onChanged(context, newValue);
        }
      },
      visualDensity: VisualDensity.compact,
      dense: true,
      selected: value == groupValue,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _onChanged(BuildContext context, String newValue) {}
}
