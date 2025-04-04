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
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_altitude_option_widget.dart';
import 'package:mapiah/src/widgets/mp_author_option_widget.dart';
import 'package:mapiah/src/widgets/mp_available_scraps_widget.dart';
import 'package:mapiah/src/widgets/mp_context_option_widget.dart';
import 'package:mapiah/src/widgets/mp_copyright_option_widget.dart';
import 'package:mapiah/src/widgets/mp_cs_option_widget.dart';
import 'package:mapiah/src/widgets/mp_date_value_option_widget.dart';
import 'package:mapiah/src/widgets/mp_dimensions_option_widget.dart';
import 'package:mapiah/src/widgets/mp_distance_type_option_widget.dart';
import 'package:mapiah/src/widgets/mp_id_option_widget.dart';
import 'package:mapiah/src/widgets/mp_double_value_option_widget.dart';
import 'package:mapiah/src/widgets/mp_multiple_choices_widget.dart';
import 'package:mapiah/src/widgets/mp_options_edit_widget.dart';
import 'package:mapiah/src/widgets/mp_pl_scale_option_widget.dart';
import 'package:mapiah/src/widgets/mp_pla_type_options_widget.dart';
import 'package:mapiah/src/widgets/mp_station_type_option_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOverlayWindowFactory {
  static OverlayEntry createOverlayWindow({
    required TH2FileEditController th2FileEditController,
    required Offset outerAnchorPosition,
    required MPWindowType type,
  }) {
    final TH2FileEditOverlayWindowController overlayWindowController =
        th2FileEditController.overlayWindowController;
    final int thFileMPID = th2FileEditController.thFileMPID;
    Widget overlayWindowWidget;

    switch (type) {
      case MPWindowType.availableScraps:
        final GlobalKey changeScrapButtonGlobalKey = overlayWindowController
            .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType.changeScrapButton]!;
        final Rect? changeScrapButtonBoundingBox =
            MPInteractionAux.getWidgetRectFromGlobalKey(
          widgetGlobalKey: changeScrapButtonGlobalKey,
          ancestorGlobalKey: th2FileEditController.thFileWidgetKey,
        );

        if (changeScrapButtonBoundingBox != null) {
          outerAnchorPosition = Offset(
              changeScrapButtonBoundingBox.left - mpButtonSpace,
              changeScrapButtonBoundingBox.center.dy);
        }

        overlayWindowWidget = MPAvailableScrapsWidget(
          key: ValueKey("MPAvailableScrapsWidget|$thFileMPID"),
          th2FileEditController: th2FileEditController,
          outerAnchorPosition: outerAnchorPosition,
        );
      case MPWindowType.commandOptions:
        overlayWindowWidget = MPOptionsEditWidget(
          key: ValueKey("MPOptionsEditWidget|$thFileMPID"),
          th2FileEditController: th2FileEditController,
          outerAnchorPosition: outerAnchorPosition,
          innerAnchorType: MPWidgetPositionType.center,
        );
      case MPWindowType.mainTHFileEditWindow:
        throw UnimplementedError(
          'The main TH file edit window is automatically created when opening a TH2File.',
        );
      case MPWindowType.optionChoices:
        throw UnimplementedError(
          'Call MPOverlayWindowFactory.createOptionChoices() to create option choices widgets.',
        );
      case MPWindowType.plaTypes:
        throw UnimplementedError(
          'Call MPOverlayWindowFactory.createPLATypeOptions() to create PLA type options widgets.',
        );
    }

    return OverlayEntry(builder: (context) => overlayWindowWidget);
  }

  static OverlayEntry createOptionChoices({
    required TH2FileEditController th2FileEditController,
    required Offset outerAnchorPosition,
    required MPOptionInfo optionInfo,
  }) {
    final THCommandOptionType optionType = optionInfo.type;
    Widget overlayWindowWidget;

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

      overlayWindowWidget = MPMultipleChoicesWidget(
        th2FileEditController: th2FileEditController,
        key: ValueKey("MPMultipleChoicesWidget|$thFileMPID|${optionType.name}"),
        optionInfo: optionInfo,
        choices: MPTextToUser.getOptionChoicesWithUnset(choices),
        outerAnchorPosition: outerAnchorPosition,
        innerAnchorType: MPWidgetPositionType.leftCenter,
      );
    } else {
      switch (optionType) {
        case THCommandOptionType.altitude:
        case THCommandOptionType.altitudeValue:
          overlayWindowWidget = MPAltitudeOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.author:
          overlayWindowWidget = MPAuthorOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.context:
          overlayWindowWidget = MPContextOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.copyright:
          overlayWindowWidget = MPCopyrightOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.cs:
          overlayWindowWidget = MPCSOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.dateValue:
          overlayWindowWidget = MPDateValueOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.dimensionsValue:
          overlayWindowWidget = MPDimensionsOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.dist:
        case THCommandOptionType.explored:
          overlayWindowWidget = MPDistanceTypeOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.extend:
        case THCommandOptionType.from:
          overlayWindowWidget = MPStationTypeOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.id:
          overlayWindowWidget = MPIDOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.lineHeight:
        case THCommandOptionType.lSize:
          overlayWindowWidget = MPDoubleValueOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        case THCommandOptionType.plScale:
          overlayWindowWidget = MPPLScaleOptionWidget(
            th2FileEditController: th2FileEditController,
            optionInfo: optionInfo,
            outerAnchorPosition: outerAnchorPosition,
            innerAnchorType: MPWidgetPositionType.leftCenter,
          );
        default:
          throw Exception(
              'Unsupported non-multiple choice option type: $optionType at MPOverlayWindowFactory.createOptionChoices');
      }
    }

    return OverlayEntry(builder: (context) => overlayWindowWidget);
  }

  static OverlayEntry createPLATypeOptions({
    required TH2FileEditController th2FileEditController,
    required Offset position,
    required THElementType elementType,
    required String? selectedType,
  }) {
    final int thFileMPID = th2FileEditController.thFileMPID;

    return OverlayEntry(
      builder: (context) => MPPLATypeOptionsWidget(
        th2FileEditController: th2FileEditController,
        key: ValueKey("MPPLATypeOptionsWidget|$thFileMPID"),
        plaType: elementType,
        selectedType: selectedType,
        outerAnchorPosition: position,
        innerAnchorType: MPWidgetPositionType.leftCenter,
      ),
    );
  }
}
