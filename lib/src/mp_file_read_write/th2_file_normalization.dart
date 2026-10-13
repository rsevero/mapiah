// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// What a parser clean-up pass did to an element.
enum TH2FileNormalizationKind {
  /// The element's stored text was cleared, so the writer rewrites it.
  rewrittenLine,
  removedDuplicateLinePoint,
  removedShortLine,
  removedBorderOfShortLine,
  removedEmptyArea,
}

/// A change a parser clean-up pass made to the parsed model.
class TH2FileNormalization {
  final TH2FileNormalizationKind kind;

  /// 1-based raw line where the element started.
  final int line;

  final int mpID;

  /// The removed element and all its descendants, collected before the
  /// removal; empty for [TH2FileNormalizationKind.rewrittenLine].
  final Set<int> removedMPIDs;

  const TH2FileNormalization({
    required this.kind,
    required this.line,
    required this.mpID,
    this.removedMPIDs = const <int>{},
  });

  @override
  String toString() =>
      'TH2FileNormalization(kind: $kind, line: $line, mpID: $mpID, '
      'removedMPIDs: $removedMPIDs)';
}
