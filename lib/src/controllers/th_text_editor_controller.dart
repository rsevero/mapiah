// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:ui' show TextRange;

import 'package:flutter/widgets.dart' show FocusNode, visibleForTesting;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_fold_aux.dart';
import 'package:mapiah/src/auxiliary/th_text_search_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_project_reparse_flush_result.dart';
import 'package:mapiah/src/controllers/th_text_file_revert_result.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/th_text_project_content_snapshot.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

part 'th_text_editor_controller.g.dart';

class THTextEditorController = THTextEditorControllerBase
    with _$THTextEditorController;

/// Durable load state of a [THTextEditorController]. Unlike the transient
/// [THTextEditorControllerBase.isLoading] flag, this distinguishes a controller
/// that has never loaded from one whose load failed, so multi-file search never
/// scans an empty/stale buffer as if it were authoritative content.
enum THTextEditorLoadState { notLoaded, loading, loaded, failed }

/// MobX store owning the state of one open `thconfig`/`.th` text-editor
/// instance: current text, dirty state, cursor/scroll position, fold state,
/// and a diagnostics snapshot filtered from [THProjectController.allDiagnostics].
///
/// This controller is a UI/data bridge, not a replacement for
/// [THProjectController]: parsing and tree mutation stay there. One instance
/// exists per open editor; it is not a locator singleton.
///
/// A project-bound controller captures `(projectEpoch, rootPath)` as an
/// immutable ownership identity for its whole lifetime. Every entry point and
/// delayed callback checks that identity against the project controller before
/// mutating either the editor buffer or project state; loading the same path
/// under a newer epoch requires a fresh controller instance.
abstract class THTextEditorControllerBase
    with Store
    implements THTextEditorControllerHandle {
  final THProjectController _projectController;

  THTextEditorControllerBase({THProjectController? projectController})
    : _projectController = projectController ?? mpLocator.thProjectController;

  @observable
  String canonicalPath = '';

  @observable
  String content = '';

  @observable
  bool isDirty = false;

  @observable
  bool isLoading = false;

  @observable
  int cursorLine = 0;

  @observable
  int cursorColumn = 0;

  @observable
  ObservableSet<int> collapsedFoldStarts = ObservableSet<int>();

  @observable
  String findQuery = '';

  @observable
  String replaceQuery = '';

  @observable
  bool findCaseSensitive = false;

  @observable
  bool isFindBarVisible = false;

  @observable
  int? activeMatchIndex;

  @observable
  int? pendingScrollToLine;

  /// A pending exact selection to apply once the widget has synchronized the
  /// controller content into its `TextEditingController`. Set by multi-file
  /// search result navigation; consumed and cleared by [THTextEditorWidget].
  @observable
  TextRange? pendingSelectionRange;

  /// Durable load state; see [THTextEditorLoadState].
  @observable
  THTextEditorLoadState loadState = THTextEditorLoadState.notLoaded;

  /// Logged technical description of the last load failure, or `null`. Not a
  /// localized, user-facing string.
  String? loadFailureTechnicalMessage;

  /// The project content revision this editor currently represents. `0` for a
  /// clean disk-backed load or an unbound editor.
  @observable
  int observedRevision = 0;

  /// Set true when the last [setContent] / [flushPendingReparse] / [save] /
  /// [revert] could not act because the project moved to a newer epoch/root.
  @observable
  bool lastOperationRejectedByProjectChange = false;

  /// The `(projectEpoch, rootPath)` this controller is bound to, or `null`
  /// while it is unbound (path not tracked by any open project). Immutable
  /// once set for the controller's lifetime.
  int? _ownedProjectEpoch;
  String? _ownedRootPath;

  bool get isProjectBound => _ownedProjectEpoch != null;

  /// Whether this controller's immutable ownership identity still matches the
  /// project controller's current epoch/root.
  bool matchesCurrentProject() =>
      isProjectBound &&
      (_ownedProjectEpoch == _projectController.projectEpoch) &&
      (_ownedRootPath == _projectController.rootConfigPath);

  /// Whether a generic project save for `(epoch, rootPath, revision)` may
  /// synchronize this controller's dirty state from its typed result.
  bool matchesProjectSaveRequest(int epoch, String rootPath, int revision) =>
      isProjectBound &&
      (_ownedProjectEpoch == epoch) &&
      (_ownedRootPath == rootPath) &&
      (observedRevision == revision);

  final FocusNode textEditorFocusNode = FocusNode();

  @computed
  List<THProjectParseError> get diagnostics => _projectController
      .allDiagnostics
      .where((THProjectParseError error) => error.filePath == canonicalPath)
      .toList();

  @computed
  List<THTextEditorFoldRegion> get foldRegions => buildFoldRegions(content);

  /// Non-overlapping, left-to-right occurrences of [findQuery] in [content].
  /// A plain substring scan — no regex support in this increment. Delegates to
  /// the shared [findPlainTextMatches] helper so single-file and multi-file
  /// search have identical semantics.
  @computed
  List<TextRange> get findMatches => findPlainTextMatches(
    content: content,
    query: findQuery,
    caseSensitive: findCaseSensitive,
  );

  Timer? _reparseTimer;

  @action
  Future<void> loadFile(String filePath) async {
    final String resolvedCanonicalPath = THProjectPathResolver.canonicalize(
      p.absolute(filePath),
    );

    final THTextProjectContentSnapshot snapshot = _projectController
        .textContentSnapshot(resolvedCanonicalPath);

    // A controller already bound to a different project identity must never
    // rebind or replace its buffer. Loading the same path under a newer epoch
    // requires a new controller instance.
    if (isProjectBound &&
        ((_ownedProjectEpoch != snapshot.projectEpoch) ||
            (_ownedRootPath != snapshot.rootPath))) {
      lastOperationRejectedByProjectChange = true;

      return;
    }

    canonicalPath = resolvedCanonicalPath;
    isLoading = true;
    loadState = THTextEditorLoadState.loading;

    try {
      if (snapshot.isProjectTracked) {
        _ownedProjectEpoch = snapshot.projectEpoch;
        _ownedRootPath = snapshot.rootPath;
        content = snapshot.content;
        observedRevision = snapshot.currentRevision;
        isDirty = snapshot.isDirty;
      } else {
        content = THProjectParser.readFileContent(
          resolvedCanonicalPath,
        ).content;
        observedRevision = 0;
        isDirty = false;
      }

      cursorLine = 0;
      cursorColumn = 0;
      collapsedFoldStarts = ObservableSet<int>();
      lastOperationRejectedByProjectChange = false;
      loadFailureTechnicalMessage = null;
      loadState = THTextEditorLoadState.loaded;
    } catch (error, stackTrace) {
      loadFailureTechnicalMessage =
          '[THTextEditorController] loadFile failed for '
          '$resolvedCanonicalPath: $error';
      loadState = THTextEditorLoadState.failed;
      mpLocator.mpLog.e(
        loadFailureTechnicalMessage,
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Records a pending exact selection to apply after the widget synchronizes
  /// content. Analogous to [scrollToLine]/[pendingScrollToLine]; used by
  /// multi-file search result navigation so it never mutates [findQuery].
  @action
  void revealRange(TextRange range) {
    pendingSelectionRange = range;
  }

  @action
  void clearPendingSelectionRange() {
    pendingSelectionRange = null;
  }

  @action
  void setContent(String newContent) {
    if (!isProjectBound) {
      // Unbound editor: local text buffer only, no project re-parse.
      content = newContent;
      isDirty = true;

      return;
    }

    final int revision = _projectController.registerTextContentChange(
      canonicalPath: canonicalPath,
      content: newContent,
      expectedProjectEpoch: _ownedProjectEpoch!,
      expectedRootPath: _ownedRootPath!,
    );

    if (revision == -1) {
      lastOperationRejectedByProjectChange = true;

      return;
    }

    content = newContent;
    isDirty = true;
    observedRevision = revision;

    final int capturedEpoch = _ownedProjectEpoch!;
    final String capturedRoot = _ownedRootPath!;

    _reparseTimer?.cancel();
    _reparseTimer = Timer(
      const Duration(milliseconds: mpTextEditorReparseDebounceMilliseconds),
      () {
        unawaited(
          _projectController.reparseFile(
            filePath: canonicalPath,
            updatedContent: content,
            revision: revision,
            expectedProjectEpoch: capturedEpoch,
            expectedRootPath: capturedRoot,
          ),
        );
      },
    );
  }

  @action
  void setCursorPosition({required int line, required int column}) {
    cursorLine = line;
    cursorColumn = column;
  }

  @action
  void scrollToLine(int lineNumber) {
    pendingScrollToLine = lineNumber - 1; // THProjectNode.lineNumber is 1-based.
  }

  @action
  void clearPendingScrollToLine() {
    pendingScrollToLine = null;
  }

  @action
  void toggleFold(int startLine) {
    if (!collapsedFoldStarts.remove(startLine)) {
      collapsedFoldStarts.add(startLine);
    }
  }

  @action
  void openFindBar() {
    isFindBarVisible = true;
    _clampActiveMatchIndex();

    if (activeMatchIndex == null && findMatches.isNotEmpty) {
      activeMatchIndex = 0;
    }
  }

  @action
  void closeFindBar() {
    isFindBarVisible = false;
    findQuery = '';
    replaceQuery = '';
    activeMatchIndex = null;
  }

  @action
  void setFindQuery(String query) {
    findQuery = query;
    _clampActiveMatchIndex();

    if (activeMatchIndex == null && findMatches.isNotEmpty) {
      activeMatchIndex = 0;
    }
  }

  @action
  void setReplaceQuery(String query) {
    replaceQuery = query;
  }

  @action
  void setFindCaseSensitive(bool value) {
    findCaseSensitive = value;
    _clampActiveMatchIndex();
  }

  @action
  void findNext() {
    final List<TextRange> matches = findMatches;

    if (matches.isEmpty) {
      activeMatchIndex = null;

      return;
    }

    final int currentIndex = activeMatchIndex ?? -1;

    activeMatchIndex = (currentIndex + 1) % matches.length;
  }

  @action
  void findPrevious() {
    final List<TextRange> matches = findMatches;

    if (matches.isEmpty) {
      activeMatchIndex = null;

      return;
    }

    final int currentIndex = activeMatchIndex ?? 0;

    activeMatchIndex = (currentIndex - 1 + matches.length) % matches.length;
  }

  @action
  void replaceActiveMatch() {
    final List<TextRange> matches = findMatches;
    final int? index = activeMatchIndex;

    if (index == null || index < 0 || index >= matches.length) {
      return;
    }

    final TextRange match = matches[index];

    setContent(content.replaceRange(match.start, match.end, replaceQuery));
    _clampActiveMatchIndex();
  }

  @action
  void replaceAllMatches() {
    final List<TextRange> matches = findMatches;

    if (matches.isEmpty) {
      return;
    }

    final StringBuffer buffer = StringBuffer();
    int cursor = 0;

    for (final TextRange match in matches) {
      buffer
        ..write(content.substring(cursor, match.start))
        ..write(replaceQuery);
      cursor = match.end;
    }

    buffer.write(content.substring(cursor));
    setContent(buffer.toString());
    activeMatchIndex = null;
  }

  void _clampActiveMatchIndex() {
    final List<TextRange> matches = findMatches;

    if (matches.isEmpty) {
      activeMatchIndex = null;
    } else if (activeMatchIndex != null && activeMatchIndex! >= matches.length) {
      activeMatchIndex = matches.length - 1;
    }
  }

  /// Drains the editor-level `_reparseTimer`, then chains into the
  /// project-level flush so a stale parsed node can never reach the writers.
  /// Returns the project-level typed reparse outcome.
  @action
  Future<THProjectReparseFlushResult> flushPendingReparse() async {
    _reparseTimer?.cancel();

    if (!isProjectBound) {
      return THProjectReparseFlushResult(
        canonicalPath: canonicalPath,
        projectEpoch: -1,
        expectedRevision: observedRevision,
        parsedRevision: observedRevision,
        status: THProjectReparseFlushStatus.alreadyCurrent,
      );
    }

    final int requestedRevision = observedRevision;
    final int capturedEpoch = _ownedProjectEpoch!;
    final String capturedRoot = _ownedRootPath!;

    if (isDirty) {
      await _projectController.reparseFile(
        filePath: canonicalPath,
        updatedContent: content,
        revision: requestedRevision,
        expectedProjectEpoch: capturedEpoch,
        expectedRootPath: capturedRoot,
      );
    }

    return _projectController.flushPendingReparse(
      canonicalPath: canonicalPath,
      expectedRevision: requestedRevision,
      expectedProjectEpoch: capturedEpoch,
      expectedRootPath: capturedRoot,
    );
  }

  @action
  Future<THTextFileSaveResult> save() async {
    if (!isProjectBound) {
      return THTextFileSaveResult(
        canonicalPath: canonicalPath,
        projectEpoch: -1,
        requestedRevision: observedRevision,
        writtenRevision: null,
        currentRevision: observedRevision,
        status: THTextFileSaveStatus.unknownPath,
      );
    }

    final int capturedEpoch = _ownedProjectEpoch!;
    final String capturedRoot = _ownedRootPath!;
    final int requestedRevision = observedRevision;

    final THProjectReparseFlushResult flush = await flushPendingReparse();

    if (!flush.canProceedToSave) {
      final THTextFileSaveStatus status = switch (flush.status) {
        THProjectReparseFlushStatus.projectChanged =>
          THTextFileSaveStatus.projectChangedBeforeWrite,
        THProjectReparseFlushStatus.superseded =>
          THTextFileSaveStatus.supersededBeforeWrite,
        _ => THTextFileSaveStatus.reparseFailed,
      };

      if (status == THTextFileSaveStatus.projectChangedBeforeWrite) {
        lastOperationRejectedByProjectChange = true;
      }

      return THTextFileSaveResult(
        canonicalPath: canonicalPath,
        projectEpoch: capturedEpoch,
        requestedRevision: requestedRevision,
        writtenRevision: null,
        currentRevision: null,
        status: status,
      );
    }

    final THTextFileSaveResult result = await _projectController
        .saveTextProjectFile(
          canonicalPath: canonicalPath,
          requestedRevision: requestedRevision,
          expectedProjectEpoch: capturedEpoch,
          expectedRootPath: capturedRoot,
        );

    _applySaveResult(result);

    return result;
  }

  @override
  void applyExternalSaveResult(THTextFileSaveResult result) {
    _applySaveResult(result);
  }

  void _applySaveResult(THTextFileSaveResult result) {
    if (result.isCurrentRevisionSaved) {
      isDirty = false;
    } else if (result.status == THTextFileSaveStatus.savedButSuperseded) {
      isDirty = true;
    } else if (result.status ==
        THTextFileSaveStatus.projectChangedBeforeWrite) {
      lastOperationRejectedByProjectChange = true;
    }
  }

  @action
  Future<void> revert() async {
    _reparseTimer?.cancel();

    if (!isProjectBound) {
      _revertUntrackedFromDisk();

      return;
    }

    if (!isDirty) {
      final THTextProjectContentSnapshot snapshot = _projectController
          .textContentSnapshot(canonicalPath);

      if (snapshot.isProjectTracked) {
        content = snapshot.content;
        observedRevision = snapshot.currentRevision;
        isDirty = snapshot.isDirty;
      }

      return;
    }

    final THTextFileRevertResult result = await _projectController
        .revertTextProjectFile(
          canonicalPath: canonicalPath,
          requestedRevision: observedRevision,
          expectedProjectEpoch: _ownedProjectEpoch!,
          expectedRootPath: _ownedRootPath!,
        );

    final THTextProjectContentSnapshot? snapshot = result.snapshot;

    switch (result.status) {
      case THTextFileRevertStatus.reverted:
      case THTextFileRevertStatus.alreadyClean:
        if (snapshot != null) {
          content = snapshot.content;
          observedRevision = snapshot.currentRevision;
        }
        isDirty = false;
      case THTextFileRevertStatus.superseded:
        if (snapshot != null) {
          content = snapshot.content;
          observedRevision = snapshot.currentRevision;
          isDirty = snapshot.isDirty;
        }
      case THTextFileRevertStatus.projectChanged:
        lastOperationRejectedByProjectChange = true;
      case THTextFileRevertStatus.readFailed:
      case THTextFileRevertStatus.reparseFailed:
      case THTextFileRevertStatus.unknownPath:
        break;
    }
  }

  void _revertUntrackedFromDisk() {
    if (canonicalPath.isEmpty) {
      return;
    }

    try {
      content = THProjectParser.readFileContent(canonicalPath).content;
      observedRevision = 0;
      isDirty = false;
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THTextEditorController] revert disk read failed for $canonicalPath',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cancels the pending debounced `reparseFile` call, if any, without
  /// disposing the rest of the controller (unlike `dispose()`, this leaves
  /// `textEditorFocusNode` usable). Exists for tests that call `setContent`
  /// without wanting its debounce to fire later mid-test, and for the project
  /// controller's generic save path.
  @override
  @visibleForTesting
  void cancelPendingReparse() {
    _reparseTimer?.cancel();
  }

  /// Closes this tab. `removeFileTab` disposes this controller (via
  /// `MPGeneralController.removeFileController`), so no separate `dispose()`
  /// call is needed here.
  void close() {
    mpLocator.mpGeneralController.removeFileTab(filename: canonicalPath);
  }

  void dispose() {
    _reparseTimer?.cancel();
    textEditorFocusNode.dispose();
  }
}
