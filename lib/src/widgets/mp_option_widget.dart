import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/widgets/mp_tile_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';

/// A widget representing a single option in a list of command options.
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
    final MPOptionStateType optionState = optionInfo.state;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    late final Color? iconColor;
    late final Color? textColor;
    late final Color? backgroundColor;

    if (isSelected) {
      iconColor = null;
      textColor = null;
      backgroundColor = null;
    } else {
      switch (optionState) {
        case MPOptionStateType.set:
          iconColor = colorScheme.onTertiaryFixed;
          textColor = colorScheme.onTertiaryFixed;
          backgroundColor = colorScheme.tertiaryFixed;
        case MPOptionStateType.setMixed:
          iconColor = colorScheme.onTertiaryContainer;
          textColor = colorScheme.onTertiaryContainer;
          backgroundColor = colorScheme.tertiaryContainer;
        case MPOptionStateType.setUnsupported:
          iconColor = colorScheme.onTertiary;
          textColor = colorScheme.onTertiary;
          backgroundColor = colorScheme.tertiary;
        case MPOptionStateType.unset:
          iconColor = colorScheme.onSurfaceVariant;
          textColor = colorScheme.onSurfaceVariant;
          backgroundColor = colorScheme.surfaceContainer;
      }
    }

    return MPTileWidget(
      title: MPTextToUser.getCommandOptionType(optionInfo.type),
      onTap: () => onOptionTap(context, optionInfo.type),
      dense: true,
      iconColor: iconColor,
      textColor: textColor,
      backgroundColor: backgroundColor,
    );
  }

  void onOptionTap(BuildContext context, THCommandOptionType type) {
    onOptionSelected(context, type);
  }
}
