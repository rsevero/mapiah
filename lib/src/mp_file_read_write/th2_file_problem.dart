// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

enum TH2FileProblemKind {
  plaOutsideScrap,
  scrapInsideScrap,
  strayEndscrap,
  missingEndline,
  missingEndarea,
  missingEndscrap,

  /// An area border reference that names no line of the file, or names
  /// something that is not a line.
  invalidBorderReference,
  parseError,
}

class TH2FileProblem {
  final TH2FileProblemKind kind;
  final int lineNumber;
  final String sourceLine;
  final String detail;

  const TH2FileProblem({
    required this.kind,
    required this.lineNumber,
    required this.sourceLine,
    required this.detail,
  });
}
