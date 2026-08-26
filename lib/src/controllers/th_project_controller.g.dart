// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_project_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THProjectController on THProjectControllerBase, Store {
  Computed<List<THProjectParseError>>? _$allDiagnosticsComputed;

  @override
  List<THProjectParseError> get allDiagnostics =>
      (_$allDiagnosticsComputed ??= Computed<List<THProjectParseError>>(
        () => super.allDiagnostics,
        name: 'THProjectControllerBase.allDiagnostics',
      )).value;
  Computed<bool>? _$hasUnsavedChangesComputed;

  @override
  bool get hasUnsavedChanges => (_$hasUnsavedChangesComputed ??= Computed<bool>(
    () => super.hasUnsavedChanges,
    name: 'THProjectControllerBase.hasUnsavedChanges',
  )).value;

  late final _$rootConfigPathAtom = Atom(
    name: 'THProjectControllerBase.rootConfigPath',
    context: context,
  );

  @override
  String get rootConfigPath {
    _$rootConfigPathAtom.reportRead();
    return super.rootConfigPath;
  }

  @override
  set rootConfigPath(String value) {
    _$rootConfigPathAtom.reportWrite(value, super.rootConfigPath, () {
      super.rootConfigPath = value;
    });
  }

  late final _$projectRootNodeAtom = Atom(
    name: 'THProjectControllerBase.projectRootNode',
    context: context,
  );

  @override
  THProjectFileNode? get projectRootNode {
    _$projectRootNodeAtom.reportRead();
    return super.projectRootNode;
  }

  @override
  set projectRootNode(THProjectFileNode? value) {
    _$projectRootNodeAtom.reportWrite(value, super.projectRootNode, () {
      super.projectRootNode = value;
    });
  }

  late final _$isParsingAtom = Atom(
    name: 'THProjectControllerBase.isParsing',
    context: context,
  );

  @override
  bool get isParsing {
    _$isParsingAtom.reportRead();
    return super.isParsing;
  }

  @override
  set isParsing(bool value) {
    _$isParsingAtom.reportWrite(value, super.isParsing, () {
      super.isParsing = value;
    });
  }

  late final _$projectErrorsAtom = Atom(
    name: 'THProjectControllerBase.projectErrors',
    context: context,
  );

  @override
  ObservableList<THProjectParseError> get projectErrors {
    _$projectErrorsAtom.reportRead();
    return super.projectErrors;
  }

  @override
  set projectErrors(ObservableList<THProjectParseError> value) {
    _$projectErrorsAtom.reportWrite(value, super.projectErrors, () {
      super.projectErrors = value;
    });
  }

  late final _$activeSelectedNodeIdAtom = Atom(
    name: 'THProjectControllerBase.activeSelectedNodeId',
    context: context,
  );

  @override
  String? get activeSelectedNodeId {
    _$activeSelectedNodeIdAtom.reportRead();
    return super.activeSelectedNodeId;
  }

  @override
  set activeSelectedNodeId(String? value) {
    _$activeSelectedNodeIdAtom.reportWrite(
      value,
      super.activeSelectedNodeId,
      () {
        super.activeSelectedNodeId = value;
      },
    );
  }

  late final _$fileContentsCacheAtom = Atom(
    name: 'THProjectControllerBase.fileContentsCache',
    context: context,
  );

  @override
  ObservableMap<String, String> get fileContentsCache {
    _$fileContentsCacheAtom.reportRead();
    return super.fileContentsCache;
  }

  @override
  set fileContentsCache(ObservableMap<String, String> value) {
    _$fileContentsCacheAtom.reportWrite(value, super.fileContentsCache, () {
      super.fileContentsCache = value;
    });
  }

  late final _$dirtyFilePathsAtom = Atom(
    name: 'THProjectControllerBase.dirtyFilePaths',
    context: context,
  );

  @override
  ObservableSet<String> get dirtyFilePaths {
    _$dirtyFilePathsAtom.reportRead();
    return super.dirtyFilePaths;
  }

  @override
  set dirtyFilePaths(ObservableSet<String> value) {
    _$dirtyFilePathsAtom.reportWrite(value, super.dirtyFilePaths, () {
      super.dirtyFilePaths = value;
    });
  }

  late final _$compilerErrorsAtom = Atom(
    name: 'THProjectControllerBase.compilerErrors',
    context: context,
  );

  @override
  ObservableList<THProjectParseError> get compilerErrors {
    _$compilerErrorsAtom.reportRead();
    return super.compilerErrors;
  }

  @override
  set compilerErrors(ObservableList<THProjectParseError> value) {
    _$compilerErrorsAtom.reportWrite(value, super.compilerErrors, () {
      super.compilerErrors = value;
    });
  }

  late final _$openProjectAsyncAction = AsyncAction(
    'THProjectControllerBase.openProject',
    context: context,
  );

  @override
  Future<void> openProject(
    String configFilePath, {
    bool forceConfigShape = false,
  }) {
    return _$openProjectAsyncAction.run(
      () =>
          super.openProject(configFilePath, forceConfigShape: forceConfigShape),
    );
  }

  late final _$reloadProjectAsyncAction = AsyncAction(
    'THProjectControllerBase.reloadProject',
    context: context,
  );

  @override
  Future<void> reloadProject() {
    return _$reloadProjectAsyncAction.run(() => super.reloadProject());
  }

  late final _$reparseFileAsyncAction = AsyncAction(
    'THProjectControllerBase.reparseFile',
    context: context,
  );

  @override
  Future<void> reparseFile({
    required String filePath,
    required String updatedContent,
  }) {
    return _$reparseFileAsyncAction.run(
      () =>
          super.reparseFile(filePath: filePath, updatedContent: updatedContent),
    );
  }

  late final _$_performReparseAsyncAction = AsyncAction(
    'THProjectControllerBase._performReparse',
    context: context,
  );

  @override
  Future<void> _performReparse(String canonicalPath, String updatedContent) {
    return _$_performReparseAsyncAction.run(
      () => super._performReparse(canonicalPath, updatedContent),
    );
  }

  late final _$saveProjectFileAsyncAction = AsyncAction(
    'THProjectControllerBase.saveProjectFile',
    context: context,
  );

  @override
  Future<void> saveProjectFile(String filePath) {
    return _$saveProjectFileAsyncAction.run(
      () => super.saveProjectFile(filePath),
    );
  }

  late final _$saveAllModifiedFilesAsyncAction = AsyncAction(
    'THProjectControllerBase.saveAllModifiedFiles',
    context: context,
  );

  @override
  Future<void> saveAllModifiedFiles() {
    return _$saveAllModifiedFilesAsyncAction.run(
      () => super.saveAllModifiedFiles(),
    );
  }

  late final _$THProjectControllerBaseActionController = ActionController(
    name: 'THProjectControllerBase',
    context: context,
  );

  @override
  void applyTherionRunDiagnostics(List<THProjectParseError> diagnostics) {
    final _$actionInfo = _$THProjectControllerBaseActionController.startAction(
      name: 'THProjectControllerBase.applyTherionRunDiagnostics',
    );
    try {
      return super.applyTherionRunDiagnostics(diagnostics);
    } finally {
      _$THProjectControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void closeProject() {
    final _$actionInfo = _$THProjectControllerBaseActionController.startAction(
      name: 'THProjectControllerBase.closeProject',
    );
    try {
      return super.closeProject();
    } finally {
      _$THProjectControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectNode(String nodeId) {
    final _$actionInfo = _$THProjectControllerBaseActionController.startAction(
      name: 'THProjectControllerBase.selectNode',
    );
    try {
      return super.selectNode(nodeId);
    } finally {
      _$THProjectControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
rootConfigPath: ${rootConfigPath},
projectRootNode: ${projectRootNode},
isParsing: ${isParsing},
projectErrors: ${projectErrors},
activeSelectedNodeId: ${activeSelectedNodeId},
fileContentsCache: ${fileContentsCache},
dirtyFilePaths: ${dirtyFilePaths},
compilerErrors: ${compilerErrors},
allDiagnostics: ${allDiagnostics},
hasUnsavedChanges: ${hasUnsavedChanges}
    ''';
  }
}
