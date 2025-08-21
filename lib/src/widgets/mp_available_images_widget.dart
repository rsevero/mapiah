import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';
import 'package:path/path.dart' as p;

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
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return MPOverlayWindowWidget(
      title: appLocalizations.th2FileEditPageChangeImageTitle,
      overlayWindowType: MPOverlayWindowType.primary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: MPWidgetPositionType.centerRight,
      th2FileEditController: th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        Observer(
          builder: (_) {
            th2FileEditController.redrawTriggerImages;

            final Iterable<THXTherionImageInsertConfig> images =
                thFile.getImages();

            return MPOverlayWindowBlockWidget(
              overlayWindowBlockType: MPOverlayWindowBlockType.main,
              padding: mpOverlayWindowBlockEdgeInsets,
              children: [
                Builder(builder: (blockContext) {
                  final ColorScheme colorScheme = Theme.of(context).colorScheme;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (images.isNotEmpty)
                        ...images.map((image) {
                          final bool isVisible = image.isVisible;
                          final String name = p.basename(image.filename);

                          return Row(
                            children: [
                              Checkbox(
                                value: isVisible,
                                onChanged: (bool? value) {
                                  _imageVisibilityChanged(image.mpID, value);
                                },
                                checkColor: colorScheme.onSurface,
                                side: BorderSide(
                                  color: colorScheme.onSurface,
                                  width: 2,
                                ),
                                fillColor: WidgetStateProperty.all(
                                  colorScheme.surfaceContainerHighest,
                                ),
                              ),
                              Expanded(
                                child: Text(name),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: colorScheme.onSecondary,
                                ),
                                tooltip: appLocalizations
                                    .th2FileEditPageRemoveImageButton,
                                onPressed: () =>
                                    _onPressedRemoveImage(image.mpID),
                              ),
                            ],
                          );
                        }),
                      const SizedBox(height: mpButtonSpace),
                      ElevatedButton(
                        onPressed: () => _onPressedAddImage(context),
                        child: Text(
                          appLocalizations.th2FileEditPageAddImageButton,
                        ),
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

  void _onPressedAddImage(BuildContext context) {
    th2FileEditController.elementEditController.addImage();
  }

  void _onPressedRemoveImage(int imageMPID) {
    th2FileEditController.elementEditController.removeImage(imageMPID);
  }
}
