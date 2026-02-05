import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_option_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_tile_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPScrapOptionsEditWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPScrapOptionsEditWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPScrapOptionsEditWidget> createState() =>
      _MPScrapOptionsEditWidgetState();
}

class _MPScrapOptionsEditWidgetState extends State<MPScrapOptionsEditWidget> {
  late final TH2FileEditController th2FileEditController =
      widget.th2FileEditController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerOptionsList;

        final int scrapMPID =
            th2FileEditController.optionEditController.optionsScrapMPID;
        final THScrap scrap = th2FileEditController.thFile.scrapByMPID(
          scrapMPID,
        );
        final AppLocalizations appLocalizations = mpLocator.appLocalizations;
        final List<Widget> widgets = [];
        final TH2FileEditOptionEditController optionEditController =
            th2FileEditController.optionEditController;
        final Iterable<MapEntry<THCommandOptionType, MPOptionInfo>>
        optionsStateMap = optionEditController.optionStateMap.entries;

        MPInteractionAux.addWidgetWithTopSpace(
          widgets,
          MPOverlayWindowBlockWidget(
            title: appLocalizations.thElementScrap,
            children: [MPTileWidget(title: scrap.thID)],
            overlayWindowBlockType: MPOverlayWindowBlockType.main,
          ),
        );

        List<Widget> blockWidgets = [];

        for (final optionEntry in optionsStateMap) {
          final THCommandOptionType optionType = optionEntry.key;
          final MPOptionInfo optionInfo = optionEntry.value;

          blockWidgets.add(
            MPOptionWidget(
              optionInfo: optionInfo,
              th2FileEditController: th2FileEditController,
              isSelected: optionType == optionEditController.currentOptionType,
              onOptionSelected: onOptionSelected,
            ),
          );
        }

        if (blockWidgets.isNotEmpty) {
          addWithTopSpace(
            widgets,
            MPOverlayWindowBlockWidget(
              children: blockWidgets,
              overlayWindowBlockType: MPOverlayWindowBlockType.secondary,
            ),
          );
        }

        return MPOverlayWindowWidget(
          title: appLocalizations.mpOptionsEditTitle,
          overlayWindowType: MPOverlayWindowType.primary,
          outerAnchorPosition: widget.outerAnchorPosition,
          innerAnchorType: widget.innerAnchorType,
          th2FileEditController: th2FileEditController,
          children: widgets,
        );
      },
    );
  }

  void addWithTopSpace(List<Widget> widgetsList, Widget newWidget) {
    widgetsList.add(const SizedBox(height: mpButtonSpace));
    widgetsList.add(newWidget);
  }

  void onOptionSelected(BuildContext childContext, THCommandOptionType type) {
    Rect? thisBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: context,
      ancestorGlobalKey: th2FileEditController.getTHFileWidgetGlobalKey(),
    );

    Rect? childBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: childContext,
      ancestorGlobalKey: th2FileEditController.getTHFileWidgetGlobalKey(),
    );

    /// Use the left of this widget and the vertical center of the child (taped
    /// option) widget as the outer anchor position for the option edit window.
    final Offset anchorPosition =
        (thisBoundingBox == null) || (childBoundingBox == null)
        ? th2FileEditController.screenBoundingBox.center
        : Offset(thisBoundingBox.left, childBoundingBox.center.dy);

    th2FileEditController.optionEditController.performToggleOptionShownStatus(
      optionType: type,
      outerAnchorPosition: anchorPosition,
    );
  }
}
