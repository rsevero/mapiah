// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/mp_modal_overlay_widget.dart';
import 'package:mapiah/src/widgets/mp_search_select_dialog_widget.dart';
import 'package:mapiah/src/widgets/th_file_widget.dart';

class TH2FileEditBodyWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Future<TH2FileEditControllerCreateResult> loadFuture;

  const TH2FileEditBodyWidget({
    required this.th2FileEditController,
    required this.loadFuture,
    super.key,
  });

  @override
  State<TH2FileEditBodyWidget> createState() => _TH2FileEditBodyWidgetState();
}

class _TH2FileEditBodyWidgetState extends State<TH2FileEditBodyWidget> {
  late final TH2FileEditController th2FileEditController;
  late AppLocalizations appLocalizations;
  late ColorScheme colorScheme;

  bool isSelectMode = false;
  bool enableSelectedButton = false;

  @override
  void initState() {
    super.initState();

    th2FileEditController = widget.th2FileEditController;
    appLocalizations = mpLocator.appLocalizations;
  }

  @override
  Widget build(BuildContext context) {
    final String heroPrefix = th2FileEditController.th2FileMPID.toString();

    appLocalizations = mpLocator.appLocalizations;
    colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: FutureBuilder<TH2FileEditControllerCreateResult>(
            future: widget.loadFuture,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<TH2FileEditControllerCreateResult> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text(
                        appLocalizations.th2FileEditPageLoadingFile(
                          th2FileEditController.currentScrapName,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final List<String> errorMessages = snapshot.data!.errors;

                    if (snapshot.data!.isSuccessful) {
                      if (mpDebugMousePosition) {
                        return MouseRegion(
                          onHover: (event) => th2FileEditController
                              .performSetMousePosition(event.localPosition),
                          child: Stack(
                            children: [
                              TH2FileWidget(
                                key: th2FileEditController
                                    .getTH2FileWidgetGlobalKey(),
                                th2FileEditController: th2FileEditController,
                              ),
                              _stateActionButtons(heroPrefix),
                              _actionButtons(heroPrefix),
                            ],
                          ),
                        );
                      } else {
                        return Stack(
                          children: [
                            TH2FileWidget(
                              key: th2FileEditController
                                  .getTH2FileWidgetGlobalKey(),
                              th2FileEditController: th2FileEditController,
                            ),
                            _stateActionButtons(heroPrefix),
                            _actionButtons(heroPrefix),
                          ],
                        );
                      }
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MPErrorDialog(
                              errorMessages: errorMessages,
                              filename: th2FileEditController.th2File.filename,
                            );
                          },
                        ).then((_) {
                          th2FileEditController.close();
                        });
                      });

                      return Container();
                    }
                  } else {
                    throw Exception(
                      'Unexpected snapshot state: ${snapshot.connectionState}',
                    );
                  }
                },
          ),
        ),
        BottomAppBar(
          height: 40,
          color: colorScheme.secondary,
          child: Observer(
            builder: (_) {
              final TextStyle statusBarTextStyle = TextStyle(
                color: colorScheme.onSecondary,
                fontStyle: FontStyle.italic,
              );
              final TextStyle statusBarInfoStyle = TextStyle(
                color: colorScheme.onSecondary,
              );
              final String currentScrapName =
                  th2FileEditController.currentScrapName;
              final String statusBarMessage =
                  th2FileEditController.statusBarMessage;
              final String canvasScaleAsPercentageText =
                  th2FileEditController.canvasScaleAsPercentageText;
              final Offset? movingMousePosition =
                  th2FileEditController.movingMousePosition;
              final String movingMousePositionText =
                  (movingMousePosition == null)
                  ? ''
                  : appLocalizations.mpTH2FileEditPageMousePosition(
                      movingMousePosition.dx.toStringAsFixed(1),
                      movingMousePosition.dy.toStringAsFixed(1),
                    );

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double maxScrapNameWidth = constraints.maxWidth / 5;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: maxScrapNameWidth,
                        ),
                        child: Text(
                          currentScrapName,
                          style: statusBarInfoStyle,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: mpButtonMargin),
                      Expanded(
                        child: Text(
                          statusBarMessage,
                          style: statusBarTextStyle,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (movingMousePositionText.isNotEmpty) ...[
                        const SizedBox(width: mpButtonMargin),
                        Text(
                          movingMousePositionText,
                          style: statusBarInfoStyle,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(width: mpButtonMargin),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "🔍 $canvasScaleAsPercentageText",
                          style: statusBarInfoStyle,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButtons(String heroPrefix) {
    return Observer(
      builder: (context) {
        final List<Widget> generalActionButtons = [];

        enableSelectedButton = th2FileEditController.enableSelectButton;
        isSelectMode = th2FileEditController.isSelectMode;

        generalActionButtons.addAll(_changeImageButton(heroPrefix));
        generalActionButtons.addAll(_changeScrapButton(heroPrefix));
        generalActionButtons.addAll(_editElementButtons(heroPrefix));
        generalActionButtons.addAll(_addElementButtons(heroPrefix));
        generalActionButtons.addAll(_zoomButtonWithOptions(heroPrefix));

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
    required MPButtonType type,
    required bool isTypeButton,
    required String heroPrefix,
  }) {
    final String typeName = type.name;
    final String heroTag = '${heroPrefix}_add_element_$typeName';
    final String buttonIcon = 'assets/icons/add_element-$typeName.png';
    final bool isPressedButton =
        th2FileEditController.isAddElementMode && !isTypeButton;
    late String tooltip;

    switch (type) {
      case MPButtonType.addArea:
        tooltip = appLocalizations.th2FileEditPageAddArea;
      case MPButtonType.addElement:
        tooltip = appLocalizations.th2FileEditPageAddElementOptions;
      case MPButtonType.addLine:
        tooltip = appLocalizations.th2FileEditPageAddLine;
      case MPButtonType.addPoint:
        tooltip = appLocalizations.th2FileEditPageAddPoint;
      default:
        return [SizedBox.shrink()];
    }

    return [
      FloatingActionButton(
        heroTag: heroTag,
        onPressed: () => _onAddElementButtonPressed(type),
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
      if (isTypeButton) SizedBox(width: mpButtonSpace),
    ];
  }

  List<Widget> _addElementButtons(String heroPrefix) {
    return [
      SizedBox(height: mpButtonSpace),
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
              children: [
                if (th2FileEditController.isAddElementButtonsHovered) ...[
                  _imageAssetButton(
                    isPressed: false,
                    onPressed: _onAddImageButtonPressed,
                    imageAssetPath: mpXTherionImageInsertButtonImagePath,
                    tooltip: appLocalizations.th2FileEditPageAddImageButton,
                  ),
                  SizedBox(width: mpButtonSpace),
                  _imageAssetButton(
                    isPressed: false,
                    onPressed: _onAddScrapButtonPressed,
                    imageAssetPath: mpScrapButtonImagePath,
                    tooltip: appLocalizations.th2FileEditPageAddScrapButton,
                  ),
                  SizedBox(width: mpButtonSpace),
                  ..._addElementButton(
                    type: MPButtonType.addArea,
                    isTypeButton: true,
                    heroPrefix: heroPrefix,
                  ),
                  ..._addElementButton(
                    type: MPButtonType.addLine,
                    isTypeButton: true,
                    heroPrefix: heroPrefix,
                  ),
                  ..._addElementButton(
                    type: MPButtonType.addPoint,
                    isTypeButton: true,
                    heroPrefix: heroPrefix,
                  ),
                ],
                ..._addElementButton(
                  type: th2FileEditController.activeAddElementButton,
                  isTypeButton: false,
                  heroPrefix: heroPrefix,
                ),
              ],
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _changeImageButton(String heroPrefix) {
    return [
      SizedBox(height: mpButtonSpace),
      Observer(
        builder: (_) {
          final bool isChangeImageButtonPressed = th2FileEditController
              .overlayWindowController
              .showChangeImageOverlayWindow;

          return _imageAssetButton(
            isPressed: isChangeImageButtonPressed,
            onPressed: _onChangeImageButtonPressed,
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

  Widget _imageAssetButton({
    required bool isPressed,
    required VoidCallback? onPressed,
    required String imageAssetPath,
    String? tooltip,
    Object? heroTag,
    Key? key,
  }) {
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

  List<Widget> _changeScrapButton(String heroPrefix) {
    return [
      SizedBox(height: mpButtonSpace),
      Observer(
        builder: (_) {
          final bool isChangeScrapButtonPressed = widget
              .th2FileEditController
              .overlayWindowController
              .showChangeScrapOverlayWindow;

          return _imageAssetButton(
            isPressed: isChangeScrapButtonPressed,
            onPressed: _onChangeScrapButtonPressed,
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

  List<Widget> _editElementButtons(String heroPrefix) {
    final bool isEditLineMode = widget.th2FileEditController.isEditLineMode;
    final bool enableNodeEditButton =
        th2FileEditController.enableNodeEditButton;

    return [
      SizedBox(height: mpButtonSpace),
      FloatingActionButton(
        heroTag: '${heroPrefix}_select_tool',
        onPressed: enableSelectedButton ? _onSelectToolPressed : null,
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
      SizedBox(height: mpButtonSpace),
      FloatingActionButton(
        heroTag: '${heroPrefix}_node_edit_tool',
        onPressed: enableNodeEditButton ? _onNodeEditToolPressed : null,
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

  void _onAddElementButtonPressed(MPButtonType type) {
    th2FileEditController.stateController.onButtonPressed(type);
  }

  void _onAddImageButtonPressed() {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.addImage,
    );
  }

  void _onAddScrapButtonPressed() {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.addScrap,
    );
  }

  void _onChangeImageButtonPressed() {
    th2FileEditController.overlayWindowController.toggleOverlayWindow(
      MPWindowType.changeImage,
    );
  }

  void _onChangeScrapButtonPressed() {
    th2FileEditController.overlayWindowController.toggleOverlayWindow(
      MPWindowType.availableScraps,
    );
  }

  void onRemovePressed() {
    th2FileEditController.overlayWindowController.clearOverlayWindows();
    th2FileEditController.stateController.onButtonPressed(MPButtonType.remove);
  }

  void _onNodeEditToolPressed() {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.nodeEdit,
    );
  }

  void onRedoPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.redo);
  }

  void _onSelectToolPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.select);
  }

  void onUndoPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.undo);
  }

  Widget _stateActionButtons(String heroPrefix) {
    return Observer(
      builder: (_) {
        final bool hasUndo = th2FileEditController.hasUndo;
        final bool hasRedo = th2FileEditController.hasRedo;
        final bool enableRemoveButton =
            th2FileEditController.enableRemoveButton;
        final bool isSomeSnapTargetActive =
            th2FileEditController.snapController.isSomeSnapTargetActive;

        th2FileEditController.redrawSnapTargetsWindow;

        return Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              FloatingActionButton(
                heroTag: '${heroPrefix}_search_select',
                mini: true,
                tooltip: appLocalizations.th2FileEditPageSearchSelectButton,
                onPressed: () {
                  th2FileEditController.overlayWindowController
                      .clearOverlayWindows();
                  MPModalOverlayWidget.show(
                    context: context,
                    childBuilder: (VoidCallback onPressedClose) =>
                        MPSearchSelectDialogWidget(
                          th2FileEditController: th2FileEditController,
                          onPressedClose: onPressedClose,
                        ),
                  );
                },
                child: const Icon(Icons.search),
              ),
              SizedBox(width: mpButtonSpace),
              FloatingActionButton(
                key:
                    th2FileEditController
                        .overlayWindowController
                        .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType
                        .snapTargetsButton]!,
                heroTag: '${heroPrefix}_snap',
                mini: true,
                tooltip: appLocalizations.th2FileEditPageSnapButton,
                onPressed: () {
                  th2FileEditController.overlayWindowController
                      .clearOverlayWindows(except: {MPWindowType.snapTargets});
                  th2FileEditController.overlayWindowController
                      .toggleOverlayWindow(MPWindowType.snapTargets);
                  th2FileEditController.triggerSnapTargetsWindowRedraw();
                },
                backgroundColor: isSomeSnapTargetActive
                    ? null
                    : colorScheme.surfaceContainerLowest,
                foregroundColor: isSomeSnapTargetActive
                    ? null
                    : colorScheme.surfaceContainerHighest,
                elevation: isSomeSnapTargetActive ? 6.0 : 3.0,
                child: Image.asset(
                  'assets/icons/snap-tool.png',
                  width: mpFloatingStateActionZoomIconSize,
                  height: mpFloatingStateActionZoomIconSize,
                  color: isSomeSnapTargetActive
                      ? null
                      : colorScheme.surfaceContainerHighest,
                ),
              ),
              if (th2FileEditController.showRemoveButton) ...[
                SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  heroTag: '${heroPrefix}_remove',
                  mini: true,
                  tooltip: appLocalizations.th2FileEditPageRemoveButton,
                  backgroundColor: enableRemoveButton
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: enableRemoveButton
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  onPressed: enableRemoveButton ? onRemovePressed : null,
                  elevation: enableRemoveButton ? 6.0 : 3.0,
                  child: const Icon(Icons.delete_outlined),
                ),
              ],
              if (th2FileEditController.showUndoRedoButtons) ...[
                SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  heroTag: '${heroPrefix}_undo',
                  mini: true,
                  tooltip: hasUndo
                      ? th2FileEditController.undoDescription
                      : appLocalizations.th2FileEditPageNoUndoAvailable,
                  backgroundColor: hasUndo
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: hasUndo
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  onPressed: hasUndo ? onUndoPressed : null,
                  elevation: hasUndo ? 6.0 : 3.0,
                  child: const Icon(Icons.undo),
                ),
                SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  heroTag: '${heroPrefix}_redo',
                  mini: true,
                  tooltip: hasRedo
                      ? th2FileEditController.redoDescription
                      : appLocalizations.th2FileEditPageNoRedoAvailable,
                  backgroundColor: hasRedo
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: hasRedo
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  onPressed: hasRedo ? onRedoPressed : null,
                  elevation: hasRedo ? 6.0 : 3.0,
                  child: const Icon(Icons.redo),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _zoomButtonWithOptions(String heroPrefix) {
    return [
      SizedBox(height: mpButtonSpace),
      MouseRegion(
        onEnter: (_) =>
            th2FileEditController.performSetZoomButtonsHovered(true),
        onExit: (_) =>
            th2FileEditController.performSetZoomButtonsHovered(false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  children: [
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_in',
                      onPressed: zoomInPressed,
                      tooltip: appLocalizations.th2FileEditPageZoomIn,
                      child: Image.asset(
                        'assets/icons/zoom_plus.png',
                        width: mpFloatingActionZoomIconSize,
                        height: mpFloatingActionZoomIconSize,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_1_1',
                      onPressed: zoomOneToOne,
                      tooltip: appLocalizations.th2FileEditPageZoomOneToOne,
                      child: Image.asset(
                        'assets/icons/zoom_one_to_one.png',
                        width: mpFloatingActionZoomIconSize,
                        height: mpFloatingActionZoomIconSize,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_selection',
                      onPressed: selectedElementsEmpty ? null : zoomSelection,
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
                    SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_selection_window',
                      onPressed: zoomSelectionWindow,
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
                    SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_out_scrap',
                      onPressed: th2FileEditController.hasMultipleScraps
                          ? zoomAllScrapPressed
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
                    SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_out_file',
                      onPressed: zoomAllFilePressed,
                      tooltip: appLocalizations.th2FileEditPageZoomOutFile,
                      child: Icon(
                        Icons.zoom_out_map,
                        size: mpFloatingActionIconSize,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: '${heroPrefix}_zoom_out',
                      onPressed: zoomOutPressed,
                      tooltip: appLocalizations.th2FileEditPageZoomOut,
                      child: Image.asset(
                        'assets/icons/zoom_minus.png',
                        width: mpFloatingActionZoomIconSize,
                        height: mpFloatingActionZoomIconSize,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    SizedBox(width: mpButtonSpace),
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

  void zoomInPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.zoomIn);
  }

  void zoomAllFilePressed() {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.zoomAllFile,
    );
  }

  void zoomAllScrapPressed() {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.zoomAllScrap,
    );
  }

  void zoomOutPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.zoomOut);
  }

  void zoomOneToOne() {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.zoomOneToOne,
    );
  }

  void zoomSelection() {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.zoomSelection,
    );
  }

  void zoomSelectionWindow() {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.zoomSelection,
    );
  }
}
