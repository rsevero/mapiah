// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/mp_copy_template.dart';

/// Pairs a template with its children result.
///
/// Each element independently owns its children — the area and its border lines
/// are siblings, each carrying their own nested result.
class MPCopyElementWithChildren {
  final MPCopyTemplate template;
  final MPCopyElementResult childrenResult;

  MPCopyElementWithChildren({
    required this.template,
    required this.childrenResult,
  });

  Map<String, dynamic> toMap() {
    return {
      'template': template.toMap(),
      'childrenResult': childrenResult.toMap(),
    };
  }

  factory MPCopyElementWithChildren.fromMap(Map<String, dynamic> map) {
    return MPCopyElementWithChildren(
      template: MPCopyTemplate.fromMap(map['template'] as Map<String, dynamic>),
      childrenResult: MPCopyElementResult.fromMap(
        map['childrenResult'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Hierarchical clipboard structure for copied elements.
///
/// Each entry in the lists holds a template paired with its own child result.
/// This structure allows depth-first processing where each element independently
/// owns its children.
///
/// Example — THLine:
/// ```
/// MPCopyElementResult (top level):
///   addAtEndMinusOneOfParent:
///     (template(line), childrenResult:
///        addAtEndMinusOneOfParent: []
///        addAtEndOfParent: [(seg1,empty), (seg2,empty), (endLine,empty)]
///     )
///   addAtEndOfParent: []
/// ```
///
/// Example — THArea with one border line:
/// ```
/// MPCopyElementResult (top level, parent context = activeScrap):
///   addAtEndMinusOneOfParent:
///     (template(borderLine), childrenResult:
///        addAtEndOfParent: [(seg1,empty), (seg2,empty), (endLine,empty)]
///     )
///     (template(area), childrenResult:
///        addAtEndOfParent: [(THAreaBorderTHID,empty), (endArea,empty)]
///     )
///   addAtEndOfParent: []
/// ```
class MPCopyElementResult {
  /// Elements that should be added before the last child of parent.
  ///
  /// Typically main elements (THPoint, THLine, THArea, etc.) that need to exist
  /// before the parent's end element (THEndScrap, etc.).
  final List<MPCopyElementWithChildren> addAtEndMinusOneOfParent;

  /// Elements that should be added after the last child of parent.
  ///
  /// Typically children and end-marker elements.
  final List<MPCopyElementWithChildren> addAtEndOfParent;

  MPCopyElementResult({
    required this.addAtEndMinusOneOfParent,
    required this.addAtEndOfParent,
  });

  /// Create an empty result (no elements).
  factory MPCopyElementResult.empty() {
    return MPCopyElementResult(
      addAtEndMinusOneOfParent: [],
      addAtEndOfParent: [],
    );
  }

  bool get isEmpty =>
      addAtEndMinusOneOfParent.isEmpty && addAtEndOfParent.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'addAtEndMinusOneOfParent': addAtEndMinusOneOfParent
          .map((entry) => entry.toMap())
          .toList(),
      'addAtEndOfParent': addAtEndOfParent
          .map((entry) => entry.toMap())
          .toList(),
    };
  }

  factory MPCopyElementResult.fromMap(Map<String, dynamic> map) {
    final List<dynamic> mainList =
        map['addAtEndMinusOneOfParent'] as List? ?? [];
    final List<dynamic> childrenList = map['addAtEndOfParent'] as List? ?? [];

    return MPCopyElementResult(
      addAtEndMinusOneOfParent: mainList
          .cast<Map<String, dynamic>>()
          .map((entry) => MPCopyElementWithChildren.fromMap(entry))
          .toList(),
      addAtEndOfParent: childrenList
          .cast<Map<String, dynamic>>()
          .map((entry) => MPCopyElementWithChildren.fromMap(entry))
          .toList(),
    );
  }
}

/// Result of materializing a copy into live THElements.
///
/// This is the output of MPTHElementPasteAux.materialise(). It contains
/// live THElements ready to be added to a file.
class MPMaterialisedResult {
  /// Elements to be added before the last child of parent.
  final List<dynamic> addAtEndMinusOneOfParent;

  /// Elements to be added after the last child of parent.
  final List<dynamic> addAtEndOfParent;

  MPMaterialisedResult({
    required this.addAtEndMinusOneOfParent,
    required this.addAtEndOfParent,
  });
}
