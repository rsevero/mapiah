import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_pla_type_option_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPPLATypeOptionsOverlayWindowWidget extends StatelessWidget {
  final THElementType elementType;
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;
  final String? selectedPLAType;

  MPPLATypeOptionsOverlayWindowWidget({
    super.key,
    required this.elementType,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
    required this.selectedPLAType,
  });

  @override
  Widget build(BuildContext context) {
    late Map<String, String> choices;
    late List<String> lastUsedChoices;
    late List<String> lastUsedChoicesReduced = [];
    late List<String> mostUsedChoices;
    final List<String> mostUsedChoicesReduced = [];
    late String title;
    final String selectedPLATypeNotNull = selectedPLAType == null
        ? ''
        : selectedPLAType!;

    switch (elementType) {
      case THElementType.area:
        title = mpLocator.appLocalizations.mpPLATypeAreaTitle;
        choices = MPTextToUser.getOrderedChoices(
          MPTextToUser.getAreaTypeChoices(),
        );
        lastUsedChoices =
            th2FileEditController.elementEditController.lastUsedAreaTypes;
        mostUsedChoices =
            th2FileEditController.elementEditController.mostUsedAreaTypes;
      case THElementType.line:
        title = mpLocator.appLocalizations.mpPLATypeLineTitle;
        choices = MPTextToUser.getOrderedChoices(
          MPTextToUser.getLineTypeChoices(),
        );
        lastUsedChoices =
            th2FileEditController.elementEditController.lastUsedLineTypes;
        mostUsedChoices =
            th2FileEditController.elementEditController.mostUsedLineTypes;
      case THElementType.point:
        title = mpLocator.appLocalizations.mpPLATypePointTitle;
        choices = MPTextToUser.getOrderedChoices(
          MPTextToUser.getPointTypeChoices(),
        );
        lastUsedChoices =
            th2FileEditController.elementEditController.lastUsedPointTypes;
        mostUsedChoices =
            th2FileEditController.elementEditController.mostUsedPointTypes;
      default:
        return SizedBox.shrink();
    }

    for (final String choice in lastUsedChoices) {
      if (choice == selectedPLATypeNotNull) {
        continue;
      }

      lastUsedChoicesReduced.add(choice);

      if (lastUsedChoicesReduced.length >= mpMaxLastUsedTypes) {
        break;
      }
    }

    for (final String choice in mostUsedChoices) {
      if (lastUsedChoicesReduced.contains(choice) ||
          (choice == selectedPLATypeNotNull)) {
        continue;
      }

      mostUsedChoicesReduced.add(choice);

      if (mostUsedChoicesReduced.length >= mpMaxMostUsedTypes) {
        break;
      }
    }

    return MPOverlayWindowWidget(
      title: title,
      overlayWindowType: MPOverlayWindowType.secondary,
      outerAnchorPosition: outerAnchorPosition,
      innerAnchorType: innerAnchorType,
      th2FileEditController: th2FileEditController,
      children: [
        RadioGroup(
          groupValue: selectedPLATypeNotNull,
          onChanged: (String? newValue) {
            if (newValue != null) {
              _onChanged(context, newValue);
            }
          },
          child: Column(
            children: [
              if (selectedPLATypeNotNull != '') ...[
                const SizedBox(height: mpButtonSpace),
                SizedBox(
                  width: double.infinity,
                  child: MPOverlayWindowBlockWidget(
                    title: mpLocator.appLocalizations.mpPLATypeCurrent,
                    overlayWindowBlockType: MPOverlayWindowBlockType.choiceSet,
                    padding: mpOverlayWindowBlockEdgeInsets,
                    children: [Text(selectedPLATypeNotNull)],
                  ),
                ),
              ],
              if (lastUsedChoicesReduced.isNotEmpty) ...[
                const SizedBox(height: mpButtonSpace),
                MPOverlayWindowBlockWidget(
                  title: mpLocator.appLocalizations.mpPLATypeLastUsed,
                  overlayWindowBlockType: MPOverlayWindowBlockType.choices,
                  padding: mpOverlayWindowBlockEdgeInsets,
                  children: [
                    ...lastUsedChoicesReduced.map((String choice) {
                      return MPPLATypeOptionWidget(
                        value: choice,
                        label: choices[choice]!,
                        th2FileEditController: th2FileEditController,
                      );
                    }),
                  ],
                ),
              ],
              if (mostUsedChoicesReduced.isNotEmpty) ...[
                const SizedBox(height: mpButtonSpace),
                MPOverlayWindowBlockWidget(
                  title: mpLocator.appLocalizations.mpPLATypeMostUsed,
                  overlayWindowBlockType: MPOverlayWindowBlockType.choices,
                  padding: mpOverlayWindowBlockEdgeInsets,
                  children: [
                    ...mostUsedChoicesReduced.map((String choice) {
                      return MPPLATypeOptionWidget(
                        value: choice,
                        label: choices[choice]!,
                        th2FileEditController: th2FileEditController,
                      );
                    }),
                  ],
                ),
              ],
              const SizedBox(height: mpButtonSpace),
              MPOverlayWindowBlockWidget(
                title: mpLocator.appLocalizations.mpPLATypeAll,
                overlayWindowBlockType: MPOverlayWindowBlockType.choices,
                padding: mpOverlayWindowBlockEdgeInsets,
                children: [
                  ...choices.entries.map((MapEntry<String, String> entry) {
                    return MPPLATypeOptionWidget(
                      value: entry.key,
                      label: entry.value,
                      th2FileEditController: th2FileEditController,
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onChanged(BuildContext context, String newValue) {
    th2FileEditController.userInteractionController.prepareSetPLAType(
      plaType: elementType,
      newType: newValue,
    );
    th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.plaTypes,
      false,
    );
  }
}
