// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_copy_element_result.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';

/// Materializes copied elements (templates) into live THElements.
///
/// Processing is depth-first: each entry's childrenResult is fully processed
/// before moving to the next sibling. This guarantees that when a
/// THAreaBorderTHID is processed, the border line's new THID is already
/// recorded in _oldToNewTHIDMap.
class MPTHElementPasteAux {
  final MPCopyElementResult copyResult;
  final TH2File th2File;
  final int activeScrapMPID;

  /// Map old MPID → new MPID for all pasted elements.
  final Map<int, int> _oldToNewMPIDMap = {};

  /// Map old MPID → new THID for elements with THID (THLine, THScrap, etc).
  final Map<int, String> _oldToNewTHIDMap = {};

  /// Cached materialised result.
  MPMaterialisedResult? _cachedResult;

  MPTHElementPasteAux({
    required this.copyResult,
    required this.th2File,
    required this.activeScrapMPID,
  });

  /// Materialize the copied elements into live THElements ready for insertion.
  MPMaterialisedResult materialise() {
    if (_cachedResult != null) {
      return _cachedResult!;
    }

    final List<dynamic> mainElements = [];
    final List<dynamic> childrenElements = [];

    /// Process top-level entries.
    for (final entry in copyResult.addAtEndMinusOneOfParent) {
      final (main, children) = _processEntry(
        entry: entry,
        parentMPID: _getTopLevelParentMPID(entry),
        isAddAtEndMinusOne: true,
      );

      mainElements.addAll(main);
      childrenElements.addAll(children);
    }

    for (final entry in copyResult.addAtEndOfParent) {
      final (main, children) = _processEntry(
        entry: entry,
        parentMPID: _getTopLevelParentMPID(entry),
        isAddAtEndMinusOne: false,
      );

      mainElements.addAll(main);
      childrenElements.addAll(children);
    }

    _cachedResult = MPMaterialisedResult(
      addAtEndMinusOneOfParent: mainElements,
      addAtEndOfParent: childrenElements,
    );

    return _cachedResult!;
  }

  /// Determine parent MPID for top-level elements.
  int _getTopLevelParentMPID(MPCopyElementWithChildren entry) {
    final element = THElement.fromMap(entry.template.elementMap);
    return element is THScrap ? th2File.mpID : activeScrapMPID;
  }

  /// Process a single copy entry with depth-first recursion.
  ///
  /// Returns a tuple of (mainElements, childrenElements).
  (List<dynamic>, List<dynamic>) _processEntry({
    required MPCopyElementWithChildren entry,
    required int parentMPID,
    required bool isAddAtEndMinusOne,
  }) {
    final template = entry.template;
    final List<dynamic> result = [];

    /// 1. Allocate new MPID.
    final int newMPID = mpLocator.mpGeneralController.nextMPIDForElements();

    /// 2. Create element from template.
    THElement element = THElement.fromMap(template.elementMap);

    /// 3. Resolve THID options if present, then apply all updates in one copyWith.
    if (element is THArea) {
      final newOptionsMap = _resolveOptionsTHIDs(element.optionsMap, newMPID);
      element = element.copyWith(
        mpID: newMPID,
        parentMPID: parentMPID,
        originalLineInTH2File: '',
        optionsMap: newOptionsMap,
      );
    } else if (element is THLine) {
      final newOptionsMap = _resolveOptionsTHIDs(element.optionsMap, newMPID);
      element = element.copyWith(
        mpID: newMPID,
        parentMPID: parentMPID,
        originalLineInTH2File: '',
        optionsMap: newOptionsMap,
      );
    } else if (element is THPoint) {
      final newOptionsMap = _resolveOptionsTHIDs(element.optionsMap, newMPID);
      element = element.copyWith(
        mpID: newMPID,
        parentMPID: parentMPID,
        originalLineInTH2File: '',
        optionsMap: newOptionsMap,
      );
    } else if (element is THScrap) {
      final newOptionsMap = _resolveOptionsTHIDs(element.optionsMap, newMPID);
      element = element.copyWith(
        mpID: newMPID,
        parentMPID: parentMPID,
        originalLineInTH2File: '',
        optionsMap: newOptionsMap,
      );
    } else {
      /// For other element types, just update MPID and parent.
      element = element.copyWith(
        mpID: newMPID,
        parentMPID: parentMPID,
        originalLineInTH2File: '',
      );
    }

    /// 4. Record MPID mapping.
    _oldToNewMPIDMap[template.originalMPID ?? 0] = newMPID;

    /// 5. Handle THAreaBorderTHID references (depth-first ensures border lines done).
    if (element is THAreaBorderTHID) {
      final String? newReferencedTHID =
          _oldToNewTHIDMap[template.originalMPID ?? 0];

      if (newReferencedTHID != null) {
        element = element.copyWith(thID: newReferencedTHID);
      }
    }

    /// Place in correct list.
    result.add(element);

    /// 6. Depth-first recursion: process children.
    final List<dynamic> allChildren = [];
    final List<int> newChildrenMPIDs = [];

    for (final childEntry in entry.childrenResult.addAtEndMinusOneOfParent) {
      final (childMain, childChildren) = _processEntry(
        entry: childEntry,
        parentMPID: newMPID,
        isAddAtEndMinusOne: true,
      );

      result.addAll(childMain);
      allChildren.addAll(childChildren);

      if (childEntry.template.originalMPID != null) {
        final newChildMPID =
            _oldToNewMPIDMap[childEntry.template.originalMPID!];
        if (newChildMPID != null) {
          newChildrenMPIDs.add(newChildMPID);
        }
      }
    }

    for (final childEntry in entry.childrenResult.addAtEndOfParent) {
      final (childMain, childChildren) = _processEntry(
        entry: childEntry,
        parentMPID: newMPID,
        isAddAtEndMinusOne: false,
      );

      result.addAll(childMain);
      allChildren.addAll(childChildren);

      if (childEntry.template.originalMPID != null) {
        final newChildMPID =
            _oldToNewMPIDMap[childEntry.template.originalMPID!];
        if (newChildMPID != null) {
          newChildrenMPIDs.add(newChildMPID);
        }
      }
    }

    /// 7. Update parent's childrenMPIDs to point to newly materialized children.
    if (element is THIsParentMixin && newChildrenMPIDs.isNotEmpty) {
      final parent = element as THIsParentMixin;
      parent.childrenMPIDs.clear();
      parent.childrenMPIDs.addAll(newChildrenMPIDs);
    }

    return (result, allChildren);
  }

  /// Resolve THIDs in command options, checking for conflicts.
  SplayTreeMap<THCommandOptionType, THCommandOption> _resolveOptionsTHIDs(
    SplayTreeMap<THCommandOptionType, THCommandOption> optionsMap,
    int elementMPID,
  ) {
    final newMap = SplayTreeMap<THCommandOptionType, THCommandOption>();

    for (final entry in optionsMap.entries) {
      final option = entry.value;

      if (option is THIDCommandOption) {
        final String originalTHID = option.thID;
        final String resolvedTHID;

        if (th2File.hasElementByTHID(originalTHID)) {
          /// Conflict: generate new THID.
          resolvedTHID = th2File.getNewTHID(prefix: '$originalTHID-');
        } else {
          /// No conflict: keep original THID.
          resolvedTHID = originalTHID;
        }

        /// Update the mapping and option.
        _oldToNewTHIDMap[elementMPID] = resolvedTHID;
        final updatedOption = option.copyWith(thID: resolvedTHID);
        newMap[entry.key] = updatedOption;
      } else {
        newMap[entry.key] = option;
      }
    }

    return newMap;
  }
}
