import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';

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
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // late final Color? iconColor;
    // late final Color? textColor;
    // late final Color? tileColor;

    // if (isSelected) {
    // iconColor = null;
    // textColor = null;
    // tileColor = null;
    // } else {
    // switch (state) {
    //   case MPOptionStateType.set:
    //     // mpLocator.mpLog.fine("MPOptionWidget.build() MPOptionStateType.set");
    //     iconColor = colorScheme.onTertiaryFixed;
    //     textColor = colorScheme.onTertiaryFixed;
    //     tileColor = colorScheme.tertiaryFixed;

    //   case MPOptionStateType.setMixed:
    //     // mpLocator.mpLog
    //     //     .fine("MPOptionWidget.build() MPOptionStateType.setMixed");
    //     iconColor = colorScheme.onTertiaryContainer;
    //     textColor = colorScheme.onTertiaryContainer;
    //     tileColor = colorScheme.tertiaryContainer;
    //   case MPOptionStateType.setUnsupported:
    //     // mpLocator.mpLog
    //     //     .fine("MPOptionWidget.build() MPOptionStateType.setUnsupported");
    //     iconColor = colorScheme.onTertiary;
    //     textColor = colorScheme.onTertiary;
    //     tileColor = colorScheme.tertiary;
    //   case MPOptionStateType.unset:
    //     // mpLocator.mpLog
    //     //     .fine("MPOptionWidget.build() MPOptionStateType.unset");
    //     iconColor = colorScheme.onSurfaceVariant;
    //     textColor = colorScheme.onSurfaceVariant;
    //     tileColor = colorScheme.surfaceContainer;
    // }
    // }

    // mpLocator.mpLog.fine("MPOptionWidget.build() $tileColor");

    return ListTile(
      title: Text(label),
      // onTap: () => onOptionTap(context, type),
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

  void onOptionTap(BuildContext context, THCommandOptionType type) {}
}
