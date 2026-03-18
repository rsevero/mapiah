// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/mp_copy_template.dart';

/// Represents one element in the copy clipboard with its position and children.
///
/// The clipboard is a flat `List<MPCopyElementWithChildren>` where each entry
/// carries its position indicator and recursively structured children.
class MPCopyElementWithChildren {
  final MPCopyTemplate template;

  /// Position of this element relative to its parent:
  /// - mpAddChildAtEndMinusOneOfParentChildrenList (-1): main elements, before end marker
  /// - mpAddChildAtEndOfParentChildrenList (-2): after main elements
  final int positionAtParent;

  /// This element's children, recursively structured.
  /// Can be empty if element has no children.
  final List<MPCopyElementWithChildren> childrenResult;

  MPCopyElementWithChildren({
    required this.template,
    required this.positionAtParent,
    required this.childrenResult,
  });

  Map<String, dynamic> toMap() => {
    'template': template.toMap(),
    'positionAtParent': positionAtParent,
    'childrenResult': childrenResult.map((c) => c.toMap()).toList(),
  };

  factory MPCopyElementWithChildren.fromMap(Map<String, dynamic> map) =>
      MPCopyElementWithChildren(
        template: MPCopyTemplate.fromMap(
          map['template'] as Map<String, dynamic>,
        ),
        positionAtParent: map['positionAtParent'] as int,
        childrenResult: (map['childrenResult'] as List)
            .cast<Map<String, dynamic>>()
            .map(MPCopyElementWithChildren.fromMap)
            .toList(),
      );
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
