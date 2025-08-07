import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPAvailableImagesWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;

  const MPAvailableImagesWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
  });

  @override
  State<MPAvailableImagesWidget> createState() =>
      _MPAvailableImagesWidgetState();
}

class _MPAvailableImagesWidgetState extends State<MPAvailableImagesWidget> {
  late final TH2FileEditController th2FileEditController;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
  }

  @override
  Widget build(BuildContext context) {
    final THFile thFile = th2FileEditController.thFile;
    final List<THXTherionImageInsertConfig> images =
        thFile.getImages().toList();

    return MPOverlayWindowWidget(
      title: mpLocator.appLocalizations.th2FileEditPageChangeImageTitle,
      overlayWindowType: MPOverlayWindowType.primary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: MPWidgetPositionType.centerRight,
      th2FileEditController: th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        Observer(
          builder: (_) {
            th2FileEditController.redrawTriggerImages;

            return MPOverlayWindowBlockWidget(
              overlayWindowBlockType: MPOverlayWindowBlockType.main,
              padding: mpOverlayWindowBlockEdgeInsets,
              children: [
                Builder(builder: (blockContext) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (images.isNotEmpty)
                        ...images.map((image) {
                          final bool isVisible = image.isVisible;

                          return Row(
                            children: [
                              Checkbox(
                                value: isVisible,
                                onChanged: (bool? value) {
                                  _imageVisibilityChanged(image.mpID, value);
                                },
                              ),
                              Expanded(
                                child: Text(image.filename),
                              ),
                            ],
                          );
                        }),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _onAddImage,
                        child: Text('Add image'),
                      ),
                    ],
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  void _imageVisibilityChanged(int imageMPID, bool? newVisibility) {
    th2FileEditController.selectionController.setImageVisibility(
      imageMPID,
      newVisibility ?? true,
    );
  }

  void _onAddImage() {
    // TODO: Implement image addition logic (e.g., open file picker, update model, etc.)
    // You can call a method on th2FileEditController or show a dialog as needed.
  }
}
