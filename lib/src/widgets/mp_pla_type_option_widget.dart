import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Single PLA type option used inside MPPLATypeOptionsOverlayWidget.
class MPPLATypeOptionWidget extends StatelessWidget {
  final String value;
  final String label;
  final String groupValue;
  final bool isSelected;
  final THElementType plaType;
  final TH2FileEditController th2FileEditController;

  MPPLATypeOptionWidget({
    super.key,
    required this.value,
    required this.label,
    required this.groupValue,
    required this.isSelected,
    required this.plaType,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: (String? newValue) {
        if (newValue != null) {
          _onChanged(context, newValue);
        }
      },
      visualDensity: VisualDensity.adaptivePlatformDensity,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _onChanged(BuildContext context, String newValue) {
    th2FileEditController.userInteractionController.prepareSetPLAType(
      plaType: plaType,
      newType: newValue,
    );
    th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.plaTypes,
      false,
    );
  }
}
