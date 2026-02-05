import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/help_button_widget.dart';
import 'package:mapiah/src/widgets/th_file_widget.dart';

class TH2FileEditPage extends StatefulWidget {
  final String filename;
  final TH2FileEditController? th2FileEditController;
  final Uint8List? fileBytes;

  TH2FileEditPage({
    required this.filename,
    super.key,
    this.th2FileEditController,
    this.fileBytes,
  }) : assert(filename.isNotEmpty, 'Filename cannot be empty');

  @override
  State<TH2FileEditPage> createState() => _TH2FileEditPageState();
}

class _TH2FileEditPageState extends State<TH2FileEditPage> {
  late final TH2FileEditController th2FileEditController;
  late final Future<TH2FileEditControllerCreateResult>
  th2FileEditControllerCreateResult;
  bool _th2FileEditControllerLoaded = false;
  late ColorScheme colorScheme;
  bool isSelectMode = false;
  bool enableSelectedButton = false;

  @override
  void initState() {
    super.initState();

    if (widget.th2FileEditController == null) {
      th2FileEditController = mpLocator.mpGeneralController
          .getTH2FileEditController(
            filename: widget.filename,
            fileBytes: widget.fileBytes,
          );
      th2FileEditControllerCreateResult = th2FileEditController.load();
    } else {
      th2FileEditController = widget.th2FileEditController!;
      th2FileEditControllerCreateResult = Future.value(
        TH2FileEditControllerCreateResult(true, []),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<TH2FileEditControllerCreateResult>(
      future: th2FileEditControllerCreateResult,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<TH2FileEditControllerCreateResult> snapshot,
          ) {
            final bool fileReady =
                (snapshot.connectionState == ConnectionState.done) &&
                snapshot.hasData &&
                snapshot.data!.isSuccessful;

            if (fileReady && !_th2FileEditControllerLoaded) {
              _th2FileEditControllerLoaded = true;
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(appLocalizations.fileEditWindowWindowTitle),
                elevation: 4,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  onPressed: _onLeavePage,
                ),
                actions: <Widget>[
                  if (fileReady) ...[
                    Observer(
                      builder: (context) => IconButton(
                        icon: Icon(
                          Icons.save_outlined,
                          color: th2FileEditController.enableSaveButton
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSecondaryContainer.withAlpha(100),
                        ),
                        onPressed: th2FileEditController.enableSaveButton
                            ? () => th2FileEditController.saveTH2File()
                            : null,
                        tooltip: appLocalizations.th2FileEditPageSave,
                      ),
                    ),
                    if (!kIsWeb)
                      IconButton(
                        icon: Icon(
                          Icons.save_as_outlined,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        onPressed: () => th2FileEditController.saveAsTH2File(),
                        tooltip: appLocalizations.th2FileEditPageSaveAs,
                      ),
                  ],
                  MPHelpButtonWidget(
                    context,
                    mpHelpPageKeyboardShortcutsEdit,
                    appLocalizations.mapiahKeyboardShortcutsTitle,
                    iconData: Icons.keyboard_alt_outlined,
                    tooltip: appLocalizations.mapiahKeyboardShortcutsTooltip,
                  ),
                  MPHelpButtonWidget(
                    context,
                    mpHelpPageTh2FileEdit,
                    appLocalizations.th2FileEditPageHelpDialogTitle,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    onPressed: _onLeavePage,
                  ),
                ],
              ),
              body: FutureBuilder<TH2FileEditControllerCreateResult>(
                future: th2FileEditControllerCreateResult,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<TH2FileEditControllerCreateResult> snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Text(
                            appLocalizations.th2FileEditPageLoadingFile(
                              widget.filename,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final List<String> errorMessages =
                            snapshot.data!.errors;

                        if (snapshot.data!.isSuccessful) {
                          if (mpDebugMousePosition) {
                            return MouseRegion(
                              onHover: (event) => th2FileEditController
                                  .performSetMousePosition(event.localPosition),
                              child: Stack(
                                children: [
                                  THFileWidget(
                                    key: th2FileEditController
                                        .getTHFileWidgetGlobalKey(),
                                    th2FileEditController:
                                        th2FileEditController,
                                  ),
                                  _stateActionButtons(),
                                  _actionButtons(),
                                ],
                              ),
                            );
                          } else {
                            return Stack(
                              children: [
                                THFileWidget(
                                  key: th2FileEditController
                                      .getTHFileWidgetGlobalKey(),
                                  th2FileEditController: th2FileEditController,
                                ),
                                _stateActionButtons(),
                                _actionButtons(),
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
                                );
                              },
                            );
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
              bottomNavigationBar: BottomAppBar(
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

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            th2FileEditController.filenameAndScrap,
                            style: statusBarInfoStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: mpButtonMargin),
                        Expanded(
                          child: Text(
                            th2FileEditController.statusBarMessage,
                            style: statusBarTextStyle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: mpButtonMargin),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "🔍 ${th2FileEditController.canvasScaleAsPercentageText}",
                              style: statusBarInfoStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
    );
  }

  Widget _actionButtons() {
    return Observer(
      builder: (context) {
        final List<Widget> generalActionButtons = [];

        enableSelectedButton = th2FileEditController.enableSelectButton;
        isSelectMode = th2FileEditController.isSelectMode;

        generalActionButtons.addAll(_changeImageButton());
        generalActionButtons.addAll(_changeScrapButton());
        generalActionButtons.addAll(_editElementButtons());
        generalActionButtons.addAll(_addElementButtons());
        generalActionButtons.addAll(_zoomButtonWithOptions());

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
  }) {
    final String typeName = type.name;
    final String heroTag = 'add_element_$typeName';
    final String buttonIcon = 'assets/icons/add_element-$typeName.png';
    final bool isPressedButton =
        th2FileEditController.isAddElementMode && !isTypeButton;
    late String tooltip;

    switch (type) {
      case MPButtonType.addArea:
        tooltip = mpLocator.appLocalizations.th2FileEditPageAddArea;
      case MPButtonType.addElement:
        tooltip = mpLocator.appLocalizations.th2FileEditPageAddElementOptions;
      case MPButtonType.addLine:
        tooltip = mpLocator.appLocalizations.th2FileEditPageAddLine;
      case MPButtonType.addPoint:
        tooltip = mpLocator.appLocalizations.th2FileEditPageAddPoint;
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

  List<Widget> _addElementButtons() {
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
                    tooltip: mpLocator
                        .appLocalizations
                        .th2FileEditPageAddImageButton,
                  ),
                  SizedBox(width: mpButtonSpace),
                  _imageAssetButton(
                    isPressed: false,
                    onPressed: _onAddScrapButtonPressed,
                    imageAssetPath: mpScrapButtonImagePath,
                    tooltip: mpLocator
                        .appLocalizations
                        .th2FileEditPageAddScrapButton,
                  ),
                  SizedBox(width: mpButtonSpace),
                  ..._addElementButton(
                    type: MPButtonType.addArea,
                    isTypeButton: true,
                  ),
                  ..._addElementButton(
                    type: MPButtonType.addLine,
                    isTypeButton: true,
                  ),
                  ..._addElementButton(
                    type: MPButtonType.addPoint,
                    isTypeButton: true,
                  ),
                ],
                ..._addElementButton(
                  type: th2FileEditController.activeAddElementButton,
                  isTypeButton: false,
                ),
              ],
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _changeImageButton() {
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
            tooltip: mpLocator.appLocalizations.th2FileEditPageChangeImageTool,
            imageAssetPath: mpXTherionImageInsertButtonImagePath,
            heroTag: 'change_image_tool',
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

  List<Widget> _changeScrapButton() {
    return [
      SizedBox(height: mpButtonSpace),
      Observer(
        builder: (_) {
          final bool isChangeScrapButtonPressed = th2FileEditController
              .overlayWindowController
              .showChangeScrapOverlayWindow;

          return _imageAssetButton(
            isPressed: isChangeScrapButtonPressed,
            onPressed: _onChangeScrapButtonPressed,
            tooltip:
                mpLocator.appLocalizations.th2FileEditPageChangeActiveScrapTool,
            imageAssetPath: mpScrapButtonImagePath,
            heroTag: 'change_active_scrap_tool',
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

  List<Widget> _editElementButtons() {
    final bool isEditLineMode = th2FileEditController.isEditLineMode;
    final bool enableNodeEditButton =
        th2FileEditController.enableNodeEditButton;

    return [
      SizedBox(height: mpButtonSpace),
      FloatingActionButton(
        heroTag: 'select_tool',
        onPressed: enableSelectedButton ? _onSelectToolPressed : null,
        tooltip: mpLocator.appLocalizations.th2FileEditPageSelectTool,
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
        heroTag: 'node_edit_tool',
        onPressed: enableNodeEditButton ? _onNodeEditToolPressed : null,
        tooltip: mpLocator.appLocalizations.th2FileEditPageNodeEditTool,
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
    th2FileEditController.stateController.onButtonPressed(MPButtonType.remove);
  }

  void _onLeavePage() {
    th2FileEditController.close();
    Navigator.pop(context);
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

  Widget _stateActionButtons() {
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
                key:
                    th2FileEditController
                        .overlayWindowController
                        .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType
                        .snapTargetsButton]!,
                heroTag: 'snap',
                mini: true,
                tooltip: mpLocator.appLocalizations.th2FileEditPageSnapButton,
                onPressed: () {
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
                  heroTag: 'remove',
                  mini: true,
                  tooltip:
                      mpLocator.appLocalizations.th2FileEditPageRemoveButton,
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
                  heroTag: 'undo',
                  mini: true,
                  tooltip: hasUndo
                      ? th2FileEditController.undoDescription
                      : mpLocator
                            .appLocalizations
                            .th2FileEditPageNoUndoAvailable,
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
                  heroTag: 'redo',
                  mini: true,
                  tooltip: hasRedo
                      ? th2FileEditController.redoDescription
                      : mpLocator
                            .appLocalizations
                            .th2FileEditPageNoRedoAvailable,
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

  List<Widget> _zoomButtonWithOptions() {
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
                      heroTag: 'zoom_in',
                      onPressed: zoomInPressed,
                      tooltip: mpLocator.appLocalizations.th2FileEditPageZoomIn,
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
                      heroTag: 'zoom_1_1',
                      onPressed: zoomOneToOne,
                      tooltip: mpLocator
                          .appLocalizations
                          .th2FileEditPageZoomOneToOne,
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
                      heroTag: 'zoom_selection',
                      onPressed: selectedElementsEmpty ? null : zoomSelection,
                      tooltip: mpLocator
                          .appLocalizations
                          .th2FileEditPageZoomToSelection,
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
                      heroTag: 'zoom_out_scrap',
                      onPressed: th2FileEditController.hasMultipleScraps
                          ? zoomAllScrapPressed
                          : null,
                      tooltip: mpLocator
                          .appLocalizations
                          .th2FileEditPageZoomOutScrap,
                      child: Image.asset(
                        'assets/icons/zoom-out-scrap.png',
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
                      heroTag: 'zoom_out_file',
                      onPressed: zoomAllFilePressed,
                      tooltip:
                          mpLocator.appLocalizations.th2FileEditPageZoomOutFile,
                      child: Icon(
                        Icons.zoom_out_map,
                        size: mpFloatingActionIconSize,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    SizedBox(width: mpButtonSpace),
                    FloatingActionButton(
                      heroTag: 'zoom_out',
                      onPressed: zoomOutPressed,
                      tooltip:
                          mpLocator.appLocalizations.th2FileEditPageZoomOut,
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
              heroTag: 'zoom_options',
              onPressed: () {},
              tooltip: mpLocator.appLocalizations.th2FileEditPageZoomOptions,
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
}
