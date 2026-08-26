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

  late final _$loadFileAsyncAction = AsyncAction(
    'THTextEditorControllerBase.loadFile',
    context: context,
  );

  @override
  Future<void> loadFile(String filePath) {
    return _$loadFileAsyncAction.run(() => super.loadFile(filePath));
  }

  late final _$saveAsyncAction = AsyncAction(
    'THTextEditorControllerBase.save',
    context: context,
  );

  @override
  Future<void> save() {
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
diagnostics: ${diagnostics},
foldRegions: ${foldRegions}
    ''';
  }
}
