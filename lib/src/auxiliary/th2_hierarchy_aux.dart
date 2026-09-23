// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';

class MPHierarchyMoveCheck {
  final bool ok;
  final String? reasonKey;
  const MPHierarchyMoveCheck.ok() : ok = true, reasonKey = null;
  const MPHierarchyMoveCheck.rejected(this.reasonKey) : ok = false;
}

class TH2HierarchyAux {
  static MPHierarchyMoveCheck validateMove(
    TH2File th2File, {
    required List<int> elementMPIDs,
    required int newParentMPID,
    int? beforeSiblingMPID,
  }) {
    if (elementMPIDs.isEmpty) {
      return const MPHierarchyMoveCheck.rejected('empty_selection');
    }
    final THElement? parent = newParentMPID == th2File.mpID
        ? null
        : th2File.tryElementByMPID(newParentMPID);
    if (newParentMPID != th2File.mpID && parent is! THScrap) {
      return const MPHierarchyMoveCheck.rejected('invalid_target_parent');
    }
    final Set<int> moving = elementMPIDs.toSet();
    for (final int mpID in moving) {
      final THElement? element = th2File.tryElementByMPID(mpID);
      if (element == null) {
        return const MPHierarchyMoveCheck.rejected('unknown_element');
      }
      if (element is! THScrap && element is! THPoint &&
          element is! THLine && element is! THArea) {
        return const MPHierarchyMoveCheck.rejected('unsupported_element');
      }
      if (element is THScrap && newParentMPID != th2File.mpID) {
        return const MPHierarchyMoveCheck.rejected('scrap_parent_must_be_file');
      }
      if (element is! THScrap && newParentMPID == th2File.mpID) {
        return const MPHierarchyMoveCheck.rejected('drawable_parent_must_be_scrap');
      }
      if (element.mpID == newParentMPID) {
        return const MPHierarchyMoveCheck.rejected('self_parent');
      }
    }
    if (beforeSiblingMPID != null) {
      if (moving.contains(beforeSiblingMPID)) {
        return const MPHierarchyMoveCheck.rejected('target_is_moving');
      }
      final List<int> children = newParentMPID == th2File.mpID
          ? th2File.childrenMPIDs
          : (parent as THScrap).childrenMPIDs;
      if (!children.contains(beforeSiblingMPID)) {
        return const MPHierarchyMoveCheck.rejected('target_not_child');
      }
      final THElement target = th2File.elementByMPID(beforeSiblingMPID);
      if (target is! THScrap && target is! THPoint && target is! THLine &&
          target is! THArea && target.elementType != THElementType.endscrap) {
        return const MPHierarchyMoveCheck.rejected('target_not_movable');
      }
    }
    for (final int mpID in moving) {
      final THElement element = th2File.elementByMPID(mpID);
      if (element is THLine && element.parentMPID != newParentMPID &&
          th2File.getAreaMPIDsByLineMPID(element.mpID).any(
            (int area) => !moving.contains(area),
          )) {
        return const MPHierarchyMoveCheck.rejected('line_border_shared');
      }
      if (element is! THArea) continue;
      final int sourceScrap = element.parentMPID;
      for (final int lineMPID in element.getLineMPIDs(th2File)) {
        final THElement? resolved = th2File.tryElementByMPID(lineMPID);
        if (resolved is! THLine) {
          return const MPHierarchyMoveCheck.rejected('area_border_not_line');
        }
        if (resolved.parentMPID != sourceScrap && newParentMPID != sourceScrap) {
          return const MPHierarchyMoveCheck.rejected('area_border_wrong_scrap');
        }
        if (newParentMPID != sourceScrap &&
            th2File.getAreaMPIDsByLineMPID(lineMPID).any(
              (int area) => !moving.contains(area),
            )) {
          return const MPHierarchyMoveCheck.rejected('area_border_shared');
        }
      }
    }
    return const MPHierarchyMoveCheck.ok();
  }
}

MPHierarchyMoveCheck validateMove(
  TH2File th2File, {
  required List<int> elementMPIDs,
  required int newParentMPID,
  int? beforeSiblingMPID,
}) => TH2HierarchyAux.validateMove(
  th2File,
  elementMPIDs: elementMPIDs,
  newParentMPID: newParentMPID,
  beforeSiblingMPID: beforeSiblingMPID,
);
