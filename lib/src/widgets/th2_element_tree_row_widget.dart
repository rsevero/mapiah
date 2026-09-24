// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/th2_element_tree_aux.dart';
import 'package:mapiah/src/widgets/th2_element_tree_drag_controller.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/auxiliary/th2_hierarchy_aux.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_visible_row.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/th_project_tree_row_context_menu_widget.dart';
import 'package:material_ui/material_ui.dart';

/// Detects a second tap on the same TH2 element row, so a single tap acts
/// at once and a double tap only adds its extra steps.
class TH2ElementTreeTapTracker {
  /// Clock used to time taps. Tests may replace it.
  DateTime Function() now = DateTime.now;

  String? _rowId;

  String? rangeAnchorRowId;

  DateTime? _time;

  Offset? _position;

  /// Records a tap on [rowId] at [position] and returns whether it completes
  /// a double tap. A completed double tap resets the tracker.
  bool registerTap({required String rowId, required Offset position}) {
    final DateTime tapTime = now();
    final DateTime? previousTime = _time;
    final Offset? previousPosition = _position;
    final bool isSecondTap =
        (_rowId == rowId) &&
        (previousTime != null) &&
        (previousPosition != null) &&
        (tapTime.difference(previousTime) < kDoubleTapTimeout) &&
        ((position - previousPosition).distance <= kDoubleTapSlop);

    if (isSecondTap) {
      reset();
    } else {
      _rowId = rowId;
      _time = tapTime;
      _position = position;
    }

    return isSecondTap;
  }

  void reset() {
    _rowId = null;
    _time = null;
    _position = null;
  }
}

/// The tap tracker shared by every TH2 element row of the project tree.
final TH2ElementTreeTapTracker th2ElementTreeTapTracker =
    TH2ElementTreeTapTracker();

/// A project-tree row for a TH2 scrap, point, line or area, or for the
/// loading, load-error or broken status of a `.th2` file.
class TH2ElementTreeRowWidget extends StatelessWidget {
  final THProjectTreeVisibleRow row;
  final TH2ElementTreeDragController? dragController;

  const TH2ElementTreeRowWidget({super.key, required this.row,
    this.dragController});

  @override
  Widget build(BuildContext context) {
    final THProjectTreeVisibleRow currentRow = row;

    return switch (currentRow) {
      TH2ElementTreeRow elementRow => _TH2ElementRow(row: elementRow,
        dragController: dragController),
      TH2FileStatusTreeRow statusRow => _TH2FileStatusRow(row: statusRow),
      THProjectTreeNodeRow _ => throw ArgumentError(
        'TH2ElementTreeRowWidget does not render project node rows.',
      ),
    };
  }
}

/// Resolves the registered controller of a loaded valid file, or `null`.
TH2FileEditController? _validControllerFor(String th2FilePath) {
  final TH2FileEditController? controller = mpLocator.mpGeneralController
      .getTH2FileEditControllerIfExists(th2FilePath);

  if ((controller == null) ||
      !controller.isFileLoaded ||
      controller.isBroken ||
      (controller.loadError != null)) {
    return null;
  }

  return controller;
}

class _TH2ElementRow extends StatelessWidget {
  final TH2ElementTreeRow row;
  final TH2ElementTreeDragController? dragController;

  const _TH2ElementRow({required this.row, this.dragController});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Widget shell = SizedBox(
      height: mpProjectTreeRowHeight,
      child: Row(
        children: <Widget>[
          SizedBox(width: row.depth * mpProjectTreeIndent),
          _buildExpandControl(colorScheme),
          ExcludeSemantics(child: _buildIcon()),
          const SizedBox(width: 4),
          Expanded(child: _buildLabel(colorScheme)),
          if (row.isScrap && !row.isExpanded)
            _buildContainsSelectionDot(context),
          const SizedBox(width: 4),
        ],
      ),
    );
    Offset tapPosition = Offset.zero;
    int? dragPointerId;

    return Observer(
      builder: (_) {
        final bool isHighlighted = _isHighlighted();

        final Widget content = Material(
          key: ValueKey('TH2ElementTreeRowWidget|${row.rowId}'),
          color: isHighlighted
              ? colorScheme.secondaryContainer
              : Colors.transparent,
          child: InkWell(
            onTapDown: (TapDownDetails details) {
              tapPosition = details.globalPosition;
            },
            onTap: () => _onTap(tapPosition),
            child: shell,
          ),
        );
        final Widget menu = THProjectTreeRowContextMenuWidget(
          key: ValueKey('THProjectTreeRowContextMenu|${row.rowId}'),
          rowId: row.rowId,
          onBeforeOpen: _onBeforeOpenMenu,
          menuChildrenBuilder: () => _menuItems(context),
          child: content,
        );
        if (dragController == null) return menu;
        final Widget target = TH2ElementTreeDropTarget(
          controller: dragController!, rowId: row.rowId,
          th2FilePath: row.th2FilePath,
          targetMPID: row.elementMPID,
          collapsedScrap: row.isScrap && !row.isExpanded,
          expanded: row.isExpanded, child: menu);
        if (mpLocator.thProjectTreeUIController.filterText.isNotEmpty) {
          return target;
        }
        final TH2ElementTreeDragPayload? payload = _dragPayload();
        if (payload == null) {
          return target;
        }
        return Listener(
          onPointerDown: (PointerDownEvent event) {
            dragPointerId = event.pointer;
          },
          child: Draggable<TH2ElementTreeDragPayload>(
          data: payload,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          onDragStarted: () => dragController!.start(payload,
            pointerId: dragPointerId),
          onDragEnd: (_) => dragController!.end(),
          onDraggableCanceled: (_, _) => dragController!.end(),
          onDragCompleted: () => dragController!.end(),
          feedback: Opacity(opacity: mpDragFeedbackOpacity,
            child: Material(color: colorScheme.surface,
              child: Padding(padding: const EdgeInsets.all(8),
                child: AnimatedBuilder(animation: dragController!,
                  builder: (BuildContext context, Widget? child) {
                    final MPHierarchyMoveCheck? check =
                        dragController!.hoverCheck;
                    final String? reason = check != null && !check.ok
                        ? TH2ElementTreeAux.moveRejectionMessage(check,
                            payload.controller.th2File,
                            AppLocalizations.of(context)) : null;
                    return Column(mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(row.label.plainText),
                        if (payload.elementMPIDs.length > 1)
                          Text(AppLocalizations.of(context)
                            .th2ElementTreeDragCount(payload.elementMPIDs.length)),
                        if (reason != null) Text(reason),
                      ]);
                  })))),
          childWhenDragging: Opacity(opacity: mpDragFeedbackOpacity,
            child: target),
          child: target));

      },
    );
  }

  TH2ElementTreeDragPayload? _dragPayload() {
    final TH2FileEditController? controller = _validControllerFor(
      row.th2FilePath);
    if (controller == null || controller.th2File.tryElementByMPID(
        row.elementMPID) == null) {
      return null;
    }
    final List<int> ids;
    if (row.isScrap) {
      final List<int> selected = controller.selectionController
          .selectedScrapMPIDsInFileOrder;
      ids = selected.contains(row.elementMPID) ? selected
          : <int>[row.elementMPID];
    } else {
      final THElement element = controller.th2File.elementByMPID(
        row.elementMPID);
      final THScrap scrap = controller.th2File.scrapByMPID(
        element.parentMPID);
      final Set<int> selected = controller.selectionController
          .mpSelectedElementsLogical.keys.toSet();
      ids = selected.contains(row.elementMPID)
          ? <int>[
              ...controller.th2File.childrenMPIDs.where(selected.contains),
              ...scrap.childrenMPIDs.where(selected.contains),
            ]
          : <int>[row.elementMPID];
    }
    return TH2ElementTreeDragPayload(th2FilePath: row.th2FilePath,
      controller: controller, elementMPIDs: ids, isScrap: row.isScrap);
  }

  /// Selected element rows and the active scrap row are highlighted.
  bool _isHighlighted() {
    final TH2FileEditController? controller = _validControllerFor(
      row.th2FilePath,
    );

    if (controller == null) {
      return false;
    }

    if (row.isScrap) {
      final Set<int> scraps = controller.selectionController.selectedScrapMPIDs;
      return scraps.isEmpty ? controller.activeScrapID == row.elementMPID
          : scraps.contains(row.elementMPID);
    }

    return controller.selectionController.mpSelectedElementsLogical
        .containsKey(row.elementMPID);
  }

  Widget _buildExpandControl(ColorScheme colorScheme) {
    if (!row.isExpandable) {
      return const SizedBox(width: mpSmallIconSize);
    }

    return GestureDetector(
      key: ValueKey('TH2ElementTreeScrapChevron|${row.rowId}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        mpLocator.thProjectTreeUIController.toggleTH2ScrapCollapsed(row.rowId);
      },
      child: SizedBox(
        width: mpSmallIconSize,
        height: mpProjectTreeRowHeight,
        child: Icon(
          row.isExpanded ? Icons.expand_more : Icons.chevron_right,
          size: mpSmallIconSize,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final String? imagePath = switch (row.elementType) {
      THElementType.point => mpAddPointButtonImagePath,
      THElementType.line => mpAddLineButtonImagePath,
      THElementType.area => mpAddAreaButtonImagePath,
      _ => null,
    };

    if (imagePath == null) {
      return const Icon(Icons.map_outlined, size: mpSmallIconSize);
    }

    return Image.asset(
      imagePath,
      width: mpSmallIconSize,
      height: mpSmallIconSize,
    );
  }

  Widget _buildLabel(ColorScheme colorScheme) {
    final String? thID = row.label.thID;
    final bool hasTHID = (thID != null) && thID.isNotEmpty;
    final String? detail = row.label.detail;
    final bool hasDetail = (detail != null) && detail.isNotEmpty;
    final bool hasPrimaryText = row.label.primaryText.isNotEmpty;
    final String? tooltipText = row.label.tooltipText;

    final Widget label = Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: row.label.primaryText),
          if (hasDetail)
            TextSpan(
              text: hasPrimaryText ? ' $detail' : detail,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          if (hasTHID)
            TextSpan(
              text: (hasPrimaryText || hasDetail) ? ' $thID' : thID,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
      style: row.isScrap && _validControllerFor(row.th2FilePath)?.activeScrapID ==
          row.elementMPID ? const TextStyle(fontWeight: FontWeight.bold) : null,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: row.label.plainText,
    );

    if (tooltipText == null) {
      return label;
    }

    return Tooltip(
      key: ValueKey('TH2ElementTreeLabelTooltip|${row.rowId}'),
      message: tooltipText,
      excludeFromSemantics: true,
      // Hover only: the default long-press trigger would take a held press
      // away from the row's drag.
      triggerMode: TooltipTriggerMode.manual,
      child: label,
    );
  }

  /// The dot a collapsed scrap shows while one of its children is selected.
  Widget _buildContainsSelectionDot(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String message = AppLocalizations.of(
      context,
    ).th2ElementTreeScrapContainsSelection;

    return Observer(
      builder: (_) {
        if (!_scrapContainsSelection()) {
          return const SizedBox.shrink();
        }

        return Tooltip(
          key: ValueKey('TH2ElementTreeScrapContainsSelectionDot|${row.rowId}'),
          message: message,
          child: Semantics(
            label: message,
            child: Container(
              width: mpProjectTreeStatusDotSize,
              height: mpProjectTreeStatusDotSize,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Whether any selected element of the file is a child of this scrap.
  bool _scrapContainsSelection() {
    final TH2FileEditController? controller = _validControllerFor(
      row.th2FilePath,
    );

    if (controller == null) {
      return false;
    }

    for (final int selectedMPID
        in controller.selectionController.mpSelectedElementsLogical.keys) {
      final THElement? element = controller.th2File.tryElementByMPID(
        selectedMPID,
      );

      if ((element != null) && (element.parentMPID == row.elementMPID)) {
        return true;
      }
    }

    return false;
  }

  void _bringOpenTabToFront() {
    final MPGeneralController general = mpLocator.mpGeneralController;
    if (general.openFileOrder.contains(row.th2FilePath)) {
      general.addFileTab(row.th2FilePath);
    }
  }

  void _leaveCreationMode(TH2FileEditController controller) {
    final TH2FileEditSelectionController selection =
        controller.selectionController;
    final List<int> strayScraps = selection.mpSelectedElementsLogical.entries
        .where((entry) => entry.value is MPSelectedScrap)
        .map((entry) => entry.key).toList();
    if (strayScraps.isNotEmpty) {
      selection.removeSelectedElementsByMPIDs(strayScraps);
    }
    controller.stateController.onButtonPressed(MPButtonType.select);
  }

  void _onTap(Offset tapPosition) {
    final TH2FileEditController? controller = _validControllerFor(
      row.th2FilePath);
    if (controller == null) return;
    final bool ctrl = MPInteractionAux.isCtrlPressed() ||
        MPInteractionAux.isMetaPressed();
    final bool shift = MPInteractionAux.isShiftPressed();
    if (row.isScrap) {
      _leaveCreationMode(controller);
      if (ctrl) {
        if (controller.selectionController.mpSelectedElementsLogical.isNotEmpty) {
          controller.selectionController.setSelectedElements(
            <THElement>[], setState: true);
        }
        controller.selectionController.toggleSelectedScrap(row.elementMPID);
      } else {
        controller.selectionController.clearSelectedScraps();
        controller.setActiveScrap(row.elementMPID);
      }
      _bringOpenTabToFront();
      return;
    }
    final THElement? element = controller.th2File.tryElementByMPID(
      row.elementMPID);
    if (element == null) return;
    if (ctrl || shift) {
      bool replaceRangeAnchor = ctrl;
      th2ElementTreeTapTracker.reset();
      _leaveCreationMode(controller);
      if (controller.activeScrapID != element.parentMPID) {
        replaceRangeAnchor = true;
        _applySingleTap(controller: controller, element: element);
      } else if (ctrl) {
        final TH2FileEditSelectionController selection =
            controller.selectionController;
        if (selection.mpSelectedElementsLogical.containsKey(element.mpID)) {
          selection.removeSelectedElementsByMPIDs(<int>[element.mpID]);
          selection.setSelectionState();
        } else {
          selection.addSelectedElement(element, setState: true);
        }
      } else {
        final String? anchorId = th2ElementTreeTapTracker.rangeAnchorRowId;
        final THScrap scrap = controller.th2File.scrapByMPID(element.parentMPID);
        final List<int> visible = scrap.childrenMPIDs.where((int id) {
          final THElement child = controller.th2File.elementByMPID(id);
          return child is THPoint || child is THLine || child is THArea;
        }).toList();
        final int anchorIndex = visible.indexWhere((int id) =>
          th2ElementTreeRowId(th2FilePath: row.th2FilePath,
            elementMPID: id) == anchorId);
        final int end = visible.indexOf(element.mpID);
        if (anchorIndex < 0 || end < 0) {
          replaceRangeAnchor = true;
          _applySingleTap(controller: controller, element: element);
        } else {
          final int start = anchorIndex < end ? anchorIndex : end;
          final int stop = anchorIndex > end ? anchorIndex : end;
          for (final int id in visible.sublist(start, stop + 1)) {
            if (!controller.selectionController.mpSelectedElementsLogical
                .containsKey(id)) {
              controller.selectionController.addSelectedElement(
                controller.th2File.elementByMPID(id));
            }
          }
          controller.selectionController.setSelectionState();
        }
      }
      if (replaceRangeAnchor) {
        th2ElementTreeTapTracker.rangeAnchorRowId = row.rowId;
      }
      _bringOpenTabToFront();
      return;
    }
    final bool isSecondTap = th2ElementTreeTapTracker.registerTap(
      rowId: row.rowId, position: tapPosition);
    th2ElementTreeTapTracker.rangeAnchorRowId = row.rowId;
    if (isSecondTap) {
      _applyDoubleTapExtras(controller);
    } else {
      _leaveCreationMode(controller);
      _applySingleTap(controller: controller, element: element);
    }
  }

  /// Does what the Select tool plus a click on the element does, and brings
  /// an open file's tab to the front. A tab-less file stays tab-less.
  void _applySingleTap({
    required TH2FileEditController controller,
    required THElement element,
  }) {
    final MPGeneralController generalController =
        mpLocator.mpGeneralController;

    controller.setActiveScrapByChildElement(element);
    controller.selectionController.setSelectedElements(<THElement>[
      element,
    ], setState: true);

    if (generalController.openFileOrder.contains(row.th2FilePath)) {
      generalController.addFileTab(row.th2FilePath);
    }
  }

  /// Opens a tab-less file's tab and zooms to the selection.
  void _applyDoubleTapExtras(TH2FileEditController controller) {
    final MPGeneralController generalController =
        mpLocator.mpGeneralController;

    if (!generalController.openFileOrder.contains(row.th2FilePath)) {
      generalController.addFileTab(row.th2FilePath);
    }

    controller.requestZoomToFit(MPZoomToFitType.selection);
  }

  void _onBeforeOpenMenu() {
    final TH2FileEditController? controller = _validControllerFor(row.th2FilePath);
    if (controller == null) return;
    _leaveCreationMode(controller);
    if (!row.isScrap) {
      final THElement? element = controller.th2File.tryElementByMPID(
        row.elementMPID);
      if (element == null) return;
      if (!controller.selectionController.mpSelectedElementsLogical
          .containsKey(row.elementMPID)) {
        controller.setActiveScrapByChildElement(element);
        controller.selectionController.setSelectedElements(
          <THElement>[element], setState: true);
      }
    }
  }

  List<int> _menuSelection(TH2FileEditController controller) {
    if (row.isScrap) {
      final List<int> selected = controller.selectionController
          .selectedScrapMPIDsInFileOrder;
      return selected.contains(row.elementMPID) ? selected
          : <int>[row.elementMPID];
    }
    final THElement? element = controller.th2File.tryElementByMPID(
      row.elementMPID);
    if (element == null) return const <int>[];
    final Set<int> selected = controller.selectionController
        .mpSelectedElementsLogical.keys.toSet();
    if (!selected.contains(row.elementMPID)) return <int>[row.elementMPID];
    final THScrap scrap = controller.th2File.scrapByMPID(element.parentMPID);
    return scrap.childrenMPIDs.where(selected.contains).toList();
  }

  List<Widget> _menuItems(BuildContext context) {
    final TH2FileEditController? controller = _validControllerFor(
      row.th2FilePath);
    if (controller == null || controller.th2File.tryElementByMPID(
        row.elementMPID) == null) {
      return const <Widget>[];
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<int> ids = _menuSelection(controller);
    if (ids.isEmpty) {
      return const <Widget>[];
    }
    final List<Widget> items = <Widget>[];
    for (final MPDrawingOrderAction action in MPDrawingOrderAction.values) {
      final MPMoveElementsPreview preview = controller.elementEditController
          .previewDrawingOrderAction(action, elementMPIDs: ids);
      final String title = switch (action) {
        MPDrawingOrderAction.bringForward => l10n.th2ElementTreeBringForward,
        MPDrawingOrderAction.sendBackward => l10n.th2ElementTreeSendBackward,
        MPDrawingOrderAction.bringToFront => l10n.th2ElementTreeBringToFront,
        MPDrawingOrderAction.sendToBack => l10n.th2ElementTreeSendToBack,
      };
      items.add(MenuItemButton(
        key: ValueKey('THProjectTreeRowContextMenu${action.name[0].toUpperCase()}${action.name.substring(1)}|${row.rowId}'),
        onPressed: preview.noOp || preview.rejection != null
            ? null : () => _executeOrder(action),
        leadingIcon: Icon(switch (action) {
          MPDrawingOrderAction.bringForward => Icons.arrow_downward,
          MPDrawingOrderAction.sendBackward => Icons.arrow_upward,
          MPDrawingOrderAction.bringToFront => Icons.flip_to_front,
          MPDrawingOrderAction.sendToBack => Icons.flip_to_back,
        }),
        child: preview.rejection == null ? Text(title)
          : Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title),
                Text(l10n.th2MoveRejectedGeneric,
                  style: Theme.of(context).textTheme.bodySmall),
              ])));
    }
    if (!row.isScrap) {
      final THElement element = controller.th2File.elementByMPID(
        row.elementMPID);
      final List<Widget> targets = <Widget>[];
      for (final int scrapID in controller.th2File.childrenMPIDs) {
        final THElement target = controller.th2File.elementByMPID(scrapID);
        if (target is! THScrap || scrapID == element.parentMPID) {
          continue;
        }
        final MPHierarchyMoveCheck check = controller.elementEditController
            .checkMoveElements(elementMPIDs: ids,
              newParentMPID: scrapID);
        targets.add(MenuItemButton(
          key: ValueKey('THProjectTreeRowContextMenuMoveToScrap|${row.rowId}|$scrapID'),
          onPressed: check.ok ? () => _executeMoveToScrap(scrapID) : null,
          child: check.ok ? Text(TH2ElementTreeAux.buildLabel(target).plainText)
            : Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(TH2ElementTreeAux.buildLabel(target).plainText),
                  Text(TH2ElementTreeAux.moveRejectionMessage(check,
                    controller.th2File, l10n),
                    style: Theme.of(context).textTheme.bodySmall),
                ])));
      }
      if (targets.isNotEmpty) {
        items.add(const Divider());
        items.add(SubmenuButton(
          key: ValueKey('THProjectTreeRowContextMenuMoveToScrap|${row.rowId}'),
          menuChildren: targets,
          leadingIcon: const Icon(Icons.drive_file_move_outline),
          child: Text(l10n.th2ElementTreeMoveToScrap)));
      }
    }
    return items;
  }

  void _selectMovedDrawables(TH2FileEditController controller,
      List<int> ids, int parentMPID) {
    if (row.isScrap) return;
    controller.setActiveScrap(parentMPID);
    controller.selectionController.setSelectedElements(
      ids.map(controller.th2File.elementByMPID).toList(), setState: true);
  }

  void _executeOrder(MPDrawingOrderAction action) {
    final TH2FileEditController? controller = mpLocator.mpGeneralController
        .prepareTH2FileForTreeEdit(row.th2FilePath);
    if (controller == null || controller.th2File.tryElementByMPID(
        row.elementMPID) == null) {
      return;
    }
    final List<int> ids = _menuSelection(controller);
    if (ids.isEmpty) return;
    final THElement element = controller.th2File.elementByMPID(ids.first);
    final int parentMPID = row.isScrap ? controller.th2File.mpID
        : element.parentMPID;
    final MPMoveElementsResult result = switch (action) {
      MPDrawingOrderAction.bringForward => controller.elementEditController
          .bringForward(elementMPIDs: ids),
      MPDrawingOrderAction.sendBackward => controller.elementEditController
          .sendBackward(elementMPIDs: ids),
      MPDrawingOrderAction.bringToFront => controller.elementEditController
          .bringToFront(elementMPIDs: ids),
      MPDrawingOrderAction.sendToBack => controller.elementEditController
          .sendToBack(elementMPIDs: ids),
    };
    if (result.executed) {
      _selectMovedDrawables(controller, ids, parentMPID);
    }
  }

  void _executeMoveToScrap(int scrapMPID) {
    final TH2FileEditController? controller = mpLocator.mpGeneralController
        .prepareTH2FileForTreeEdit(row.th2FilePath);
    if (controller == null || controller.th2File.tryElementByMPID(
        row.elementMPID) == null) {
      return;
    }
    final List<int> ids = _menuSelection(controller);
    if (ids.isEmpty) return;
    final MPMoveElementsResult result = controller.elementEditController
        .moveElementsToScrap(elementMPIDs: ids, scrapMPID: scrapMPID);
    if (result.executed) {
      _selectMovedDrawables(controller, ids, scrapMPID);
    }
  }

}

class _TH2FileStatusRow extends StatelessWidget {
  final TH2FileStatusTreeRow row;

  const _TH2FileStatusRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool offersReload = row.kind != TH2FileStatusTreeRowKind.loading;
    final Widget content = Material(
      key: ValueKey('TH2FileStatusTreeRow|${row.rowId}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: offersReload ? _openTab : null,
        child: SizedBox(
          height: mpProjectTreeRowHeight,
          child: Row(
            children: <Widget>[
              SizedBox(width: row.depth * mpProjectTreeIndent),
              const SizedBox(width: mpSmallIconSize),
              ExcludeSemantics(child: _buildIcon(colorScheme)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _statusText(appLocalizations),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _statusColor(colorScheme)),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );

    if (!offersReload) {
      return content;
    }

    return THProjectTreeRowContextMenuWidget(
      key: ValueKey('THProjectTreeRowContextMenu|${row.rowId}'),
      rowId: row.rowId,
      menuChildrenBuilder: () => <Widget>[
        THProjectTreeRowContextMenuWidget.reloadMenuItem(
          rowId: row.rowId,
          th2FilePath: row.th2FilePath,
          appLocalizations: appLocalizations,
        ),
      ],
      child: content,
    );
  }

  String _statusText(AppLocalizations appLocalizations) {
    return switch (row.kind) {
      TH2FileStatusTreeRowKind.loading =>
        appLocalizations.th2ElementTreeLoading,
      TH2FileStatusTreeRowKind.loadError =>
        appLocalizations.th2ElementTreeLoadError,
      TH2FileStatusTreeRowKind.broken =>
        appLocalizations.th2ElementTreeBrokenFile,
    };
  }

  Color _statusColor(ColorScheme colorScheme) {
    return (row.kind == TH2FileStatusTreeRowKind.loading)
        ? colorScheme.onSurfaceVariant
        : colorScheme.error;
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    final IconData icon = switch (row.kind) {
      TH2FileStatusTreeRowKind.loading => Icons.hourglass_empty,
      TH2FileStatusTreeRowKind.loadError => Icons.error_outline,
      TH2FileStatusTreeRowKind.broken => Icons.report_problem_outlined,
    };

    return Icon(icon, size: mpSmallIconSize, color: _statusColor(colorScheme));
  }

  /// Opens the file's tab, whose body shows the broken-file panel or the
  /// load-failure dialog.
  void _openTab() {
    final MPGeneralController generalController =
        mpLocator.mpGeneralController;

    generalController.getTH2FileEditController(filename: row.th2FilePath);
    generalController.addFileTab(row.th2FilePath);
  }
}
