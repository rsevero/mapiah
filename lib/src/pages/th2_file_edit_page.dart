import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/auxiliary/th2_file_edit_mode.dart';
import 'package:mapiah/src/stores/th_file_edit_store.dart';
import 'package:mapiah/src/stores/mp_general_store.dart';
import 'package:mapiah/src/widgets/th_file_widget.dart';

class TH2FileEditPage extends StatefulWidget {
  final String filename;

  TH2FileEditPage({required this.filename});

  @override
  State<TH2FileEditPage> createState() => _TH2FileEditPageState();
}

class _TH2FileEditPageState extends State<TH2FileEditPage> {
  late final THFileEditStore thFileEditStore;
  late final Future<THFileEditStoreCreateResult> thFileEditStoreCreateResult;
  bool _thFileEditStoreLoaded = false;

  @override
  void initState() {
    super.initState();
    thFileEditStore =
        getIt<MPGeneralStore>().getTHFileEditStore(filename: widget.filename);
    thFileEditStoreCreateResult = thFileEditStore.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<THFileEditStoreCreateResult>(
      future: thFileEditStoreCreateResult,
      builder: (BuildContext context,
          AsyncSnapshot<THFileEditStoreCreateResult> snapshot) {
        final bool fileReady =
            (snapshot.connectionState == ConnectionState.done) &&
                snapshot.hasData &&
                snapshot.data!.isSuccessful;

        if (fileReady && !_thFileEditStoreLoaded) {
          _thFileEditStoreLoaded = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).fileEditWindowWindowTitle),
            elevation: 4,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: <Widget>[
              if (fileReady) ...[
                IconButton(
                  icon: Icon(Icons.save_outlined),
                  onPressed: () => thFileEditStore.saveTH2File(),
                ),
                IconButton(
                  icon: Icon(Icons.save_as_outlined),
                  onPressed: () => thFileEditStore.saveAsTH2File(),
                ),
              ],
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: FutureBuilder<THFileEditStoreCreateResult>(
            future: thFileEditStoreCreateResult,
            builder: (BuildContext context,
                AsyncSnapshot<THFileEditStoreCreateResult> snapshot) {
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
                          key: ValueKey(thFileEditStore.thFileMapiahID),
                          thFileEditStore: thFileEditStore,
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
        );
      },
    );
  }

  Widget _undoRedoButtons() {
    return Observer(
      builder: (_) {
        if (!thFileEditStore.isSelectMode) {
          return const SizedBox();
        }

        return Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              Observer(
                builder: (_) => FloatingActionButton(
                  heroTag: 'undo',
                  mini: true,
                  tooltip: thFileEditStore.hasUndo
                      ? thFileEditStore.undoDescription
                      : AppLocalizations.of(context)
                          .th2FileEditPageNoUndoAvailable,
                  backgroundColor: thFileEditStore.hasUndo
                      ? null
                      : Theme.of(context).colorScheme.surfaceContainerLowest,
                  foregroundColor: thFileEditStore.hasUndo
                      ? null
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  onPressed:
                      thFileEditStore.hasUndo ? thFileEditStore.undo : null,
                  child: const Icon(Icons.undo),
                ),
              ),
              const SizedBox(width: 8),
              Observer(
                builder: (_) => FloatingActionButton(
                  heroTag: 'redo',
                  mini: true,
                  tooltip: thFileEditStore.hasRedo
                      ? thFileEditStore.redoDescription
                      : AppLocalizations.of(context)
                          .th2FileEditPageNoRedoAvailable,
                  backgroundColor: thFileEditStore.hasRedo
                      ? null
                      : Theme.of(context).colorScheme.surfaceContainerLowest,
                  foregroundColor: thFileEditStore.hasRedo
                      ? null
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  onPressed:
                      thFileEditStore.hasRedo ? thFileEditStore.redo : null,
                  child: const Icon(Icons.redo),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButtons() {
    return Observer(
      builder: (context) {
        final bool isPanMode = thFileEditStore.mode == TH2FileEditMode.pan;
        final bool isSelectMode =
            thFileEditStore.mode == TH2FileEditMode.select;
        final ColorScheme colorScheme = Theme.of(context).colorScheme;

        return Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'pan_tool',
                onPressed: () {
                  thFileEditStore.setTH2FileEditMode(TH2FileEditMode.pan);
                },
                tooltip: AppLocalizations.of(context).th2FileEditPagePanTool,
                child: Image.asset(
                  'assets/icons/pan-tool.png',
                  width: thFloatingActionIconSize,
                  height: thFloatingActionIconSize,
                  color: isPanMode ? colorScheme.onPrimary : null,
                ),
                backgroundColor: isPanMode ? colorScheme.primary : null,
                elevation: isPanMode ? 0 : null,
              ),
              SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'select_tool',
                onPressed: () {
                  thFileEditStore.setTH2FileEditMode(TH2FileEditMode.select);
                },
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

  Widget _zoomButtonWithOptions() {
    return MouseRegion(
      onEnter: (_) => thFileEditStore.setZoomButtonsHovered(true),
      onExit: (_) => thFileEditStore.setZoomButtonsHovered(false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Observer(
            builder: (_) {
              if (!thFileEditStore.isZoomButtonsHovered) {
                return const SizedBox();
              }

              return Row(
                children: [
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    onPressed: () => thFileEditStore.zoomIn(),
                    tooltip: AppLocalizations.of(context).th2FileEditPageZoomIn,
                    child: Icon(Icons.zoom_in, size: thFloatingActionIconSize),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_show_all',
                    onPressed: () => thFileEditStore.zoomShowAll(),
                    tooltip:
                        AppLocalizations.of(context).th2FileEditPageZoomShowAll,
                    child: Icon(Icons.zoom_out_map,
                        size: thFloatingActionIconSize),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    onPressed: () => thFileEditStore.zoomOut(),
                    tooltip:
                        AppLocalizations.of(context).th2FileEditPageZoomOut,
                    child: Icon(Icons.zoom_out, size: thFloatingActionIconSize),
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
            child: SvgPicture.asset(
              'assets/icons/zoom_plus_minus.svg',
              width: thFloatingActionIconSize,
              height: thFloatingActionIconSize,
            ),
          ),
        ],
      ),
    );
  }
}
