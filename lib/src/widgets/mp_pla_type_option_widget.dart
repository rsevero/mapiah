import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Single PLA type option used inside MPPLATypeOptionsOverlayWidget.
class MPPLATypeOptionWidget extends StatelessWidget {
  final String value;
  final String label;
  final bool isSelected;
  final THElementType plaType;
  final TH2FileEditController th2FileEditController;

  MPPLATypeOptionWidget({
    super.key,
    required this.value,
    required this.label,
    required this.isSelected,
    required this.plaType,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
