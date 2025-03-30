import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';

class MPOptionWidget extends StatelessWidget {
  final MPOptionInfo optionInfo;
  final TH2FileEditController th2FileEditController;
  final TH2FileEditOptionEditController optionEditController;
  final bool isSelected;
  final Function(BuildContext, THCommandOptionType) onOptionSelected;

  MPOptionWidget({
    super.key,
    required this.optionInfo,
    required this.th2FileEditController,
    required this.isSelected,
    required this.onOptionSelected,
  }) : optionEditController = th2FileEditController.optionEditController;

  @override
  Widget build(BuildContext context) {
    // mpLocator.mpLog.fine("MPOptionWidget.build() $tileColor");

    return ListTile(
      title: Text(MPTextToUser.getCommandOptionType(optionInfo.type)),
      onTap: () => onOptionTap(context, optionInfo.type),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      visualDensity: VisualDensity.compact,
      dense: true,
      minLeadingWidth: 0,
      // iconColor: iconColor,
      // textColor: textColor,
      // tileColor: tileColor,
      selected: isSelected,
    );
  }

  void onOptionTap(BuildContext context, THCommandOptionType type) {
    onOptionSelected(context, type);
  }
}
