import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
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
  final bool isSelected;

  MPOptionWidget({
    required this.type,
    required this.state,
    this.option,
    required this.th2FileEditController,
    required this.isSelected,
  }) : optionEditController = th2FileEditController.optionEditController;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    late final Color? iconColor;
    late final Color? textColor;
    late final Color? tileColor;

    if (isSelected) {
      iconColor = null;
      textColor = null;
      tileColor = null;
    } else {
      switch (state) {
        case MPOptionStateType.set:
          // mpLocator.mpLog.fine("MPOptionWidget.build() MPOptionStateType.set");
          iconColor = colorScheme.onTertiaryFixed;
          textColor = colorScheme.onTertiaryFixed;
          tileColor = colorScheme.tertiaryFixed;

        case MPOptionStateType.setMixed:
          // mpLocator.mpLog
          //     .fine("MPOptionWidget.build() MPOptionStateType.setMixed");
          iconColor = colorScheme.onTertiaryContainer;
          textColor = colorScheme.onTertiaryContainer;
          tileColor = colorScheme.tertiaryContainer;
        case MPOptionStateType.setUnsupported:
          // mpLocator.mpLog
          //     .fine("MPOptionWidget.build() MPOptionStateType.setUnsupported");
          iconColor = colorScheme.onTertiary;
          textColor = colorScheme.onTertiary;
          tileColor = colorScheme.tertiary;
        case MPOptionStateType.unset:
          // mpLocator.mpLog
          //     .fine("MPOptionWidget.build() MPOptionStateType.unset");
          iconColor = colorScheme.onSurfaceVariant;
          textColor = colorScheme.onSurfaceVariant;
          tileColor = colorScheme.surfaceContainer;
      }
    }

    // mpLocator.mpLog.fine("MPOptionWidget.build() $tileColor");

    return ListTile(
      title: Text("${MPTextToUser.getCommandOptionType(type)}: ${state.name}"),
      onTap: () => onOptionTap(context, type),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      visualDensity: VisualDensity.compact,
      dense: true,
      minLeadingWidth: 0,
      iconColor: iconColor,
      textColor: textColor,
      tileColor: tileColor,
      selected: isSelected,
    );
  }

  void onOptionTap(BuildContext context, THCommandOptionType type) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Rect boundingBox = MPNumericAux.orderedRectFromLTWH(
      left: position.dx,
      top: position.dy,
      width: size.width,
      height: size.height,
    );

    // Perform your existing logic
    optionEditController.toggleOptionShownStatus(type, boundingBox);
  }
}
