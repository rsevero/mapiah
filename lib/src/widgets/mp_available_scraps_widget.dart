// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPAvailableScrapsWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;

  const MPAvailableScrapsWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
  });

  @override
  State<MPAvailableScrapsWidget> createState() =>
      _MPAvailableScrapsWidgetState();
}

class _MPAvailableScrapsWidgetState extends State<MPAvailableScrapsWidget> {
  late final TH2FileEditController th2FileEditController;
  int? _draggedScrapMPID;
  int? _dragTargetScrapMPID;
  bool _isDragTargetAfterLast = false;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return MPOverlayWindowWidget(
      title: appLocalizations.th2FileEditPageChangeActiveScrapTitle,
      overlayWindowType: MPOverlayWindowType.primary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: MPWidgetPositionType.centerRight,
      th2FileEditController: th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        Observer(
          builder: (_) {
            final int activeScrapID = th2FileEditController.activeScrapID;
            final Map<int, String> scraps = th2FileEditController
                .availableScraps();
            final List<MapEntry<int, String>> scrapEntries = scraps.entries
                .toList();
            final bool showVisibilityCheckboxes = scraps.length > 1;
            final bool showDragHandles = scraps.length > 1;
            final int draggedScrapIndex = (_draggedScrapMPID == null)
                ? -1
                : scrapEntries.indexWhere(
                    (MapEntry<int, String> e) => e.key == _draggedScrapMPID,
                  );

            th2FileEditController.redrawTriggerNonSelectedElements;

            return MPOverlayWindowBlockWidget(
              overlayWindowBlockType: MPOverlayWindowBlockType.main,
              padding: mpOverlayWindowBlockEdgeInsets,
              children: [
                Builder(
                  builder: (blockContext) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showVisibilityCheckboxes)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Tooltip(
                              message: th2FileEditController.allScrapsVisible
                                  ? appLocalizations
                                        .th2FileEditPageToggleAllScrapsVisibilityHideOthersTooltip
                                  : appLocalizations
                                        .th2FileEditPageToggleAllScrapsVisibilityShowAllTooltip,
                              child: IconButton(
                                icon: Icon(
                                  th2FileEditController.allScrapsVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: colorScheme.onSecondary,
                                ),
                                iconSize: mpSmallIconSize,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _onPressedToggleAllScrapsVisibility,
                              ),
                            ),
                          ),
                        RadioGroup(
                          groupValue: activeScrapID,
                          onChanged: (int? value) {
                            if (value != null) {
                              _onTapSelectScrap(value);
                            }
                          },
                          child: Column(
                            children: [
                              ...scrapEntries.asMap().entries.map((
                                MapEntry<int, MapEntry<int, String>>
                                indexedEntry,
                              ) {
                                final int entryIndex = indexedEntry.key;
                                final MapEntry<int, String> entry =
                                    indexedEntry.value;
                                final int scrapID = entry.key;
                                final String scrapName = entry.value;
                                final bool isVisible = th2FileEditController
                                    .isScrapVisible(scrapID);
                                final bool isActiveScrap =
                                    scrapID == activeScrapID;
                                final bool isVisibilityCheckboxDisabled =
                                    isActiveScrap &&
                                    (th2FileEditController.visibleScrapCount <=
                                        1);
                                final bool isDragTarget =
                                    (_dragTargetScrapMPID == scrapID) &&
                                    (_draggedScrapMPID != scrapID) &&
                                    (entryIndex != draggedScrapIndex + 1);
                                final bool isDragged =
                                    _draggedScrapMPID == scrapID;

                                return DragTarget<int>(
                                  key: ValueKey(
                                    'MPAvailableScrapsWidget|ScrapRow|$scrapID',
                                  ),
                                  onWillAcceptWithDetails:
                                      (DragTargetDetails<int> details) {
                                        if (details.data == scrapID) {
                                          return false;
                                        }

                                        setState(() {
                                          _dragTargetScrapMPID = scrapID;
                                        });

                                        return true;
                                      },
                                  onLeave: (_) {
                                    if (_dragTargetScrapMPID == scrapID) {
                                      setState(() {
                                        _dragTargetScrapMPID = null;
                                      });
                                    }
                                  },
                                  onAcceptWithDetails:
                                      (DragTargetDetails<int> details) {
                                        _onAcceptReorderedScrap(
                                          draggedScrapMPID: details.data,
                                          targetScrapMPID: scrapID,
                                          scrapEntries: scrapEntries,
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
                                                  child: Builder(
                                                    builder: (listenerContext) {
                                                      return Listener(
                                                        onPointerDown: (PointerDownEvent event) {
                                                          if (event.kind ==
                                                                  PointerDeviceKind
                                                                      .mouse &&
                                                              event.buttons ==
                                                                  kSecondaryMouseButton) {
                                                            _onRightClickSelectScrap(
                                                              listenerContext,
                                                              scrapID,
                                                            );
                                                          }
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Expanded(
                                                              child: RadioListTile<int>(
                                                                key: ValueKey(
                                                                  "MPAvailableScrapsWidget|RadioListTile|$scrapID",
                                                                ),
                                                                title: Text(
                                                                  scrapName,
                                                                  style: DefaultTextStyle.of(
                                                                    blockContext,
                                                                  ).style,
                                                                ),
                                                                value: scrapID,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                activeColor:
                                                                    IconTheme.of(
                                                                      blockContext,
                                                                    ).color,
                                                                dense: true,
                                                                visualDensity:
                                                                    VisualDensity
                                                                        .adaptivePlatformDensity,
                                                              ),
                                                            ),
                                                            if (showVisibilityCheckboxes)
                                                              Tooltip(
                                                                message:
                                                                    appLocalizations
                                                                        .th2FileEditPageToggleScrapVisibilityTooltip,
                                                                child: Checkbox(
                                                                  key: ValueKey(
                                                                    "MPAvailableScrapsWidget|VisibilityCheckbox|$scrapID",
                                                                  ),
                                                                  value:
                                                                      isVisible,
                                                                  onChanged:
                                                                      isVisibilityCheckboxDisabled
                                                                      ? null
                                                                      : (
                                                                          _,
                                                                        ) => _onToggleScrapVisibility(
                                                                          scrapID,
                                                                        ),
                                                                  visualDensity:
                                                                      VisualDensity
                                                                          .adaptivePlatformDensity,
                                                                ),
                                                              ),
                                                            const SizedBox(
                                                              width:
                                                                  mpButtonSpace,
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .copy_outlined,
                                                                color: colorScheme
                                                                    .onSecondary,
                                                              ),
                                                              tooltip:
                                                                  appLocalizations
                                                                      .th2FileEditPageCopyScrapButton,
                                                              iconSize:
                                                                  mpSmallIconSize,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        mpButtonSpace,
                                                                  ),
                                                              constraints:
                                                                  const BoxConstraints(),
                                                              onPressed: () =>
                                                                  _onPressedCopyScrap(
                                                                    scrapID,
                                                                  ),
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .content_cut,
                                                                color: colorScheme
                                                                    .onSecondary,
                                                              ),
                                                              tooltip:
                                                                  appLocalizations
                                                                      .th2FileEditPageCutScrapButton,
                                                              iconSize:
                                                                  mpSmallIconSize,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        mpButtonSpace,
                                                                  ),
                                                              constraints:
                                                                  const BoxConstraints(),
                                                              onPressed: () =>
                                                                  _onPressedCutScrap(
                                                                    scrapID,
                                                                  ),
                                                            ),
                                                            IconButton(
                                                              icon: Transform.translate(
                                                                offset: const Offset(
                                                                  0,
                                                                  mpFinePixelAdjustment,
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .file_copy_outlined,
                                                                  color: colorScheme
                                                                      .onSecondary,
                                                                ),
                                                              ),
                                                              tooltip:
                                                                  appLocalizations
                                                                      .th2FileEditPageDuplicateScrapButton,
                                                              iconSize:
                                                                  mpSmallIconSize,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        mpButtonSpace,
                                                                  ),
                                                              constraints:
                                                                  const BoxConstraints(),
                                                              onPressed: () =>
                                                                  _onPressedDuplicateScrap(
                                                                    scrapID,
                                                                  ),
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .delete_outline_rounded,
                                                                color: colorScheme
                                                                    .onSecondary,
                                                              ),
                                                              tooltip:
                                                                  appLocalizations
                                                                      .th2FileEditPageRemoveScrapButton,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        mpButtonSpace,
                                                                  ),
                                                              constraints:
                                                                  const BoxConstraints(),
                                                              onPressed: () =>
                                                                  _onPressedRemoveScrap(
                                                                    scrapID,
                                                                  ),
                                                            ),
                                                            if (showDragHandles)
                                                              Draggable<int>(
                                                                data: scrapID,
                                                                dragAnchorStrategy:
                                                                    pointerDragAnchorStrategy,
                                                                onDragStarted: () {
                                                                  setState(() {
                                                                    _draggedScrapMPID =
                                                                        scrapID;
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
                                                                            Text(
                                                                              scrapName,
                                                                              style: DefaultTextStyle.of(
                                                                                blockContext,
                                                                              ).style,
                                                                            ),
                                                                            Icon(
                                                                              Icons.drag_indicator,
                                                                              color: colorScheme.onSecondary,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                childWhenDragging: Padding(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        mpButtonSpace,
                                                                  ),
                                                                  child: Icon(
                                                                    Icons
                                                                        .drag_indicator,
                                                                    color: colorScheme
                                                                        .onSecondary,
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        mpButtonSpace,
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
                                                              ),
                                                          ],
                                                        ),
                                                      );
                                                    },
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
                              if (showDragHandles)
                                DragTarget<int>(
                                  key: const ValueKey(
                                    'MPAvailableScrapsWidget|TrailingDropZone',
                                  ),
                                  onWillAcceptWithDetails:
                                      (DragTargetDetails<int> details) {
                                        final int lastScrapMPID =
                                            scrapEntries.last.key;

                                        if (details.data == lastScrapMPID) {
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
                                        _onAcceptReorderedScrapAtEnd(
                                          draggedScrapMPID: details.data,
                                          scrapEntries: scrapEntries,
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
                        ),
                        const SizedBox(height: mpButtonSpace),
                        ElevatedButton(
                          onPressed: () => _onPressedAddScrap(context),
                          child: Text(
                            appLocalizations.th2FileEditPageAddScrapButton,
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

  void _onTapSelectScrap(int scrapID) {
    th2FileEditController.setActiveScrap(scrapID);
  }

  void _onRightClickSelectScrap(BuildContext childContext, int scrapID) {
    th2FileEditController.selectionController.setSelectedScrapByMPID(scrapID);

    Rect? thisBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: context,
      ancestorGlobalKey: th2FileEditController.getTH2FileWidgetGlobalKey(),
    );

    Rect? childBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: childContext,
      ancestorGlobalKey: th2FileEditController.getTH2FileWidgetGlobalKey(),
    );

    /// Use the left of this widget and the vertical center of the child (taped
    /// option) widget as the outer anchor position for the option edit window.
    final Offset anchorPosition =
        (thisBoundingBox == null) || (childBoundingBox == null)
        ? th2FileEditController.screenBoundingBox.center
        : Offset(thisBoundingBox.left, childBoundingBox.center.dy);

    th2FileEditController.overlayWindowController
        .perfomToggleScrapOptionsOverlayWindow(
          scrapMPID: scrapID,
          outerAnchorPosition: anchorPosition,
        );
  }

  void _onPressedAddScrap(BuildContext context) {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.addScrap,
    );
  }

  void _onPressedCopyScrap(int scrapID) {
    th2FileEditController.copyPasteController.copyScrap(scrapID);
  }

  void _onPressedCutScrap(int scrapID) {
    th2FileEditController.copyPasteController.cutScrap(scrapID);
  }

  void _onPressedDuplicateScrap(int scrapID) {
    th2FileEditController.copyPasteController.duplicateScrap(scrapID);
  }

  void _onPressedRemoveScrap(int scrapID) {
    th2FileEditController.elementEditController.removeScrap(scrapID);
  }

  void _onPressedToggleAllScrapsVisibility() {
    th2FileEditController.toggleAllScrapsVisibility();
  }

  void _onToggleScrapVisibility(int scrapID) {
    th2FileEditController.toggleScrapVisibility(scrapID);
  }

  void _onAcceptReorderedScrap({
    required int draggedScrapMPID,
    required int targetScrapMPID,
    required List<MapEntry<int, String>> scrapEntries,
  }) {
    final int oldIndex = scrapEntries.indexWhere(
      (MapEntry<int, String> entry) => entry.key == draggedScrapMPID,
    );
    int newIndex = scrapEntries.indexWhere(
      (MapEntry<int, String> entry) => entry.key == targetScrapMPID,
    );

    // When dragging downward the removeAt shifts later indices by -1, so the
    // item would land one position below the visual indicator without this fix.
    if (oldIndex < newIndex) {
      newIndex--;
    }

    // Clear drag state BEFORE the MobX action so the Observer sees null values
    // when it rebuilds in response to the reorder — preventing the row from
    // staying hidden after the drag completes.
    _draggedScrapMPID = null;
    _dragTargetScrapMPID = null;
    _isDragTargetAfterLast = false;

    if ((oldIndex < 0) || (newIndex < 0) || (oldIndex == newIndex)) {
      if (mounted) {
        setState(() {});
      }

      return;
    }

    th2FileEditController.elementEditController.reorderScraps(
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  void _onAcceptReorderedScrapAtEnd({
    required int draggedScrapMPID,
    required List<MapEntry<int, String>> scrapEntries,
  }) {
    final int oldIndex = scrapEntries.indexWhere(
      (MapEntry<int, String> entry) => entry.key == draggedScrapMPID,
    );
    final int newIndex = scrapEntries.length - 1;

    // Clear drag state BEFORE the MobX action (same timing fix as above).
    _draggedScrapMPID = null;
    _dragTargetScrapMPID = null;
    _isDragTargetAfterLast = false;

    if ((oldIndex < 0) || (oldIndex == newIndex)) {
      if (mounted) {
        setState(() {});
      }

      return;
    }

    th2FileEditController.elementEditController.reorderScraps(
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  void _clearDragState() {
    if (!mounted) {
      return;
    }

    setState(() {
      _draggedScrapMPID = null;
      _dragTargetScrapMPID = null;
      _isDragTargetAfterLast = false;
    });
  }
}
