// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';

class TH2FileEditActionButtonsWidget extends StatelessWidget {
  final String heroPrefix;
  final TH2FileEditController th2FileEditController;

  const TH2FileEditActionButtonsWidget({
    required this.heroPrefix,
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        final List<Widget> generalActionButtons = [];

        generalActionButtons.addAll(_changeImageButton(context));
        generalActionButtons.addAll(_changeScrapButton(context));
        generalActionButtons.addAll(_editElementButtons(context));
        generalActionButtons.addAll(_addElementButtons(context));
        generalActionButtons.addAll(_zoomButtonWithOptions(context));

        return Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: generalActionButtons,
          ),
        );
      },
    );
  }

  List<Widget> _addElementButton({
    required BuildContext context,
    required MPButtonType pla,
    required bool isTypeButton,
  }) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String plaName = pla.name;
    final String heroTag = '${heroPrefix}_add_element_$plaName';
    final String buttonIcon = 'assets/icons/add_element-$plaName.png';
    final bool isPressedButton =
        th2FileEditController.isAddElementMode && !isTypeButton;
    late String tooltip;

    switch (pla) {
      case MPButtonType.addArea:
        tooltip = appLocalizations.th2FileEditPageAddArea;
      case MPButtonType.addElement:
        tooltip = appLocalizations.th2FileEditPageAddElementOptions;
      case MPButtonType.addLine:
        tooltip = appLocalizations.th2FileEditPageAddLine;
      case MPButtonType.addPoint:
        tooltip = appLocalizations.th2FileEditPageAddPoint;
      default:
        return <Widget>[const SizedBox.shrink()];
    }

    return <Widget>[
      FloatingActionButton(
        heroTag: heroTag,
        onPressed: () => _onButtonPressed(pla),
        tooltip: tooltip,
        child: Image.asset(
          buttonIcon,
          width: mpFloatingActionIconSize,
          height: mpFloatingActionIconSize,
          color: isPressedButton
              ? colorScheme.onPrimary
              : colorScheme.onSecondaryContainer,
        ),
        backgroundColor: isPressedButton
            ? colorScheme.primary
            : colorScheme.secondaryContainer,
        elevation: isPressedButton ? 0 : null,
      ),
      if (isTypeButton) const SizedBox(width: mpButtonSpace),
    ];
  }

  List<Widget> _addElementButtons(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return <Widget>[
      const SizedBox(height: mpButtonSpace),
      MouseRegion(
        onEnter: (_) =>
            th2FileEditController.performSetAddElementButtonsHovered(true),
        onExit: (_) =>
            th2FileEditController.performSetAddElementButtonsHovered(false),
        child: Observer(
          builder: (_) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (th2FileEditController.isAddElementButtonsHovered) ...[
                  _imageAssetButton(
                    context: context,
                    isPressed: false,
                    onPressed: () => _onButtonPressed(MPButtonType.addImage),
                    imageAssetPath: mpXTherionImageInsertButtonImagePath,
                    tooltip: appLocalizations.th2FileEditPageAddImageButton,
                  ),
                  const SizedBox(width: mpButtonSpace),
                  _imageAssetButton(
                    context: context,
                    isPressed: false,
                    onPressed: () => _onButtonPressed(MPButtonType.addScrap),
                    imageAssetPath: mpScrapButtonImagePath,
                    tooltip: appLocalizations.th2FileEditPageAddScrapButton,
                  ),
                  const SizedBox(width: mpButtonSpace),
                  ..._addElementButton(
                    context: context,
                    pla: MPButtonType.addArea,
                    isTypeButton: true,
                  ),
                  ..._addElementButton(
                    context: context,
                    pla: MPButtonType.addLine,
                    isTypeButton: true,
                  ),
                  ..._addElementButton(
                    context: context,
                    pla: MPButtonType.addPoint,
                    isTypeButton: true,
                  ),
                ],
                ..._addElementButton(
                  context: context,
                  pla: th2FileEditController.activeAddElementButton,
                  isTypeButton: false,
                ),
              ],
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _changeImageButton(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return <Widget>[
      const SizedBox(height: mpButtonSpace),
      Observer(
        builder: (_) {
          final bool isPressed = th2FileEditController
              .overlayWindowController
              .showChangeImageOverlayWindow;

          return _imageAssetButton(
            context: context,
            isPressed: isPressed,
            onPressed: () => _toggleOverlayWindow(MPWindowType.changeImage),
            tooltip: appLocalizations.th2FileEditPageChangeImageTool,
            imageAssetPath: mpXTherionImageInsertButtonImagePath,
            heroTag: '${heroPrefix}_change_image_tool',
            key:
                th2FileEditController
                    .overlayWindowController
                    .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType
                    .changeImageButton]!,
          );
        },
      ),
    ];
  }

  List<Widget> _changeScrapButton(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return <Widget>[
      const SizedBox(height: mpButtonSpace),
      Observer(
        builder: (_) {
          final bool isPressed = th2FileEditController
              .overlayWindowController
              .showChangeScrapOverlayWindow;

          return _imageAssetButton(
            context: context,
            isPressed: isPressed,
            onPressed: () => _toggleOverlayWindow(MPWindowType.availableScraps),
            tooltip: appLocalizations.th2FileEditPageChangeActiveScrapTool,
            imageAssetPath: mpScrapButtonImagePath,
            heroTag: '${heroPrefix}_change_active_scrap_tool',
            key:
                th2FileEditController
                    .overlayWindowController
                    .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType
                    .changeScrapButton]!,
          );
        },
      ),
    ];
  }

  List<Widget> _editElementButtons(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isEditLineMode = th2FileEditController.isEditLineMode;
    final bool enableNodeEditButton =
        th2FileEditController.enableNodeEditButton;
    final bool enableSelectedButton = th2FileEditController.enableSelectButton;
    final bool isSelectMode = th2FileEditController.isSelectMode;

    return <Widget>[
      const SizedBox(height: mpButtonSpace),
      FloatingActionButton(
        heroTag: '${heroPrefix}_select_tool',
        onPressed: enableSelectedButton
            ? () => _onButtonPressed(MPButtonType.select)
            : null,
        tooltip: appLocalizations.th2FileEditPageSelectTool,
        child: Image.asset(
          'assets/icons/select-tool.png',
          width: mpFloatingActionIconSize,
          height: mpFloatingActionIconSize,
          color: enableSelectedButton
              ? (isSelectMode
                    ? colorScheme.onPrimary
                    : colorScheme.onSecondaryContainer)
              : colorScheme.surfaceContainerHighest,
        ),
        backgroundColor: enableSelectedButton
            ? (isSelectMode
                  ? colorScheme.primary
                  : colorScheme.secondaryContainer)
            : colorScheme.surfaceContainerLowest,
        elevation: isSelectMode && enableSelectedButton ? 0 : null,
      ),
      const SizedBox(height: mpButtonSpace),
      FloatingActionButton(
        heroTag: '${heroPrefix}_node_edit_tool',
        onPressed: enableNodeEditButton
            ? () => _onButtonPressed(MPButtonType.nodeEdit)
            : null,
        tooltip: appLocalizations.th2FileEditPageNodeEditTool,
        child: Icon(
          Icons.polyline_outlined,
          size: mpFloatingActionIconSize,
          color: enableNodeEditButton
              ? (isEditLineMode
                    ? colorScheme.onPrimary
                    : colorScheme.onSecondaryContainer)
              : colorScheme.surfaceContainerHighest,
        ),
        backgroundColor: enableNodeEditButton
            ? (isEditLineMode
                  ? colorScheme.primary
                  : colorScheme.secondaryContainer)
            : colorScheme.surfaceContainerLowest,
        elevation: isEditLineMode && enableNodeEditButton ? 0 : null,
      ),
    ];
  }

  Widget _imageAssetButton({
    required BuildContext context,
    required bool isPressed,
    required VoidCallback? onPressed,
    required String imageAssetPath,
    String? tooltip,
    Object? heroTag,
    Key? key,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: isPressed
          ? const EdgeInsets.only(left: mpButtonSpace)
          : EdgeInsets.zero,
      child: FloatingActionButton(
        key: key,
        heroTag: heroTag,
        onPressed: onPressed,
        tooltip: tooltip,
        child: Image.asset(
          imageAssetPath,
          width: mpFloatingActionIconSize,
          height: mpFloatingActionIconSize,
          color: isPressed
              ? colorScheme.onPrimary
              : colorScheme.onSecondaryContainer,
        ),
        backgroundColor: isPressed
            ? colorScheme.primary
            : colorScheme.secondaryContainer,
        elevation: isPressed ? 0 : null,
      ),
    );
  }

  List<Widget> _zoomButtonWithOptions(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return <Widget>[
      const SizedBox(height: mpButtonSpace),
      MouseRegion(
        onEnter: (_) =>
            th2FileEditController.performSetZoomButtonsHovered(true),
        onExit: (_) =>
            th2FileEditController.performSetZoomButtonsHovered(false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Observer(
              builder: (_) {
                if (!th2FileEditController.isZoomButtonsHovered) {
                  return const SizedBox();
                }

                final bool selectedElementsEmpty = th2FileEditController
                    .selectionController
                    .mpSelectedElementsLogical
                    .isEmpty;

                return Row(
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_in',
                      onPressed: () => _onButtonPressed(MPButtonType.zoomIn),
                      tooltip: appLocalizations.th2FileEditPageZoomIn,
                      child: Image.asset(
                        'assets/icons/zoom_plus.png',
                        width: mpFloatingActionZoomIconSize,
                        height: mpFloatingActionZoomIconSize,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    const SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_1_1',
                      onPressed: () =>
                          _onButtonPressed(MPButtonType.zoomOneToOne),
                      tooltip: appLocalizations.th2FileEditPageZoomOneToOne,
                      child: Image.asset(
                        'assets/icons/zoom_one_to_one.png',
                        width: mpFloatingActionZoomIconSize,
                        height: mpFloatingActionZoomIconSize,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    const SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_selection',
                      onPressed: selectedElementsEmpty
                          ? null
                          : () => _onButtonPressed(MPButtonType.zoomSelection),
                      tooltip: appLocalizations.th2FileEditPageZoomToSelection,
                      child: Image.asset(
                        'assets/icons/zoom_selection.png',
                        width: mpFloatingActionZoomIconSize,
                        height: mpFloatingActionZoomIconSize,
                        color: selectedElementsEmpty
                            ? Colors.grey
                            : colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    const SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_selection_window',
                      onPressed: () =>
                          _onButtonPressed(MPButtonType.zoomSelectionWindow),
                      tooltip:
                          appLocalizations.th2FileEditPageZoomToSelectionWindow,
                      child: Image.asset(
                        'assets/icons/zoom_selection_window.png',
                        width: mpFloatingActionZoomIconSize,
                        height: mpFloatingActionZoomIconSize,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    const SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_out_scrap',
                      onPressed: th2FileEditController.hasMultipleScraps
                          ? () => _onButtonPressed(MPButtonType.zoomAllScrap)
                          : null,
                      tooltip: appLocalizations.th2FileEditPageZoomOutScrap,
                      child: Image.asset(
                        'assets/icons/zoom_out_scrap.png',
                        width: mpFloatingActionZoomIconSize,
                        height: mpFloatingActionZoomIconSize,
                        color: th2FileEditController.hasMultipleScraps
                            ? colorScheme.onSecondaryContainer
                            : Colors.grey,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    const SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_out_file',
                      onPressed: () =>
                          _onButtonPressed(MPButtonType.zoomAllFile),
                      tooltip: appLocalizations.th2FileEditPageZoomOutFile,
                      child: Icon(
                        Icons.zoom_out_map,
                        size: mpFloatingActionIconSize,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    const SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_out',
                      onPressed: () => _onButtonPressed(MPButtonType.zoomOut),
                      tooltip: appLocalizations.th2FileEditPageZoomOut,
                      child: Image.asset(
                        'assets/icons/zoom_minus.png',
                        width: mpFloatingActionZoomIconSize,
                        height: mpFloatingActionZoomIconSize,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    const SizedBox(width: mpButtonSpace),
                  ],
                );
              },
            ),
            FloatingActionButton(
              heroTag: '${heroPrefix}_zoom_options',
              onPressed: () {},
              tooltip: appLocalizations.th2FileEditPageZoomOptions,
              child: Image.asset(
                'assets/icons/zoom_plus_minus.png',
                width: mpFloatingActionZoomIconSize,
                height: mpFloatingActionZoomIconSize,
                color: colorScheme.onSecondaryContainer,
              ),
              backgroundColor: colorScheme.secondaryContainer,
            ),
          ],
        ),
      ),
    ];
  }

  void _onButtonPressed(MPButtonType buttonType) {
    th2FileEditController.stateController.onButtonPressed(buttonType);
  }

  void _toggleOverlayWindow(MPWindowType windowType) {
    th2FileEditController.overlayWindowController.toggleOverlayWindow(
      windowType,
    );
  }
}
