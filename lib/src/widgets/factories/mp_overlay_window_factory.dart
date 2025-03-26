import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/widgets/mp_available_scraps_widget.dart';
import 'package:mapiah/src/widgets/mp_multiple_choices_widget.dart';
import 'package:mapiah/src/widgets/mp_options_edit_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOverlayWindowFactory {
  static Widget createOverlayWindow({
    required TH2FileEditController th2FileEditController,
    required Offset position,
    required MPOverlayWindowType type,
  }) {
    final TH2FileEditOverlayWindowController overlayWindowController =
        th2FileEditController.overlayWindowController;
    final int thFileMPID = th2FileEditController.thFileMPID;

    switch (type) {
      case MPOverlayWindowType.availableScraps:
        final GlobalKey changeScrapButtonKey = overlayWindowController
            .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType.changeScrapButton]!;
        final Rect? rect = MPInteractionAux.getWidgetRectFromGlobalKey(
          widgetGlobalKey: changeScrapButtonKey,
          ancestorGlobalKey: th2FileEditController.thFileWidgetKey,
        );

        if (rect != null) {
          position = Offset(rect.left - mpButtonSpace, rect.center.dy);
        }

        return MPAvailableScrapsWidget(
          key: ValueKey("MPAvailableScrapsWidget|$thFileMPID"),
          th2FileEditController: th2FileEditController,
          position: position,
        );
      case MPOverlayWindowType.commandOptions:
        return MPOptionsEditWidget(
          key: ValueKey("MPOptionsEditWidget|$thFileMPID"),
          th2FileEditController: th2FileEditController,
          position: position,
          positionType: MPWidgetPositionType.center,
          maxHeight: getMaxHeightForOverlayWindows(
            th2FileEditController.thFileWidgetKey,
          ),
        );
      case MPOverlayWindowType.optionChoices:
        throw UnimplementedError(
          'Call MPOverlayWindowFactory.createOptionChoices() to create option choices widgets.',
        );
    }
  }

  static Map<String, String> getAdjustOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesAdjustType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoiceAdjustChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getAlignOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesAlignType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoiceAlignChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getOnOffOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesOnOffType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoiceOnOffChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getOnOffAutoOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesOnOffAutoType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoiceOnOffAutoChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getFlipOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesFlipType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoiceFlipChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getArrowPositionOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesArrowPositionType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoiceArrowPositionChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getLineGradientOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesLineGradientType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoiceLineGradientChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getLinePointDirectionOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesLinePointDirectionType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoiceLinePointDirectionChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getLinePointGradientOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesLinePointGradientType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoiceLinePointGradientChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getOutlineOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesOutlineType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoiceOutlineChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getPlaceOptions() {
    final Map<String, String> options = {};

    for (final choiceType in THOptionChoicesPlaceType.values) {
      options[choiceType.name] =
          MPTextToUser.getMultipleChoicePlaceChoice(choiceType);
    }

    return options;
  }

  static Map<String, String> getOptionChoicesWithUnset(
    Map<String, String> choices,
  ) {
    final Map<String, String> choicesWithUnset = {
      mpMultipleChoiceUnsetID: mpLocator.appLocalizations.mpMultipleChoiceUnset,
    };

    final List<MapEntry<String, String>> orderedChoices =
        choices.entries.toList()
          ..sort((a, b) => MPTextToUser.compareStringsUsingLocale(
                a.value,
                b.value,
              ));

    choicesWithUnset.addAll(Map.fromEntries(orderedChoices));

    return choicesWithUnset;
  }

  static Widget createOptionChoices({
    required TH2FileEditController th2FileEditController,
    required Offset position,
    required MPOptionInfo optionInfo,
  }) {
    final THCommandOptionType optionType = optionInfo.type;

    if (THCommandOption.isMultipleChoiceOptions(optionType)) {
      final int thFileMPID = th2FileEditController.thFileMPID;
      late Map<String, String> choices;

      switch (optionType) {
        case THCommandOptionType.adjust:
          choices = getAdjustOptions();
        case THCommandOptionType.align:
          choices = getAlignOptions();
        case THCommandOptionType.anchors:
        case THCommandOptionType.border:
        case THCommandOptionType.clip:
        case THCommandOptionType.rebelays:
        case THCommandOptionType.reverse:
        case THCommandOptionType.visibility:
          choices = getOnOffOptions();
        case THCommandOptionType.close:
        case THCommandOptionType.smooth:
        case THCommandOptionType.walls:
          choices = getOnOffAutoOptions();
        case THCommandOptionType.flip:
          choices = getFlipOptions();
        case THCommandOptionType.head:
        case THCommandOptionType.lineDirection:
          choices = getArrowPositionOptions();
        case THCommandOptionType.lineGradient:
          choices = getLineGradientOptions();
        case THCommandOptionType.linePointDirection:
          choices = getLinePointDirectionOptions();
        case THCommandOptionType.linePointGradient:
          choices = getLinePointGradientOptions();
        case THCommandOptionType.outline:
          choices = getOutlineOptions();
        case THCommandOptionType.place:
          choices = getPlaceOptions();
        default:
          throw Exception('Unknown multiple choice option type: $optionType');
      }

      return MPMultipleChoicesWidget(
        th2FileEditController: th2FileEditController,
        key: ValueKey("MPMultipleChoicesWidget|$thFileMPID|${optionType.name}"),
        type: optionType,
        choices: getOptionChoicesWithUnset(choices),
        selectedChoice: optionInfo.currentChoice,
        defaultChoice: THCommandOption.getDefaultChoiceAsString(optionType),
        position: position,
        positionType: MPWidgetPositionType.leftCenter,
        maxHeight: getMaxHeightForOverlayWindows(
          th2FileEditController.thFileWidgetKey,
        ),
      );
    } else {
      switch (optionType) {
        case THCommandOptionType.altitude:
        // return MPAltitudeOptionWidget(th2FileEditController: th2FileEditController, currentOption: currentOption, position: position, positionType: positionType, maxHeight: maxHeight)

        default:
          throw Exception(
              'Unsupported non-multiple choice option type: $optionType at MPOverlayWindowFactory.createOptionChoices');
      }
    }
  }

  static double getMaxHeightForOverlayWindows(GlobalKey targetKey) {
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      throw Exception('No render box found for THFileWidget.');
    }

    return renderBox.size.height;
  }
}
