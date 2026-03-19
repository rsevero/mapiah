// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
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
  int? _draggedImageMPID;
  int? _dragTargetImageMPID;
  bool _isDragTargetAfterLast = false;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
  }

  @override
  Widget build(BuildContext context) {
    final TH2File th2File = th2FileEditController.th2File;
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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

            final List<THXTherionImageInsertConfig> images = th2File
                .getImages()
                .toList();

            final bool allImagesVisible = images.every(
              (THXTherionImageInsertConfig image) => image.isVisible,
            );
            final int draggedImageIndex = (_draggedImageMPID == null)
                ? -1
                : images.indexWhere(
                    (THXTherionImageInsertConfig img) =>
                        img.mpID == _draggedImageMPID,
                  );

            return MPOverlayWindowBlockWidget(
              overlayWindowBlockType: MPOverlayWindowBlockType.main,
              padding: mpOverlayWindowBlockEdgeInsets,
              children: [
                Builder(
                  builder: (blockContext) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (images.isNotEmpty)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Tooltip(
                              message: allImagesVisible
                                  ? appLocalizations
                                        .th2FileEditPageToggleAllImagesVisibilityHideAllTooltip
                                  : appLocalizations
                                        .th2FileEditPageToggleAllImagesVisibilityShowAllTooltip,
                              child: IconButton(
                                icon: Icon(
                                  allImagesVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: colorScheme.onSecondary,
                                ),
                                iconSize: mpSmallIconSize,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _onPressedToggleAllImagesVisibility,
                              ),
                            ),
                          ),
                        if (images.isNotEmpty)
                          Column(
                            children: [
                              ...images.asMap().entries.map((
                                MapEntry<int, THXTherionImageInsertConfig>
                                indexedEntry,
                              ) {
                                final int entryIndex = indexedEntry.key;
                                final THXTherionImageInsertConfig image =
                                    indexedEntry.value;
                                final bool isVisible = image.isVisible;
                                final String name = p.basename(image.filename);
                                final bool isDragTarget =
                                    (_dragTargetImageMPID == image.mpID) &&
                                    (_draggedImageMPID != image.mpID) &&
                                    (entryIndex != draggedImageIndex + 1);
                                final bool isDragged =
                                    _draggedImageMPID == image.mpID;

                                return DragTarget<int>(
                                  key: ValueKey(
                                    'MPAvailableImagesWidget|ImageRow|${image.mpID}',
                                  ),
                                  onWillAcceptWithDetails:
                                      (DragTargetDetails<int> details) {
                                        if (details.data == image.mpID) {
                                          return false;
                                        }

                                        setState(() {
                                          _dragTargetImageMPID = image.mpID;
                                        });

                                        return true;
                                      },
                                  onLeave: (_) {
                                    if (_dragTargetImageMPID == image.mpID) {
                                      setState(() {
                                        _dragTargetImageMPID = null;
                                      });
                                    }
                                  },
                                  onAcceptWithDetails:
                                      (DragTargetDetails<int> details) {
                                        _onAcceptReorderedImage(
                                          draggedImageMPID: details.data,
                                          targetImageMPID: image.mpID,
                                          images: images,
                                        );
                                      },
                                  builder:
                                      (
                                        BuildContext context,
                                        List<int?> candidateData,
                                        List<dynamic> rejectedData,
                                      ) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 150,
                                              ),
                                              height: isDragTarget
                                                  ? mpDragDropIndicatorHeight
                                                  : 0.0,
                                              decoration: BoxDecoration(
                                                color: colorScheme.secondary,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      mpDragDropIndicatorHeight /
                                                          2,
                                                    ),
                                              ),
                                            ),
                                            Stack(
                                              children: [
                                                Visibility(
                                                  visible: !isDragged,
                                                  maintainSize: true,
                                                  maintainAnimation: true,
                                                  maintainState: true,
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                        value: isVisible,
                                                        onChanged: (bool? value) {
                                                          if (value == null) {
                                                            return;
                                                          }
                                                          _imageVisibilityChanged(
                                                            image.mpID,
                                                            value,
                                                          );
                                                        },
                                                        checkColor: colorScheme
                                                            .onSurface,
                                                        side: BorderSide(
                                                          color: colorScheme
                                                              .onSurface,
                                                          width: 2,
                                                        ),
                                                        fillColor:
                                                            WidgetStateProperty.all(
                                                              colorScheme
                                                                  .surfaceContainerHighest,
                                                            ),
                                                      ),
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () =>
                                                              _imageVisibilityChanged(
                                                                image.mpID,
                                                                !isVisible,
                                                              ),
                                                          child: Text(name),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons
                                                              .delete_outline_rounded,
                                                          color: colorScheme
                                                              .onSecondary,
                                                        ),
                                                        tooltip: appLocalizations
                                                            .th2FileEditPageRemoveImageButton,
                                                        onPressed: () =>
                                                            _onPressedRemoveImage(
                                                              image.mpID,
                                                            ),
                                                      ),
                                                      Draggable<int>(
                                                        data: image.mpID,
                                                        dragAnchorStrategy:
                                                            pointerDragAnchorStrategy,
                                                        onDragStarted: () {
                                                          setState(() {
                                                            _draggedImageMPID =
                                                                image.mpID;
                                                          });
                                                        },
                                                        onDragEnd: (_) {
                                                          _clearDragState();
                                                        },
                                                        onDraggableCanceled:
                                                            (_, _) {
                                                              _clearDragState();
                                                            },
                                                        feedback: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: Opacity(
                                                            opacity:
                                                                mpDragFeedbackOpacity,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                color: colorScheme
                                                                    .surfaceContainerHighest,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      mpDefaultButtonRadius,
                                                                    ),
                                                              ),
                                                              child: IntrinsicWidth(
                                                                child: Row(
                                                                  children: [
                                                                    Checkbox(
                                                                      value:
                                                                          isVisible,
                                                                      onChanged:
                                                                          null,
                                                                      checkColor:
                                                                          colorScheme
                                                                              .onSurface,
                                                                      side: BorderSide(
                                                                        color: colorScheme
                                                                            .onSurface,
                                                                        width:
                                                                            2,
                                                                      ),
                                                                      fillColor: WidgetStateProperty.all(
                                                                        colorScheme
                                                                            .surfaceContainerHighest,
                                                                      ),
                                                                    ),
                                                                    Text(name),
                                                                    IconButton(
                                                                      icon: Icon(
                                                                        Icons
                                                                            .delete_outline_rounded,
                                                                        color: colorScheme
                                                                            .onSecondary,
                                                                      ),
                                                                      onPressed:
                                                                          null,
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .drag_indicator,
                                                                      color: colorScheme
                                                                          .onSecondary,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        childWhenDragging: Icon(
                                                          Icons.drag_indicator,
                                                          color: colorScheme
                                                              .onSecondary,
                                                        ),
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .grab,
                                                          child: Icon(
                                                            Icons
                                                                .drag_indicator,
                                                            color: colorScheme
                                                                .onSecondary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (isDragged)
                                                  Positioned.fill(
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: colorScheme
                                                            .secondary,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              mpDragDropIndicatorHeight /
                                                                  2,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                );
                              }),
                              DragTarget<int>(
                                key: const ValueKey(
                                  'MPAvailableImagesWidget|TrailingDropZone',
                                ),
                                onWillAcceptWithDetails:
                                    (DragTargetDetails<int> details) {
                                      final int lastImageMPID =
                                          images.last.mpID;

                                      if (details.data == lastImageMPID) {
                                        return false;
                                      }

                                      setState(() {
                                        _isDragTargetAfterLast = true;
                                      });

                                      return true;
                                    },
                                onLeave: (_) {
                                  setState(() {
                                    _isDragTargetAfterLast = false;
                                  });
                                },
                                onAcceptWithDetails:
                                    (DragTargetDetails<int> details) {
                                      _onAcceptReorderedImageAtEnd(
                                        draggedImageMPID: details.data,
                                        images: images,
                                      );
                                    },
                                builder:
                                    (
                                      BuildContext context,
                                      List<int?> candidateData,
                                      List<dynamic> rejectedData,
                                    ) {
                                      // Always render at full height so the
                                      // DragTarget has a hit area; toggle
                                      // color instead of height.
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        height: mpDragDropIndicatorHeight,
                                        decoration: BoxDecoration(
                                          color: _isDragTargetAfterLast
                                              ? colorScheme.secondary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            mpDragDropIndicatorHeight / 2,
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ],
                          ),
                        const SizedBox(height: mpButtonSpace),
                        ElevatedButton(
                          onPressed: () => _onPressedAddImage(context),
                          child: Text(
                            appLocalizations.th2FileEditPageAddImageButton,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _onPressedToggleAllImagesVisibility() {
    th2FileEditController.selectionController.toggleAllImagesVisibility();
  }

  void _imageVisibilityChanged(int imageMPID, bool newVisibility) {
    th2FileEditController.selectionController.setImageVisibility(
      imageMPID,
      newVisibility,
    );
  }

  void _onPressedAddImage(BuildContext context) {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.addImage,
    );
  }

  void _onPressedRemoveImage(int imageMPID) {
    th2FileEditController.elementEditController.removeImage(imageMPID);
  }

  void _onAcceptReorderedImage({
    required int draggedImageMPID,
    required int targetImageMPID,
    required List<THXTherionImageInsertConfig> images,
  }) {
    final int oldIndex = images.indexWhere(
      (THXTherionImageInsertConfig image) => image.mpID == draggedImageMPID,
    );
    int newIndex = images.indexWhere(
      (THXTherionImageInsertConfig image) => image.mpID == targetImageMPID,
    );

    // When dragging downward the removeAt shifts later indices by -1, so the
    // item would land one position below the visual indicator without this fix.
    if (oldIndex < newIndex) {
      newIndex--;
    }

    _clearDragState();

    if ((oldIndex < 0) || (newIndex < 0) || (oldIndex == newIndex)) {
      return;
    }

    th2FileEditController.elementEditController.reorderImages(
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  void _onAcceptReorderedImageAtEnd({
    required int draggedImageMPID,
    required List<THXTherionImageInsertConfig> images,
  }) {
    final int oldIndex = images.indexWhere(
      (THXTherionImageInsertConfig image) => image.mpID == draggedImageMPID,
    );
    final int newIndex = images.length - 1;

    _clearDragState();

    if ((oldIndex < 0) || (oldIndex == newIndex)) {
      return;
    }

    th2FileEditController.elementEditController.reorderImages(
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  void _clearDragState() {
    if (!mounted) {
      return;
    }

    setState(() {
      _draggedImageMPID = null;
      _dragTargetImageMPID = null;
      _isDragTargetAfterLast = false;
    });
  }
}
