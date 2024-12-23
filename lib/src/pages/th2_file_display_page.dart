import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/stores/th_file_display_page_store.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/th_widgets/th_file_widget.dart';
import 'package:provider/provider.dart';

class THFileDisplayPage extends StatelessWidget {
  final String filename;
  late final THFileDisplayPageStore thFileDisplayPageStore;
  late final THFileStore thFileStore;

  THFileDisplayPage({required this.filename});

  @override
  Widget build(BuildContext context) {
    thFileStore = Provider.of<THFileStore>(context);
    thFileDisplayPageStore = Provider.of<THFileDisplayPageStore>(context);
    thFileDisplayPageStore.loadFile(context, filename);
    return Scaffold(
      appBar: AppBar(
        title: Text('File Display'),
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save_alt_outlined),
            onPressed: () => thFileDisplayPageStore.saveTH2File(),
          ),
          IconButton(
            icon: Icon(Icons.save_as_outlined),
            onPressed: () => thFileDisplayPageStore.saveAsTH2File(),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Observer(
        builder: (context) {
          if (thFileDisplayPageStore.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(
              child: Stack(children: [
                THFileWidget(thFileDisplayPageStore.thFile, thFileStore),
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
            thFileStore.zoomIn();
          }),
          SizedBox(height: 8.0),
          _zoomButton(Icons.zoom_out_map, () {
            thFileStore.zoomShowAll();
          }),
          SizedBox(height: 8.0),
          _zoomButton(Icons.zoom_out, () {
            thFileStore.zoomOut();
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
