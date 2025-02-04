import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mapiah/src/widgets/th_file_widget.dart';

class TH2FileEditPage extends StatefulWidget {
  final String filename;

  TH2FileEditPage({required this.filename});

  @override
  State<TH2FileEditPage> createState() => _TH2FileEditPageState();
}

class _TH2FileEditPageState extends State<TH2FileEditPage> {
  late final TH2FileEditStore th2FileEditStore;
  late final Future<TH2FileEditStoreCreateResult> th2FileEditStoreCreateResult;
  bool _th2FileEditStoreLoaded = false;

  @override
  void initState() {
    super.initState();
    th2FileEditStore =
        mpLocator.mpGeneralStore.getTH2FileEditStore(filename: widget.filename);
    th2FileEditStoreCreateResult = th2FileEditStore.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TH2FileEditStoreCreateResult>(
      future: th2FileEditStoreCreateResult,
      builder: (
        BuildContext context,
        AsyncSnapshot<TH2FileEditStoreCreateResult> snapshot,
      ) {
        final bool fileReady =
            (snapshot.connectionState == ConnectionState.done) &&
                snapshot.hasData &&
                snapshot.data!.isSuccessful;

        if (fileReady && !_th2FileEditStoreLoaded) {
          _th2FileEditStoreLoaded = true;
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
                  icon: Icon(Icons.save_outlined),
                  onPressed: () => th2FileEditStore.saveTH2File(),
                  tooltip: mpLocator.appLocalizations.th2FileEditPageSave,
                ),
                IconButton(
                  icon: Icon(Icons.save_as_outlined),
                  onPressed: () => th2FileEditStore.saveAsTH2File(),
                  tooltip: mpLocator.appLocalizations.th2FileEditPageSaveAs,
                ),
              ],
              IconButton(
                icon: Icon(Icons.close),
                onPressed: _onLeavePage,
              ),
            ],
          ),
          body: FutureBuilder<TH2FileEditStoreCreateResult>(
            future: th2FileEditStoreCreateResult,
            builder: (
              BuildContext context,
              AsyncSnapshot<TH2FileEditStoreCreateResult> snapshot,
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
                            "THFileWidget|${th2FileEditStore.thFileMapiahID}",
                          ),
                          th2FileEditStore: th2FileEditStore,
                        ),
                        _undoRedoButtons(),
                        _actionButtons(),
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
                      th2FileEditStore.filenameAndScrap,
                      style: statusBarTextStyle,
                    ),
                    Text(th2FileEditStore.statusBarMessage),
                    Text(
                      "🔍 ${th2FileEditStore.canvasScaleAsPercentageText}",
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
    th2FileEditStore.close();
    Navigator.pop(context);
  }

  Widget _undoRedoButtons() {
    return Observer(
      builder: (_) {
        if (!th2FileEditStore.showUndoRedoButtons) {
          return const SizedBox();
        }

        return Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              Observer(
                builder: (_) {
                  final bool hasUndo = th2FileEditStore.hasUndo;

                  return FloatingActionButton(
                    heroTag: 'undo',
                    mini: true,
                    tooltip: hasUndo
                        ? th2FileEditStore.undoDescription
                        : AppLocalizations.of(context)
                            .th2FileEditPageNoUndoAvailable,
                    backgroundColor: hasUndo
                        ? null
                        : Theme.of(context).colorScheme.surfaceContainerLowest,
                    foregroundColor: hasUndo
                        ? null
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    onPressed: hasUndo ? onUndoPressed : null,
                    elevation: hasUndo ? 6.0 : 3.0,
                    child: const Icon(Icons.undo),
                  );
                },
              ),
              const SizedBox(width: 8),
              Observer(
                builder: (_) {
                  final bool hasRedo = th2FileEditStore.hasRedo;

                  return FloatingActionButton(
                    heroTag: 'redo',
                    mini: true,
                    tooltip: hasRedo
                        ? th2FileEditStore.redoDescription
                        : AppLocalizations.of(context)
                            .th2FileEditPageNoRedoAvailable,
                    backgroundColor: hasRedo
                        ? null
                        : Theme.of(context).colorScheme.surfaceContainerLowest,
                    foregroundColor: hasRedo
                        ? null
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    onPressed: hasRedo ? onRedoPressed : null,
                    elevation: hasRedo ? 6.0 : 3.0,
                    child: const Icon(Icons.redo),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void onUndoPressed() {
    th2FileEditStore.onButtonPressed(MPButtonType.undo);
  }

  void onRedoPressed() {
    th2FileEditStore.onButtonPressed(MPButtonType.redo);
  }

  Widget _actionButtons() {
    return Observer(
      builder: (context) {
        final bool isSelectMode = th2FileEditStore.isSelectMode;
        final ColorScheme colorScheme = Theme.of(context).colorScheme;

        return Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (th2FileEditStore.hasMultipleScraps) ...[
                MouseRegion(
                  onEnter: (PointerEvent event) {
                    th2FileEditStore
                        .changeScrapsPopupOverlayPortalControllerController
                        .show();
                    th2FileEditStore.isChangeScrapsPopupVisible = true;
                  },
                  onExit: (PointerEvent event) {
                    th2FileEditStore
                        .changeScrapsPopupOverlayPortalControllerController
                        .hide();
                    th2FileEditStore.isChangeScrapsPopupVisible = false;
                  },
                  child: Stack(
                    children: [
                      Padding(
                        padding: th2FileEditStore.isChangeScrapsPopupVisible
                            ? const EdgeInsets.only(left: 48.0)
                            : EdgeInsets.zero,
                        child: FloatingActionButton(
                          key: th2FileEditStore.changeScrapsFABKey,
                          heroTag: 'change_active_scrap_tool',
                          onPressed: _onChangeActiveScrapToolPressed,
                          tooltip: AppLocalizations.of(context)
                              .th2FileEditPageChangeActiveScrapTool,
                          child: Image.asset(
                            'assets/icons/change-scrap-tool.png',
                            width: thFloatingActionIconSize,
                            height: thFloatingActionIconSize,
                          ),
                        ),
                      ),
                      OverlayPortal(
                        controller: th2FileEditStore
                            .changeScrapsPopupOverlayPortalControllerController,
                        overlayChildBuilder: (context) {
                          final RenderBox fabBox = th2FileEditStore
                              .changeScrapsFABKey.currentContext!
                              .findRenderObject() as RenderBox;
                          final Offset fabPosition =
                              fabBox.localToGlobal(Offset.zero);
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
                                    th2FileEditStore.activeScrap;
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: th2FileEditStore
                                          .availableScraps()
                                          .map(
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
                                                  Icon(Icons.check,
                                                      color: Colors.blue),
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
              ],
              FloatingActionButton(
                heroTag: 'select_tool',
                onPressed: _onSelectToolPressed,
                tooltip: AppLocalizations.of(context).th2FileEditPageSelectTool,
                child: Image.asset(
                  'assets/icons/select-tool.png',
                  width: thFloatingActionIconSize,
                  height: thFloatingActionIconSize,
                  color: isSelectMode ? colorScheme.onPrimary : null,
                ),
                backgroundColor: isSelectMode ? colorScheme.primary : null,
                elevation: isSelectMode ? 0 : null,
              ),
              SizedBox(height: 8),
              _zoomButtonWithOptions(),
            ],
          ),
        );
      },
    );
  }

  void _onChangeActiveScrapToolPressed() {
    th2FileEditStore.onButtonPressed(MPButtonType.changeScrap);
  }

  void _onSelectToolPressed() {
    th2FileEditStore.onButtonPressed(MPButtonType.select);
  }

  Widget _zoomButtonWithOptions() {
    return MouseRegion(
      onEnter: (_) => th2FileEditStore.setZoomButtonsHovered(true),
      onExit: (_) => th2FileEditStore.setZoomButtonsHovered(false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Observer(
            builder: (_) {
              if (!th2FileEditStore.isZoomButtonsHovered) {
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
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_selection',
                    onPressed: th2FileEditStore.selectedElements.isEmpty
                        ? null
                        : zoomSelection,
                    tooltip: AppLocalizations.of(context)
                        .th2FileEditPageZoomToSelection,
                    child: Image.asset(
                      'assets/icons/zoom_selection.png',
                      width: thFloatingActionZoomIconSize,
                      height: thFloatingActionZoomIconSize,
                      color: th2FileEditStore.selectedElements.isEmpty
                          ? Colors.grey
                          : null,
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
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_out_scrap',
                    onPressed: th2FileEditStore.hasMultipleScraps
                        ? zoomAllScrapPressed
                        : null,
                    tooltip: AppLocalizations.of(context)
                        .th2FileEditPageZoomOutScrap,
                    child: Image.asset(
                      'assets/icons/zoom-out-scrap.png',
                      width: thFloatingActionZoomIconSize,
                      height: thFloatingActionZoomIconSize,
                      color: th2FileEditStore.hasMultipleScraps
                          ? null
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
            ),
          ),
        ],
      ),
    );
  }

  void zoomInPressed() {
    th2FileEditStore.onButtonPressed(MPButtonType.zoomIn);
  }

  void zoomAllFilePressed() {
    th2FileEditStore.onButtonPressed(MPButtonType.zoomAllFile);
  }

  void zoomAllScrapPressed() {
    th2FileEditStore.onButtonPressed(MPButtonType.zoomAllScrap);
  }

  void zoomOutPressed() {
    th2FileEditStore.onButtonPressed(MPButtonType.zoomOut);
  }

  void zoomOneToOne() {
    th2FileEditStore.onButtonPressed(MPButtonType.zoomOneToOne);
  }

  void zoomSelection() {
    th2FileEditStore.onButtonPressed(MPButtonType.zoomSelection);
  }
}
