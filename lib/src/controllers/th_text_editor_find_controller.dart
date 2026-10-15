// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' show TextRange;

import 'package:mapiah/src/auxiliary/th_text_search_aux.dart';
import 'package:mapiah/src/controllers/th_text_editor_buffer.dart';
import 'package:mobx/mobx.dart';

part 'th_text_editor_find_controller.g.dart';

class THTextEditorFindController = THTextEditorFindControllerBase
    with _$THTextEditorFindController;

/// Find/replace state of one text editor buffer. Replacements go through the
/// buffer's `setContent`, so one replacement updates the buffer's dirty
/// state, tracking and validation once.
abstract class THTextEditorFindControllerBase with Store {
  final THTextEditorBuffer _buffer;

  THTextEditorFindControllerBase(this._buffer);

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

  /// Non-overlapping, left-to-right occurrences of [findQuery] in the
  /// buffer's content. A plain substring scan — no regex support. Delegates to
  /// the shared [findPlainTextMatches] helper so single-file and multi-file
  /// search have identical semantics.
  @computed
  List<TextRange> get findMatches => findPlainTextMatches(
    content: _buffer.content,
    query: findQuery,
    caseSensitive: findCaseSensitive,
  );

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
    if (_buffer.isReadOnly) {
      return;
    }

    final List<TextRange> matches = findMatches;
    final int? index = activeMatchIndex;

    if (index == null || index < 0 || index >= matches.length) {
      return;
    }

    final TextRange match = matches[index];

    _buffer.setContent(
      _buffer.content.replaceRange(match.start, match.end, replaceQuery),
      cursorOffset: match.start + replaceQuery.length,
    );
    _clampActiveMatchIndex();
  }

  @action
  void replaceAllMatches() {
    if (_buffer.isReadOnly) {
      return;
    }

    final List<TextRange> matches = findMatches;

    if (matches.isEmpty) {
      return;
    }

    final String content = _buffer.content;
    final StringBuffer buffer = StringBuffer();
    int cursor = 0;

    for (final TextRange match in matches) {
      buffer
        ..write(content.substring(cursor, match.start))
        ..write(replaceQuery);
      cursor = match.end;
    }

    final int lastReplacementEnd = buffer.length;

    buffer.write(content.substring(cursor));
    _buffer.setContent(buffer.toString(), cursorOffset: lastReplacementEnd);
    activeMatchIndex = null;
  }

  /// Clears the find state of a session that ended.
  @action
  void reset() {
    closeFindBar();
    findCaseSensitive = false;
  }

  @action
  void clampActiveMatchIndex() {
    _clampActiveMatchIndex();
  }

  void _clampActiveMatchIndex() {
    final List<TextRange> matches = findMatches;

    if (matches.isEmpty) {
      activeMatchIndex = null;
    } else if (activeMatchIndex != null && activeMatchIndex! >= matches.length) {
      activeMatchIndex = matches.length - 1;
    }
  }
}
