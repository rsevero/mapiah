// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// A source line where the parser started an element, or read an option line
/// for one.
class TH2ParserLineStart {
  /// 1-based source line number.
  final int line;
  final int mpID;

  const TH2ParserLineStart({required this.line, required this.mpID});

  @override
  String toString() => 'TH2ParserLineStart(line: $line, mpID: $mpID)';
}
