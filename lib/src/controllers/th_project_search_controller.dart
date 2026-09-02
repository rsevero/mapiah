// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io' show Directory, File, FileSystemEntity;
import 'dart:ui' show TextRange;

import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_text_search_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/th_text_project_content_snapshot.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_failure.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_file_result.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_match.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_preflight.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_replace_result.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_scope.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

part 'th_project_search_controller.g.dart';

class THProjectSearchController = THProjectSearchControllerBase
    with _$THProjectSearchController;

/// Orchestrates multi-file plain-text search and project-wide Replace All.
///
/// This controller owns search query/options/progress and immutable result
/// snapshots only. It does not own editor widgets, `TextEditingController`s,
/// tabs, parsing, disk serialization, sidebar visibility/mode, or focus
/// requests — those stay in `THProjectTreeUIController`, `THTextEditorController`,
/// `MPGeneralController`, and `THProjectController`.
abstract class THProjectSearchControllerBase with Store {
  THProjectSearchControllerBase({
    THProjectController? projectController,
    MPGeneralController? generalController,
  }) : _projectController =
           projectController ?? mpLocator.thProjectController,
       _generalController =
           generalController ?? mpLocator.mpGeneralController {
    scope = _projectController.rootConfigPath.isEmpty
        ? THProjectSearchScope.openTextTabs
        : THProjectSearchScope.projectFiles;

    _lifecycleReaction = reaction<(int, String)>(
      (_) => (
        _projectController.projectEpoch,
        _projectController.rootConfigPath,
      ),
      (_) => clearForProjectChange(),
    );
  }

  final THProjectController _projectController;
  final MPGeneralController _generalController;

  late final ReactionDisposer _lifecycleReaction;

  @observable
  String query = '';

  @observable
  String replacement = '';

  @observable
  bool caseSensitive = false;

  @observable
  THProjectSearchScope scope = THProjectSearchScope.projectFiles;

  @observable
  bool isSearching = false;

  @observable
  bool isReplacing = false;

  @observable
  ObservableList<THProjectSearchFileResult> results =
      ObservableList<THProjectSearchFileResult>();

  @observable
  ObservableList<THProjectSearchFailure> failures =
      ObservableList<THProjectSearchFailure>();

  @observable
  ObservableSet<String> expandedResultPaths = ObservableSet<String>();

  int _searchGeneration = 0;
  int _replaceGeneration = 0;
  Timer? _debounceTimer;

  int? _resultProjectEpoch;
  String? _resultRootPath;

  // ---------------------------------------------------------------------------
  // Derived state
  // ---------------------------------------------------------------------------

  int get totalMatchCount =>
      results.fold<int>(0, (int sum, THProjectSearchFileResult r) => sum + r.matchCount);

  int get totalFileCount => results.length;

  int get replaceEligibleMatchCount => results
      .where((THProjectSearchFileResult r) => r.isReplaceEligible)
      .fold<int>(0, (int sum, THProjectSearchFileResult r) => sum + r.matchCount);

  int get replaceEligibleFileCount =>
      results.where((THProjectSearchFileResult r) => r.isReplaceEligible).length;

  int get standaloneMatchCount => results
      .where((THProjectSearchFileResult r) => !r.isReplaceEligible)
      .fold<int>(0, (int sum, THProjectSearchFileResult r) => sum + r.matchCount);

  int get standaloneFileCount =>
      results.where((THProjectSearchFileResult r) => !r.isReplaceEligible).length;

  bool get _resultsCurrent =>
      _resultProjectEpoch == _projectController.projectEpoch &&
      _resultRootPath == _projectController.rootConfigPath;

  bool get canReplaceAll =>
      query.isNotEmpty &&
      !isSearching &&
      !isReplacing &&
      replaceEligibleMatchCount > 0 &&
      _resultsCurrent;

  // ---------------------------------------------------------------------------
  // Input
  // ---------------------------------------------------------------------------

  @action
  void setQuery(String value) {
    if (query == value) {
      return;
    }
    query = value;
    _scheduleSearch();
  }

  @action
  void setReplacement(String value) {
    replacement = value;
  }

  @action
  void setCaseSensitive(bool value) {
    if (caseSensitive == value) {
      return;
    }
    caseSensitive = value;
    _scheduleSearch();
  }

  @action
  void setScope(THProjectSearchScope value) {
    if (scope == value) {
      return;
    }
    scope = value;
    _scheduleSearch();
  }

  @action
  void toggleExpanded(String canonicalPath) {
    if (!expandedResultPaths.add(canonicalPath)) {
      expandedResultPaths.remove(canonicalPath);
    }
  }

  void _scheduleSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: mpProjectSearchQueryDebounceMilliseconds),
      () => unawaited(runSearch()),
    );
  }

  /// Runs the search immediately, cancelling any pending debounce. Bound to
  /// query submit and the refresh action.
  @action
  Future<void> submitQuery() async {
    _debounceTimer?.cancel();
    await runSearch();
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  @action
  Future<void> runSearch() async {
    final int generation = ++_searchGeneration;
    final int epoch = _projectController.projectEpoch;
    final String root = _projectController.rootConfigPath;

    if (scope == THProjectSearchScope.projectFiles && root.isEmpty) {
      scope = THProjectSearchScope.openTextTabs;
    }

    if (query.isEmpty) {
      results = ObservableList<THProjectSearchFileResult>();
      failures = ObservableList<THProjectSearchFailure>();
      _resultProjectEpoch = epoch;
      _resultRootPath = root;
      isSearching = false;
      return;
    }

    isSearching = true;

    final List<THProjectSearchFileResult> collected =
        <THProjectSearchFileResult>[];
    final List<THProjectSearchFailure> collectedFailures =
        <THProjectSearchFailure>[];

    final List<_SearchSource> sources = scope == THProjectSearchScope.openTextTabs
        ? _collectOpenTabSources(collectedFailures)
        : _collectProjectSources(collectedFailures);

    for (final _SearchSource source in sources) {
      // Yield so a rapidly superseded search can bail before publishing.
      await Future<void>.delayed(Duration.zero);

      if (!_searchIdentityCurrent(generation, epoch, root)) {
        return;
      }

      final List<TextRange> ranges = findPlainTextMatches(
        content: source.content,
        query: query,
        caseSensitive: caseSensitive,
      );

      if (ranges.isEmpty) {
        continue;
      }

      final List<THProjectSearchMatch> matches = <THProjectSearchMatch>[];

      for (final TextRange range in ranges) {
        final THTextSearchLinePreview preview = buildLinePreview(
          content: source.content,
          matchRange: range,
        );

        matches.add(
          THProjectSearchMatch(
            canonicalPath: source.canonicalPath,
            range: range,
            lineNumber: lineNumberForOffset(source.content, range.start),
            columnNumber: columnNumberForOffset(source.content, range.start),
            linePreview: preview.preview,
            previewMatchRange: preview.matchRange,
          ),
        );
      }

      collected.add(
        THProjectSearchFileResult(
          canonicalPath: source.canonicalPath,
          displayPath: source.displayPath,
          searchedContent: source.content,
          searchedRevision: source.revision,
          isReplaceEligible: source.isReplaceEligible,
          matches: matches,
        ),
      );
    }

    if (!_searchIdentityCurrent(generation, epoch, root)) {
      return;
    }

    collected.sort(_compareFileResults);

    results = ObservableList<THProjectSearchFileResult>.of(collected);
    failures = ObservableList<THProjectSearchFailure>.of(collectedFailures);
    _resultProjectEpoch = epoch;
    _resultRootPath = root;
    isSearching = false;
  }

  bool _searchIdentityCurrent(int generation, int epoch, String root) =>
      generation == _searchGeneration &&
      epoch == _projectController.projectEpoch &&
      root == _projectController.rootConfigPath;

  int _compareFileResults(
    THProjectSearchFileResult a,
    THProjectSearchFileResult b,
  ) {
    final int byDisplay = a.displayPath.toLowerCase().compareTo(
      b.displayPath.toLowerCase(),
    );

    if (byDisplay != 0) {
      return byDisplay;
    }

    return a.canonicalPath.compareTo(b.canonicalPath);
  }

  List<_SearchSource> _collectOpenTabSources(
    List<THProjectSearchFailure> outFailures,
  ) {
    final List<_SearchSource> sources = <_SearchSource>[];

    for (final String path in _generalController.openFileOrder) {
      if (isTH2Tab(path)) {
        continue;
      }

      final THProjectFileNode? node = _projectController.nodeByCanonicalPath(
        path,
      );
      final bool eligible =
          (node is THConfigFileNode) || (node is THDataFileNode);
      final THTextEditorController? controller = _generalController
          .getTextEditorControllerIfExists(path);

      if (controller != null &&
          controller.loadState == THTextEditorLoadState.loaded) {
        sources.add(
          _SearchSource(
            canonicalPath: path,
            displayPath: _displayPathFor(path, node),
            content: controller.content,
            revision: eligible ? controller.observedRevision : null,
            isReplaceEligible: eligible,
          ),
        );
        continue;
      }

      if (controller != null &&
          controller.loadState == THTextEditorLoadState.failed) {
        outFailures.add(
          THProjectSearchFailure(
            canonicalPath: path,
            displayPath: _displayPathFor(path, node),
            kind: THProjectSearchFailureKind.read,
            technicalMessage:
                controller.loadFailureTechnicalMessage ?? 'load failed',
          ),
        );
        continue;
      }

      // notLoaded / loading / no controller: never scan a stale buffer.
      final _SearchSource? fallback = _fallbackSource(
        path,
        node,
        eligible,
        outFailures,
      );

      if (fallback != null) {
        sources.add(fallback);
      }
    }

    return sources;
  }

  List<_SearchSource> _collectProjectSources(
    List<THProjectSearchFailure> outFailures,
  ) {
    final List<_SearchSource> sources = <_SearchSource>[];

    for (final String path
        in _projectController.writableTextFileCanonicalPaths()) {
      final THProjectFileNode? node = _projectController.nodeByCanonicalPath(
        path,
      );
      final THTextEditorController? controller = _generalController
          .getTextEditorControllerIfExists(path);

      if (controller != null &&
          controller.loadState == THTextEditorLoadState.loaded) {
        sources.add(
          _SearchSource(
            canonicalPath: path,
            displayPath: _displayPathFor(path, node),
            content: controller.content,
            revision: controller.observedRevision,
            isReplaceEligible: true,
          ),
        );
        continue;
      }

      final _SearchSource? fallback = _fallbackSource(
        path,
        node,
        true,
        outFailures,
      );

      if (fallback != null) {
        sources.add(fallback);
      }
    }

    return sources;
  }

  _SearchSource? _fallbackSource(
    String path,
    THProjectFileNode? node,
    bool eligible,
    List<THProjectSearchFailure> outFailures,
  ) {
    final THTextProjectContentSnapshot snapshot = _projectController
        .textContentSnapshot(path);

    if (snapshot.isProjectTracked) {
      return _SearchSource(
        canonicalPath: path,
        displayPath: _displayPathFor(path, node),
        content: snapshot.content,
        revision: eligible ? snapshot.currentRevision : null,
        isReplaceEligible: eligible,
      );
    }

    try {
      return _SearchSource(
        canonicalPath: path,
        displayPath: _displayPathFor(path, node),
        content: THProjectParser.readFileContent(path).content,
        revision: null,
        isReplaceEligible: false,
      );
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THProjectSearchController] read failed for $path',
        error: error,
        stackTrace: stackTrace,
      );
      outFailures.add(
        THProjectSearchFailure(
          canonicalPath: path,
          displayPath: _displayPathFor(path, node),
          kind: THProjectSearchFailureKind.read,
          technicalMessage: '$error',
        ),
      );
      return null;
    }
  }

  String _displayPathFor(String canonicalPath, THProjectFileNode? node) {
    if (node != null && node.relativePathToProjectRoot.isNotEmpty) {
      return node.relativePathToProjectRoot;
    }

    final String root = _projectController.rootConfigPath;

    if (root.isNotEmpty && p.isWithin(p.dirname(root), canonicalPath)) {
      return p.relative(canonicalPath, from: p.dirname(root));
    }

    return canonicalPath;
  }

  // ---------------------------------------------------------------------------
  // Project lifecycle reaction
  // ---------------------------------------------------------------------------

  @action
  void clearForProjectChange() {
    _debounceTimer?.cancel();
    _searchGeneration++;
    _replaceGeneration++;
    results = ObservableList<THProjectSearchFileResult>();
    failures = ObservableList<THProjectSearchFailure>();
    expandedResultPaths = ObservableSet<String>();
    _resultProjectEpoch = null;
    _resultRootPath = null;
    isSearching = false;
    isReplacing = false;

    if (_projectController.rootConfigPath.isEmpty &&
        scope == THProjectSearchScope.projectFiles) {
      scope = THProjectSearchScope.openTextTabs;
    }
  }

  // ---------------------------------------------------------------------------
  // Replace All
  // ---------------------------------------------------------------------------

  /// Re-runs the search, discards standalone results, precomputes every
  /// eligible replacement string, performs read-only structural I/O checks,
  /// and returns an immutable snapshot for the confirmation dialog. Returns
  /// `null` when nothing eligible remains (Replace All stays disabled) or a
  /// preflight check fails.
  @action
  Future<THProjectSearchReplacePreflight?> prepareReplaceAll() async {
    if (query.isEmpty || isReplacing) {
      return null;
    }

    await submitQuery();

    if (!_resultsCurrent) {
      return null;
    }

    final int epoch = _projectController.projectEpoch;
    final String root = _projectController.rootConfigPath;
    final List<THProjectSearchReplaceTarget> targets =
        <THProjectSearchReplaceTarget>[];
    final List<THProjectSearchFailure> preflightFailures =
        <THProjectSearchFailure>[];
    int eligibleMatchCount = 0;

    for (final THProjectSearchFileResult result in results) {
      if (!result.isReplaceEligible) {
        continue;
      }

      final THProjectFileNode? node = _projectController.nodeByCanonicalPath(
        result.canonicalPath,
      );

      if ((node is! THConfigFileNode) && (node is! THDataFileNode)) {
        // Became standalone since the refreshed search.
        continue;
      }

      final String replaced = _applyReplacement(
        result.searchedContent,
        findPlainTextMatches(
          content: result.searchedContent,
          query: query,
          caseSensitive: caseSensitive,
        ),
      );

      if (replaced == result.searchedContent) {
        continue;
      }

      final THProjectSearchFailure? structuralFailure = _readOnlyPreflightCheck(
        result.canonicalPath,
        result.displayPath,
      );

      if (structuralFailure != null) {
        preflightFailures.add(structuralFailure);
        continue;
      }

      final int? revision = result.searchedRevision;

      if (revision == null) {
        continue;
      }

      eligibleMatchCount += result.matchCount;
      targets.add(
        THProjectSearchReplaceTarget(
          canonicalPath: result.canonicalPath,
          displayPath: result.displayPath,
          searchedContent: result.searchedContent,
          searchedRevision: revision,
          replacementContent: replaced,
          matchCount: result.matchCount,
          hasOpenTab:
              _generalController.getTextEditorControllerIfExists(
                result.canonicalPath,
              ) !=
              null,
        ),
      );
    }

    if (preflightFailures.isNotEmpty) {
      failures = ObservableList<THProjectSearchFailure>.of(<
        THProjectSearchFailure
      >[...failures, ...preflightFailures]);
    }

    if (targets.isEmpty || eligibleMatchCount == 0) {
      return null;
    }

    return THProjectSearchReplacePreflight(
      replaceGeneration: ++_replaceGeneration,
      searchGeneration: _searchGeneration,
      projectEpoch: epoch,
      rootPath: root,
      query: query,
      replacement: replacement,
      caseSensitive: caseSensitive,
      scope: scope,
      targets: targets,
      eligibleMatchCount: eligibleMatchCount,
      excludedStandaloneFileCount: standaloneFileCount,
      excludedStandaloneMatchCount: standaloneMatchCount,
      preflightFailures: preflightFailures,
    );
  }

  String _applyReplacement(String content, List<TextRange> ranges) {
    if (ranges.isEmpty) {
      return content;
    }

    final StringBuffer buffer = StringBuffer();
    int cursor = 0;

    for (final TextRange range in ranges) {
      buffer
        ..write(content.substring(cursor, range.start))
        ..write(replacement);
      cursor = range.end;
    }

    buffer.write(content.substring(cursor));

    return buffer.toString();
  }

  THProjectSearchFailure? _readOnlyPreflightCheck(
    String canonicalPath,
    String displayPath,
  ) {
    try {
      final FileSystemEntity? entity = _resolveEntitySync(canonicalPath);

      if (entity is! File) {
        return THProjectSearchFailure(
          canonicalPath: canonicalPath,
          displayPath: displayPath,
          kind: THProjectSearchFailureKind.save,
          technicalMessage: 'target is missing or not a regular file',
        );
      }

      final Directory parent = Directory(p.dirname(canonicalPath));

      if (!parent.existsSync()) {
        return THProjectSearchFailure(
          canonicalPath: canonicalPath,
          displayPath: displayPath,
          kind: THProjectSearchFailureKind.save,
          technicalMessage: 'parent directory is missing',
        );
      }

      // An unopened target must still be readable; an open editor already
      // holds authoritative content.
      if (_generalController.getTextEditorControllerIfExists(canonicalPath) ==
          null) {
        THProjectParser.readFileContent(canonicalPath);
      }

      return null;
    } catch (error) {
      return THProjectSearchFailure(
        canonicalPath: canonicalPath,
        displayPath: displayPath,
        kind: THProjectSearchFailureKind.save,
        technicalMessage: '$error',
      );
    }
  }

  FileSystemEntity? _resolveEntitySync(String canonicalPath) {
    final File file = File(canonicalPath);

    if (file.existsSync()) {
      return file;
    }

    final Directory dir = Directory(canonicalPath);

    if (dir.existsSync()) {
      return dir;
    }

    return null;
  }

  /// Revalidates [preflight] in full, then applies every still-valid target
  /// through its editor controller, saves, materializes failed temporary
  /// targets as ordinary dirty tabs, and re-runs the search. Returns the
  /// aggregate report for the completion dialog.
  @action
  Future<THProjectSearchReplaceReport> executeReplaceAll(
    THProjectSearchReplacePreflight preflight,
  ) async {
    final List<THProjectSearchReplaceOutcome> outcomes =
        <THProjectSearchReplaceOutcome>[];
    final List<String> materializedPaths = <String>[];

    if (!_replaceIdentityCurrent(preflight)) {
      return THProjectSearchReplaceReport(
        outcomes: outcomes,
        materializedPaths: materializedPaths,
        excludedStandaloneFileCount: preflight.excludedStandaloneFileCount,
        excludedStandaloneMatchCount: preflight.excludedStandaloneMatchCount,
      );
    }

    isReplacing = true;

    final List<String> failedTemporaryTargets = <String>[];

    try {
      final List<THProjectSearchReplaceTarget> ordered =
          List<THProjectSearchReplaceTarget>.of(preflight.targets)..sort(
            (THProjectSearchReplaceTarget a, THProjectSearchReplaceTarget b) =>
                a.canonicalPath.compareTo(b.canonicalPath),
          );

      for (final THProjectSearchReplaceTarget target in ordered) {
        if (!_replaceIdentityCurrent(preflight)) {
          outcomes.add(
            THProjectSearchReplaceOutcome.skipped(
              canonicalPath: target.canonicalPath,
              displayPath: target.displayPath,
            matchCount: target.matchCount,
              skipReason: _replaceGeneration != preflight.replaceGeneration
                  ? THProjectSearchReplaceSkipReason.searchSuperseded
                  : THProjectSearchReplaceSkipReason.projectChanged,
            ),
          );
          continue;
        }

        final _TargetApplication application = await _applyTarget(
          target,
          preflight,
        );

        outcomes.add(application.outcome);

        if (application.failedTemporary) {
          failedTemporaryTargets.add(target.canonicalPath);
        }
      }
    } finally {
      isReplacing = false;
    }

    // Materialize failed/incomplete temporary targets as ordinary dirty tabs,
    // after the replacement loop so opening them cannot perturb source
    // collection mid-run.
    for (final String path in failedTemporaryTargets.toSet().toList()..sort()) {
      if (!_replaceIdentityCurrent(preflight)) {
        break;
      }

      final bool materialized = await _materializeFailedTemporaryTarget(
        path,
        preflight,
      );

      if (materialized) {
        materializedPaths.add(path);
      }
    }

    await runSearch();

    return THProjectSearchReplaceReport(
      outcomes: outcomes,
      materializedPaths: materializedPaths,
      excludedStandaloneFileCount: preflight.excludedStandaloneFileCount,
      excludedStandaloneMatchCount: preflight.excludedStandaloneMatchCount,
    );
  }

  bool _replaceIdentityCurrent(THProjectSearchReplacePreflight preflight) =>
      _replaceGeneration == preflight.replaceGeneration &&
      _projectController.projectEpoch == preflight.projectEpoch &&
      _projectController.rootConfigPath == preflight.rootPath;

  Future<_TargetApplication> _applyTarget(
    THProjectSearchReplaceTarget target,
    THProjectSearchReplacePreflight preflight,
  ) async {
    final bool reuseOpen =
        _generalController.getTextEditorControllerIfExists(
          target.canonicalPath,
        ) !=
        null;
    THTextEditorController? temporary;
    final THTextEditorController controller;

    if (reuseOpen) {
      controller = _generalController.getTextEditorControllerIfExists(
        target.canonicalPath,
      )!;
    } else {
      temporary = THTextEditorController(
        projectController: _projectController,
      );
      try {
        await temporary.loadFile(target.canonicalPath);
      } catch (_) {
        temporary.dispose();
        return _TargetApplication(
          outcome: THProjectSearchReplaceOutcome.skipped(
            canonicalPath: target.canonicalPath,
            displayPath: target.displayPath,
            matchCount: target.matchCount,
            skipReason: THProjectSearchReplaceSkipReason.contentChanged,
          ),
          failedTemporary: false,
        );
      }
      controller = temporary;
    }

    try {
      // Final per-target revalidation — must be the last thing before
      // setContent(): an earlier save can change the dependency tree, another
      // controller can register a newer revision, or the load above can yield.
      if (!_replaceIdentityCurrent(preflight)) {
        return _TargetApplication(
          outcome: THProjectSearchReplaceOutcome.skipped(
            canonicalPath: target.canonicalPath,
            displayPath: target.displayPath,
            matchCount: target.matchCount,
            skipReason:
                _replaceGeneration != preflight.replaceGeneration
                ? THProjectSearchReplaceSkipReason.searchSuperseded
                : THProjectSearchReplaceSkipReason.projectChanged,
          ),
          failedTemporary: false,
        );
      }

      final THProjectFileNode? node = _projectController.nodeByCanonicalPath(
        target.canonicalPath,
      );

      if ((node is! THConfigFileNode) && (node is! THDataFileNode)) {
        return _TargetApplication(
          outcome: THProjectSearchReplaceOutcome.skipped(
            canonicalPath: target.canonicalPath,
            displayPath: target.displayPath,
            matchCount: target.matchCount,
            skipReason: THProjectSearchReplaceSkipReason.eligibilityChanged,
          ),
          failedTemporary: false,
        );
      }

      final THTextProjectContentSnapshot snapshot = _projectController
          .textContentSnapshot(target.canonicalPath);

      if (!snapshot.isProjectTracked ||
          snapshot.content != target.searchedContent ||
          snapshot.currentRevision != target.searchedRevision) {
        return _TargetApplication(
          outcome: THProjectSearchReplaceOutcome.skipped(
            canonicalPath: target.canonicalPath,
            displayPath: target.displayPath,
            matchCount: target.matchCount,
            skipReason: THProjectSearchReplaceSkipReason.contentChanged,
          ),
          failedTemporary: false,
        );
      }

      controller.setContent(target.replacementContent);

      final THTextFileSaveResult saveResult = await controller.save();

      final THProjectSearchReplaceOutcome outcome =
          THProjectSearchReplaceOutcome.saved(
            canonicalPath: target.canonicalPath,
            displayPath: target.displayPath,
            matchCount: target.matchCount,
            saveResult: saveResult,
          );

      final bool failedTemporary =
          temporary != null && !saveResult.isCurrentRevisionSaved;

      return _TargetApplication(
        outcome: outcome,
        failedTemporary: failedTemporary,
      );
    } finally {
      temporary?.dispose();
    }
  }

  Future<bool> _materializeFailedTemporaryTarget(
    String canonicalPath,
    THProjectSearchReplacePreflight preflight,
  ) async {
    // Only recoverable if pending dirty content still belongs to this project.
    if (!_projectController.isFileDirty(canonicalPath)) {
      return false;
    }

    if (_generalController.getTextEditorControllerIfExists(canonicalPath) !=
        null) {
      // The user opened/edited it during replacement — just ensure the tab.
      _generalController.addFileTab(canonicalPath);
      return true;
    }

    final THTextEditorController controller = _generalController
        .getTextEditorController(canonicalPath);

    try {
      await controller.loadFile(canonicalPath);
    } catch (_) {
      _generalController.removeFileController(filename: canonicalPath);
      return false;
    }

    if (!_replaceIdentityCurrent(preflight)) {
      _generalController.removeFileController(filename: canonicalPath);
      return false;
    }

    _generalController.addFileTab(canonicalPath);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Navigation support
  // ---------------------------------------------------------------------------

  /// Whether [match]'s range still contains [query] under the current case
  /// rule in the file's current authoritative content.
  bool matchIsStillValid(THProjectSearchMatch match) {
    final String? content = _currentContentFor(match.canonicalPath);

    if (content == null) {
      return false;
    }

    if (match.range.end > content.length) {
      return false;
    }

    final String slice = content.substring(match.range.start, match.range.end);

    return caseSensitive
        ? slice == query
        : slice.toLowerCase() == query.toLowerCase();
  }

  String? _currentContentFor(String canonicalPath) {
    final THTextEditorController? controller = _generalController
        .getTextEditorControllerIfExists(canonicalPath);

    if (controller != null &&
        controller.loadState == THTextEditorLoadState.loaded) {
      return controller.content;
    }

    final THTextProjectContentSnapshot snapshot = _projectController
        .textContentSnapshot(canonicalPath);

    if (snapshot.isProjectTracked) {
      return snapshot.content;
    }

    try {
      return THProjectParser.readFileContent(canonicalPath).content;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Disposal
  // ---------------------------------------------------------------------------

  void dispose() {
    _debounceTimer?.cancel();
    _lifecycleReaction();
  }
}

class _SearchSource {
  final String canonicalPath;
  final String displayPath;
  final String content;
  final int? revision;
  final bool isReplaceEligible;

  const _SearchSource({
    required this.canonicalPath,
    required this.displayPath,
    required this.content,
    required this.revision,
    required this.isReplaceEligible,
  });
}

class _TargetApplication {
  final THProjectSearchReplaceOutcome outcome;
  final bool failedTemporary;

  const _TargetApplication({
    required this.outcome,
    required this.failedTemporary,
  });
}
