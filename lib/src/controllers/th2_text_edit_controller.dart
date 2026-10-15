// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:ui' show TextRange;

import 'package:flutter/widgets.dart' show FocusNode, visibleForTesting;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th2_file_problem_text_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_tracker.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_diagnostic.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_fold_aux.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_syntax_highlighter.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_text_edit_owner.dart';
import 'package:mapiah/src/controllers/th_text_editor_buffer.dart';
import 'package:mapiah/src/controllers/th_text_editor_find_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mobx/mobx.dart';

part 'th2_text_edit_controller.g.dart';

/// A complete text session baseline, prepared before it is installed so that
/// preparing never touches the live session.
class TH2TextEditBaseline {
  /// The live model's text, as Save writes it.
  final String content;

  /// The writer map of [content].
  final TH2TextLineMap lineMap;

  final int cursorLine;

  final int cursorColumn;

  /// A selection to apply after installation, or `null`.
  final TextRange? selection;

  final bool selectionRequestsFocus;

  final TH2TextLineTracker _lineTracker;

  final TH2TextValidationCache _validationCache;

  TH2TextEditBaseline({
    required this.content,
    required this.lineMap,
    this.cursorLine = 0,
    this.cursorColumn = 0,
    this.selection,
    this.selectionRequestsFocus = true,
  }) : _lineTracker = TH2TextLineTracker(content),
       _validationCache = TH2TextValidationCache();
}

class TH2TextEditController = TH2TextEditControllerBase
    with _$TH2TextEditController;

/// MobX store of the text session of one `.th2` file in text mode: the
/// buffer, its baseline, diagnostics and native-history routing state.
///
/// The text controller outlives its sessions. A session starts when a
/// baseline is installed and ends with [endSession]. Buffer edits never
/// change the live model or canvas history: the owner applies the text.
abstract class TH2TextEditControllerBase
    with Store
    implements THTextEditorBuffer, TH2TextApplySession {
  final TH2TextEditOwner _owner;

  TH2TextEditControllerBase({required TH2TextEditOwner owner})
    : _owner = owner;

  @observable
  String _content = '';

  @observable
  String _initialContent = '';

  TH2TextLineMap? _initialLineMap;

  @observable
  bool _isOpen = false;

  @observable
  int _sessionRevision = 0;

  @observable
  int _baselineRevision = 0;

  @observable
  bool _hasTextEdits = false;

  /// Read-only after a failed session regeneration, independently of the
  /// operation-owned buffer lock.
  @observable
  bool _isRecoveryReadOnly = false;

  @observable
  int _cursorLine = 0;

  @observable
  int _cursorColumn = 0;

  @observable
  int? _pendingScrollToLine;

  @observable
  TextRange? _pendingSelectionRange;

  @observable
  bool _pendingSelectionRequestsFocus = true;

  @observable
  List<THTextEditorDiagnostic> _diagnostics = const <THTextEditorDiagnostic>[];

  /// The main field's last scroll offset. Kept across sessions, for
  /// re-entry.
  @override
  double lastScrollOffset = 0;

  @override
  final FocusNode textEditorFocusNode = FocusNode();

  @override
  final FocusNode textFieldFocusNode = FocusNode();

  @override
  late final THTextEditorFindController find = THTextEditorFindController(
    this,
  );

  TH2TextValidationCache _validationCache = TH2TextValidationCache();

  TH2TextLineTracker? _lineTracker;

  Timer? _idleTimer;

  /// Advances with every buffer edit; reset by a baseline installation.
  int _editGeneration = 0;

  bool _isDisposed = false;

  @override
  String get content => _content;

  @override
  String get initialContent => _initialContent;

  @override
  bool get isOpen => _isOpen;

  @override
  int get sessionRevision => _sessionRevision;

  @override
  int get baselineRevision => _baselineRevision;

  @override
  bool get hasTextEdits => _hasTextEdits;

  bool get isRecoveryReadOnly => _isRecoveryReadOnly;

  @override
  int get cursorLine => _cursorLine;

  int get cursorColumn => _cursorColumn;

  @override
  int? get pendingScrollToLine => _pendingScrollToLine;

  @override
  TextRange? get pendingSelectionRange => _pendingSelectionRange;

  @override
  bool get pendingSelectionRequestsFocus => _pendingSelectionRequestsFocus;

  @override
  List<THTextEditorDiagnostic> get diagnostics => _diagnostics;

  @override
  THTextEditorLanguage get language => THTextEditorLanguage.th2;

  @override
  String get lineEnding => _owner.defaultLineEnding;

  @override
  String? get revertTooltip =>
      mpLocator.appLocalizations.th2TextEditorDiscardTooltip;

  @override
  TH2TextLineMap get initialLineMap {
    final TH2TextLineMap? lineMap = _initialLineMap;

    if (lineMap == null) {
      throw StateError('No TH2 text session is open.');
    }

    return lineMap;
  }

  @override
  TH2TextValidationCache get validationCache => _validationCache;

  /// Follows the baseline's lines through the buffer's changes; `null` while
  /// no session is open.
  TH2TextLineTracker? get lineTracker => _lineTracker;

  bool get isDisposed => _isDisposed;

  @override
  @computed
  bool get isDirty => _isOpen && (_content != _initialContent);

  @override
  @computed
  bool get isReadOnly => _owner.isBufferLocked || _isRecoveryReadOnly;

  @override
  @computed
  bool get canSave => !_isRecoveryReadOnly && _owner.canSave;

  @override
  @computed
  List<THTextEditorToken> get tokens =>
      tokenizeTherionText(_content, language: THTextEditorLanguage.th2);

  @computed
  List<THTextEditorFoldRegion> get foldRegions =>
      buildFoldRegions(_content, language: THTextEditorLanguage.th2);

  /// Installs [baseline] as a new session, replacing any open one. Every
  /// field is set before the new session and baseline revisions are
  /// published, in one action. Never counts as an edit, never releases the
  /// operation-owned lock, and keeps the find bar's UI and query.
  @action
  void installBaseline(TH2TextEditBaseline baseline) {
    if (_isDisposed) {
      return;
    }

    _idleTimer?.cancel();
    _idleTimer = null;
    _content = baseline.content;
    _initialContent = baseline.content;
    _initialLineMap = baseline.lineMap;
    _lineTracker = baseline._lineTracker;
    _validationCache = baseline._validationCache;
    _diagnostics = const <THTextEditorDiagnostic>[];
    _hasTextEdits = false;
    _isRecoveryReadOnly = false;
    _cursorLine = baseline.cursorLine;
    _cursorColumn = baseline.cursorColumn;
    _pendingScrollToLine = null;
    _pendingSelectionRange = baseline.selection;
    _pendingSelectionRequestsFocus = baseline.selectionRequestsFocus;
    _editGeneration = 0;
    find.clampActiveMatchIndex();
    _isOpen = true;
    _sessionRevision++;
    _baselineRevision++;
  }

  /// Ends the session without an apply. Keeps only the last scroll offset.
  /// Never releases the operation-owned lock.
  @action
  void endSession() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _sessionRevision++;
    _isOpen = false;
    _content = '';
    _initialContent = '';
    _initialLineMap = null;
    _lineTracker = null;
    _validationCache.clear();
    _validationCache = TH2TextValidationCache();
    _diagnostics = const <THTextEditorDiagnostic>[];
    _hasTextEdits = false;
    _editGeneration = 0;
    _cursorLine = 0;
    _cursorColumn = 0;
    _pendingScrollToLine = null;
    _pendingSelectionRange = null;
    _pendingSelectionRequestsFocus = true;
    find.reset();
  }

  /// Makes the buffer read-only until a new baseline is installed.
  @action
  void enterRecoveryReadOnly() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _isRecoveryReadOnly = true;
  }

  @override
  @action
  bool setContent(String newContent, {int? cursorOffset}) {
    if (_isDisposed || !_isOpen || isReadOnly) {
      return false;
    }

    if (newContent == _content) {
      return true;
    }

    _lineTracker?.recordChange(
      oldText: _content,
      newText: newContent,
      cursorOffset: cursorOffset,
    );
    _content = newContent;
    _hasTextEdits = true;
    _diagnostics = const <THTextEditorDiagnostic>[];
    _editGeneration++;
    find.clampActiveMatchIndex();
    _scheduleValidation();

    return true;
  }

  @override
  @action
  void setCursorPosition({required int line, required int column}) {
    _cursorLine = line;
    _cursorColumn = column;
  }

  /// Scrolls to the 0-based [line].
  @action
  void scrollToLine(int line) {
    _pendingScrollToLine = line;
  }

  @override
  @action
  void clearPendingScrollToLine() {
    _pendingScrollToLine = null;
  }

  @action
  void revealRange(TextRange range, {bool requestFocus = true}) {
    _pendingSelectionRange = range;
    _pendingSelectionRequestsFocus = requestFocus;
  }

  @override
  @action
  void clearPendingSelectionRange() {
    _pendingSelectionRange = null;
    _pendingSelectionRequestsFocus = true;
  }

  /// Takes the owner's operation-owned buffer lock.
  @override
  void lockBuffer() {
    _owner.acquireBufferLock();
  }

  @override
  Future<void> save() async {
    if (!canSave) {
      return;
    }

    try {
      await _owner.save();
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[TH2TextEditController] save failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Discards the text edits through the owner's gated operation.
  @override
  Future<void> revert() async {
    if (_isRecoveryReadOnly) {
      return;
    }

    await _owner.discardTextEdits();
  }

  /// Canvas history is reachable only before the first text edit.
  @override
  Future<void> requestCanvasHistory({required bool redo}) async {
    if (isReadOnly || _hasTextEdits || !_isOpen) {
      return;
    }

    await _owner.requestCanvasHistory(redo: redo);
  }

  void _scheduleValidation() {
    _idleTimer?.cancel();

    final int revision = _sessionRevision;
    final int generation = _editGeneration;

    _idleTimer = Timer(
      const Duration(milliseconds: mpTH2TextValidationIdleMilliseconds),
      () {
        _idleTimer = null;
        unawaited(_validateIdle(revision, generation));
      },
    );
  }

  bool _isCurrent(int revision, int generation) =>
      !_isDisposed &&
      !_owner.isDisposed &&
      _isOpen &&
      (_sessionRevision == revision) &&
      (_editGeneration == generation);

  Future<void> _validateIdle(int revision, int generation) async {
    if (!_isCurrent(revision, generation)) {
      return;
    }

    final String content = _content;

    try {
      final TH2TextValidationResult result = await _validationCache.validate(
        content,
        filename: _owner.filename,
        th2FileMPID: _owner.th2FileMPID,
        lineEnding: _owner.defaultLineEnding,
      );

      if (!_isCurrent(revision, generation) ||
          (result.content != _content)) {
        return;
      }

      _publishDiagnostics(result.diagnostics);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[TH2TextEditController] idle validation failed',
        error: error,
        stackTrace: stackTrace,
      );

      if (_isCurrent(revision, generation)) {
        _publishValidationFailure();
      }
    }
  }

  @action
  void _publishDiagnostics(List<TH2TextDiagnostic> diagnostics) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    _diagnostics = List<THTextEditorDiagnostic>.unmodifiable(
      diagnostics.map(
        (TH2TextDiagnostic diagnostic) =>
            thTextEditorDiagnosticFromTH2(diagnostic, appLocalizations),
      ),
    );
  }

  @action
  void _publishValidationFailure() {
    _diagnostics = List<THTextEditorDiagnostic>.unmodifiable(
      <THTextEditorDiagnostic>[
        THTextEditorDiagnostic(
          line: null,
          message:
              mpLocator.appLocalizations.th2TextDiagnosticValidationFailed,
          severity: THTextEditorDiagnosticSeverity.error,
        ),
      ],
    );
  }

  /// Late completions can neither install diagnostics nor revive a session.
  void dispose() {
    _isDisposed = true;
    _idleTimer?.cancel();
    _idleTimer = null;
    _validationCache.clear();
    textEditorFocusNode.dispose();
    textFieldFocusNode.dispose();
  }

  @visibleForTesting
  bool get hasPendingIdleValidation => _idleTimer?.isActive ?? false;
}

/// The editor diagnostic of a TH2 text [diagnostic]. Its line stays 0-based.
THTextEditorDiagnostic thTextEditorDiagnosticFromTH2(
  TH2TextDiagnostic diagnostic,
  AppLocalizations appLocalizations,
) {
  final String message = switch (diagnostic.kind) {
    TH2TextDiagnosticKind.unsupportedLineEnding =>
      appLocalizations.th2TextDiagnosticUnsupportedLineEnding,
    TH2TextDiagnosticKind.unencodableCharacter =>
      appLocalizations.th2TextDiagnosticUnencodableCharacter(
        diagnostic.detail ?? '',
      ),
    TH2TextDiagnosticKind.unreadableText =>
      appLocalizations.th2TextDiagnosticUnreadableText,
    TH2TextDiagnosticKind.parseProblem =>
      (diagnostic.problem == null)
          ? appLocalizations.th2FileProblemParseError
          : TH2FileProblemTextAux.userMessage(
              diagnostic.problem!.kind,
              appLocalizations,
            ),
    TH2TextDiagnosticKind.removedDuplicateLinePoint =>
      appLocalizations.th2TextDiagnosticRemovedDuplicateLinePoint,
    TH2TextDiagnosticKind.removedShortLine =>
      appLocalizations.th2TextDiagnosticRemovedShortLine,
    TH2TextDiagnosticKind.removedBorderOfShortLine =>
      appLocalizations.th2TextDiagnosticRemovedBorderOfShortLine,
    TH2TextDiagnosticKind.removedEmptyArea =>
      appLocalizations.th2TextDiagnosticRemovedEmptyArea,
    TH2TextDiagnosticKind.rewrittenLine =>
      appLocalizations.th2TextDiagnosticRewrittenLine,
    TH2TextDiagnosticKind.genericRewrite =>
      appLocalizations.th2TextDiagnosticGenericRewrite,
    TH2TextDiagnosticKind.movedSetting =>
      appLocalizations.th2TextDiagnosticMovedSetting(
        (diagnostic.destinationLine ?? 0) + 1,
      ),
    TH2TextDiagnosticKind.addedLine =>
      appLocalizations.th2TextDiagnosticAddedLine(diagnostic.detail ?? ''),
    TH2TextDiagnosticKind.addedEnding =>
      appLocalizations.th2TextDiagnosticAddedEnding,
  };

  return THTextEditorDiagnostic(
    line: diagnostic.line,
    message: message,
    severity: diagnostic.isError
        ? THTextEditorDiagnosticSeverity.error
        : THTextEditorDiagnosticSeverity.information,
  );
}
