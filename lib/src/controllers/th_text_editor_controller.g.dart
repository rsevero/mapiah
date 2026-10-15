// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_text_editor_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THTextEditorController on THTextEditorControllerBase, Store {
  Computed<List<THTextEditorDiagnostic>>? _$diagnosticsComputed;

  @override
  List<THTextEditorDiagnostic> get diagnostics =>
      (_$diagnosticsComputed ??= Computed<List<THTextEditorDiagnostic>>(
        () => super.diagnostics,
        name: 'THTextEditorControllerBase.diagnostics',
      )).value;
  Computed<List<THTextEditorToken>>? _$tokensComputed;

  @override
  List<THTextEditorToken> get tokens =>
      (_$tokensComputed ??= Computed<List<THTextEditorToken>>(
        () => super.tokens,
        name: 'THTextEditorControllerBase.tokens',
      )).value;
  Computed<List<THTextEditorFoldRegion>>? _$foldRegionsComputed;

  @override
  List<THTextEditorFoldRegion> get foldRegions =>
      (_$foldRegionsComputed ??= Computed<List<THTextEditorFoldRegion>>(
        () => super.foldRegions,
        name: 'THTextEditorControllerBase.foldRegions',
      )).value;

  late final _$canonicalPathAtom = Atom(
    name: 'THTextEditorControllerBase.canonicalPath',
    context: context,
  );

  @override
  String get canonicalPath {
    _$canonicalPathAtom.reportRead();
    return super.canonicalPath;
  }

  @override
  set canonicalPath(String value) {
    _$canonicalPathAtom.reportWrite(value, super.canonicalPath, () {
      super.canonicalPath = value;
    });
  }

  late final _$contentAtom = Atom(
    name: 'THTextEditorControllerBase.content',
    context: context,
  );

  @override
  String get content {
    _$contentAtom.reportRead();
    return super.content;
  }

  @override
  set content(String value) {
    _$contentAtom.reportWrite(value, super.content, () {
      super.content = value;
    });
  }

  late final _$isDirtyAtom = Atom(
    name: 'THTextEditorControllerBase.isDirty',
    context: context,
  );

  @override
  bool get isDirty {
    _$isDirtyAtom.reportRead();
    return super.isDirty;
  }

  @override
  set isDirty(bool value) {
    _$isDirtyAtom.reportWrite(value, super.isDirty, () {
      super.isDirty = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'THTextEditorControllerBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$cursorLineAtom = Atom(
    name: 'THTextEditorControllerBase.cursorLine',
    context: context,
  );

  @override
  int get cursorLine {
    _$cursorLineAtom.reportRead();
    return super.cursorLine;
  }

  @override
  set cursorLine(int value) {
    _$cursorLineAtom.reportWrite(value, super.cursorLine, () {
      super.cursorLine = value;
    });
  }

  late final _$cursorColumnAtom = Atom(
    name: 'THTextEditorControllerBase.cursorColumn',
    context: context,
  );

  @override
  int get cursorColumn {
    _$cursorColumnAtom.reportRead();
    return super.cursorColumn;
  }

  @override
  set cursorColumn(int value) {
    _$cursorColumnAtom.reportWrite(value, super.cursorColumn, () {
      super.cursorColumn = value;
    });
  }

  late final _$collapsedFoldStartsAtom = Atom(
    name: 'THTextEditorControllerBase.collapsedFoldStarts',
    context: context,
  );

  @override
  ObservableSet<int> get collapsedFoldStarts {
    _$collapsedFoldStartsAtom.reportRead();
    return super.collapsedFoldStarts;
  }

  @override
  set collapsedFoldStarts(ObservableSet<int> value) {
    _$collapsedFoldStartsAtom.reportWrite(value, super.collapsedFoldStarts, () {
      super.collapsedFoldStarts = value;
    });
  }

  late final _$pendingScrollToLineAtom = Atom(
    name: 'THTextEditorControllerBase.pendingScrollToLine',
    context: context,
  );

  @override
  int? get pendingScrollToLine {
    _$pendingScrollToLineAtom.reportRead();
    return super.pendingScrollToLine;
  }

  @override
  set pendingScrollToLine(int? value) {
    _$pendingScrollToLineAtom.reportWrite(value, super.pendingScrollToLine, () {
      super.pendingScrollToLine = value;
    });
  }

  late final _$pendingSelectionRangeAtom = Atom(
    name: 'THTextEditorControllerBase.pendingSelectionRange',
    context: context,
  );

  @override
  TextRange? get pendingSelectionRange {
    _$pendingSelectionRangeAtom.reportRead();
    return super.pendingSelectionRange;
  }

  @override
  set pendingSelectionRange(TextRange? value) {
    _$pendingSelectionRangeAtom.reportWrite(
      value,
      super.pendingSelectionRange,
      () {
        super.pendingSelectionRange = value;
      },
    );
  }

  late final _$pendingSelectionRequestsFocusAtom = Atom(
    name: 'THTextEditorControllerBase.pendingSelectionRequestsFocus',
    context: context,
  );

  @override
  bool get pendingSelectionRequestsFocus {
    _$pendingSelectionRequestsFocusAtom.reportRead();
    return super.pendingSelectionRequestsFocus;
  }

  @override
  set pendingSelectionRequestsFocus(bool value) {
    _$pendingSelectionRequestsFocusAtom.reportWrite(
      value,
      super.pendingSelectionRequestsFocus,
      () {
        super.pendingSelectionRequestsFocus = value;
      },
    );
  }

  late final _$loadStateAtom = Atom(
    name: 'THTextEditorControllerBase.loadState',
    context: context,
  );

  @override
  THTextEditorLoadState get loadState {
    _$loadStateAtom.reportRead();
    return super.loadState;
  }

  @override
  set loadState(THTextEditorLoadState value) {
    _$loadStateAtom.reportWrite(value, super.loadState, () {
      super.loadState = value;
    });
  }

  late final _$observedRevisionAtom = Atom(
    name: 'THTextEditorControllerBase.observedRevision',
    context: context,
  );

  @override
  int get observedRevision {
    _$observedRevisionAtom.reportRead();
    return super.observedRevision;
  }

  @override
  set observedRevision(int value) {
    _$observedRevisionAtom.reportWrite(value, super.observedRevision, () {
      super.observedRevision = value;
    });
  }

  late final _$lastOperationRejectedByProjectChangeAtom = Atom(
    name: 'THTextEditorControllerBase.lastOperationRejectedByProjectChange',
    context: context,
  );

  @override
  bool get lastOperationRejectedByProjectChange {
    _$lastOperationRejectedByProjectChangeAtom.reportRead();
    return super.lastOperationRejectedByProjectChange;
  }

  @override
  set lastOperationRejectedByProjectChange(bool value) {
    _$lastOperationRejectedByProjectChangeAtom.reportWrite(
      value,
      super.lastOperationRejectedByProjectChange,
      () {
        super.lastOperationRejectedByProjectChange = value;
      },
    );
  }

  late final _$loadFileAsyncAction = AsyncAction(
    'THTextEditorControllerBase.loadFile',
    context: context,
  );

  @override
  Future<void> loadFile(String filePath) {
    return _$loadFileAsyncAction.run(() => super.loadFile(filePath));
  }

  late final _$flushPendingReparseAsyncAction = AsyncAction(
    'THTextEditorControllerBase.flushPendingReparse',
    context: context,
  );

  @override
  Future<THProjectReparseFlushResult> flushPendingReparse() {
    return _$flushPendingReparseAsyncAction.run(
      () => super.flushPendingReparse(),
    );
  }

  late final _$saveAsyncAction = AsyncAction(
    'THTextEditorControllerBase.save',
    context: context,
  );

  @override
  Future<THTextFileSaveResult> save() {
    return _$saveAsyncAction.run(() => super.save());
  }

  late final _$saveAsAsyncAction = AsyncAction(
    'THTextEditorControllerBase.saveAs',
    context: context,
  );

  @override
  Future<THTextFileSaveAsResult> saveAs() {
    return _$saveAsAsyncAction.run(() => super.saveAs());
  }

  late final _$revertAsyncAction = AsyncAction(
    'THTextEditorControllerBase.revert',
    context: context,
  );

  @override
  Future<void> revert() {
    return _$revertAsyncAction.run(() => super.revert());
  }

  late final _$THTextEditorControllerBaseActionController = ActionController(
    name: 'THTextEditorControllerBase',
    context: context,
  );

  @override
  void revealRange(TextRange range, {bool requestFocus = true}) {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.revealRange');
    try {
      return super.revealRange(range, requestFocus: requestFocus);
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPendingSelectionRange() {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(
          name: 'THTextEditorControllerBase.clearPendingSelectionRange',
        );
    try {
      return super.clearPendingSelectionRange();
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  bool setContent(String newContent, {int? cursorOffset}) {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.setContent');
    try {
      return super.setContent(newContent, cursorOffset: cursorOffset);
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCursorPosition({required int line, required int column}) {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.setCursorPosition');
    try {
      return super.setCursorPosition(line: line, column: column);
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void scrollToLine(int lineNumber) {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.scrollToLine');
    try {
      return super.scrollToLine(lineNumber);
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPendingScrollToLine() {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(
          name: 'THTextEditorControllerBase.clearPendingScrollToLine',
        );
    try {
      return super.clearPendingScrollToLine();
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleFold(int startLine) {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.toggleFold');
    try {
      return super.toggleFold(startLine);
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
canonicalPath: ${canonicalPath},
content: ${content},
isDirty: ${isDirty},
isLoading: ${isLoading},
cursorLine: ${cursorLine},
cursorColumn: ${cursorColumn},
collapsedFoldStarts: ${collapsedFoldStarts},
pendingScrollToLine: ${pendingScrollToLine},
pendingSelectionRange: ${pendingSelectionRange},
pendingSelectionRequestsFocus: ${pendingSelectionRequestsFocus},
loadState: ${loadState},
observedRevision: ${observedRevision},
lastOperationRejectedByProjectChange: ${lastOperationRejectedByProjectChange},
diagnostics: ${diagnostics},
tokens: ${tokens},
foldRegions: ${foldRegions}
    ''';
  }
}
