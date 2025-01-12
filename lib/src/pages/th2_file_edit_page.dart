import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_error_dialog.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
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

        if (fileReady) {
          thFileStore = snapshot.data!.thFileStore;
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
                  icon: Icon(Icons.save_alt_outlined),
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
                return Container();
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
                      _zoomButtonWithOptions(),
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

  Widget _zoomButtonWithOptions() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isHovered) ...[
              FloatingActionButton(
                onPressed: () => thFileDisplayStore.zoomIn(),
                tooltip: AppLocalizations.of(context).th2FileEditPageZoomIn,
                child: Icon(Icons.zoom_in),
                mini: true,
              ),
              SizedBox(width: 8),
              FloatingActionButton(
                onPressed: () => thFileDisplayStore.zoomShowAll(),
                tooltip:
                    AppLocalizations.of(context).th2FileEditPageZoomShowAll,
                child: Icon(Icons.zoom_out_map),
                mini: true,
              ),
              SizedBox(width: 8),
              FloatingActionButton(
                onPressed: () => thFileDisplayStore.zoomOut(),
                tooltip: AppLocalizations.of(context).th2FileEditPageZoomOut,
                child: Icon(Icons.zoom_out),
                mini: true,
              ),
              SizedBox(width: 8),
            ],
            FloatingActionButton(
              onPressed: () {},
              tooltip: AppLocalizations.of(context).th2FileEditPageZoomOptions,
              child: Icon(Icons.zoom_out_map),
            ),
          ],
        ),
      ),
    );
  }
}
