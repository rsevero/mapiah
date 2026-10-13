// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';

/// What applying a text buffer to the model needs from a text session.
abstract interface class TH2TextApplySession {
  /// Changes whenever the session ends or is replaced.
  int get sessionRevision;

  bool get isOpen;

  /// The current buffer.
  String get content;

  /// The live model's text when the session started.
  String get initialContent;

  /// The writer map of [initialContent].
  TH2TextLineMap get initialLineMap;

  /// The raw cursor line, 0-based.
  int get cursorLine;

  TH2TextValidationCache get validationCache;

  /// Takes the operation-owned buffer lock.
  void lockBuffer();
}

/// The outcome of `TH2FileEditController.applyTextContent`.
sealed class TH2TextApplyResult {
  const TH2TextApplyResult();
}

/// The text was applied as one canvas undo step.
class TH2TextApplyApplied extends TH2TextApplyResult {
  /// The live writer map after the apply.
  final TH2TextLineMap lineMap;

  /// The mapped cursor line in [lineMap].
  final int cursorLine;

  const TH2TextApplyApplied(this.lineMap, this.cursorLine);
}

/// The text describes the live model already: nothing changed.
class TH2TextApplyUnchanged extends TH2TextApplyResult {
  final TH2TextLineMap lineMap;
  final int cursorLine;

  const TH2TextApplyUnchanged(this.lineMap, this.cursorLine);
}

/// The text is invalid: nothing changed.
class TH2TextApplyRejected extends TH2TextApplyResult {
  final List<TH2TextDiagnostic> diagnostics;

  const TH2TextApplyRejected(this.diagnostics);
}

/// The session ended, was replaced or the controller was disposed during
/// validation: nothing changed.
class TH2TextApplyCancelled extends TH2TextApplyResult {
  const TH2TextApplyCancelled();
}
