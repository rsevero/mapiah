import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_pla_type_option_widget.dart';
import 'package:mapiah/src/widgets/mp_single_column_list_overlay_window_content_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPPLATypeOptionsWidget extends StatelessWidget {
  final THElementType plaType;
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final MPWidgetPositionType positionType;
  final double maxHeight;
  final String? selectedType;

  MPPLATypeOptionsWidget({
    super.key,
    required this.plaType,
    required this.th2FileEditController,
    required this.position,
    required this.positionType,
    required this.maxHeight,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    late Map<String, String> choices;
    late List<String> lastUsedChoices;
    late List<String> lastUsedChoicesReduced = [];
    late List<String> mostUsedChoices;
    final List<String> mostUsedChoicesReduced = [];
    late String title;

    switch (plaType) {
      case THElementType.area:
        title = mpLocator.appLocalizations.mpPLATypeAreaTitle;
        choices =
            MPTextToUser.getOrderedChoices(MPTextToUser.getAreaTypeChoices());
        lastUsedChoices =
            th2FileEditController.elementEditController.lastUsedAreaTypes;
        mostUsedChoices =
            th2FileEditController.elementEditController.mostUsedAreaTypes;
      case THElementType.line:
        title = mpLocator.appLocalizations.mpPLATypeLineTitle;
        choices =
            MPTextToUser.getOrderedChoices(MPTextToUser.getLineTypeChoices());
        lastUsedChoices =
            th2FileEditController.elementEditController.lastUsedLineTypes;
        mostUsedChoices =
            th2FileEditController.elementEditController.mostUsedLineTypes;
      case THElementType.point:
        title = mpLocator.appLocalizations.mpPLATypePointTitle;
        choices =
            MPTextToUser.getOrderedChoices(MPTextToUser.getPointTypeChoices());
        lastUsedChoices =
            th2FileEditController.elementEditController.lastUsedPointTypes;
        mostUsedChoices =
            th2FileEditController.elementEditController.mostUsedPointTypes;
      default:
        return SizedBox.shrink();
    }

    for (final String choice in lastUsedChoices) {
      if (choice == selectedType) {
        continue;
      }

      lastUsedChoicesReduced.add(choice);

      if (lastUsedChoicesReduced.length >= mpMaxLastUsedTypes) {
        break;
      }
    }

    for (final String choice in mostUsedChoices) {
      if (lastUsedChoicesReduced.contains(choice) || (choice == selectedType)) {
        continue;
      }

      mostUsedChoicesReduced.add(choice);

      if (mostUsedChoicesReduced.length >= mpMaxMostUsedTypes) {
        break;
      }
    }

    return MPOverlayWindowWidget(
      position: position,
      positionType: positionType,
      windowType: MPWindowType.commandOptions,
      th2FileEditController: th2FileEditController,
      child: MPSingleColumnListOverlayWindowContentWidget(
        maxHeight: maxHeight,
        children: [
          Text(title),
          if (selectedType != null) ...[
            const Divider(),
            Text(mpLocator.appLocalizations.mpPLATypeCurrent),
            MPPLATypeOptionWidget(
              value: selectedType!,
              label: choices[selectedType]!,
              groupValue: selectedType!,
              isSelected: true,
              plaType: plaType,
              th2FileEditController: th2FileEditController,
            ),
          ],
          if (lastUsedChoicesReduced.isNotEmpty) ...[
            const Divider(),
            Text(mpLocator.appLocalizations.mpPLATypeLastUsed),
            ...lastUsedChoicesReduced.map((String choice) {
              return MPPLATypeOptionWidget(
                value: choice,
                label: choices[choice]!,
                groupValue: selectedType == null ? '' : selectedType!,
                isSelected: choice == selectedType,
                plaType: plaType,
                th2FileEditController: th2FileEditController,
              );
            }),
          ],
          if (mostUsedChoicesReduced.isNotEmpty) ...[
            const Divider(),
            Text(mpLocator.appLocalizations.mpPLATypeMostUsed),
            ...mostUsedChoicesReduced.map((String choice) {
              return MPPLATypeOptionWidget(
                value: choice,
                label: choices[choice]!,
                groupValue: selectedType == null ? '' : selectedType!,
                isSelected: choice == selectedType,
                plaType: plaType,
                th2FileEditController: th2FileEditController,
              );
            }),
          ],
          const Divider(),
          Text(mpLocator.appLocalizations.mpPLATypeAll),
          ...choices.entries.map((MapEntry<String, String> entry) {
            return MPPLATypeOptionWidget(
              value: entry.key,
              label: entry.value,
              groupValue: selectedType == null ? '' : selectedType!,
              isSelected: entry.key == selectedType,
              plaType: plaType,
              th2FileEditController: th2FileEditController,
            );
          }),
        ],
      ),
    );
  }
}
