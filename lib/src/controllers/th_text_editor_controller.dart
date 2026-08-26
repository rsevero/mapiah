// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:ui' show TextRange;

import 'package:flutter/widgets.dart' show FocusNode, visibleForTesting;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_fold_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

part 'th_text_editor_controller.g.dart';

class THTextEditorController = THTextEditorControllerBase
    with _$THTextEditorController;

/// MobX store owning the state of one open `thconfig`/`.th` text-editor
/// instance: current text, dirty state, cursor/scroll position, fold state,
/// and a diagnostics snapshot filtered from [THProjectController.allDiagnostics].
///
/// This controller is a UI/data bridge, not a replacement for
/// [THProjectController]: parsing and tree mutation stay there. One instance
/// exists per open editor; it is not a locator singleton.
abstract class THTextEditorControllerBase with Store {
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

  final FocusNode textEditorFocusNode = FocusNode();

  @computed
  List<THProjectParseError> get diagnostics => _projectController
      .allDiagnostics
      .where((THProjectParseError error) => error.filePath == canonicalPath)
      .toList();

  @computed
  List<THTextEditorFoldRegion> get foldRegions => buildFoldRegions(content);

  /// Non-overlapping, left-to-right occurrences of [findQuery] in [content].
  /// A plain substring scan — no regex support in this increment.
  @computed
  List<TextRange> get findMatches {
    if (findQuery.isEmpty) {
      return const <TextRange>[];
    }

    final String haystack = findCaseSensitive ? content : content.toLowerCase();
    final String needle = findCaseSensitive
        ? findQuery
        : findQuery.toLowerCase();
    final List<TextRange> matches = <TextRange>[];
    int searchStart = 0;

    while (searchStart <= haystack.length - needle.length) {
      final int foundIndex = haystack.indexOf(needle, searchStart);

      if (foundIndex == -1) {
        break;
      }

      matches.add(
        TextRange(start: foundIndex, end: foundIndex + needle.length),
      );
      searchStart = foundIndex + needle.length;
    }

    return matches;
  }

  Timer? _reparseTimer;

  @action
  Future<void> loadFile(String filePath) async {
    final String resolvedCanonicalPath = THProjectPathResolver.canonicalize(
      p.absolute(filePath),
    );

    canonicalPath = resolvedCanonicalPath;
    isLoading = true;

    try {
      final String? cachedContent =
          _projectController.fileContentsCache[resolvedCanonicalPath];

      content =
          cachedContent ??
          THProjectParser.readFileContent(resolvedCanonicalPath).content;
      isDirty = false;
      cursorLine = 0;
      cursorColumn = 0;
      collapsedFoldStarts = ObservableSet<int>();
    } finally {
      isLoading = false;
    }
  }

  @action
  void setContent(String newContent) {
    content = newContent;
    isDirty = true;

    _reparseTimer?.cancel();
    _reparseTimer = Timer(
      const Duration(milliseconds: mpTextEditorReparseDebounceMilliseconds),
      () {
        _projectController.reparseFile(
          filePath: canonicalPath,
          updatedContent: content,
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

  @action
  Future<void> save() async {
    await _projectController.saveProjectFile(canonicalPath);

    if (!_projectController.dirtyFilePaths.contains(canonicalPath)) {
      isDirty = false;
    }
  }

  @action
  Future<void> revert() async {
    _reparseTimer?.cancel();
    await loadFile(canonicalPath);
  }

  /// Cancels the pending debounced `reparseFile` call, if any, without
  /// disposing the rest of the controller (unlike `dispose()`, this leaves
  /// `textEditorFocusNode` usable). Exists for tests that call `setContent`
  /// without wanting its debounce to fire later mid-test.
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
