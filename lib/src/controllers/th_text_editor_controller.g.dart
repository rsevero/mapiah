// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_text_editor_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THTextEditorController on THTextEditorControllerBase, Store {
  Computed<List<THProjectParseError>>? _$diagnosticsComputed;

  @override
  List<THProjectParseError> get diagnostics =>
      (_$diagnosticsComputed ??= Computed<List<THProjectParseError>>(
        () => super.diagnostics,
        name: 'THTextEditorControllerBase.diagnostics',
      )).value;
  Computed<List<THTextEditorFoldRegion>>? _$foldRegionsComputed;

  @override
  List<THTextEditorFoldRegion> get foldRegions =>
      (_$foldRegionsComputed ??= Computed<List<THTextEditorFoldRegion>>(
        () => super.foldRegions,
        name: 'THTextEditorControllerBase.foldRegions',
      )).value;
  Computed<List<TextRange>>? _$findMatchesComputed;

  @override
  List<TextRange> get findMatches =>
      (_$findMatchesComputed ??= Computed<List<TextRange>>(
        () => super.findMatches,
        name: 'THTextEditorControllerBase.findMatches',
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

  late final _$findQueryAtom = Atom(
    name: 'THTextEditorControllerBase.findQuery',
    context: context,
  );

  @override
  String get findQuery {
    _$findQueryAtom.reportRead();
    return super.findQuery;
  }

  @override
  set findQuery(String value) {
    _$findQueryAtom.reportWrite(value, super.findQuery, () {
      super.findQuery = value;
    });
  }

  late final _$replaceQueryAtom = Atom(
    name: 'THTextEditorControllerBase.replaceQuery',
    context: context,
  );

  @override
  String get replaceQuery {
    _$replaceQueryAtom.reportRead();
    return super.replaceQuery;
  }

  @override
  set replaceQuery(String value) {
    _$replaceQueryAtom.reportWrite(value, super.replaceQuery, () {
      super.replaceQuery = value;
    });
  }

  late final _$findCaseSensitiveAtom = Atom(
    name: 'THTextEditorControllerBase.findCaseSensitive',
    context: context,
  );

  @override
  bool get findCaseSensitive {
    _$findCaseSensitiveAtom.reportRead();
    return super.findCaseSensitive;
  }

  @override
  set findCaseSensitive(bool value) {
    _$findCaseSensitiveAtom.reportWrite(value, super.findCaseSensitive, () {
      super.findCaseSensitive = value;
    });
  }

  late final _$isFindBarVisibleAtom = Atom(
    name: 'THTextEditorControllerBase.isFindBarVisible',
    context: context,
  );

  @override
  bool get isFindBarVisible {
    _$isFindBarVisibleAtom.reportRead();
    return super.isFindBarVisible;
  }

  @override
  set isFindBarVisible(bool value) {
    _$isFindBarVisibleAtom.reportWrite(value, super.isFindBarVisible, () {
      super.isFindBarVisible = value;
    });
  }

  late final _$activeMatchIndexAtom = Atom(
    name: 'THTextEditorControllerBase.activeMatchIndex',
    context: context,
  );

  @override
  int? get activeMatchIndex {
    _$activeMatchIndexAtom.reportRead();
    return super.activeMatchIndex;
  }

  @override
  set activeMatchIndex(int? value) {
    _$activeMatchIndexAtom.reportWrite(value, super.activeMatchIndex, () {
      super.activeMatchIndex = value;
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
  void revealRange(TextRange range) {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.revealRange');
    try {
      return super.revealRange(range);
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
  void setContent(String newContent) {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.setContent');
    try {
      return super.setContent(newContent);
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
  void openFindBar() {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.openFindBar');
    try {
      return super.openFindBar();
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void closeFindBar() {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.closeFindBar');
    try {
      return super.closeFindBar();
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFindQuery(String query) {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.setFindQuery');
    try {
      return super.setFindQuery(query);
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReplaceQuery(String query) {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.setReplaceQuery');
    try {
      return super.setReplaceQuery(query);
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFindCaseSensitive(bool value) {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.setFindCaseSensitive');
    try {
      return super.setFindCaseSensitive(value);
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void findNext() {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.findNext');
    try {
      return super.findNext();
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void findPrevious() {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.findPrevious');
    try {
      return super.findPrevious();
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void replaceActiveMatch() {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.replaceActiveMatch');
    try {
      return super.replaceActiveMatch();
    } finally {
      _$THTextEditorControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void replaceAllMatches() {
    final _$actionInfo = _$THTextEditorControllerBaseActionController
        .startAction(name: 'THTextEditorControllerBase.replaceAllMatches');
    try {
      return super.replaceAllMatches();
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
findQuery: ${findQuery},
replaceQuery: ${replaceQuery},
findCaseSensitive: ${findCaseSensitive},
isFindBarVisible: ${isFindBarVisible},
activeMatchIndex: ${activeMatchIndex},
pendingScrollToLine: ${pendingScrollToLine},
pendingSelectionRange: ${pendingSelectionRange},
loadState: ${loadState},
observedRevision: ${observedRevision},
lastOperationRejectedByProjectChange: ${lastOperationRejectedByProjectChange},
diagnostics: ${diagnostics},
foldRegions: ${foldRegions},
findMatches: ${findMatches}
    ''';
  }
}
