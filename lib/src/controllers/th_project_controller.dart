// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:typed_data';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller_operations.dart';
import 'package:mapiah/src/controllers/th_project_reparse_aux.dart';
import 'package:mapiah/src/controllers/th_project_reparse_flush_result.dart';
import 'package:mapiah/src/controllers/th_text_file_revert_result.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/th_text_project_content_snapshot.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

part 'th_project_controller.g.dart';

class THProjectController = THProjectControllerBase with _$THProjectController;

/// MobX store that loads, holds, reloads, and closes a whole Therion
/// project starting from a root `thconfig` or root `.th` file.
///
/// This is a non-UI layer: it owns the project's file/logical tree,
/// dependency indexes, revisioned pending-content tracking, and debounced
/// single-file re-parsing so that a project tree widget and text editor
/// widget can observe it.
///
/// Every lifecycle transition (`openProject`, explicit disk `reloadProject`,
/// `closeProject`) reserves exactly one new [projectEpoch] before it cancels
/// timers or clears state; every asynchronous operation captures
/// `(projectEpoch, rootConfigPath)` and refuses to mutate the project once
/// either has moved on. [THProjectController] is the sole allocator of the
/// monotonically increasing per-path content revision.
abstract class THProjectControllerBase with Store {
  THProjectControllerBase({THProjectControllerOperations? operations})
    : _operations = operations ?? THProjectControllerOperations.defaults();

  final THProjectControllerOperations _operations;

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

  /// Monotonically increasing project lifecycle epoch. Advanced by exactly one
  /// at the start of every non-no-op `openProject` / explicit disk
  /// `reloadProject` / `closeProject`, before timers are cancelled or state is
  /// cleared. Read-only to the outside.
  @readonly
  int _projectEpoch = 0;

  /// Diagnostics parsed from a finished Therion run (see
  /// `th_project_therion_diagnostics_aux.dart`), kept separate from
  /// [projectErrors] because that list is fully reassigned on every
  /// `openProject`/`reloadProject`/`reparseFile`, which would silently wipe
  /// compiler diagnostics on the next keystroke if they were merged into it
  /// directly.
  @observable
  ObservableList<THProjectParseError> compilerErrors =
      ObservableList<THProjectParseError>();

  @computed
  List<THProjectParseError> get allDiagnostics =>
      <THProjectParseError>[...projectErrors, ...compilerErrors];

  @computed
  bool get hasUnsavedChanges => dirtyFilePaths.isNotEmpty;

  /// Replaces [compilerErrors] with the diagnostics from a just-finished
  /// Therion run. Always a full replacement (never an append), so calling
  /// this with a fresh full parse result at the end of every run naturally
  /// clears diagnostics that no longer reproduce.
  @action
  void applyTherionRunDiagnostics(List<THProjectParseError> diagnostics) {
    compilerErrors = ObservableList<THProjectParseError>.of(diagnostics);
  }

  List<THProjectParseError> compilerErrorsForPath(String canonicalPath) =>
      compilerErrors
          .where((THProjectParseError error) => error.filePath == canonicalPath)
          .toList();

  final Map<String, Set<String>> _fileDependencies = <String, Set<String>>{};

  final Map<String, Set<String>> _reverseDependencies =
      <String, Set<String>>{};

  final Map<String, THProjectFileNode> _nodesByCanonicalPath =
      <String, THProjectFileNode>{};

  final Map<String, THProjectNode> _nodesById = <String, THProjectNode>{};

  final Map<String, Timer> _reparseTimers = <String, Timer>{};

  /// Per-epoch count of in-flight asynchronous operations. `isParsing` is
  /// derived from the current epoch's entry, so a stale project-A completion
  /// can never clear project B's progress flag.
  final Map<int, int> _activeOpsByEpoch = <int, int>{};

  /// Coalescing map for concurrent flush callers targeting the same
  /// `path@epoch@revision`.
  final Map<String, Future<THProjectReparseFlushResult>> _inFlightReparse =
      <String, Future<THProjectReparseFlushResult>>{};

  /// Never-decremented last-allocated revision per canonical text path.
  final Map<String, int> _allocationCounter = <String, int>{};

  /// Current content revision per canonical text path.
  final Map<String, int> _currentRevision = <String, int>{};

  /// Revision represented by the currently parsed writable node per path.
  final Map<String, int> _parsedRevision = <String, int>{};

  /// Pending (unsaved) content per canonical text path. Kept in lock-step with
  /// [dirtyFilePaths]: a path is dirty iff it has a pending record.
  final Map<String, String> _pendingContent = <String, String>{};

  /// Whether the current project's root was opened with a forced config
  /// shape; carried into reloads and dirty-preserving full re-parses.
  bool _rootForcedConfigShape = false;

  /// Project-level diagnostics that are not attached to any tree node, such
  /// as cycle-detection warnings. Kept separately because [projectErrors] is
  /// otherwise rebuilt from a tree walk after every incremental re-parse.
  final List<THProjectParseError> _looseProjectErrors =
      <THProjectParseError>[];

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @action
  Future<void> openProject(
    String configFilePath, {
    bool forceConfigShape = false,
  }) async {
    final String canonicalRootPath = THProjectPathResolver.canonicalize(
      p.absolute(configFilePath),
    );

    final int epoch = _beginProjectLifecycleTransition();
    _clearProjectState();

    rootConfigPath = canonicalRootPath;
    _rootForcedConfigShape = forceConfigShape;
    _beginActivity(epoch);

    try {
      final THProjectLoadResult result = await _operations.loadProject(
        canonicalRootPath,
        expectedShape: forceConfigShape ? THProjectShape.config : null,
      );

      if (!_isCurrent(epoch, canonicalRootPath)) {
        return;
      }

      _applyFreshLoadResult(result);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] openProject failed for $canonicalRootPath',
        error: error,
        stackTrace: stackTrace,
      );

      if (_isCurrent(epoch, canonicalRootPath)) {
        projectErrors.add(
          THProjectParseError(
            message: mpLocator.appLocalizations.thProjectOpenFailed('$error'),
            severity: THProjectParseErrorSeverity.error,
            filePath: canonicalRootPath,
            lineNumber: 0,
          ),
        );
      }
    } finally {
      _endActivity(epoch);
    }
  }

  @action
  Future<void> reloadProject() async {
    if (rootConfigPath.isEmpty) {
      return;
    }

    final String canonicalRootPath = rootConfigPath;
    final bool forcedConfigShape = _rootForcedConfigShape;
    final int epoch = _beginProjectLifecycleTransition();

    _beginActivity(epoch);

    try {
      final THProjectLoadResult result = await _operations.loadProject(
        canonicalRootPath,
        expectedShape: forcedConfigShape ? THProjectShape.config : null,
      );

      if (!_isCurrent(epoch, canonicalRootPath)) {
        return;
      }

      _applyFreshLoadResult(result);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] reloadProject failed for $canonicalRootPath',
        error: error,
        stackTrace: stackTrace,
      );

      if (_isCurrent(epoch, canonicalRootPath)) {
        projectErrors.add(
          THProjectParseError(
            message: mpLocator.appLocalizations.thProjectReloadFailed('$error'),
            severity: THProjectParseErrorSeverity.error,
            filePath: canonicalRootPath,
            lineNumber: 0,
          ),
        );
      }
    } finally {
      _endActivity(epoch);
    }
  }

  @action
  void closeProject() {
    _beginProjectLifecycleTransition();
    _clearProjectState();
  }

  /// Reserves exactly one new epoch, disposes the outgoing project's file
  /// tabs/controllers, and cancels queued timers. Called once by every
  /// non-no-op public lifecycle entry point, before its first `await` and
  /// before any state reset/replacement. Never advances the epoch more than
  /// once, and never calls another public lifecycle method.
  int _beginProjectLifecycleTransition() {
    final List<String> outgoingPaths = _projectOwnedCanonicalPaths();

    _projectEpoch++;
    _cancelAllReparseTimers();
    _inFlightReparse.clear();
    _resetActivityOwnershipForCurrentEpoch();

    if (outgoingPaths.isNotEmpty) {
      mpLocator.mpGeneralController.closeProjectFileTabs(outgoingPaths);
    }

    return _projectEpoch;
  }

  /// Clears root/tree, indexes, diagnostics, caches, and dirty/revision state.
  /// Does not advance the epoch or cancel work.
  void _clearProjectState() {
    rootConfigPath = '';
    projectRootNode = null;
    projectErrors = ObservableList<THProjectParseError>();
    compilerErrors = ObservableList<THProjectParseError>();
    activeSelectedNodeId = null;
    fileContentsCache = ObservableMap<String, String>();
    dirtyFilePaths = ObservableSet<String>();
    _fileDependencies.clear();
    _reverseDependencies.clear();
    _nodesByCanonicalPath.clear();
    _nodesById.clear();
    _looseProjectErrors.clear();
    _allocationCounter.clear();
    _currentRevision.clear();
    _parsedRevision.clear();
    _pendingContent.clear();
    _rootForcedConfigShape = false;
    _updateIsParsing();
  }

  List<String> _projectOwnedCanonicalPaths() =>
      _nodesByCanonicalPath.keys.toList(growable: false);

  bool _isCurrent(int epoch, String rootPath) =>
      (epoch == _projectEpoch) && (rootPath == rootConfigPath);

  void _resetActivityOwnershipForCurrentEpoch() {
    _activeOpsByEpoch.removeWhere((int epoch, _) => epoch != _projectEpoch);
    _updateIsParsing();
  }

  void _beginActivity(int epoch) {
    _activeOpsByEpoch[epoch] = (_activeOpsByEpoch[epoch] ?? 0) + 1;
    _updateIsParsing();
  }

  void _endActivity(int epoch) {
    final int next = (_activeOpsByEpoch[epoch] ?? 0) - 1;

    if (next <= 0) {
      _activeOpsByEpoch.remove(epoch);
    } else {
      _activeOpsByEpoch[epoch] = next;
    }

    _updateIsParsing();
  }

  void _updateIsParsing() {
    isParsing = (_activeOpsByEpoch[_projectEpoch] ?? 0) > 0;
  }

  // ---------------------------------------------------------------------------
  // Revisioned pending content
  // ---------------------------------------------------------------------------

  /// Synchronous, atomic allocation of the next content revision for
  /// [canonicalPath] and registration of its pending [content]. Returns the
  /// allocated revision, or `-1` when the captured project identity is stale
  /// (no project state is mutated in that case).
  @action
  int registerTextContentChange({
    required String canonicalPath,
    required String content,
    required int expectedProjectEpoch,
    required String expectedRootPath,
  }) {
    final String path = THProjectPathResolver.canonicalize(
      p.absolute(canonicalPath),
    );

    if (!_isCurrent(expectedProjectEpoch, expectedRootPath)) {
      return -1;
    }

    final int next = (_allocationCounter[path] ?? 0) + 1;

    _allocationCounter[path] = next;
    _currentRevision[path] = next;
    _setPending(path, content);

    return next;
  }

  /// One synchronous project-content snapshot for [canonicalPath]: content,
  /// current revision, dirty/pending status, project epoch, and root path.
  /// When the project does not track the path, returns an explicitly untracked
  /// snapshot and the caller falls back to its own disk read.
  THTextProjectContentSnapshot textContentSnapshot(String canonicalPath) {
    final String path = THProjectPathResolver.canonicalize(
      p.absolute(canonicalPath),
    );
    final THProjectFileNode? node = _nodesByCanonicalPath[path];
    final bool tracked =
        (node is THConfigFileNode) || (node is THDataFileNode);

    if (!tracked) {
      return THTextProjectContentSnapshot.untracked(
        canonicalPath: path,
        content: '',
      );
    }

    return THTextProjectContentSnapshot(
      canonicalPath: path,
      content: fileContentsCache[path] ?? '',
      currentRevision: _currentRevision[path] ?? 0,
      isDirty: _pendingContent.containsKey(path),
      projectEpoch: _projectEpoch,
      rootPath: rootConfigPath,
      isProjectTracked: true,
    );
  }

  void _setPending(String path, String content) {
    _pendingContent[path] = content;
    fileContentsCache[path] = content;
    dirtyFilePaths.add(path);
  }

  void _clearPending(String path) {
    _pendingContent.remove(path);
    dirtyFilePaths.remove(path);
  }

  // ---------------------------------------------------------------------------
  // Re-parse
  // ---------------------------------------------------------------------------

  /// Editor-timer entry point. Accepts only a revision previously allocated
  /// for the same epoch/path, refuses to replace a path's pending record with
  /// an older revision or different content, and schedules the project-level
  /// debounce that drains into [flushPendingReparse].
  @action
  Future<void> reparseFile({
    required String filePath,
    required String updatedContent,
    required int revision,
    required int expectedProjectEpoch,
    required String expectedRootPath,
  }) async {
    final String path = THProjectPathResolver.canonicalize(
      p.absolute(filePath),
    );

    if (!_isCurrent(expectedProjectEpoch, expectedRootPath)) {
      return;
    }

    if (revision > (_allocationCounter[path] ?? 0)) {
      // Not an allocated revision; the controller never allocates here.
      return;
    }

    final int? current = _currentRevision[path];
    if ((current != null) && (revision < current)) {
      return;
    }

    // A late callback for a revision that is already parsed and no longer
    // pending (saved or reverted) is idempotent: it must not recreate
    // pending/dirty state.
    if ((revision == current) &&
        (_parsedRevision[path] == revision) &&
        !_pendingContent.containsKey(path)) {
      return;
    }

    if ((current != null) &&
        (revision == current) &&
        _pendingContent.containsKey(path) &&
        (_pendingContent[path] != updatedContent)) {
      return;
    }

    _currentRevision[path] = revision;
    _setPending(path, updatedContent);

    _reparseTimers[path]?.cancel();
    _reparseTimers[path] = Timer(
      const Duration(milliseconds: mpProjectReparseDebounceMilliseconds),
      () {
        unawaited(
          flushPendingReparse(
            canonicalPath: path,
            expectedRevision: _currentRevision[path] ?? revision,
            expectedProjectEpoch: expectedProjectEpoch,
            expectedRootPath: expectedRootPath,
          ),
        );
      },
    );
  }

  /// Drains the project-level re-parse timer for [canonicalPath] and awaits
  /// the actual work needed for [expectedRevision], using the dirty-preserving
  /// in-memory full-project re-parse whenever the incremental splice cannot be
  /// used. Returns a typed outcome; only [THProjectReparseFlushStatus.reparsed]
  /// / [THProjectReparseFlushStatus.alreadyCurrent] with a matching parsed
  /// revision permit the save boundary to proceed.
  @action
  Future<THProjectReparseFlushResult> flushPendingReparse({
    required String canonicalPath,
    required int expectedRevision,
    required int expectedProjectEpoch,
    required String expectedRootPath,
  }) async {
    final String path = THProjectPathResolver.canonicalize(
      p.absolute(canonicalPath),
    );

    if (!_isCurrent(expectedProjectEpoch, expectedRootPath)) {
      return _flushResult(
        path,
        expectedProjectEpoch,
        expectedRevision,
        null,
        THProjectReparseFlushStatus.projectChanged,
      );
    }

    _reparseTimers.remove(path)?.cancel();

    final int? currentRevision = _currentRevision[path];
    final int? parsedRevision = _parsedRevision[path];

    if (!_pendingContent.containsKey(path)) {
      return _flushResult(
        path,
        _projectEpoch,
        expectedRevision,
        parsedRevision,
        (parsedRevision == expectedRevision)
            ? THProjectReparseFlushStatus.alreadyCurrent
            : THProjectReparseFlushStatus.superseded,
      );
    }

    if ((currentRevision != null) && (currentRevision > expectedRevision)) {
      unawaited(
        flushPendingReparse(
          canonicalPath: path,
          expectedRevision: currentRevision,
          expectedProjectEpoch: _projectEpoch,
          expectedRootPath: rootConfigPath,
        ),
      );

      return _flushResult(
        path,
        _projectEpoch,
        expectedRevision,
        parsedRevision,
        THProjectReparseFlushStatus.superseded,
      );
    }

    if (parsedRevision == expectedRevision) {
      return _flushResult(
        path,
        _projectEpoch,
        expectedRevision,
        parsedRevision,
        THProjectReparseFlushStatus.alreadyCurrent,
      );
    }

    final String key = '$path@$_projectEpoch@$expectedRevision';
    final Future<THProjectReparseFlushResult>? existing = _inFlightReparse[key];
    if (existing != null) {
      return existing;
    }

    final Future<THProjectReparseFlushResult> work = _doReparse(
      path,
      _projectEpoch,
      expectedRevision,
    );
    _inFlightReparse[key] = work;

    try {
      return await work;
    } finally {
      _inFlightReparse.remove(key);
    }
  }

  Future<THProjectReparseFlushResult> _doReparse(
    String path,
    int epoch,
    int targetRevision,
  ) async {
    _beginActivity(epoch);

    try {
      final THProjectFileNode? existingNode = _nodesByCanonicalPath[path];

      if (existingNode is TH2FileNode) {
        return _flushResult(
          path,
          epoch,
          targetRevision,
          _parsedRevision[path],
          THProjectReparseFlushStatus.failed,
        );
      }

      final bool mustFullReparse =
          (projectRootNode == null) ||
          (path == rootConfigPath) ||
          (existingNode == null) ||
          (existingNode.parent == null);

      if (!mustFullReparse) {
        final bool incrementalDone = await _tryIncrementalReparse(
          path,
          epoch,
          targetRevision,
          existingNode,
        );

        if (!_isCurrent(epoch, rootConfigPath)) {
          return _flushResult(
            path,
            epoch,
            targetRevision,
            null,
            THProjectReparseFlushStatus.projectChanged,
          );
        }

        if (incrementalDone) {
          return _flushResult(
            path,
            epoch,
            targetRevision,
            _parsedRevision[path],
            THProjectReparseFlushStatus.reparsed,
          );
        }
      }

      return await _fullDirtyPreservingReparse(path, epoch, targetRevision);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] reparse failed for $path',
        error: error,
        stackTrace: stackTrace,
      );

      return _flushResult(
        path,
        epoch,
        targetRevision,
        _parsedRevision[path],
        THProjectReparseFlushStatus.failed,
      );
    } finally {
      _endActivity(epoch);
    }
  }

  /// Attempts the local shallow-parse + splice path. Returns `true` on
  /// success (tree spliced, parsed revision updated), `false` when a full
  /// dirty-preserving re-parse is required instead (root/parent moved,
  /// reference-role/expected-shape conflict).
  Future<bool> _tryIncrementalReparse(
    String path,
    int epoch,
    int targetRevision,
    THProjectFileNode existingNode,
  ) async {
    final THProjectNode? parent = existingNode.parent;
    if (parent == null) {
      return false;
    }

    final THProjectShape shape = existingNode is THConfigFileNode
        ? THProjectShape.config
        : THProjectShape.data;
    final String content = _pendingContent[path]!;

    final THProjectFileNode freshNode = await _operations.parseFileContent(
      canonicalPath: path,
      content: content,
      shape: shape,
      sourceFilePath: existingNode.sourceFilePath,
      lineNumber: existingNode.lineNumber,
    );

    if (!_isCurrent(epoch, rootConfigPath)) {
      return false;
    }

    final Map<String, THProjectFileNode> reuseCache =
        collectDescendantFileNodes(existingNode);
    final String projectRootDirectory = p.dirname(rootConfigPath);

    final THProjectSpliceResult spliceResult =
        await _operations.spliceFileNodeChildren(
          targetNode: freshNode,
          canonicalPath: path,
          projectRootDirectory: projectRootDirectory,
          reuseByCanonicalPath: reuseCache,
        );

    if (!_isCurrent(epoch, rootConfigPath)) {
      return false;
    }

    if (spliceResult.shapeConflictPath != null) {
      return false;
    }

    final int childIndex = parent.children.indexOf(existingNode);
    if (childIndex == -1) {
      return false;
    }

    parent.children[childIndex] = freshNode;
    freshNode.parent = parent;

    _reindexAfterTreeChange(spliceResult.projectErrors);
    _parsedRevision[path] = targetRevision;

    return true;
  }

  Future<THProjectReparseFlushResult> _fullDirtyPreservingReparse(
    String path,
    int epoch,
    int targetRevision,
  ) async {
    final Map<String, THProjectContentOverride> overrides = _buildOverrideMap();

    final THProjectLoadResult result;
    try {
      result = await _operations.loadProject(
        rootConfigPath,
        expectedShape: _rootForcedConfigShape ? THProjectShape.config : null,
        contentOverrides: overrides,
      );
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] full dirty-preserving reparse failed for $path',
        error: error,
        stackTrace: stackTrace,
      );

      return _flushResult(
        path,
        epoch,
        targetRevision,
        _parsedRevision[path],
        THProjectReparseFlushStatus.failed,
      );
    }

    if (!_isCurrent(epoch, rootConfigPath)) {
      return _flushResult(
        path,
        epoch,
        targetRevision,
        null,
        THProjectReparseFlushStatus.projectChanged,
      );
    }

    _applyDirtyPreservingReparseResult(result, overridesUsed: overrides);

    final int? parsedRevision = _parsedRevision[path];

    return _flushResult(
      path,
      epoch,
      targetRevision,
      parsedRevision,
      (parsedRevision == targetRevision)
          ? THProjectReparseFlushStatus.reparsed
          : THProjectReparseFlushStatus.superseded,
    );
  }

  Map<String, THProjectContentOverride> _buildOverrideMap() {
    final Map<String, THProjectContentOverride> overrides =
        <String, THProjectContentOverride>{};

    for (final MapEntry<String, String> entry in _pendingContent.entries) {
      overrides[entry.key] = THProjectContentOverride(
        content: entry.value,
        revision: _currentRevision[entry.key] ?? 0,
      );
    }

    return Map<String, THProjectContentOverride>.unmodifiable(overrides);
  }

  THProjectReparseFlushResult _flushResult(
    String path,
    int epoch,
    int expectedRevision,
    int? parsedRevision,
    THProjectReparseFlushStatus status,
  ) {
    return THProjectReparseFlushResult(
      canonicalPath: path,
      projectEpoch: epoch,
      expectedRevision: expectedRevision,
      parsedRevision: parsedRevision,
      status: status,
    );
  }

  // ---------------------------------------------------------------------------
  // Revert
  // ---------------------------------------------------------------------------

  /// Revision-aware revert of one project-tracked text file to its on-disk
  /// content. Reserves a fresh revision for the disk content, parses it under
  /// the captured epoch/root, and only publishes it as clean while
  /// [requestedRevision] is still current. Read/re-parse failure, project
  /// replacement, or a newer edit preserves the pending revision.
  @action
  Future<THTextFileRevertResult> revertTextProjectFile({
    required String canonicalPath,
    required int requestedRevision,
    required int expectedProjectEpoch,
    required String expectedRootPath,
  }) async {
    final String path = THProjectPathResolver.canonicalize(
      p.absolute(canonicalPath),
    );

    THTextFileRevertResult result(
      THTextFileRevertStatus status, {
      int? reservedRevision,
      THTextProjectContentSnapshot? snapshot,
    }) {
      return THTextFileRevertResult(
        canonicalPath: path,
        projectEpoch: expectedProjectEpoch,
        requestedRevision: requestedRevision,
        reservedRevision: reservedRevision,
        status: status,
        snapshot: snapshot,
      );
    }

    if (!_isCurrent(expectedProjectEpoch, expectedRootPath)) {
      return result(THTextFileRevertStatus.projectChanged);
    }

    final THProjectFileNode? node = _nodesByCanonicalPath[path];
    if ((node is! THConfigFileNode) && (node is! THDataFileNode)) {
      return result(THTextFileRevertStatus.unknownPath);
    }

    final int currentRevision = _currentRevision[path] ?? 0;
    if (currentRevision != requestedRevision) {
      return result(
        THTextFileRevertStatus.superseded,
        snapshot: textContentSnapshot(path),
      );
    }

    if (!_pendingContent.containsKey(path)) {
      return result(
        THTextFileRevertStatus.alreadyClean,
        snapshot: textContentSnapshot(path),
      );
    }

    final ({String content, String encoding}) disk;
    try {
      disk = _operations.readFileContent(path);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] revert read failed for $path',
        error: error,
        stackTrace: stackTrace,
      );

      return result(THTextFileRevertStatus.readFailed);
    }

    if (!_isCurrent(expectedProjectEpoch, expectedRootPath)) {
      return result(THTextFileRevertStatus.projectChanged);
    }
    if ((_currentRevision[path] ?? 0) != requestedRevision) {
      return result(
        THTextFileRevertStatus.superseded,
        snapshot: textContentSnapshot(path),
      );
    }

    final int reservedRevision = (_allocationCounter[path] ?? 0) + 1;
    _allocationCounter[path] = reservedRevision;

    final Map<String, THProjectContentOverride> overrides =
        <String, THProjectContentOverride>{
          ..._buildOverrideMap(),
          path: THProjectContentOverride(
            content: disk.content,
            revision: reservedRevision,
          ),
        };

    final THProjectLoadResult loadResult;
    try {
      loadResult = await _operations.loadProject(
        rootConfigPath,
        expectedShape: _rootForcedConfigShape ? THProjectShape.config : null,
        contentOverrides: Map<String, THProjectContentOverride>.unmodifiable(
          overrides,
        ),
      );
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] revert reparse failed for $path',
        error: error,
        stackTrace: stackTrace,
      );

      return result(
        THTextFileRevertStatus.reparseFailed,
        reservedRevision: reservedRevision,
      );
    }

    if (!_isCurrent(expectedProjectEpoch, expectedRootPath)) {
      return result(
        THTextFileRevertStatus.projectChanged,
        reservedRevision: reservedRevision,
      );
    }
    if ((_currentRevision[path] ?? 0) != requestedRevision) {
      return result(
        THTextFileRevertStatus.superseded,
        reservedRevision: reservedRevision,
        snapshot: textContentSnapshot(path),
      );
    }

    _applyDirtyPreservingReparseResult(loadResult, overridesUsed: overrides);

    // Publish the reserved disk revision as the clean current/parsed revision
    // for the target only.
    _currentRevision[path] = reservedRevision;
    _parsedRevision[path] = reservedRevision;
    fileContentsCache[path] = disk.content;
    _clearPending(path);

    return result(
      THTextFileRevertStatus.reverted,
      reservedRevision: reservedRevision,
      snapshot: textContentSnapshot(path),
    );
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  /// Typed, revision-aware persistence of one writable text (config/data)
  /// file. Callers consume the result directly and never infer success from
  /// observable state or diagnostics.
  @action
  Future<THTextFileSaveResult> saveTextProjectFile({
    required String canonicalPath,
    required int requestedRevision,
    required int expectedProjectEpoch,
    required String expectedRootPath,
  }) async {
    final String path = THProjectPathResolver.canonicalize(
      p.absolute(canonicalPath),
    );

    THTextFileSaveResult make(
      THTextFileSaveStatus status, {
      int? writtenRevision,
      int? currentRevision,
    }) {
      return THTextFileSaveResult(
        canonicalPath: path,
        projectEpoch: expectedProjectEpoch,
        requestedRevision: requestedRevision,
        writtenRevision: writtenRevision,
        currentRevision: currentRevision,
        status: status,
      );
    }

    if (!_isCurrent(expectedProjectEpoch, expectedRootPath)) {
      return make(THTextFileSaveStatus.projectChangedBeforeWrite);
    }

    final THProjectFileNode? node = _nodesByCanonicalPath[path];
    if (node == null) {
      return make(THTextFileSaveStatus.unknownPath);
    }
    if ((node is! THConfigFileNode) && (node is! THDataFileNode)) {
      return make(THTextFileSaveStatus.unsupportedNode);
    }

    if (_parsedRevision[path] != requestedRevision) {
      return make(
        THTextFileSaveStatus.reparseFailed,
        currentRevision: _currentRevision[path],
      );
    }

    final int? currentRevision = _currentRevision[path];
    final bool hasPending = _pendingContent.containsKey(path);

    if ((currentRevision != null) && (currentRevision != requestedRevision)) {
      return make(
        THTextFileSaveStatus.supersededBeforeWrite,
        currentRevision: currentRevision,
      );
    }
    if ((currentRevision == requestedRevision) && !hasPending) {
      return make(
        THTextFileSaveStatus.alreadySaved,
        currentRevision: currentRevision,
      );
    }

    final Uint8List bytes;
    try {
      bytes = _operations.serializeNode(node);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] saveTextProjectFile serialize failed for $path',
        error: error,
        stackTrace: stackTrace,
      );

      return make(
        THTextFileSaveStatus.serializationFailed,
        currentRevision: currentRevision,
      );
    }

    if (!_isCurrent(expectedProjectEpoch, expectedRootPath)) {
      return make(THTextFileSaveStatus.projectChangedBeforeWrite);
    }

    try {
      await _operations.writeBytes(path, bytes);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] saveTextProjectFile write failed for $path',
        error: error,
        stackTrace: stackTrace,
      );

      if (_isCurrent(expectedProjectEpoch, expectedRootPath)) {
        projectErrors.add(
          THProjectParseError(
            message: mpLocator.appLocalizations.thProjectSaveFailed(
              path,
              '$error',
            ),
            severity: THProjectParseErrorSeverity.error,
            filePath: path,
            lineNumber: 0,
          ),
        );

        return make(
          THTextFileSaveStatus.writeFailed,
          currentRevision: _currentRevision[path],
        );
      }

      return make(THTextFileSaveStatus.writeFailed);
    }

    if (!_isCurrent(expectedProjectEpoch, expectedRootPath)) {
      return make(
        THTextFileSaveStatus.writtenAfterProjectChange,
        writtenRevision: requestedRevision,
      );
    }

    final int? latestRevision = _currentRevision[path];
    if (latestRevision == requestedRevision) {
      _clearPending(path);

      return make(
        THTextFileSaveStatus.saved,
        writtenRevision: requestedRevision,
        currentRevision: latestRevision,
      );
    }

    return make(
      THTextFileSaveStatus.savedButSuperseded,
      writtenRevision: requestedRevision,
      currentRevision: latestRevision,
    );
  }

  /// Generic per-file save. Returns a sealed text/TH2/rejected result.
  @action
  Future<THProjectFileSaveResult> saveProjectFile(String filePath) async {
    final String path = THProjectPathResolver.canonicalize(
      p.absolute(filePath),
    );
    final int epoch = _projectEpoch;
    final String root = rootConfigPath;

    if (p.extension(path).toLowerCase() == '.th2') {
      return _saveTH2ProjectFile(path, epoch, root);
    }

    final THProjectFileNode? node = _nodesByCanonicalPath[path];
    if (node == null) {
      return THProjectRejectedFileSaveResult(
        canonicalPath: path,
        reason: THTextFileSaveStatus.unknownPath,
      );
    }
    if ((node is! THConfigFileNode) && (node is! THDataFileNode)) {
      return THProjectRejectedFileSaveResult(
        canonicalPath: path,
        reason: THTextFileSaveStatus.unsupportedNode,
      );
    }

    final int requestedRevision = _currentRevision[path] ?? 0;

    final THTextEditorControllerHandle? editor = mpLocator.mpGeneralController
        .textEditorHandleForProjectSave(path, epoch, root, requestedRevision);
    editor?.cancelPendingReparse();

    final THProjectReparseFlushResult flush = await flushPendingReparse(
      canonicalPath: path,
      expectedRevision: requestedRevision,
      expectedProjectEpoch: epoch,
      expectedRootPath: root,
    );

    if (!flush.canProceedToSave) {
      final THTextFileSaveResult mapped = THTextFileSaveResult(
        canonicalPath: path,
        projectEpoch: epoch,
        requestedRevision: requestedRevision,
        writtenRevision: null,
        currentRevision: _isCurrent(epoch, root)
            ? _currentRevision[path]
            : null,
        status: switch (flush.status) {
          THProjectReparseFlushStatus.projectChanged =>
            THTextFileSaveStatus.projectChangedBeforeWrite,
          THProjectReparseFlushStatus.superseded =>
            THTextFileSaveStatus.supersededBeforeWrite,
          _ => THTextFileSaveStatus.reparseFailed,
        },
      );

      return THProjectTextFileSaveResult(mapped);
    }

    final THTextFileSaveResult saveResult = await saveTextProjectFile(
      canonicalPath: path,
      requestedRevision: requestedRevision,
      expectedProjectEpoch: epoch,
      expectedRootPath: root,
    );

    editor?.applyExternalSaveResult(saveResult);

    return THProjectTextFileSaveResult(saveResult);
  }

  Future<THProjectTH2FileSaveResult> _saveTH2ProjectFile(
    String path,
    int epoch,
    String root,
  ) async {
    if (!_isCurrent(epoch, root)) {
      return THProjectTH2FileSaveResult(
        canonicalPath: path,
        projectEpoch: epoch,
        rootPath: root,
        status: TH2FileSaveStatus.projectChanged,
      );
    }

    final TH2FileEditController? th2Controller = mpLocator.mpGeneralController
        .getTH2FileEditControllerIfExists(path);

    if (th2Controller == null) {
      return THProjectTH2FileSaveResult(
        canonicalPath: path,
        projectEpoch: epoch,
        rootPath: root,
        status: TH2FileSaveStatus.noOpenEditor,
      );
    }

    if (!th2Controller.enableSaveButton) {
      dirtyFilePaths.remove(path);

      return THProjectTH2FileSaveResult(
        canonicalPath: path,
        projectEpoch: epoch,
        rootPath: root,
        status: TH2FileSaveStatus.alreadySaved,
      );
    }

    try {
      th2Controller.saveTH2File();
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectController] saveTH2File failed for $path',
        error: error,
        stackTrace: stackTrace,
      );

      return THProjectTH2FileSaveResult(
        canonicalPath: path,
        projectEpoch: epoch,
        rootPath: root,
        status: TH2FileSaveStatus.saveFailed,
      );
    }

    if (_isCurrent(epoch, root)) {
      dirtyFilePaths.remove(path);
    }

    return THProjectTH2FileSaveResult(
      canonicalPath: path,
      projectEpoch: epoch,
      rootPath: root,
      status: TH2FileSaveStatus.saved,
    );
  }

  @action
  Future<THSaveAllModifiedFilesResult> saveAllModifiedFiles() async {
    final int epoch = _projectEpoch;
    final String root = rootConfigPath;

    final List<String> sortedDirty = dirtyFilePaths.toList()..sort();
    final List<_SaveDescriptor> descriptors = <_SaveDescriptor>[
      for (final String path in sortedDirty)
        _SaveDescriptor(
          canonicalPath: path,
          requestedRevision: _currentRevision[path] ?? 0,
          isTH2: p.extension(path).toLowerCase() == '.th2',
        ),
    ];

    final List<THProjectFileSaveResult> results = <THProjectFileSaveResult>[];

    for (final _SaveDescriptor descriptor in descriptors) {
      if (descriptor.isTH2) {
        results.add(
          await _saveTH2ProjectFile(descriptor.canonicalPath, epoch, root),
        );
        continue;
      }

      final THProjectReparseFlushResult flush = await flushPendingReparse(
        canonicalPath: descriptor.canonicalPath,
        expectedRevision: descriptor.requestedRevision,
        expectedProjectEpoch: epoch,
        expectedRootPath: root,
      );

      if (!flush.canProceedToSave) {
        results.add(
          THProjectTextFileSaveResult(
            THTextFileSaveResult(
              canonicalPath: descriptor.canonicalPath,
              projectEpoch: epoch,
              requestedRevision: descriptor.requestedRevision,
              writtenRevision: null,
              currentRevision: _isCurrent(epoch, root)
                  ? _currentRevision[descriptor.canonicalPath]
                  : null,
              status: switch (flush.status) {
                THProjectReparseFlushStatus.projectChanged =>
                  THTextFileSaveStatus.projectChangedBeforeWrite,
                THProjectReparseFlushStatus.superseded =>
                  THTextFileSaveStatus.supersededBeforeWrite,
                _ => THTextFileSaveStatus.reparseFailed,
              },
            ),
          ),
        );
        continue;
      }

      results.add(
        THProjectTextFileSaveResult(
          await saveTextProjectFile(
            canonicalPath: descriptor.canonicalPath,
            requestedRevision: descriptor.requestedRevision,
            expectedProjectEpoch: epoch,
            expectedRootPath: root,
          ),
        ),
      );
    }

    return THSaveAllModifiedFilesResult(
      results: results,
      remainingDirtyPaths: dirtyFilePaths.toList()..sort(),
    );
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

  // ---------------------------------------------------------------------------
  // Result application
  // ---------------------------------------------------------------------------

  /// Applies a normal open / successful explicit disk reload: fresh tree,
  /// diagnostics, caches populated from the load's authoritative content
  /// snapshots (no post-parse disk reread), and all revision state reset to
  /// `0`.
  void _applyFreshLoadResult(THProjectLoadResult result) {
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
    _allocationCounter.clear();
    _currentRevision.clear();
    _parsedRevision.clear();
    _pendingContent.clear();

    for (final MapEntry<String, THProjectParsedContentSnapshot> entry
        in result.contentSnapshotsByCanonicalPath.entries) {
      fileContentsCache[entry.key] = entry.value.content;
      _allocationCounter[entry.key] = 0;
      _currentRevision[entry.key] = 0;
      _parsedRevision[entry.key] = 0;
    }

    _fillMissingWritableCacheEntriesFromDisk();
  }

  /// Applies a dirty-preserving in-memory full-project re-parse: rebuilds
  /// tree/indexes/diagnostics without resetting dirty state, populates newly
  /// discovered clean cache entries from the load's content snapshots, then
  /// lets the latest pending contents/revisions win.
  void _applyDirtyPreservingReparseResult(
    THProjectLoadResult result, {
    Map<String, THProjectContentOverride> overridesUsed =
        const <String, THProjectContentOverride>{},
  }) {
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

    for (final MapEntry<String, THProjectParsedContentSnapshot> entry
        in result.contentSnapshotsByCanonicalPath.entries) {
      final String path = entry.key;
      final THProjectParsedContentSnapshot snapshot = entry.value;

      _allocationCounter.putIfAbsent(path, () => 0);

      if (snapshot.provenance == THProjectContentProvenance.override) {
        final int overrideRevision = snapshot.overrideRevision ?? 0;

        assert(
          !overridesUsed.containsKey(path) ||
              overridesUsed[path]!.content == snapshot.content,
          'override-backed node content diverged from the immutable override',
        );

        _parsedRevision[path] = overrideRevision;
        _currentRevision[path] =
            (_currentRevision[path] ?? overrideRevision) < overrideRevision
            ? overrideRevision
            : (_currentRevision[path] ?? overrideRevision);
      } else {
        _parsedRevision[path] = _parsedRevision[path] ?? 0;
        _currentRevision.putIfAbsent(path, () => 0);

        if (!_pendingContent.containsKey(path)) {
          fileContentsCache[path] = snapshot.content;
        }
      }
    }

    // Latest pending contents always win; paths that left the rebuilt tree
    // stay explicitly dirty until saved or reverted.
    for (final MapEntry<String, String> entry in _pendingContent.entries) {
      fileContentsCache[entry.key] = entry.value;
      dirtyFilePaths.add(entry.key);
    }
  }

  void _fillMissingWritableCacheEntriesFromDisk() {
    for (final MapEntry<String, THProjectFileNode> entry
        in _nodesByCanonicalPath.entries) {
      final THProjectFileNode node = entry.value;

      if ((node is! THConfigFileNode) && (node is! THDataFileNode)) {
        continue;
      }
      if (fileContentsCache.containsKey(entry.key)) {
        continue;
      }

      try {
        fileContentsCache[entry.key] =
            _operations.readFileContent(entry.key).content;
        _allocationCounter[entry.key] = 0;
        _currentRevision[entry.key] = 0;
        _parsedRevision[entry.key] = 0;
      } catch (error, stackTrace) {
        mpLocator.mpLog.e(
          '[THProjectController] failed to read ${entry.key} into cache',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
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

  void _cancelAllReparseTimers() {
    for (final Timer timer in _reparseTimers.values) {
      timer.cancel();
    }

    _reparseTimers.clear();
  }
}

class _SaveDescriptor {
  final String canonicalPath;

  final int requestedRevision;

  final bool isTH2;

  const _SaveDescriptor({
    required this.canonicalPath,
    required this.requestedRevision,
    required this.isTH2,
  });
}

/// Narrow view of a registered text-editor controller that the project
/// controller may act on during a generic project save, without importing the
/// controller (avoids a cycle) and without touching a stale/mismatched
/// controller.
abstract class THTextEditorControllerHandle {
  void cancelPendingReparse();

  void applyExternalSaveResult(THTextFileSaveResult result);
}
