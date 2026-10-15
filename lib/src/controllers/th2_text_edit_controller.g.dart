// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_text_edit_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2TextEditController on TH2TextEditControllerBase, Store {
  Computed<bool>? _$isDirtyComputed;

  @override
  bool get isDirty => (_$isDirtyComputed ??= Computed<bool>(
    () => super.isDirty,
    name: 'TH2TextEditControllerBase.isDirty',
  )).value;
  Computed<bool>? _$isReadOnlyComputed;

  @override
  bool get isReadOnly => (_$isReadOnlyComputed ??= Computed<bool>(
    () => super.isReadOnly,
    name: 'TH2TextEditControllerBase.isReadOnly',
  )).value;
  Computed<bool>? _$canSaveComputed;

  @override
  bool get canSave => (_$canSaveComputed ??= Computed<bool>(
    () => super.canSave,
    name: 'TH2TextEditControllerBase.canSave',
  )).value;
  Computed<List<THTextEditorToken>>? _$tokensComputed;

  @override
  List<THTextEditorToken> get tokens =>
      (_$tokensComputed ??= Computed<List<THTextEditorToken>>(
        () => super.tokens,
        name: 'TH2TextEditControllerBase.tokens',
      )).value;
  Computed<List<THTextEditorFoldRegion>>? _$foldRegionsComputed;

  @override
  List<THTextEditorFoldRegion> get foldRegions =>
      (_$foldRegionsComputed ??= Computed<List<THTextEditorFoldRegion>>(
        () => super.foldRegions,
        name: 'TH2TextEditControllerBase.foldRegions',
      )).value;

  late final _$_contentAtom = Atom(
    name: 'TH2TextEditControllerBase._content',
    context: context,
  );

  @override
  String get _content {
    _$_contentAtom.reportRead();
    return super._content;
  }

  @override
  set _content(String value) {
    _$_contentAtom.reportWrite(value, super._content, () {
      super._content = value;
    });
  }

  late final _$_initialContentAtom = Atom(
    name: 'TH2TextEditControllerBase._initialContent',
    context: context,
  );

  @override
  String get _initialContent {
    _$_initialContentAtom.reportRead();
    return super._initialContent;
  }

  @override
  set _initialContent(String value) {
    _$_initialContentAtom.reportWrite(value, super._initialContent, () {
      super._initialContent = value;
    });
  }

  late final _$_isOpenAtom = Atom(
    name: 'TH2TextEditControllerBase._isOpen',
    context: context,
  );

  @override
  bool get _isOpen {
    _$_isOpenAtom.reportRead();
    return super._isOpen;
  }

  @override
  set _isOpen(bool value) {
    _$_isOpenAtom.reportWrite(value, super._isOpen, () {
      super._isOpen = value;
    });
  }

  late final _$_sessionRevisionAtom = Atom(
    name: 'TH2TextEditControllerBase._sessionRevision',
    context: context,
  );

  @override
  int get _sessionRevision {
    _$_sessionRevisionAtom.reportRead();
    return super._sessionRevision;
  }

  @override
  set _sessionRevision(int value) {
    _$_sessionRevisionAtom.reportWrite(value, super._sessionRevision, () {
      super._sessionRevision = value;
    });
  }

  late final _$_baselineRevisionAtom = Atom(
    name: 'TH2TextEditControllerBase._baselineRevision',
    context: context,
  );

  @override
  int get _baselineRevision {
    _$_baselineRevisionAtom.reportRead();
    return super._baselineRevision;
  }

  @override
  set _baselineRevision(int value) {
    _$_baselineRevisionAtom.reportWrite(value, super._baselineRevision, () {
      super._baselineRevision = value;
    });
  }

  late final _$_hasTextEditsAtom = Atom(
    name: 'TH2TextEditControllerBase._hasTextEdits',
    context: context,
  );

  @override
  bool get _hasTextEdits {
    _$_hasTextEditsAtom.reportRead();
    return super._hasTextEdits;
  }

  @override
  set _hasTextEdits(bool value) {
    _$_hasTextEditsAtom.reportWrite(value, super._hasTextEdits, () {
      super._hasTextEdits = value;
    });
  }

  late final _$_isRecoveryReadOnlyAtom = Atom(
    name: 'TH2TextEditControllerBase._isRecoveryReadOnly',
    context: context,
  );

  @override
  bool get _isRecoveryReadOnly {
    _$_isRecoveryReadOnlyAtom.reportRead();
    return super._isRecoveryReadOnly;
  }

  @override
  set _isRecoveryReadOnly(bool value) {
    _$_isRecoveryReadOnlyAtom.reportWrite(value, super._isRecoveryReadOnly, () {
      super._isRecoveryReadOnly = value;
    });
  }

  late final _$_cursorLineAtom = Atom(
    name: 'TH2TextEditControllerBase._cursorLine',
    context: context,
  );

  @override
  int get _cursorLine {
    _$_cursorLineAtom.reportRead();
    return super._cursorLine;
  }

  @override
  set _cursorLine(int value) {
    _$_cursorLineAtom.reportWrite(value, super._cursorLine, () {
      super._cursorLine = value;
    });
  }

  late final _$_cursorColumnAtom = Atom(
    name: 'TH2TextEditControllerBase._cursorColumn',
    context: context,
  );

  @override
  int get _cursorColumn {
    _$_cursorColumnAtom.reportRead();
    return super._cursorColumn;
  }

  @override
  set _cursorColumn(int value) {
    _$_cursorColumnAtom.reportWrite(value, super._cursorColumn, () {
      super._cursorColumn = value;
    });
  }

  late final _$_pendingScrollToLineAtom = Atom(
    name: 'TH2TextEditControllerBase._pendingScrollToLine',
    context: context,
  );

  @override
  int? get _pendingScrollToLine {
    _$_pendingScrollToLineAtom.reportRead();
    return super._pendingScrollToLine;
  }

  @override
  set _pendingScrollToLine(int? value) {
    _$_pendingScrollToLineAtom.reportWrite(
      value,
      super._pendingScrollToLine,
      () {
        super._pendingScrollToLine = value;
      },
    );
  }

  late final _$_pendingSelectionRangeAtom = Atom(
    name: 'TH2TextEditControllerBase._pendingSelectionRange',
    context: context,
  );

  @override
  TextRange? get _pendingSelectionRange {
    _$_pendingSelectionRangeAtom.reportRead();
    return super._pendingSelectionRange;
  }

  @override
  set _pendingSelectionRange(TextRange? value) {
    _$_pendingSelectionRangeAtom.reportWrite(
      value,
      super._pendingSelectionRange,
      () {
        super._pendingSelectionRange = value;
      },
    );
  }

  late final _$_pendingSelectionRequestsFocusAtom = Atom(
    name: 'TH2TextEditControllerBase._pendingSelectionRequestsFocus',
    context: context,
  );

  @override
  bool get _pendingSelectionRequestsFocus {
    _$_pendingSelectionRequestsFocusAtom.reportRead();
    return super._pendingSelectionRequestsFocus;
  }

  @override
  set _pendingSelectionRequestsFocus(bool value) {
    _$_pendingSelectionRequestsFocusAtom.reportWrite(
      value,
      super._pendingSelectionRequestsFocus,
      () {
        super._pendingSelectionRequestsFocus = value;
      },
    );
  }

  late final _$_diagnosticsAtom = Atom(
    name: 'TH2TextEditControllerBase._diagnostics',
    context: context,
  );

  @override
  List<THTextEditorDiagnostic> get _diagnostics {
    _$_diagnosticsAtom.reportRead();
    return super._diagnostics;
  }

  @override
  set _diagnostics(List<THTextEditorDiagnostic> value) {
    _$_diagnosticsAtom.reportWrite(value, super._diagnostics, () {
      super._diagnostics = value;
    });
  }

  late final _$TH2TextEditControllerBaseActionController = ActionController(
    name: 'TH2TextEditControllerBase',
    context: context,
  );

  @override
  void installBaseline(TH2TextEditBaseline baseline) {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(name: 'TH2TextEditControllerBase.installBaseline');
    try {
      return super.installBaseline(baseline);
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void endSession() {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(name: 'TH2TextEditControllerBase.endSession');
    try {
      return super.endSession();
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void enterRecoveryReadOnly() {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(name: 'TH2TextEditControllerBase.enterRecoveryReadOnly');
    try {
      return super.enterRecoveryReadOnly();
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  bool setContent(String newContent, {int? cursorOffset}) {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(name: 'TH2TextEditControllerBase.setContent');
    try {
      return super.setContent(newContent, cursorOffset: cursorOffset);
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCursorPosition({required int line, required int column}) {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(name: 'TH2TextEditControllerBase.setCursorPosition');
    try {
      return super.setCursorPosition(line: line, column: column);
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void scrollToLine(int line) {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(name: 'TH2TextEditControllerBase.scrollToLine');
    try {
      return super.scrollToLine(line);
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPendingScrollToLine() {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(
          name: 'TH2TextEditControllerBase.clearPendingScrollToLine',
        );
    try {
      return super.clearPendingScrollToLine();
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void revealRange(TextRange range, {bool requestFocus = true}) {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(name: 'TH2TextEditControllerBase.revealRange');
    try {
      return super.revealRange(range, requestFocus: requestFocus);
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPendingSelectionRange() {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(
          name: 'TH2TextEditControllerBase.clearPendingSelectionRange',
        );
    try {
      return super.clearPendingSelectionRange();
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _publishDiagnostics(List<TH2TextDiagnostic> diagnostics) {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(name: 'TH2TextEditControllerBase._publishDiagnostics');
    try {
      return super._publishDiagnostics(diagnostics);
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _publishValidationFailure() {
    final _$actionInfo = _$TH2TextEditControllerBaseActionController
        .startAction(
          name: 'TH2TextEditControllerBase._publishValidationFailure',
        );
    try {
      return super._publishValidationFailure();
    } finally {
      _$TH2TextEditControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isDirty: ${isDirty},
isReadOnly: ${isReadOnly},
canSave: ${canSave},
tokens: ${tokens},
foldRegions: ${foldRegions}
    ''';
  }
}
