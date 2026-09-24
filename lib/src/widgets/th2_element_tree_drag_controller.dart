// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'package:flutter/gestures.dart';

import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th2_element_tree_aux.dart';
import 'package:mapiah/src/auxiliary/th2_hierarchy_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_visible_row.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:material_ui/material_ui.dart';

class TH2ElementTreeDragController extends ChangeNotifier {
  TH2ElementTreeDragPayload? activePayload;
  ScrollController? scrollController;
  GlobalKey? viewportKey;
  int? _pointerId;
  Offset? _pointerPosition;
  Timer? _scrollTimer;

  void _onPointer(PointerEvent event) {
    if (event.pointer == _pointerId && event is PointerMoveEvent) {
      _pointerPosition = event.position;
    }
  }

  void _scrollTick(Timer timer) {
    final ScrollController? scroll = scrollController;
    final RenderBox? viewport = viewportKey?.currentContext?.findRenderObject()
        as RenderBox?;
    final Offset? pointer = _pointerPosition;
    if (scroll == null || !scroll.hasClients || viewport == null ||
        pointer == null) {
      return;
    }
    final double y = viewport.globalToLocal(pointer).dy;
    final double extent = mpProjectTreeDragAutoScrollEdgeExtent;
    final double velocity;
    if (y < extent) {
      velocity = -(extent - y).clamp(0.0, extent) / extent;
    } else if (y > viewport.size.height - extent) {
      velocity = (y - (viewport.size.height - extent))
          .clamp(0.0, extent) / extent;
    } else {
      return;
    }
    final ScrollPosition position = scroll.position;
    final double next = (position.pixels +
        velocity * mpProjectTreeDragAutoScrollVelocityScalar)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (next != position.pixels) {
      scroll.jumpTo(next);
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (activePayload != null) _reevaluateAtPointer();
      });
    }
  }

  String? hoverRowId;
  bool? hoverUpper;
  MPHierarchyMoveCheck? hoverCheck;
  TH2ElementTreeDropRequest? hoverRequest;
  bool hoverCanMove = false;
  String? indicatorRowId;
  bool indicatorUpper = true;
  int? _hoverRevision;
  bool? _hoverExpanded;
  final Map<Object, bool Function(Offset)> _targetHitTests =
      <Object, bool Function(Offset)>{};

  void registerTarget(Object key, bool Function(Offset) hitTest) {
    _targetHitTests[key] = hitTest;
  }

  void unregisterTarget(Object key) {
    _targetHitTests.remove(key);
  }

  void _reevaluateAtPointer() {
    final Offset? pointer = _pointerPosition;
    if (pointer == null || activePayload == null) return;
    for (final bool Function(Offset) hitTest in
        _targetHitTests.values.toList()) {
      if (hitTest(pointer)) return;
    }
    clearHover();
  }

  Timer? _expandTimer;
  String? _expandRowId;

  void start(TH2ElementTreeDragPayload payload, {int? pointerId}) {
    activePayload = payload;
    _pointerId = pointerId;
    if (pointerId != null) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    }
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16),
      _scrollTick);
    clearHover();
  }

  void end() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    if (_pointerId != null) {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    }
    _pointerId = null;
    _pointerPosition = null;
    activePayload = null;
    clearHover();
  }

  void clearHover() {
    hoverRowId = null;
    hoverUpper = null;
    hoverCheck = null;
    hoverRequest = null;
    hoverCanMove = false;
    indicatorRowId = null;
    _hoverRevision = null;
    _hoverExpanded = null;
    _expandTimer?.cancel();
    _expandTimer = null;
    _expandRowId = null;
    notifyListeners();
  }

  void leave(String rowId) {
    if (hoverRowId == rowId) clearHover();
  }

  void hover({required TH2ElementTreeDragPayload payload,
    required String rowId, required String th2FilePath,
    required int? targetMPID, required bool upper,
    required bool collapsedScrap, required bool expanded,
  }) {
    final TH2FileEditController? registered = mpLocator.mpGeneralController
        .getTH2FileEditControllerIfExists(th2FilePath);
    if (registered == null || !registered.isFileLoaded ||
        registered.isBroken || registered.loadError != null) {
      clearHover();
      return;
    }
    if (identical(payload, activePayload) && hoverRowId == rowId &&
        hoverUpper == upper && _hoverRevision == registered.structureRevision &&
        _hoverExpanded == expanded) {
      return;
    }
    if (hoverRowId != rowId) {
      _expandTimer?.cancel();
      _expandTimer = null;
      _expandRowId = null;
    }
    hoverRowId = rowId;
    hoverUpper = upper;
    hoverCheck = null;
    hoverRequest = null;
    hoverCanMove = false;
    indicatorRowId = null;
    _hoverRevision = registered.structureRevision;
    _hoverExpanded = expanded;
    if (payload.th2FilePath != th2FilePath) {
      hoverCheck = const MPHierarchyMoveCheck.rejected(
        MPHierarchyMoveRejection.crossFile);
    } else if (identical(payload.controller, registered) &&
        (targetMPID == null ||
         !payload.elementMPIDs.contains(targetMPID))) {
      final TH2ElementTreeDropRequest? request =
          TH2ElementTreeAux.dropRequest(payload: payload,
            targetMPID: targetMPID, upper: upper);
      if (request != null) {
        final MPHierarchyMoveCheck check = registered.elementEditController
            .checkMoveElements(elementMPIDs: payload.elementMPIDs,
              newParentMPID: request.parentMPID,
              beforeSiblingMPID: request.beforeSiblingMPID);
        hoverCheck = check;
        if (check.ok) {
          final List<MPElementMove> moves = TH2HierarchyAux.resolveMoves(
            registered.th2File, elementMPIDs: payload.elementMPIDs,
            newParentMPID: request.parentMPID,
            beforeSiblingMPID: request.beforeSiblingMPID);
          if (moves.isNotEmpty) {
            hoverRequest = request;
            hoverCanMove = true;
            _placeIndicator(payload: payload, targetMPID: targetMPID,
              rowId: rowId, th2FilePath: th2FilePath,
              upper: upper, expanded: expanded);
          }
        }
      }
    }
    if (collapsedScrap && !payload.isScrap && _expandRowId != rowId) {
      _expandRowId = rowId;
      _expandTimer = Timer(const Duration(milliseconds:
        mpProjectTreeDragHoverExpandDelayMilliseconds), () {
        if (hoverRowId == rowId && activePayload != null) {
          mpLocator.thProjectTreeUIController.toggleTH2ScrapCollapsed(rowId);
        }
      });
    }
    notifyListeners();
  }

  void _placeIndicator({required TH2ElementTreeDragPayload payload,
      required int? targetMPID, required String rowId,
      required String th2FilePath, required bool upper,
      required bool expanded}) {
    indicatorRowId = rowId;
    indicatorUpper = upper;
    if (!expanded) {
      indicatorUpper = false;
      return;
    }
    final file = payload.controller.th2File;
    int? child;
    if (targetMPID == null) {
      final List<int> scraps = file.childrenMPIDs.where((int id) =>
        file.elementByMPID(id) is THScrap).toList();
      if (scraps.isEmpty) return;
      child = upper ? scraps.first : scraps.last;
      if (!upper) {
        final String scrapRowId = th2ElementTreeRowId(
          th2FilePath: th2FilePath, elementMPID: child);
        if (!mpLocator.thProjectTreeUIController.isTH2ScrapCollapsed(
            scrapRowId)) {
          final THScrap scrap = file.scrapByMPID(child);
          final List<int> visible = scrap.childrenMPIDs.where((int id) =>
            TH2HierarchyAux.isMovable(file.elementByMPID(id))).toList();
          if (visible.isNotEmpty) child = visible.last;
        }
      }
    } else {
      final THElement target = file.elementByMPID(targetMPID);
      if (target is THScrap) {
        if (payload.isScrap && upper) return;
        final List<int> visible = target.childrenMPIDs.where((int id) =>
          TH2HierarchyAux.isMovable(file.elementByMPID(id))).toList();
        if (visible.isEmpty) {
          indicatorUpper = false;
          return;
        }
        child = upper && !payload.isScrap ? visible.first : visible.last;
      } else {
        return;
      }
    }
    indicatorRowId = th2ElementTreeRowId(
      th2FilePath: th2FilePath, elementMPID: child);
    indicatorUpper = upper && !payload.isScrap;
  }

  void drop({required TH2ElementTreeDragPayload payload,
    required String th2FilePath, required int? targetMPID,
    required bool upper}) {
    if (payload.th2FilePath != th2FilePath) {
      return;
    }
    final TH2FileEditController? registered = mpLocator.mpGeneralController
        .getTH2FileEditControllerIfExists(th2FilePath);
    if (!identical(payload.controller, registered) || registered == null ||
        registered.isBroken || !registered.isFileLoaded ||
        registered.loadError != null) {
      return;
    }
    final TH2ElementTreeDropRequest? initialRequest =
        TH2ElementTreeAux.dropRequest(payload: payload,
          targetMPID: targetMPID, upper: upper);
    if (initialRequest == null) {
      return;
    }
    final MPHierarchyMoveCheck initialCheck = registered.elementEditController
        .checkMoveElements(elementMPIDs: payload.elementMPIDs,
          newParentMPID: initialRequest.parentMPID,
          beforeSiblingMPID: initialRequest.beforeSiblingMPID);
    if (!initialCheck.ok || TH2HierarchyAux.resolveMoves(registered.th2File,
      elementMPIDs: payload.elementMPIDs,
      newParentMPID: initialRequest.parentMPID,
      beforeSiblingMPID: initialRequest.beforeSiblingMPID).isEmpty) {
      return;
    }
    final TH2FileEditController? controller = mpLocator.mpGeneralController
        .prepareTH2FileForTreeEdit(th2FilePath);
    if (controller == null || !identical(controller, payload.controller)) {
      return;
    }
    final TH2ElementTreeDropRequest? request = TH2ElementTreeAux.dropRequest(
      payload: payload, targetMPID: targetMPID, upper: upper);
    if (request == null) {
      return;
    }
    final MPHierarchyMoveCheck check = controller.elementEditController
        .checkMoveElements(elementMPIDs: payload.elementMPIDs,
          newParentMPID: request.parentMPID,
          beforeSiblingMPID: request.beforeSiblingMPID);
    if (!check.ok || TH2HierarchyAux.resolveMoves(controller.th2File,
      elementMPIDs: payload.elementMPIDs,
      newParentMPID: request.parentMPID,
      beforeSiblingMPID: request.beforeSiblingMPID).isEmpty) {
      return;
    }
    final result = controller.elementEditController.moveElements(
      elementMPIDs: payload.elementMPIDs,
      newParentMPID: request.parentMPID,
      beforeSiblingMPID: request.beforeSiblingMPID);
    if (result.executed && !payload.isScrap) {
      controller.setActiveScrap(request.parentMPID);
      controller.selectionController.setSelectedElements(payload.elementMPIDs
          .map(controller.th2File.elementByMPID).toList(), setState: true);
    }
    clearHover();
  }

  @override
  void dispose() {
    end();
    _expandTimer?.cancel();
    super.dispose();
  }
}

class TH2ElementTreeDropTarget extends StatefulWidget {
  final TH2ElementTreeDragController controller;
  final String rowId;
  final String th2FilePath;
  final int? targetMPID;
  final bool collapsedScrap;
  final bool expanded;
  final Widget child;
  const TH2ElementTreeDropTarget({super.key, required this.controller,
    required this.rowId, required this.th2FilePath,
    required this.targetMPID, required this.collapsedScrap,
    required this.expanded, required this.child});

  @override
  State<TH2ElementTreeDropTarget> createState() =>
      _TH2ElementTreeDropTargetState();
}

class _TH2ElementTreeDropTargetState extends State<TH2ElementTreeDropTarget> {
  BuildContext? _targetContext;
  bool _upper = true;

  @override
  void initState() {
    super.initState();
    widget.controller.registerTarget(this, _hitTestAt);
  }

  @override
  void didUpdateWidget(TH2ElementTreeDropTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.unregisterTarget(this);
      widget.controller.registerTarget(this, _hitTestAt);
    }
  }

  @override
  void dispose() {
    widget.controller.unregisterTarget(this);
    super.dispose();
  }

  bool _hitTestAt(Offset globalPosition) {
    final TH2ElementTreeDragPayload? payload =
        widget.controller.activePayload;
    final RenderBox? box = _targetContext?.findRenderObject() as RenderBox?;
    if (payload == null || box == null || !box.attached) return false;
    final Offset local = box.globalToLocal(globalPosition);
    if (!(Offset.zero & box.size).contains(local)) return false;
    _upper = local.dy < box.size.height *
        mpProjectTreeDropZoneHalfFraction;
    widget.controller.hover(payload: payload, rowId: widget.rowId,
      th2FilePath: widget.th2FilePath,
      targetMPID: widget.targetMPID, upper: _upper,
      collapsedScrap: widget.collapsedScrap,
      expanded: widget.expanded);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<TH2ElementTreeDragPayload>(
      onWillAcceptWithDetails: (details) => true,
      onMove: (details) {
        _hitTestAt(details.offset);
      },
      onLeave: (_) => widget.controller.leave(widget.rowId),
      onAcceptWithDetails: (details) => widget.controller.drop(
        payload: details.data, th2FilePath: widget.th2FilePath,
        targetMPID: widget.targetMPID, upper: _upper),
      builder: (BuildContext targetContext, candidates, rejected) {
        _targetContext = targetContext;
        return AnimatedBuilder(animation: widget.controller,
          builder: (BuildContext context, Widget? child) {
            final bool valid = widget.controller.hoverCanMove &&
                widget.controller.indicatorRowId == widget.rowId;
            final bool hovered = widget.controller.hoverCanMove &&
                widget.controller.hoverRowId == widget.rowId;
            final bool containsDrop = hovered &&
                (widget.targetMPID == null ||
                  (widget.collapsedScrap || widget.expanded) &&
                  !widget.controller.activePayload!.isScrap);
            final ColorScheme colors = Theme.of(context).colorScheme;
            return DecoratedBox(
              decoration: BoxDecoration(
                border: valid ? Border(
                  top: widget.controller.indicatorUpper
                      ? BorderSide(color: colors.primary, width: 2)
                      : BorderSide.none,
                  bottom: !widget.controller.indicatorUpper
                      ? BorderSide(color: colors.primary, width: 2)
                      : BorderSide.none) : null),
              child: containsDrop ? Stack(children: <Widget>[
                child!,
                Positioned.fill(child: IgnorePointer(child: DecoratedBox(
                  decoration: BoxDecoration(border: Border.all(
                    color: colors.primary))))),
                Positioned(right: 0, top: 0, child: IgnorePointer(
                  child: Icon(widget.controller.hoverUpper == true
                    ? Icons.first_page : Icons.last_page,
                    size: mpSmallIconSize, color: colors.primary))),
              ]) : child);
          }, child: widget.child);
      },
    );
  }
}
