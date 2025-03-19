import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';

class MPOptionWidget extends StatelessWidget {
  final THCommandOptionType type;
  final MPOptionStateType state;
  final THCommandOption? option;
  final TH2FileEditController th2FileEditController;
  final TH2FileEditOptionEditController optionEditController;

  MPOptionWidget({
    required this.type,
    required this.state,
    this.option,
    required this.th2FileEditController,
  }) : optionEditController = th2FileEditController.optionEditController;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ListTile(
        title: Text(MPTextToUser.getCommandOptionType(type)),
        onTap: () => onOptionTap(type),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        visualDensity: VisualDensity.compact,
        dense: true,
        minLeadingWidth: 0,
      ),
    );
  }

  void onOptionTap(THCommandOptionType type) {
    optionEditController.toggleOptionShownStatus(type);
  }
}
