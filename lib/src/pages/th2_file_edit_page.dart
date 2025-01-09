import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/widgets/th_file_widget.dart';
import 'package:provider/provider.dart';

class THFileEditPage extends StatelessWidget {
  final String filename;
  late final THFileStore thFileStore;
  late final THFileDisplayStore thFileDisplayStore;

  THFileEditPage({required this.filename});

  @override
  Widget build(BuildContext context) {
    thFileDisplayStore = Provider.of<THFileDisplayStore>(context);
    thFileStore = Provider.of<THFileStore>(context);
    thFileStore.loadFile(context, filename);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).fileEditWindowWindowTitle),
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save_alt_outlined),
            onPressed: () => thFileStore.saveTH2File(),
          ),
          IconButton(
            icon: Icon(Icons.save_as_outlined),
            onPressed: () => thFileStore.saveAsTH2File(),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Observer(
        builder: (context) {
          if (thFileStore.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(
              child: Stack(children: [
                THFileWidget(thFileStore.thFile, thFileDisplayStore),
                _buildFloatingActionButtons(),
              ]),
            );
          }
        },
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Positioned(
      right: 16.0,
      bottom: 16.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _zoomButton(Icons.zoom_in, () {
            thFileDisplayStore.zoomIn();
          }),
          SizedBox(height: 8.0),
          _zoomButton(Icons.zoom_out_map, () {
            thFileDisplayStore.zoomShowAll();
          }),
          SizedBox(height: 8.0),
          _zoomButton(Icons.zoom_out, () {
            thFileDisplayStore.zoomOut();
          }),
        ],
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      mini: true,
      child: Icon(icon),
      onPressed: onPressed,
    );
  }
}
