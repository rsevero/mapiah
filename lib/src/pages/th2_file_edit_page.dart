import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/widgets/th_file_widget.dart';

class TH2FileEditPage extends StatefulWidget {
  final String filename;

  TH2FileEditPage({required this.filename});

  @override
  State<TH2FileEditPage> createState() => _TH2FileEditPageState();
}

class _TH2FileEditPageState extends State<TH2FileEditPage> {
  late final TH2FileEditController th2FileEditController;
  late final Future<TH2FileEditControllerCreateResult>
      th2FileEditControllerCreateResult;
  bool _th2FileEditControllerLoaded = false;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();
    th2FileEditController = mpLocator.mpGeneralController
        .getTH2FileEditController(filename: widget.filename);
    th2FileEditControllerCreateResult = th2FileEditController.load();
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<TH2FileEditControllerCreateResult>(
      future: th2FileEditControllerCreateResult,
      builder: (
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
            title: Text(AppLocalizations.of(context).fileEditWindowWindowTitle),
            elevation: 4,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _onLeavePage,
            ),
            actions: <Widget>[
              if (fileReady) ...[
                IconButton(
                  icon: Icon(
                    Icons.save_outlined,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  onPressed: () => th2FileEditController.saveTH2File(),
                  tooltip: mpLocator.appLocalizations.th2FileEditPageSave,
                ),
                IconButton(
                  icon: Icon(
                    Icons.save_as_outlined,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  onPressed: () => th2FileEditController.saveAsTH2File(),
                  tooltip: mpLocator.appLocalizations.th2FileEditPageSaveAs,
                ),
              ],
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
            builder: (
              BuildContext context,
              AsyncSnapshot<TH2FileEditControllerCreateResult> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Text(AppLocalizations.of(context)
                      .th2FileEditPageLoadingFile(widget.filename)),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                final List<String> errorMessages = snapshot.data!.errors;

                if (snapshot.data!.isSuccessful) {
                  return Center(
                    child: Stack(
                      children: [
                        THFileWidget(
                          key: ValueKey(
                            "THFileWidget|${th2FileEditController.thFileMapiahID}",
                          ),
                          th2FileEditController: th2FileEditController,
                        ),
                        _stateActionButtons(),
                        _generalActionButtons(),
                      ],
                    ),
                  );
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return MPErrorDialog(errorMessages: errorMessages);
                      },
                    );
                  });
                  return Container();
                }
              } else {
                throw Exception(
                    'Unexpected snapshot state: ${snapshot.connectionState}');
              }
            },
          ),
          bottomNavigationBar: BottomAppBar(
            height: 40,
            color: Theme.of(context).colorScheme.secondary,
            child: Observer(
              builder: (_) {
                final TextStyle statusBarTextStyle = TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      th2FileEditController.filenameAndScrap,
                      style: statusBarTextStyle,
                    ),
                    Text(th2FileEditController.statusBarMessage),
                    Text(
                      "🔍 ${th2FileEditController.canvasScaleAsPercentageText}",
                      style: statusBarTextStyle,
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

  void _onLeavePage() {
    th2FileEditController.close();
    Navigator.pop(context);
  }

  Widget _stateActionButtons() {
    return Observer(
      builder: (_) {
        if (!th2FileEditController.showUndoRedoButtons) {
          return const SizedBox();
        }

        final bool hasUndo = th2FileEditController.hasUndo;
        final bool hasRedo = th2FileEditController.hasRedo;
        final bool deleteButtonEnabled =
            th2FileEditController.deleteButtonEnabled;

        return Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              if (th2FileEditController.showDeleteButton) ...[
                FloatingActionButton(
                  heroTag: 'delete',
                  mini: true,
                  tooltip:
                      AppLocalizations.of(context).th2FileEditPageDeleteButton,
                  backgroundColor: deleteButtonEnabled
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: deleteButtonEnabled
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  onPressed: deleteButtonEnabled ? onDeletePressed : null,
                  elevation: deleteButtonEnabled ? 6.0 : 3.0,
                  child: const Icon(Icons.delete_outlined),
                ),
                SizedBox(width: 8),
              ],
              FloatingActionButton(
                heroTag: 'undo',
                mini: true,
                tooltip: hasUndo
                    ? th2FileEditController.undoDescription
                    : AppLocalizations.of(context)
                        .th2FileEditPageNoUndoAvailable,
                backgroundColor:
                    hasUndo ? null : colorScheme.surfaceContainerLowest,
                foregroundColor:
                    hasUndo ? null : colorScheme.surfaceContainerHighest,
                onPressed: hasUndo ? onUndoPressed : null,
                elevation: hasUndo ? 6.0 : 3.0,
                child: const Icon(Icons.undo),
              ),
              SizedBox(width: 8),
              FloatingActionButton(
                heroTag: 'redo',
                mini: true,
                tooltip: hasRedo
                    ? th2FileEditController.redoDescription
                    : AppLocalizations.of(context)
                        .th2FileEditPageNoRedoAvailable,
                backgroundColor:
                    hasRedo ? null : colorScheme.surfaceContainerLowest,
                foregroundColor:
                    hasRedo ? null : colorScheme.surfaceContainerHighest,
                onPressed: hasRedo ? onRedoPressed : null,
                elevation: hasRedo ? 6.0 : 3.0,
                child: const Icon(Icons.redo),
              )
            ],
          ),
        );
      },
    );
  }

  void onDeletePressed() {
    th2FileEditController.onButtonPressed(MPButtonType.delete);
  }

  void onUndoPressed() {
    th2FileEditController.onButtonPressed(MPButtonType.undo);
  }

  void onRedoPressed() {
    th2FileEditController.onButtonPressed(MPButtonType.redo);
  }

  Widget _generalActionButtons() {
    return Observer(
      builder: (context) {
        final bool isSelectMode = th2FileEditController.isSelectMode;

        return Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (th2FileEditController.hasMultipleScraps)
                ..._changeScrapButton(),
              FloatingActionButton(
                heroTag: 'select_tool',
                onPressed: _onSelectToolPressed,
                tooltip: AppLocalizations.of(context).th2FileEditPageSelectTool,
                child: Image.asset(
                  'assets/icons/select-tool.png',
                  width: thFloatingActionIconSize,
                  height: thFloatingActionIconSize,
                  color: isSelectMode
                      ? colorScheme.onPrimary
                      : colorScheme.onSecondaryContainer,
                ),
                backgroundColor: isSelectMode
                    ? colorScheme.primary
                    : colorScheme.onSecondaryContainer,
                elevation: isSelectMode ? 0 : null,
              ),
              SizedBox(height: 8),
              _addElementOptions(),
              SizedBox(height: 8),
              _zoomButtonWithOptions(),
            ],
          ),
        );
      },
    );
  }

  Widget _addElementOptions() {
    return MouseRegion(
      onEnter: (_) => th2FileEditController.setAddElementButtonsHovered(true),
      onExit: (_) => th2FileEditController.setAddElementButtonsHovered(false),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Observer(
                builder: (_) {
                  if (!th2FileEditController.isAddElementButtonsHovered) {
                    return const SizedBox();
                  }

                  return Row(
                    children: [
                      FloatingActionButton(
                        heroTag: 'add_point',
                        onPressed: onAddPointPressed,
                        tooltip: AppLocalizations.of(context)
                            .th2FileEditPageAddPoint,
                        child: Image.asset(
                          'assets/icons/point.png',
                          width: thFloatingActionZoomIconSize,
                          height: thFloatingActionZoomIconSize,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      SizedBox(width: 8),
                      FloatingActionButton(
                        heroTag: 'add_line',
                        onPressed: onAddLinePressed,
                        tooltip:
                            AppLocalizations.of(context).th2FileEditPageAddLine,
                        child: Image.asset(
                          'assets/icons/line.png',
                          width: thFloatingActionZoomIconSize,
                          height: thFloatingActionZoomIconSize,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      SizedBox(width: 8),
                      FloatingActionButton(
                        heroTag: 'add_area',
                        onPressed: onAddAreaPressed,
                        tooltip:
                            AppLocalizations.of(context).th2FileEditPageAddArea,
                        child: Image.asset(
                          'assets/icons/area.png',
                          width: thFloatingActionZoomIconSize,
                          height: thFloatingActionZoomIconSize,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  );
                },
              ),
              FloatingActionButton(
                heroTag: 'add_element_options',
                onPressed: () {},
                tooltip: AppLocalizations.of(context)
                    .th2FileEditPageAddElementOptions,
                child: Image.asset(
                  'assets/icons/add_element.png',
                  width: thFloatingActionZoomIconSize,
                  height: thFloatingActionZoomIconSize,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onAddPointPressed() {
    th2FileEditController.onButtonPressed(MPButtonType.addPoint);
  }

  void onAddLinePressed() {
    th2FileEditController.onButtonPressed(MPButtonType.addLine);
  }

  void onAddAreaPressed() {
    th2FileEditController.onButtonPressed(MPButtonType.addArea);
  }

  List<Widget> _changeScrapButton() {
    return [
      MouseRegion(
        onEnter: (PointerEvent event) {
          th2FileEditController
              .changeScrapsPopupOverlayPortalControllerController
              .show();
          th2FileEditController.isChangeScrapsPopupVisible = true;
        },
        onExit: (PointerEvent event) {
          th2FileEditController
              .changeScrapsPopupOverlayPortalControllerController
              .hide();
          th2FileEditController.isChangeScrapsPopupVisible = false;
        },
        child: Stack(
          children: [
            Padding(
              padding: th2FileEditController.isChangeScrapsPopupVisible
                  ? const EdgeInsets.only(left: 48.0)
                  : EdgeInsets.zero,
              child: FloatingActionButton(
                key: th2FileEditController.changeScrapsFABKey,
                heroTag: 'change_active_scrap_tool',
                onPressed: _onChangeActiveScrapToolPressed,
                tooltip: AppLocalizations.of(context)
                    .th2FileEditPageChangeActiveScrapTool,
                child: Image.asset(
                  'assets/icons/change-scrap-tool.png',
                  width: thFloatingActionIconSize,
                  height: thFloatingActionIconSize,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            OverlayPortal(
              controller: th2FileEditController
                  .changeScrapsPopupOverlayPortalControllerController,
              overlayChildBuilder: (context) {
                final RenderBox fabBox = th2FileEditController
                    .changeScrapsFABKey.currentContext!
                    .findRenderObject() as RenderBox;
                final Offset fabPosition = fabBox.localToGlobal(Offset.zero);
                final Size fabSize = fabBox.size;
                final double popupTop =
                    fabPosition.dy + fabSize.height / 2 - 50;
                final double popupLeft = fabPosition.dx - 250;

                return Positioned(
                  top: popupTop,
                  left: popupLeft,
                  child: Material(
                    elevation: 4.0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: 230,
                      color: Colors.white,
                      child: Observer(
                        builder: (_) {
                          th2FileEditController.activeScrapID;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                th2FileEditController.availableScraps().map(
                              (scrap) {
                                final int scrapID = scrap.$1;
                                final String scrapName = scrap.$2;
                                final bool isSelected = scrap.$3;

                                return PopupMenuItem<int>(
                                  value: scrapID,
                                  // onTap: () =>
                                  //     _selectActiveScrapPressed(
                                  //         scrapID),
                                  child: Row(
                                    children: [
                                      Text(scrapName),
                                      if (isSelected) ...[
                                        SizedBox(width: 8),
                                        Icon(Icons.check, color: Colors.blue),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      SizedBox(height: 8),
    ];
  }

  void _onChangeActiveScrapToolPressed() {
    th2FileEditController.onButtonPressed(MPButtonType.changeScrap);
  }

  void _onSelectToolPressed() {
    th2FileEditController.onButtonPressed(MPButtonType.select);
  }

  Widget _zoomButtonWithOptions() {
    return MouseRegion(
      onEnter: (_) => th2FileEditController.setZoomButtonsHovered(true),
      onExit: (_) => th2FileEditController.setZoomButtonsHovered(false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Observer(
            builder: (_) {
              if (!th2FileEditController.isZoomButtonsHovered) {
                return const SizedBox();
              }

              return Row(
                children: [
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    onPressed: zoomInPressed,
                    tooltip: AppLocalizations.of(context).th2FileEditPageZoomIn,
                    child: Image.asset(
                      'assets/icons/zoom_plus.png',
                      width: thFloatingActionZoomIconSize,
                      height: thFloatingActionZoomIconSize,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_1_1',
                    onPressed: zoomOneToOne,
                    tooltip: AppLocalizations.of(context)
                        .th2FileEditPageZoomOneToOne,
                    child: Image.asset(
                      'assets/icons/zoom_one_to_one.png',
                      width: thFloatingActionZoomIconSize,
                      height: thFloatingActionZoomIconSize,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_selection',
                    onPressed: th2FileEditController.selectedElements.isEmpty
                        ? null
                        : zoomSelection,
                    tooltip: AppLocalizations.of(context)
                        .th2FileEditPageZoomToSelection,
                    child: Image.asset(
                      'assets/icons/zoom_selection.png',
                      width: thFloatingActionZoomIconSize,
                      height: thFloatingActionZoomIconSize,
                      color: th2FileEditController.selectedElements.isEmpty
                          ? Colors.grey
                          : colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_out_file',
                    onPressed: zoomAllFilePressed,
                    tooltip:
                        AppLocalizations.of(context).th2FileEditPageZoomOutFile,
                    child: Icon(
                      Icons.zoom_out_map,
                      size: thFloatingActionIconSize,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_out_scrap',
                    onPressed: th2FileEditController.hasMultipleScraps
                        ? zoomAllScrapPressed
                        : null,
                    tooltip: AppLocalizations.of(context)
                        .th2FileEditPageZoomOutScrap,
                    child: Image.asset(
                      'assets/icons/zoom-out-scrap.png',
                      width: thFloatingActionZoomIconSize,
                      height: thFloatingActionZoomIconSize,
                      color: th2FileEditController.hasMultipleScraps
                          ? colorScheme.onSecondaryContainer
                          : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    onPressed: zoomOutPressed,
                    tooltip:
                        AppLocalizations.of(context).th2FileEditPageZoomOut,
                    child: Image.asset(
                      'assets/icons/zoom_minus.png',
                      width: thFloatingActionZoomIconSize,
                      height: thFloatingActionZoomIconSize,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              );
            },
          ),
          FloatingActionButton(
            heroTag: 'zoom_options',
            onPressed: () {},
            tooltip: AppLocalizations.of(context).th2FileEditPageZoomOptions,
            child: Image.asset(
              'assets/icons/zoom_plus_minus.png',
              width: thFloatingActionZoomIconSize,
              height: thFloatingActionZoomIconSize,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  void zoomInPressed() {
    th2FileEditController.onButtonPressed(MPButtonType.zoomIn);
  }

  void zoomAllFilePressed() {
    th2FileEditController.onButtonPressed(MPButtonType.zoomAllFile);
  }

  void zoomAllScrapPressed() {
    th2FileEditController.onButtonPressed(MPButtonType.zoomAllScrap);
  }

  void zoomOutPressed() {
    th2FileEditController.onButtonPressed(MPButtonType.zoomOut);
  }

  void zoomOneToOne() {
    th2FileEditController.onButtonPressed(MPButtonType.zoomOneToOne);
  }

  void zoomSelection() {
    th2FileEditController.onButtonPressed(MPButtonType.zoomSelection);
  }
}
