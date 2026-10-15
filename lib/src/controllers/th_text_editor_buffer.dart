// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' show TextRange;

import 'package:flutter/widgets.dart' show FocusNode;
import 'package:mapiah/src/auxiliary/th_text_editor_diagnostic.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_lexical_types.dart';
import 'package:mapiah/src/controllers/th_text_editor_find_controller.dart';

/// What `THTextEditorWidget` reads and calls on the text it edits. Implemented
/// by the project text editor controller and the TH2 text session controller.
abstract interface class THTextEditorBuffer {
  String get content;

  /// Replaces the content. [cursorOffset] is the cursor offset in
  /// [newContent] after the change, when known. Returns whether the change
  /// was accepted.
  bool setContent(String newContent, {int? cursorOffset});

  bool get isDirty;

  /// The line ending Enter inserts.
  String get lineEnding;

  THTextEditorLanguage get language;

  /// The tokens of [content], recomputed only when [content] changes.
  List<THTextEditorToken> get tokens;

  int get cursorLine;

  void setCursorPosition({required int line, required int column});

  /// 0-based line to scroll to, or `null`.
  int? get pendingScrollToLine;

  void clearPendingScrollToLine();

  /// An exact selection to apply once the widget has synchronized content.
  TextRange? get pendingSelectionRange;

  /// Whether applying [pendingSelectionRange] also focuses the text field.
  bool get pendingSelectionRequestsFocus;

  void clearPendingSelectionRange();

  /// The main field's scroll offset: its initial offset and the target of the
  /// widget's scroll listener.
  double get lastScrollOffset;

  set lastScrollOffset(double offset);

  /// The editor's wrapper focus node, for Tab and Esc.
  FocusNode get textEditorFocusNode;

  /// The main text field's focus node, for typing.
  FocusNode get textFieldFocusNode;

  List<THTextEditorDiagnostic> get diagnostics;

  /// Whether the toolbar's Save is enabled.
  bool get canSave;

  /// Whether every buffer mutation is refused.
  bool get isReadOnly;

  /// The Revert button's tooltip, or `null` for the default one.
  String? get revertTooltip;

  Future<void> save();

  Future<void> revert();

  /// Changes whenever the text field's native history must start over.
  int get baselineRevision;

  /// Whether the buffer changed since its baseline, even when undo restored
  /// it.
  bool get hasTextEdits;

  /// Undoes or redoes canvas history before the first text edit.
  Future<void> requestCanvasHistory({required bool redo});

  THTextEditorFindController get find;
}
