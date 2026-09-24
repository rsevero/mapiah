// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:collection/collection.dart';

enum MPHierarchyMoveRejection {
  emptySelection, mixedScrapsAndDrawables, invalidTargetParent,
  unknownElement, duplicateElement, invalidGroupPlacement,
  unsupportedElement, scrapParentMustBeFile, drawableParentMustBeScrap,
  selfParent, targetIsMoving, targetNotChild, targetNotMovable,
  lineBorderShared, areaBorderNotLine, areaBorderWrongScrap,
  areaBorderShared, brokenFile, crossFile,
}

class MPHierarchyMoveCheck {
  final bool ok;
  final MPHierarchyMoveRejection? rejection;
  final int? lineMPID;
  final int? areaMPID;
  const MPHierarchyMoveCheck.ok()
      : ok = true, rejection = null, lineMPID = null, areaMPID = null;
  const MPHierarchyMoveCheck.rejected(this.rejection,
      {this.lineMPID, this.areaMPID}) : ok = false;
}

enum MPMoveGroupPlacement { beforeSibling, afterSibling, end }

class MPMoveGroup {
  final List<int> elementMPIDs;
  final MPMoveGroupPlacement placement;
  final int? siblingMPID;
  const MPMoveGroup({required this.elementMPIDs, required this.placement,
    this.siblingMPID}) : assert((placement == MPMoveGroupPlacement.end) ==
      (siblingMPID == null));
}

class TH2HierarchyAux {
  static bool isMovable(THElement element) => element is THScrap ||
      element is THPoint || element is THLine || element is THArea;

  static MPHierarchyMoveCheck validateMoveGroups(TH2File th2File, {
    required int parentMPID, required List<MPMoveGroup> groups,
  }) {
    final Set<int> moving = <int>{};
    for (final MPMoveGroup group in groups) {
      if (group.elementMPIDs.isEmpty) {
        return const MPHierarchyMoveCheck.rejected(
          MPHierarchyMoveRejection.emptySelection);
      }
      if ((group.placement == MPMoveGroupPlacement.end) !=
          (group.siblingMPID == null)) {
        return const MPHierarchyMoveCheck.rejected(
          MPHierarchyMoveRejection.invalidGroupPlacement);
      }
      for (final int id in group.elementMPIDs) {
        if (!moving.add(id)) {
          return const MPHierarchyMoveCheck.rejected(
            MPHierarchyMoveRejection.duplicateElement);
        }
      }
    }
    for (final MPMoveGroup group in groups) {
      if (group.siblingMPID != null && moving.contains(group.siblingMPID)) {
        return const MPHierarchyMoveCheck.rejected(
          MPHierarchyMoveRejection.targetIsMoving);
      }
      final MPHierarchyMoveCheck check = validateMove(th2File,
        elementMPIDs: group.elementMPIDs, newParentMPID: parentMPID,
        beforeSiblingMPID: group.placement == MPMoveGroupPlacement.beforeSibling
            ? group.siblingMPID : null,
        afterSiblingMPID: group.placement == MPMoveGroupPlacement.afterSibling
            ? group.siblingMPID : null);
      if (!check.ok) return check;
    }
    return const MPHierarchyMoveCheck.ok();
  }

  static List<MPElementMove> resolveMoves(TH2File th2File, {
    required List<int> elementMPIDs, required int newParentMPID,
    int? beforeSiblingMPID,
  }) => resolveMoveGroups(th2File, parentMPID: newParentMPID,
    groups: <MPMoveGroup>[MPMoveGroup(elementMPIDs: elementMPIDs,
      placement: beforeSiblingMPID == null ? MPMoveGroupPlacement.end
          : MPMoveGroupPlacement.beforeSibling,
      siblingMPID: beforeSiblingMPID)]);

  static List<MPElementMove> resolveMoveGroups(TH2File th2File, {
    required int parentMPID, required List<MPMoveGroup> groups,
  }) {
    if (groups.isEmpty) return const <MPElementMove>[];
    final Map<int, List<int>> lists = <int, List<int>>{};
    final Map<int, List<int>> initial = <int, List<int>>{};
    List<int> listFor(int parent) => lists.putIfAbsent(parent, () {
      final List<int> value = (parent == th2File.mpID
          ? th2File.childrenMPIDs : th2File.parentByMPID(parent).childrenMPIDs)
          .toList();
      initial[parent] = value.toList();
      return value;
    });
    final Set<int> moving = groups.expand((MPMoveGroup group) =>
      group.elementMPIDs).toSet();
    final List<int> order = <int>[];
    for (final int id in th2File.childrenMPIDs) {
      final THElement element = th2File.elementByMPID(id);
      if (element is THScrap) {
        order.add(id);
        order.addAll(element.childrenMPIDs.where((int child) =>
          isMovable(th2File.elementByMPID(child))));
      }
    }
    final List<MPMoveGroup> sortedGroups = groups.toList()
      ..sort((MPMoveGroup a, MPMoveGroup b) =>
        order.indexOf(a.elementMPIDs.first).compareTo(
          order.indexOf(b.elementMPIDs.first)));
    final List<MPElementMove> moves = <MPElementMove>[];
    for (final MPMoveGroup group in sortedGroups) {
      final Set<int> selected = group.elementMPIDs.toSet();
      final Set<int> folded = <int>{};
      for (final int id in selected) {
        final THElement element = th2File.elementByMPID(id);
        if (element is THArea && element.parentMPID != parentMPID) {
          folded.addAll(element.getLineMPIDs(th2File).where((int lineID) {
            final THElement? line = th2File.tryElementByMPID(lineID);
            return line is THLine && line.parentMPID == element.parentMPID;
          }));
        }
      }
      final List<int> effective = <int>[];
      for (final int id in order) {
        if (!selected.contains(id) || folded.contains(id)) continue;
        final THElement element = th2File.elementByMPID(id);
        if (element is THArea && element.parentMPID != parentMPID) {
          for (final int lineID in element.getLineMPIDs(th2File)) {
            if (folded.contains(lineID) && !effective.contains(lineID)) {
              effective.add(lineID);
            }
          }
        }
        if (!effective.contains(id)) effective.add(id);
      }
      final List<int> target = listFor(parentMPID);
      for (final int id in effective) {
        final THElement element = th2File.elementByMPID(id);
        final int oldParent = element.parentMPID < 0
            ? th2File.mpID : element.parentMPID;
        listFor(oldParent).remove(id);
        int position;
        if (group.placement == MPMoveGroupPlacement.beforeSibling) {
          position = target.indexOf(group.siblingMPID!);
        } else if (group.placement == MPMoveGroupPlacement.afterSibling) {
          final int anchorIndex = target.indexOf(group.siblingMPID!);
          int? next;
          for (int i = anchorIndex + 1; i < target.length; i++) {
            final int candidate = target[i];
            if (isMovable(th2File.elementByMPID(candidate)) &&
                !moving.contains(candidate)) {
              next = candidate;
              break;
            }
          }
          position = next == null ? _endPosition(th2File, parentMPID, target)
              : target.indexOf(next);
        } else {
          position = _endPosition(th2File, parentMPID, target);
        }
        target.insert(position, id);
        moves.add(MPElementMove(elementMPID: id,
          newParentMPID: parentMPID, positionInNewParent: position));
      }
    }
    bool sameMovable(MapEntry<int, List<int>> entry) =>
      const ListEquality<int>().equals(
        entry.value.where((int id) => isMovable(th2File.elementByMPID(id))).toList(),
        listFor(entry.key).where((int id) =>
          isMovable(th2File.elementByMPID(id))).toList());
    return moves.isEmpty || initial.entries.every(sameMovable)
        ? const <MPElementMove>[] : moves;
  }

  static int _endPosition(TH2File th2File, int parentMPID, List<int> target) {
    if (parentMPID == th2File.mpID) {
      int lastScrap = -1;
      for (int i = 0; i < target.length; i++) {
        if (th2File.elementByMPID(target[i]) is THScrap) {
          lastScrap = i;
        }
      }
      return lastScrap + 1;
    }
    for (int i = 0; i < target.length; i++) {
      if (th2File.elementByMPID(target[i]).elementType ==
          THElementType.endscrap) {
        return i;
      }
    }
    return target.length;
  }

  static MPHierarchyMoveCheck validateMove(
    TH2File th2File, {
    required List<int> elementMPIDs,
    required int newParentMPID,
    int? beforeSiblingMPID,
    int? afterSiblingMPID,
  }) {
    assert(beforeSiblingMPID == null || afterSiblingMPID == null);
    if (elementMPIDs.isEmpty) {
      return const MPHierarchyMoveCheck.rejected(MPHierarchyMoveRejection.emptySelection);
    }
    bool hasScrap = false;
    bool hasDrawable = false;
    for (final int id in elementMPIDs) {
      final THElement? element = th2File.tryElementByMPID(id);
      hasScrap |= element is THScrap;
      hasDrawable |= element is THPoint || element is THLine || element is THArea;
    }
    if (hasScrap && hasDrawable) {
      return const MPHierarchyMoveCheck.rejected(
        MPHierarchyMoveRejection.mixedScrapsAndDrawables);
    }
    final THElement? parent = newParentMPID == th2File.mpID
        ? null
        : th2File.tryElementByMPID(newParentMPID);
    if (newParentMPID != th2File.mpID && parent is! THScrap) {
      return const MPHierarchyMoveCheck.rejected(MPHierarchyMoveRejection.invalidTargetParent);
    }
    final Set<int> moving = elementMPIDs.toSet();
    for (final int mpID in moving) {
      final THElement? element = th2File.tryElementByMPID(mpID);
      if (element == null) {
        return const MPHierarchyMoveCheck.rejected(MPHierarchyMoveRejection.unknownElement);
      }
      if (element is! THScrap && element is! THPoint &&
          element is! THLine && element is! THArea) {
        return const MPHierarchyMoveCheck.rejected(MPHierarchyMoveRejection.unsupportedElement);
      }
      if (element is THScrap && newParentMPID != th2File.mpID) {
        return const MPHierarchyMoveCheck.rejected(MPHierarchyMoveRejection.scrapParentMustBeFile);
      }
      if (element is! THScrap && newParentMPID == th2File.mpID) {
        return const MPHierarchyMoveCheck.rejected(MPHierarchyMoveRejection.drawableParentMustBeScrap);
      }
      if (element.mpID == newParentMPID) {
        return const MPHierarchyMoveCheck.rejected(MPHierarchyMoveRejection.selfParent);
      }
    }
    for (final int? siblingMPID in <int?>[beforeSiblingMPID, afterSiblingMPID]) {
      if (siblingMPID == null) continue;
      if (moving.contains(siblingMPID)) {
        return const MPHierarchyMoveCheck.rejected(MPHierarchyMoveRejection.targetIsMoving);
      }
      final List<int> children = newParentMPID == th2File.mpID
          ? th2File.childrenMPIDs
          : (parent as THScrap).childrenMPIDs;
      if (!children.contains(siblingMPID)) {
        return const MPHierarchyMoveCheck.rejected(MPHierarchyMoveRejection.targetNotChild);
      }
      final THElement target = th2File.elementByMPID(siblingMPID);
      if (target is! THScrap && target is! THPoint && target is! THLine &&
          target is! THArea && (siblingMPID == afterSiblingMPID || target.elementType != THElementType.endscrap)) {
        return const MPHierarchyMoveCheck.rejected(MPHierarchyMoveRejection.targetNotMovable);
      }
    }
    for (final int mpID in moving) {
      final THElement element = th2File.elementByMPID(mpID);
      if (element is THLine && element.parentMPID != newParentMPID &&
          th2File.getAreaMPIDsByLineMPID(element.mpID).any(
            (int area) => !moving.contains(area),
          )) {
        final int areaMPID = th2File.getAreaMPIDsByLineMPID(element.mpID)
            .firstWhere((int area) => !moving.contains(area));
        return MPHierarchyMoveCheck.rejected(
          MPHierarchyMoveRejection.lineBorderShared,
          lineMPID: element.mpID, areaMPID: areaMPID);
      }
      if (element is! THArea) continue;
      final int sourceScrap = element.parentMPID;
      for (final int lineMPID in element.getLineMPIDs(th2File)) {
        final THElement? resolved = th2File.tryElementByMPID(lineMPID);
        if (resolved is! THLine) {
          return MPHierarchyMoveCheck.rejected(
            MPHierarchyMoveRejection.areaBorderNotLine, areaMPID: element.mpID);
        }
        if (resolved.parentMPID != sourceScrap && newParentMPID != sourceScrap) {
          return MPHierarchyMoveCheck.rejected(
            MPHierarchyMoveRejection.areaBorderWrongScrap,
            lineMPID: lineMPID, areaMPID: element.mpID);
        }
        if (newParentMPID != sourceScrap &&
            th2File.getAreaMPIDsByLineMPID(lineMPID).any(
              (int area) => !moving.contains(area),
            )) {
          final int areaMPID = th2File.getAreaMPIDsByLineMPID(lineMPID)
              .firstWhere((int area) => !moving.contains(area));
          return MPHierarchyMoveCheck.rejected(
            MPHierarchyMoveRejection.areaBorderShared,
            lineMPID: lineMPID, areaMPID: areaMPID);
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
  int? afterSiblingMPID,
}) => TH2HierarchyAux.validateMove(
  th2File,
  elementMPIDs: elementMPIDs,
  newParentMPID: newParentMPID,
  beforeSiblingMPID: beforeSiblingMPID,
  afterSiblingMPID: afterSiblingMPID,
);
