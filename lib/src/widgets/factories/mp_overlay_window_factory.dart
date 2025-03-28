import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/widgets/mp_altitude_value_option_widget.dart';
import 'package:mapiah/src/widgets/mp_available_scraps_widget.dart';
import 'package:mapiah/src/widgets/mp_multiple_choices_widget.dart';
import 'package:mapiah/src/widgets/mp_options_edit_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOverlayWindowFactory {
  static Widget createOverlayWindow({
    required TH2FileEditController th2FileEditController,
    required Offset position,
    required MPWindowType type,
  }) {
    final TH2FileEditOverlayWindowController overlayWindowController =
        th2FileEditController.overlayWindowController;
    final int thFileMPID = th2FileEditController.thFileMPID;

    switch (type) {
      case MPWindowType.availableScraps:
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
      case MPWindowType.commandOptions:
        return MPOptionsEditWidget(
          key: ValueKey("MPOptionsEditWidget|$thFileMPID"),
          th2FileEditController: th2FileEditController,
          position: position,
          positionType: MPWidgetPositionType.center,
          maxHeight: getMaxHeightForOverlayWindows(
            th2FileEditController.thFileWidgetKey,
          ),
        );
      case MPWindowType.mainTHFileEditWindow:
        throw UnimplementedError(
          'The main TH file edit window is automatically created when opening a TH2File.',
        );
      case MPWindowType.optionChoices:
        throw UnimplementedError(
          'Call MPOverlayWindowFactory.createOptionChoices() to create option choices widgets.',
        );
    }
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
          choices = MPTextToUser.getAdjustChoices();
        case THCommandOptionType.align:
          choices = MPTextToUser.getAlignChoices();
        case THCommandOptionType.anchors:
        case THCommandOptionType.border:
        case THCommandOptionType.clip:
        case THCommandOptionType.rebelays:
        case THCommandOptionType.reverse:
        case THCommandOptionType.visibility:
          choices = MPTextToUser.getOnOffChoices();
        case THCommandOptionType.close:
        case THCommandOptionType.smooth:
        case THCommandOptionType.walls:
          choices = MPTextToUser.getOnOffAutoChoices();
        case THCommandOptionType.flip:
          choices = MPTextToUser.getFlipChoices();
        case THCommandOptionType.head:
        case THCommandOptionType.lineDirection:
          choices = MPTextToUser.getArrowPositionChoices();
        case THCommandOptionType.lineGradient:
          choices = MPTextToUser.getLineGradientChoices();
        case THCommandOptionType.linePointDirection:
          choices = MPTextToUser.getLinePointDirectionChoices();
        case THCommandOptionType.linePointGradient:
          choices = MPTextToUser.getLinePointGradientChoices();
        case THCommandOptionType.outline:
          choices = MPTextToUser.getOutlineChoices();
        case THCommandOptionType.place:
          choices = MPTextToUser.getPlaceChoices();
        default:
          throw Exception('Unknown multiple choice option type: $optionType');
      }

      return MPMultipleChoicesWidget(
        th2FileEditController: th2FileEditController,
        key: ValueKey("MPMultipleChoicesWidget|$thFileMPID|${optionType.name}"),
        type: optionType,
        choices: MPTextToUser.getOptionChoicesWithUnset(choices),
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
        case THCommandOptionType.altitudeValue:
          return MPAltitudeValueOptionWidget(
            th2FileEditController: th2FileEditController,
            currentOption: optionInfo.option as THAltitudeValueCommandOption?,
            position: position,
            positionType: MPWidgetPositionType.leftCenter,
            maxHeight: getMaxHeightForOverlayWindows(
              th2FileEditController.thFileWidgetKey,
            ),
          );
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
