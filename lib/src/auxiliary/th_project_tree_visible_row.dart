// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';

/// One visible row of the project sidebar tree.
sealed class THProjectTreeVisibleRow {
  const THProjectTreeVisibleRow();

  /// Indentation level of the row.
  int get depth;

  /// Stable identity of the row, used for keys and expansion state.
  String get rowId;
}

/// A row showing a [THProjectNode] of the project parser's tree.
final class THProjectTreeNodeRow extends THProjectTreeVisibleRow {
  final THProjectNode node;

  @override
  final int depth;

  const THProjectTreeNodeRow({required this.node, required this.depth});

  @override
  String get rowId => node.id;
}

/// The text of a TH2 element row: the localized kind and type[:subtype],
/// then the Therion id exactly as stored, if any.
class TH2ElementTreeLabel {
  /// Localized kind and, for points, lines and areas, type[:subtype].
  final String primaryText;

  /// The Therion id shown verbatim, or `null` when the element has none.
  final String? thID;

  const TH2ElementTreeLabel({required this.primaryText, this.thID});

  /// The plain row text used for filtering and semantics.
  String get plainText {
    final String? currentTHID = thID;

    if ((currentTHID == null) || currentTHID.isEmpty) {
      return primaryText;
    }

    if (primaryText.isEmpty) {
      return currentTHID;
    }

    return '$primaryText $currentTHID';
  }
}

/// A row showing a scrap, point, line or area of a loaded valid `.th2` file.
final class TH2ElementTreeRow extends THProjectTreeVisibleRow {
  /// Canonical path of the file, equal to its `TH2FileNode.absolutePath`.
  final String th2FilePath;

  final int elementMPID;

  final THElementType elementType;

  @override
  final int depth;

  /// True only for scrap rows.
  final bool isExpandable;

  /// Always false for non-scrap rows.
  final bool isExpanded;

  final TH2ElementTreeLabel label;

  const TH2ElementTreeRow({
    required this.th2FilePath,
    required this.elementMPID,
    required this.elementType,
    required this.depth,
    required this.isExpandable,
    required this.isExpanded,
    required this.label,
  });

  @override
  String get rowId => th2ElementTreeRowId(
    th2FilePath: th2FilePath,
    elementMPID: elementMPID,
  );

  bool get isScrap => elementType == THElementType.scrap;
}

/// The state a `.th2` file row shows instead of its element rows.
enum TH2FileStatusTreeRowKind { loading, loadError, broken }

/// A row telling that a `.th2` file is loading, failed to load or is broken.
final class TH2FileStatusTreeRow extends THProjectTreeVisibleRow {
  /// Canonical path of the file, equal to its `TH2FileNode.absolutePath`.
  final String th2FilePath;

  final TH2FileStatusTreeRowKind kind;

  @override
  final int depth;

  const TH2FileStatusTreeRow({
    required this.th2FilePath,
    required this.kind,
    required this.depth,
  });

  @override
  String get rowId => 'th2status:$th2FilePath:${kind.name}';
}

/// The row id of a TH2 element: canonical file path plus MPID.
String th2ElementTreeRowId({
  required String th2FilePath,
  required int elementMPID,
}) {
  return 'th2el:$th2FilePath:$elementMPID';
}
