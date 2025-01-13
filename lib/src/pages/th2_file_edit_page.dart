import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_error_dialog.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_edit_mode.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/stores/th_store_store.dart';
import 'package:mapiah/src/widgets/th_file_widget.dart';

class TH2FileEditPage extends StatefulWidget {
  final String filename;

  TH2FileEditPage({required this.filename});

  @override
  State<TH2FileEditPage> createState() => _TH2FileEditPageState();
}

class _TH2FileEditPageState extends State<TH2FileEditPage> {
  bool _isHovered = false;
  late final THFileStore thFileStore;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();
  late final List<String> loadErrors;
  late final Future<THFileStoreCreateResult> thFileStoreCreateResult;
  bool _thFileStoreLoaded = false;

  @override
  void initState() {
    super.initState();
    thFileStoreCreateResult =
        getIt<THStoreStore>().createFileStore(widget.filename);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<THFileStoreCreateResult>(
      future: thFileStoreCreateResult,
      builder: (BuildContext context,
          AsyncSnapshot<THFileStoreCreateResult> snapshot) {
        final bool fileReady =
            (snapshot.connectionState == ConnectionState.done) &&
                snapshot.hasData &&
                snapshot.data!.isSuccessful;

        if (fileReady && !_thFileStoreLoaded) {
          thFileStore = snapshot.data!.thFileStore;
          _thFileStoreLoaded = true;
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
                  onPressed: () => thFileStore.saveTH2File(),
                ),
                IconButton(
                  icon: Icon(Icons.save_as_outlined),
                  onPressed: () => thFileStore.saveAsTH2File(),
                ),
              ],
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: FutureBuilder<THFileStoreCreateResult>(
            future: thFileStoreCreateResult,
            builder: (BuildContext context,
                AsyncSnapshot<THFileStoreCreateResult> snapshot) {
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
                    child: Stack(children: [
                      THFileWidget(thFileStore),
                      _actionButtons(),
                    ]),
                  );
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return THErrorDialog(errorMessages: errorMessages);
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

  Widget _actionButtons() {
    return Observer(
      builder: (context) {
        final bool isPanMode =
            thFileDisplayStore.th2fileEditMode == TH2FileEditMode.pan;
        final bool isSelectMode =
            thFileDisplayStore.th2fileEditMode == TH2FileEditMode.select;
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
                  thFileDisplayStore.setTH2FileEditMode(TH2FileEditMode.pan);
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
                  thFileDisplayStore.setTH2FileEditMode(TH2FileEditMode.select);
                },
                tooltip: AppLocalizations.of(context).th2FileEditPageSelectTool,
                child: Image.asset(
                  'assets/icons/select-tool.png',
                  width: 24,
                  height: 24,
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
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_isHovered) ...[
            FloatingActionButton(
              heroTag: 'zoom_in',
              onPressed: () => thFileDisplayStore.zoomIn(),
              tooltip: AppLocalizations.of(context).th2FileEditPageZoomIn,
              child: Icon(Icons.zoom_in, size: thFloatingActionIconSize),
            ),
            SizedBox(width: 8),
            FloatingActionButton(
              heroTag: 'zoom_show_all',
              onPressed: () => thFileDisplayStore.zoomShowAll(),
              tooltip: AppLocalizations.of(context).th2FileEditPageZoomShowAll,
              child: Icon(Icons.zoom_out_map, size: thFloatingActionIconSize),
            ),
            SizedBox(width: 8),
            FloatingActionButton(
              heroTag: 'zoom_out',
              onPressed: () => thFileDisplayStore.zoomOut(),
              tooltip: AppLocalizations.of(context).th2FileEditPageZoomOut,
              child: Icon(Icons.zoom_out, size: thFloatingActionIconSize),
            ),
            SizedBox(width: 8),
          ],
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
