import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';
import 'package:path/path.dart' as p;

/// Overlay window to manage loading/replacing/removing XTherion image insert configs.
class MPLoadImageOverlayWindowWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final VoidCallback onPressedClose;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPLoadImageOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.onPressedClose,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPLoadImageOverlayWindowWidget> createState() =>
      _MPLoadImageOverlayWindowWidgetState();
}

class _MPLoadImageOverlayWindowWidgetState
    extends State<MPLoadImageOverlayWindowWidget> {
  late List<THXTherionImageInsertConfig> _images;

  @override
  void initState() {
    super.initState();
    _refreshImages();
  }

  void _refreshImages() {
    _images = widget.th2FileEditController.thFile
        .getXTherionImageInsertConfigs()
        .toList(growable: false);
  }

  bool _isImageLoaded(THXTherionImageInsertConfig img) {
    if (img.isXVI) {
      return img.getXVIFile(widget.th2FileEditController) != null;
    }
    // Raster image considered loaded when decodedRasterImage cached
    // TODO: Implement a proper cached decoded raster image presence check.
    img.getRasterImageFrameInfo(
      widget.th2FileEditController,
    ); // trigger load attempt
    return true; // assume loaded after request (placeholder)
  }

  Future<void> _pickFile(THXTherionImageInsertConfig image) async {
    final BuildContext? buildContext = context;
    if (buildContext == null) return;

    final String imagePath = await MPDialogAux.pickImageFile(buildContext);
    if (imagePath.isEmpty) return;
    // Use existing controller API: remove old then add new fresh positioned (simpler MVP)
    widget.th2FileEditController.elementEditController.removeImage(image.mpID);
    widget.th2FileEditController.elementEditController.addImage();
    setState(_refreshImages);
  }

  void _deleteFile(THXTherionImageInsertConfig image) {
    widget.th2FileEditController.elementEditController.removeImage(image.mpID);
    setState(_refreshImages);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLoc = mpLocator.appLocalizations;

    return MPOverlayWindowWidget(
      title: appLoc.mpCommandDescriptionAddXTherionImageInsertConfig,
      overlayWindowType: MPOverlayWindowType.secondary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: widget.innerAnchorType,
      th2FileEditController: widget.th2FileEditController,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_images.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(appLoc.mpChoiceUnset),
              ),
            ..._images.map((img) {
              final bool loaded = _isImageLoaded(img);
              final String base = img.filename.isEmpty
                  ? appLoc.mpChoiceUnset
                  : p.basename(img.filename);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      loaded
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: loaded ? Colors.green : theme.disabledColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(base, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _pickFile(img),
                      child: Text(appLoc.mpButtonOK),
                    ),
                    const SizedBox(width: 4),
                    if (loaded)
                      OutlinedButton(
                        onPressed: () => _deleteFile(img),
                        child: Text(appLoc.mpButtonOK),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: mpButtonSpace * 2),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  widget.onPressedClose();
                },
                child: Text(appLoc.mpButtonOK),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
