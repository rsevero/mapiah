// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

enum TH2FileProblemKind {
  plaOutsideScrap,
  scrapInsideScrap,
  strayEndscrap,
  missingEndline,
  missingEndarea,
  missingEndscrap,
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
