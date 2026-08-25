// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_project_reparse_aux.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/mp_file_read_write/th_config_file_writer.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

part 'th_project_controller.g.dart';

class THProjectController = THProjectControllerBase
    with _$THProjectController;

/// MobX store that loads, holds, reloads, and closes a whole Therion
/// project starting from a root `thconfig` or root `.th` file.
///
/// This is a non-UI layer: it owns the project's file/logical tree,
/// dependency indexes, dirty-file tracking, and debounced single-file
/// re-parsing so that a future project tree widget and text editor widget
/// can observe it.
abstract class THProjectControllerBase with Store {
  @observable
  String rootConfigPath = '';

  @observable
  THProjectFileNode? projectRootNode;

  @observable
  bool isParsing = false;

  @observable
  ObservableList<THProjectParseError> projectErrors =
      ObservableList<THProjectParseError>();

  @observable
  String? activeSelectedNodeId;

  @observable
  ObservableMap<String, String> fileContentsCache =
      ObservableMap<String, String>();

  @observable
  ObservableSet<String> dirtyFilePaths = ObservableSet<String>();

  @computed
  bool get hasUnsavedChanges => dirtyFilePaths.isNotEmpty;

  final Map<String, Set<String>> _fileDependencies = <String, Set<String>>{};

  final Map<String, Set<String>> _reverseDependencies =
      <String, Set<String>>{};

  final Map<String, THProjectFileNode> _nodesByCanonicalPath =
      <String, THProjectFileNode>{};

  final Map<String, THProjectNode> _nodesById = <String, THProjectNode>{};

  final Map<String, Timer> _reparseTimers = <String, Timer>{};

  /// Project-level diagnostics that are not attached to any tree node, such
  /// as cycle-detection warnings. Kept separately because [projectErrors] is
  /// otherwise rebuilt from a tree walk after every incremental re-parse.
  final List<THProjectParseError> _looseProjectErrors =
      <THProjectParseError>[];

  @action
  Future<void> openProject(
    String configFilePath, {
    bool forceConfigShape = false,
  }) async {
    final String canonicalRootPath = THProjectPathResolver.canonicalize(
      p.absolute(configFilePath),
    );

    _cancelAllReparseTimers();
    closeProject();

    rootConfigPath = canonicalRootPath;
    isParsing = true;

    try {
      final THProjectLoadResult result = await Future<THProjectLoadResult>(
        () => THProjectParser.loadProject(
          canonicalRootPath,
          expectedShape: forceConfigShape
              ? THProjectShape.config
              : null,
        ),
      );

      _applyLoadResult(result);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] openProject failed for $canonicalRootPath',
        error: error,
        stackTrace: stackTrace,
      );
      projectErrors.add(
        THProjectParseError(
          message: 'Failed to open project: $error',
          severity: THProjectParseErrorSeverity.error,
          filePath: canonicalRootPath,
          lineNumber: 0,
        ),
      );
    } finally {
      isParsing = false;
    }
  }

  @action
  Future<void> reloadProject() async {
    if (rootConfigPath.isEmpty) {
      return;
    }

    final String canonicalRootPath = rootConfigPath;

    _cancelAllReparseTimers();
    isParsing = true;

    try {
      final THProjectLoadResult result = await Future<THProjectLoadResult>(
        () => THProjectParser.loadProject(canonicalRootPath),
      );

      _applyLoadResult(result);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] reloadProject failed for $canonicalRootPath',
        error: error,
        stackTrace: stackTrace,
      );
      projectErrors.add(
        THProjectParseError(
          message: 'Failed to reload project: $error',
          severity: THProjectParseErrorSeverity.error,
          filePath: canonicalRootPath,
          lineNumber: 0,
        ),
      );
    } finally {
      isParsing = false;
    }
  }

  @action
  void closeProject() {
    _cancelAllReparseTimers();

    rootConfigPath = '';
    projectRootNode = null;
    projectErrors = ObservableList<THProjectParseError>();
    activeSelectedNodeId = null;
    fileContentsCache = ObservableMap<String, String>();
    dirtyFilePaths = ObservableSet<String>();
    _fileDependencies.clear();
    _reverseDependencies.clear();
    _nodesByCanonicalPath.clear();
    _nodesById.clear();
    _looseProjectErrors.clear();
    isParsing = false;
  }

  @action
  Future<void> reparseFile({
    required String filePath,
    required String updatedContent,
  }) async {
    final String canonicalPath = THProjectPathResolver.canonicalize(
      p.absolute(filePath),
    );

    fileContentsCache[canonicalPath] = updatedContent;
    dirtyFilePaths.add(canonicalPath);

    _reparseTimers[canonicalPath]?.cancel();
    _reparseTimers[canonicalPath] = Timer(
      const Duration(milliseconds: mpProjectReparseDebounceMilliseconds),
      () => _performReparse(canonicalPath, updatedContent),
    );
  }

  @action
  Future<void> _performReparse(
    String canonicalPath,
    String updatedContent,
  ) async {
    _reparseTimers.remove(canonicalPath);

    final THProjectFileNode? existingNode =
        _nodesByCanonicalPath[canonicalPath];
    final bool isRootFile = canonicalPath == rootConfigPath;

    if (existingNode is TH2FileNode) {
      // .th2 canvas edits are owned by TH2FileEditController.
      return;
    }

    if (shouldFullReloadForReparse(
      hasProjectRoot: projectRootNode != null,
      isRootFile: isRootFile,
      isKnownFile: existingNode != null,
      typeChanged: false,
    )) {
      await reloadProject();
      return;
    }

    final THProjectNode? parent = existingNode!.parent;

    if (parent == null) {
      await reloadProject();
      return;
    }

    isParsing = true;

    try {
      final THProjectShape shape = existingNode is THConfigFileNode
          ? THProjectShape.config
          : THProjectShape.data;

      final THProjectFileNode freshNode =
          await Future<THProjectFileNode>(
            () => THProjectParser.parseFileContent(
              canonicalPath: canonicalPath,
              content: updatedContent,
              shape: shape,
              sourceFilePath: existingNode.sourceFilePath,
              lineNumber: existingNode.lineNumber,
            ),
          );

      if (shouldFullReloadForReparse(
        hasProjectRoot: true,
        isRootFile: false,
        isKnownFile: true,
        typeChanged: freshNode.runtimeType != existingNode.runtimeType,
      )) {
        await reloadProject();
        return;
      }

      final Map<String, THProjectFileNode> reuseCache =
          collectDescendantFileNodes(existingNode);
      final String projectRootDirectory = p.dirname(rootConfigPath);

      final THProjectSpliceResult spliceResult =
          await Future<THProjectSpliceResult>(
            () => THProjectParser.spliceFileNodeChildren(
              targetNode: freshNode,
              canonicalPath: canonicalPath,
              projectRootDirectory: projectRootDirectory,
              reuseByCanonicalPath: reuseCache,
            ),
          );

      final int childIndex = parent.children.indexOf(existingNode);

      if (childIndex == -1) {
        await reloadProject();
        return;
      }

      parent.children[childIndex] = freshNode;
      freshNode.parent = parent;

      _reindexAfterTreeChange(spliceResult.projectErrors);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] reparseFile failed for $canonicalPath',
        error: error,
        stackTrace: stackTrace,
      );

      await reloadProject();
    } finally {
      isParsing = false;
    }
  }

  @action
  Future<void> saveProjectFile(String filePath) async {
    final String canonicalPath = THProjectPathResolver.canonicalize(
      p.absolute(filePath),
    );

    if (p.extension(canonicalPath).toLowerCase() == '.th2') {
      final TH2FileEditController? th2Controller = mpLocator
          .mpGeneralController
          .getTH2FileEditControllerIfExists(canonicalPath);

      if (th2Controller == null) {
        mpLocator.mpLog.w(
          '[THProjectController] saveProjectFile: no open editor for '
          '.th2 file $canonicalPath; skipping.',
        );

        return;
      }

      th2Controller.saveTH2File();
      dirtyFilePaths.remove(canonicalPath);

      return;
    }

    final THProjectFileNode? node = _nodesByCanonicalPath[canonicalPath];

    if (node == null) {
      mpLocator.mpLog.w(
        '[THProjectController] saveProjectFile: unknown file '
        '$canonicalPath; skipping.',
      );

      return;
    }

    try {
      final Uint8List bytes;

      if (node is THConfigFileNode) {
        bytes = THConfigFileWriter().serializeToBytes(node.configFile);
      } else if (node is THDataFileNode) {
        bytes = THFileWriter().serializeToBytes(node.dataFile);
      } else {
        mpLocator.mpLog.w(
          '[THProjectController] saveProjectFile: $canonicalPath is not '
          'a writable node type; skipping.',
        );

        return;
      }

      await File(canonicalPath).writeAsBytes(bytes);
      dirtyFilePaths.remove(canonicalPath);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] saveProjectFile failed for $canonicalPath',
        error: error,
        stackTrace: stackTrace,
      );
      projectErrors.add(
        THProjectParseError(
          message: 'Failed to save $canonicalPath: $error',
          severity: THProjectParseErrorSeverity.error,
          filePath: canonicalPath,
          lineNumber: 0,
        ),
      );
    }
  }

  @action
  Future<void> saveAllModifiedFiles() async {
    final List<String> pathsToSave = dirtyFilePaths.toList();

    for (final String path in pathsToSave) {
      await saveProjectFile(path);
    }
  }

  @action
  void selectNode(String nodeId) {
    activeSelectedNodeId = nodeId;
  }

  THProjectFileNode? nodeByCanonicalPath(String canonicalPath) =>
      _nodesByCanonicalPath[canonicalPath];

  Set<String> dependenciesOf(String canonicalPath) =>
      Set<String>.of(_fileDependencies[canonicalPath] ?? const <String>{});

  Set<String> dependentsOf(String canonicalPath) => Set<String>.of(
    _reverseDependencies[canonicalPath] ?? const <String>{},
  );

  bool isFileDirty(String canonicalPath) =>
      dirtyFilePaths.contains(canonicalPath);

  void _applyLoadResult(THProjectLoadResult result) {
    projectRootNode = result.rootNode;
    _fileDependencies
      ..clear()
      ..addAll(result.fileDependencies);
    _reverseDependencies
      ..clear()
      ..addAll(result.reverseDependencies);

    rebuildProjectIndexes(
      root: result.rootNode,
      nodesByCanonicalPath: _nodesByCanonicalPath,
      nodesById: _nodesById,
    );

    final List<THProjectParseError> treeErrors = collectTreeErrors(
      result.rootNode,
    );

    _looseProjectErrors
      ..clear()
      ..addAll(
        looseProjectErrors(
          resultProjectErrors: result.projectErrors,
          treeErrors: treeErrors,
        ),
      );

    projectErrors = ObservableList<THProjectParseError>.of(<
      THProjectParseError
    >[...treeErrors, ..._looseProjectErrors]);

    fileContentsCache = ObservableMap<String, String>();
    dirtyFilePaths = ObservableSet<String>();
    _populateFileContentsCache();
  }

  void _reindexAfterTreeChange(
    List<THProjectParseError> newSpliceProjectErrors,
  ) {
    final THProjectFileNode root = projectRootNode!;

    rebuildProjectIndexes(
      root: root,
      nodesByCanonicalPath: _nodesByCanonicalPath,
      nodesById: _nodesById,
    );
    rebuildDependencyMaps(
      root: root,
      fileDependencies: _fileDependencies,
      reverseDependencies: _reverseDependencies,
    );

    final List<THProjectParseError> treeErrors = collectTreeErrors(root);
    final List<THProjectParseError> newLooseErrors = looseProjectErrors(
      resultProjectErrors: newSpliceProjectErrors,
      treeErrors: treeErrors,
    );

    for (final THProjectParseError error in newLooseErrors) {
      if (!_looseProjectErrors.contains(error)) {
        _looseProjectErrors.add(error);
      }
    }

    projectErrors = ObservableList<THProjectParseError>.of(<
      THProjectParseError
    >[...treeErrors, ..._looseProjectErrors]);
  }

  void _populateFileContentsCache() {
    for (final MapEntry<String, THProjectFileNode> entry
        in _nodesByCanonicalPath.entries) {
      final THProjectFileNode node = entry.value;

      if ((node is! THConfigFileNode) && (node is! THDataFileNode)) {
        continue;
      }

      try {
        final ({String content, String encoding}) read =
            THProjectParser.readFileContent(entry.key);

        fileContentsCache[entry.key] = read.content;
      } catch (error, stackTrace) {
        mpLocator.mpLog.e(
          '[THProjectController] failed to read ${entry.key} into cache',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  void _cancelAllReparseTimers() {
    for (final Timer timer in _reparseTimers.values) {
      timer.cancel();
    }

    _reparseTimers.clear();
  }
}
