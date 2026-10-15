// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_diagnostic.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_fold_aux.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_syntax_highlighter.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_text_editor_buffer.dart';
import 'package:mapiah/src/controllers/th_text_editor_find_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/th_text_editor_diagnostic_marker_widget.dart';
import 'package:mapiah/src/widgets/th_text_editor_line_number_gutter_widget.dart';
import 'package:material_ui/material_ui.dart';

final RegExp _thTextEditorLeadingWhitespaceRegExp = RegExp(r'^[ \t]*');
final RegExp _thTextEditorFirstWordRegExp = RegExp(r'^([a-z]+)');
final RegExp _thTextEditorFirstWhitespaceDelimitedWordRegExp = RegExp(
  r'^([^ \t]+)',
);

const Map<THTextEditorTokenType, Color> _thTextEditorTokenColors =
    <THTextEditorTokenType, Color>{
      THTextEditorTokenType.keyword: Color(0xFF7F0055),
      THTextEditorTokenType.directive: Color(0xFF7F0055),
      THTextEditorTokenType.option: Color(0xFF0000C0),
      THTextEditorTokenType.comment: Color(0xFF808080),
      THTextEditorTokenType.string: Color(0xFF2A9D2A),
      THTextEditorTokenType.number: Color(0xFF9D4B00),
      THTextEditorTokenType.stationReference: Color(0xFF006D9D),
      THTextEditorTokenType.punctuation: Color(0xFF444444),
      THTextEditorTokenType.setting: Color(0xFF8A6D00),
      THTextEditorTokenType.plain: Color(0xFF000000),
    };

const TextStyle _thTextEditorTextStyle = TextStyle(
  fontFamily: 'monospace',
  fontSize: mpTextEditorFontSize,
  height: mpTextEditorLineHeight,
);

/// Forces every row of the main field and of the syntax overlay to one
/// height, which the gutter, the markers and navigation measure.
const StrutStyle _thTextEditorStrutStyle = StrutStyle(
  fontFamily: 'monospace',
  fontSize: mpTextEditorFontSize,
  height: mpTextEditorLineHeight,
  forceStrutHeight: true,
);

const Color _thTextEditorFindMatchColor = Color(0x554DB6AC);
const Color _thTextEditorActiveFindMatchColor = Color(0x99FFB300);

/// Editor surface for one text buffer: a line-number gutter, an editable
/// text area with a lexical syntax-highlighting overlay, and diagnostic
/// markers.
///
/// Reads and writes go through [controller]; this widget owns only local
/// text-field wiring (scroll sync, cursor tracking, keyboard shortcuts and
/// the main field's native undo history).
class THTextEditorWidget extends StatefulWidget {
  final THTextEditorBuffer controller;

  /// Shown at the start of the toolbar, before its ordinary actions.
  final List<Widget> leadingToolbarActions;

  const THTextEditorWidget({
    super.key,
    required this.controller,
    this.leadingToolbarActions = const <Widget>[],
  });

  @override
  State<THTextEditorWidget> createState() => _THTextEditorWidgetState();
}

class _THTextEditorWidgetState extends State<THTextEditorWidget> {
  late final TextEditingController _textEditingController;
  late final ScrollController _textScrollController;
  late final ScrollController _gutterScrollController;
  late final ScrollController _overlayScrollController;
  late final TextEditingController _findEditingController;
  late final TextEditingController _replaceEditingController;
  late final FocusNode _findFieldFocusNode;
  late UndoHistoryController _undoHistoryController;
  bool _isSyncingFromController = false;
  bool _isSyncingFindFromController = false;
  bool _isSyncingReplaceFromController = false;
  bool _isReplaceRowExpanded = false;
  int? _lastAppliedActiveMatchIndex;
  late int _lastBaselineRevision;

  /// The last value the buffer accepted or that was synced from it.
  late TextEditingValue _lastAcceptedValue;

  /// The text scaler of the main field, which the overlay shares.
  TextScaler _textScaler = TextScaler.noScaling;

  /// The measured height of one row of the main field.
  double _lineHeight = mpTextEditorFontSize * mpTextEditorLineHeight;

  TextScaler? _measuredTextScaler;

  THTextEditorBuffer get _buffer => widget.controller;

  THTextEditorFindController get _find => widget.controller.find;

  bool get _isTH2 => _buffer.language == THTextEditorLanguage.th2;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: _buffer.content);
    _lastAcceptedValue = _textEditingController.value;
    _textEditingController.addListener(_onTextEditingChanged);
    _textScrollController = ScrollController(
      initialScrollOffset: _buffer.lastScrollOffset,
    );
    _textScrollController.addListener(_onTextScrolled);
    _gutterScrollController = ScrollController();
    _overlayScrollController = ScrollController();
    _findEditingController = TextEditingController(text: _find.findQuery);
    _findEditingController.addListener(_onFindEditingChanged);
    _replaceEditingController = TextEditingController(
      text: _find.replaceQuery,
    );
    _replaceEditingController.addListener(_onReplaceEditingChanged);
    _findFieldFocusNode = FocusNode();
    _undoHistoryController = UndoHistoryController();
    _lastBaselineRevision = _buffer.baselineRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncScrollFollowers();
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onTextEditingChanged);
    _textEditingController.dispose();
    _textScrollController.removeListener(_onTextScrolled);
    _textScrollController.dispose();
    _gutterScrollController.dispose();
    _overlayScrollController.dispose();
    _findEditingController.removeListener(_onFindEditingChanged);
    _findEditingController.dispose();
    _replaceEditingController.removeListener(_onReplaceEditingChanged);
    _replaceEditingController.dispose();
    _findFieldFocusNode.dispose();
    _undoHistoryController.dispose();
    super.dispose();
  }

  void _onFindEditingChanged() {
    if (_isSyncingFindFromController) {
      return;
    }

    _find.setFindQuery(_findEditingController.text);
  }

  void _onReplaceEditingChanged() {
    if (_isSyncingReplaceFromController) {
      return;
    }

    _find.setReplaceQuery(_replaceEditingController.text);
  }

  /// Puts [value] into the field without reporting it as an edit.
  void _setFieldValueSilently(TextEditingValue value) {
    _isSyncingFromController = true;
    _textEditingController.value = value;
    _isSyncingFromController = false;
  }

  void _onTextEditingChanged() {
    if (_isSyncingFromController) {
      return;
    }

    TextEditingValue value = _textEditingController.value;
    final String previousText = _buffer.content;

    /// Project editors infer Enter from a single inserted LF. TH2 editors
    /// handle Enter with an action instead, so a pasted LF keeps its own
    /// ending and gets no indentation.
    if (!_isTH2 &&
        value.selection.isCollapsed &&
        value.text.length == previousText.length + 1 &&
        value.selection.baseOffset > 0 &&
        value.text[value.selection.baseOffset - 1] == '\n') {
      final String? autoIndent = _computeAutoIndent(
        value.text,
        value.selection.baseOffset,
      );

      if (autoIndent != null && autoIndent.isNotEmpty) {
        final int insertOffset = value.selection.baseOffset;
        final String newText =
            value.text.substring(0, insertOffset) +
            autoIndent +
            value.text.substring(insertOffset);

        value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: insertOffset + autoIndent.length,
          ),
        );
        _setFieldValueSilently(value);
      }
    }

    if (value.text != _buffer.content) {
      final bool isAccepted = _buffer.setContent(
        value.text,
        cursorOffset: value.selection.isValid
            ? value.selection.extentOffset
            : null,
      );

      /// The field already holds the refused value: put the last accepted
      /// one back, so the field and the buffer stay equal.
      if (!isAccepted) {
        _setFieldValueSilently(_lastAcceptedValue);

        return;
      }
    }

    _lastAcceptedValue = value;

    if (value.selection.isValid) {
      final _LineColumn position = _lineColumnAt(
        value.text,
        value.selection.baseOffset,
      );

      _buffer.setCursorPosition(line: position.line, column: position.column);
    }
  }

  /// The indentation for a new line inserted at [newlineOffset] - 1, from
  /// the text before it on its line.
  String? _computeAutoIndent(String text, int newlineOffset) {
    final int newlineIndex = newlineOffset - 1;
    final int previousLineStart =
        text.lastIndexOf('\n', newlineIndex - 1) + 1;

    if (previousLineStart > newlineIndex) {
      return null;
    }

    return _indentAfter(text.substring(previousLineStart, newlineIndex));
  }

  /// The indentation of a line following [previousLine]: its own, one level
  /// more after a block opener.
  String? _indentAfter(String previousLine) {
    String indent =
        _thTextEditorLeadingWhitespaceRegExp.firstMatch(previousLine)?.group(0) ??
        '';
    final RegExpMatch? wordMatch =
        (_isTH2
                ? _thTextEditorFirstWhitespaceDelimitedWordRegExp
                : _thTextEditorFirstWordRegExp)
            .firstMatch(previousLine.trim().toLowerCase());

    if (wordMatch != null &&
        thTextEditorBlockOpeners(_buffer.language).contains(wordMatch.group(1))) {
      indent += mpIndentation;
    }

    return indent.isEmpty ? null : indent;
  }

  bool _isComposing() {
    final TextRange composing = _textEditingController.value.composing;

    return composing.isValid && !composing.isCollapsed;
  }

  /// TH2 Enter: replaces the selection with the file's line ending and the
  /// auto-indent, in one value update.
  void _handleEnter() {
    if (_buffer.isReadOnly) {
      return;
    }

    final TextEditingValue value = _textEditingController.value;
    final TextSelection selection = value.selection;

    if (!selection.isValid) {
      return;
    }

    final String text = value.text;
    final int start = _outsideLineEnding(text, selection.start);
    final int end = _outsideLineEnding(text, selection.end);
    final int lineStart = text.lastIndexOf('\n', start - 1) + 1;
    String precedingText = text.substring(lineStart, start);

    if (precedingText.endsWith(mpCarriageReturn)) {
      precedingText = precedingText.substring(0, precedingText.length - 1);
    }

    final String insertion = _buffer.lineEnding + (_indentAfter(precedingText) ?? '');

    _textEditingController.value = TextEditingValue(
      text: text.replaceRange(start, end, insertion),
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
  }

  /// [offset], moved before the CR when it is between a CR and its LF.
  static int _outsideLineEnding(String text, int offset) {
    if ((offset > 0) &&
        (offset < text.length) &&
        (text.codeUnitAt(offset - 1) == mpCarriageReturnByte) &&
        (text.codeUnitAt(offset) == mpLineFeedByte)) {
      return offset - 1;
    }

    return offset;
  }

  /// TH2 undo/redo: text history after the first text edit, canvas history
  /// before it. Always consumes the key.
  void _handleHistory({required bool redo}) {
    if (_buffer.isReadOnly) {
      return;
    }

    if (_buffer.hasTextEdits) {
      if (redo) {
        _undoHistoryController.redo();
      } else {
        _undoHistoryController.undo();
      }

      return;
    }

    unawaited(_requestCanvasHistory(redo: redo));
  }

  Future<void> _requestCanvasHistory({required bool redo}) async {
    try {
      await _buffer.requestCanvasHistory(redo: redo);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THTextEditorWidget] canvas history request failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.tab) {
      _handleTabKey(outdent: HardwareKeyboard.instance.isShiftPressed);

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape &&
        _find.isFindBarVisible) {
      _find.closeFindBar();

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleOpenFindBar() {
    _find.openFindBar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findFieldFocusNode.requestFocus();
    });
  }

  void _handleTabKey({required bool outdent}) {
    if (_buffer.isReadOnly) {
      return;
    }

    final TextEditingValue value = _textEditingController.value;
    final String text = value.text;
    final TextSelection selection = value.selection;
    final int lineStart =
        text.lastIndexOf('\n', (selection.start - 1).clamp(0, text.length)) +
        1;
    int lineEnd = text.indexOf('\n', selection.end);

    if (lineEnd == -1) {
      lineEnd = text.length;
    }

    final String before = text.substring(0, lineStart);
    final String segment = text.substring(lineStart, lineEnd);
    final String after = text.substring(lineEnd);
    final List<String> lines = segment.split('\n');
    final List<String> newLines = <String>[];
    int firstLineDelta = 0;
    int totalDelta = 0;

    for (int index = 0; index < lines.length; index++) {
      String line = lines[index];

      if (outdent) {
        int removeCount = 0;

        while (removeCount < 2 &&
            removeCount < line.length &&
            line[removeCount] == ' ') {
          removeCount++;
        }

        line = line.substring(removeCount);

        if (index == 0) {
          firstLineDelta = -removeCount;
        }

        totalDelta -= removeCount;
      } else {
        line = '  $line';

        if (index == 0) {
          firstLineDelta = 2;
        }

        totalDelta += 2;
      }

      newLines.add(line);
    }

    final String newText = before + newLines.join('\n') + after;
    final int newSelectionStart = (selection.start + firstLineDelta).clamp(
      0,
      newText.length,
    );
    final int newSelectionEnd = (selection.end + totalDelta).clamp(
      0,
      newText.length,
    );

    _textEditingController.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: newSelectionStart,
        extentOffset: newSelectionEnd,
      ),
    );
  }

  void _onTextScrolled() {
    if (_textScrollController.positions.length != 1) {
      return;
    }

    _buffer.lastScrollOffset = _textScrollController.offset;
    _syncScrollFollowers();
  }

  /// Moves the gutter, the syntax overlay and the diagnostic markers to the
  /// main field's scroll offset.
  void _syncScrollFollowers() {
    if (_textScrollController.positions.length != 1) {
      return;
    }

    final double offset = _textScrollController.offset;

    for (final ScrollController follower in <ScrollController>[
      _gutterScrollController,
      _overlayScrollController,
    ]) {
      if (follower.hasClients) {
        follower.jumpTo(
          offset.clamp(
            follower.position.minScrollExtent,
            follower.position.maxScrollExtent,
          ),
        );
      }
    }
  }

  Future<void> _handleSaveIntent() async {
    try {
      await _buffer.save();
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THTextEditorWidget] save failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _handleRevert() async {
    try {
      await _buffer.revert();
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[THTextEditorWidget] revert failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _jumpToLine(int line) {
    if (!_textScrollController.hasClients) {
      return;
    }

    _textScrollController.jumpTo(
      (line * _lineHeight).clamp(
        _textScrollController.position.minScrollExtent,
        _textScrollController.position.maxScrollExtent,
      ),
    );
  }

  /// Moves the text field's selection to the start of [lineNumber] (0-based)
  /// and scrolls it into view, mirroring [_applyActiveMatch]'s line-height
  /// math.
  void _applyPendingScrollToLine(int lineNumber) {
    final String content = _buffer.content;
    final List<String> lines = content.split('\n');

    if (lineNumber < 0 || lineNumber >= lines.length) {
      return;
    }

    int offset = 0;

    for (int index = 0; index < lineNumber; index++) {
      offset += lines[index].length + 1;
    }

    _textEditingController.selection = TextSelection.collapsed(offset: offset);
    _jumpToLine(lineNumber);
  }

  /// Applies a pending exact selection: clamps the range, selects it,
  /// scrolls it into view, and requests typing focus when the buffer asks
  /// for it. Mirrors [_applyActiveMatch]'s line-height math.
  void _applyPendingSelectionRange(TextRange range, {required bool focus}) {
    final String content = _buffer.content;
    final int start = range.start.clamp(0, content.length);
    final int end = range.end.clamp(start, content.length);

    _textEditingController.selection = TextSelection(
      baseOffset: start,
      extentOffset: end,
    );
    _jumpToLine(_lineColumnAt(content, start).line);

    if (focus) {
      _buffer.textFieldFocusNode.requestFocus();
    }
  }

  /// Moves the text field's selection to [activeMatchIndex]'s range in
  /// [matches] and scrolls it into view. Selection-only (no text change),
  /// so the existing text-change listener only updates the reported cursor
  /// position, which is the desired side effect here too.
  void _applyActiveMatch(List<TextRange> matches, int? activeMatchIndex) {
    if (activeMatchIndex == null ||
        activeMatchIndex < 0 ||
        activeMatchIndex >= matches.length) {
      return;
    }

    final TextRange match = matches[activeMatchIndex];

    _textEditingController.selection = TextSelection(
      baseOffset: match.start,
      extentOffset: match.end,
    );
    _jumpToLine(_lineColumnAt(_buffer.content, match.start).line);
  }

  /// Applies pending navigation. Exact selection takes precedence over
  /// line-only navigation; it has already positioned the viewport, so a
  /// coincident line-only request is discarded. With [mayFocus] false, the
  /// selection never requests focus. Returns whether anything was applied.
  bool _applyPendingNavigation({bool mayFocus = true}) {
    final TextRange? pendingSelectionRange = _buffer.pendingSelectionRange;
    final int? pendingScrollToLine = _buffer.pendingScrollToLine;

    if (pendingSelectionRange != null) {
      _applyPendingSelectionRange(
        pendingSelectionRange,
        focus: mayFocus && _buffer.pendingSelectionRequestsFocus,
      );

      return true;
    } else if (pendingScrollToLine != null) {
      _applyPendingScrollToLine(pendingScrollToLine);

      return true;
    }

    return false;
  }

  void _clearPendingNavigation({required bool hadSelection}) {
    if (hadSelection) {
      _buffer.clearPendingSelectionRange();
    }
    _buffer.clearPendingScrollToLine();
  }

  /// Handles a new baseline: the main field remounts with a fresh native
  /// history in this build, so nothing touches its scroll controller until
  /// the post-frame callback, when only the new field is attached.
  void _onBaselineChanged() {
    final double recordedOffset =
        (_textScrollController.positions.length == 1)
        ? _textScrollController.offset
        : _buffer.lastScrollOffset;
    final bool hadFocus = _buffer.textFieldFocusNode.hasFocus;
    final UndoHistoryController previousUndoHistoryController =
        _undoHistoryController;

    _undoHistoryController = UndoHistoryController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      previousUndoHistoryController.dispose();

      if (!mounted) {
        return;
      }

      final bool hasPendingSelection = _buffer.pendingSelectionRange != null;
      final bool shouldFocus = hasPendingSelection
          ? _buffer.pendingSelectionRequestsFocus
          : hadFocus;
      final bool isNavigationApplied = _applyPendingNavigation(
        mayFocus: false,
      );

      if (isNavigationApplied) {
        _clearPendingNavigation(hadSelection: hasPendingSelection);
      } else if (_textScrollController.hasClients) {
        _textScrollController.jumpTo(
          recordedOffset.clamp(
            _textScrollController.position.minScrollExtent,
            _textScrollController.position.maxScrollExtent,
          ),
        );
      }

      _syncScrollFollowers();

      if (shouldFocus) {
        _refocusRemountedField();
      }
    });
  }

  /// The outgoing field's focus node detach unfocuses it, but that change
  /// is applied in a microtask: a focus request made now would coalesce with
  /// it, the new field would see no focus change and would never open its
  /// text input connection. So the focus is requested after the unfocus is
  /// applied.
  void _refocusRemountedField() {
    final FocusNode focusNode = _buffer.textFieldFocusNode;

    focusNode.unfocus();
    scheduleMicrotask(() {
      if (mounted) {
        focusNode.requestFocus();
      }
    });
  }

  /// Measures one row of the main field with [textScaler], once per scaler.
  void _updateLineHeight(TextScaler textScaler) {
    if (textScaler == _measuredTextScaler) {
      return;
    }

    final TextPainter painter = TextPainter(
      text: const TextSpan(text: ' ', style: _thTextEditorTextStyle),
      strutStyle: _thTextEditorStrutStyle,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();

    _lineHeight = painter.preferredLineHeight;
    _textScaler = textScaler;
    _measuredTextScaler = textScaler;
    painter.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    _updateLineHeight(MediaQuery.textScalerOf(context));

    return Observer(
      builder: (_) {
        final String content = _buffer.content;
        final int baselineRevision = _buffer.baselineRevision;
        final bool isBaselineChanged = baselineRevision != _lastBaselineRevision;

        if (isBaselineChanged) {
          _lastBaselineRevision = baselineRevision;
          _onBaselineChanged();
        }

        if (_textEditingController.text != content) {
          final TextSelection previousSelection =
              _textEditingController.selection;

          _setFieldValueSilently(
            TextEditingValue(
              text: content,
              selection: previousSelection.end <= content.length
                  ? previousSelection
                  : TextSelection.collapsed(offset: content.length),
            ),
          );
          _lastAcceptedValue = _textEditingController.value;
        }

        if (_findEditingController.text != _find.findQuery) {
          _isSyncingFindFromController = true;
          _findEditingController.text = _find.findQuery;
          _findEditingController.selection = TextSelection.collapsed(
            offset: _findEditingController.text.length,
          );
          _isSyncingFindFromController = false;
        }

        if (_replaceEditingController.text != _find.replaceQuery) {
          _isSyncingReplaceFromController = true;
          _replaceEditingController.text = _find.replaceQuery;
          _replaceEditingController.selection = TextSelection.collapsed(
            offset: _replaceEditingController.text.length,
          );
          _isSyncingReplaceFromController = false;
        }

        final List<THTextEditorToken> tokens = _buffer.tokens;
        final List<THTextEditorDiagnostic> diagnostics = _buffer.diagnostics;
        final List<THTextEditorDiagnostic> linelessDiagnostics =
            thTextEditorLinelessDiagnostics(diagnostics);
        final int lineCount = '\n'.allMatches(content).length + 1;
        final bool isFindBarVisible = _find.isFindBarVisible;
        final List<TextRange> findMatches = isFindBarVisible
            ? _find.findMatches
            : const <TextRange>[];
        final int? activeMatchIndex = _find.activeMatchIndex;
        final bool isReadOnly = _buffer.isReadOnly;

        /// The main field remounts in this build: pending navigation and
        /// active-match scrolling wait for the post-frame callback.
        if (!isBaselineChanged) {
          if (isFindBarVisible &&
              activeMatchIndex != _lastAppliedActiveMatchIndex) {
            _lastAppliedActiveMatchIndex = activeMatchIndex;
            _applyActiveMatch(findMatches, activeMatchIndex);
          }

          final bool hasPendingSelection = _buffer.pendingSelectionRange != null;

          if (_applyPendingNavigation()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _clearPendingNavigation(hadSelection: hasPendingSelection);
            });
          }
        }

        Widget mainEditor = Focus(
          focusNode: _buffer.textEditorFocusNode,
          onKeyEvent: _handleKeyEvent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              THTextEditorLineNumberGutterWidget(
                lineCount: lineCount,
                currentLine: _buffer.cursorLine,
                diagnosticLines: thTextEditorDiagnosticLines(diagnostics),
                scrollController: _gutterScrollController,
                lineHeight: _lineHeight,
              ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: IgnorePointer(
                        child: SingleChildScrollView(
                          key: const ValueKey(
                            'THTextEditorWidget|SyntaxOverlay',
                          ),
                          controller: _overlayScrollController,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Stack(
                            children: <Widget>[
                              ..._buildDiagnosticMarkers(diagnostics),
                              _buildSyntaxOverlay(
                                content,
                                tokens,
                                findMatches,
                                activeMatchIndex,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    KeyedSubtree(
                      key: ValueKey<int>(baselineRevision),
                      child: _buildMainTextField(
                        context,
                        appLocalizations,
                        isReadOnly,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (_isTH2) {
          mainEditor = _wrapWithTH2Shortcuts(mainEditor);
        }

        return Shortcuts(
          shortcuts: <ShortcutActivator, Intent>{
            const SingleActivator(LogicalKeyboardKey.keyS, control: true):
                const _THTextEditorSaveIntent(),
            const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
                const _THTextEditorSaveIntent(),
            const SingleActivator(LogicalKeyboardKey.keyF, control: true):
                const _THTextEditorFindIntent(),
            const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
                const _THTextEditorFindIntent(),
            // Flutter binds undo/redo to Ctrl on Linux/Windows and to Cmd on
            // macOS only; Mapiah accepts both everywhere, as on the canvas.
            const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
                const UndoTextIntent(SelectionChangedCause.keyboard),
            const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
                const UndoTextIntent(SelectionChangedCause.keyboard),
            const SingleActivator(
              LogicalKeyboardKey.keyZ,
              control: true,
              shift: true,
            ): const RedoTextIntent(
              SelectionChangedCause.keyboard,
            ),
            const SingleActivator(
              LogicalKeyboardKey.keyZ,
              meta: true,
              shift: true,
            ): const RedoTextIntent(
              SelectionChangedCause.keyboard,
            ),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              _THTextEditorSaveIntent: CallbackAction<_THTextEditorSaveIntent>(
                onInvoke: (_) {
                  _handleSaveIntent();

                  return null;
                },
              ),
              _THTextEditorFindIntent: CallbackAction<_THTextEditorFindIntent>(
                onInvoke: (_) {
                  _handleOpenFindBar();

                  return null;
                },
              ),
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildToolbar(context, appLocalizations),
                if (linelessDiagnostics.isNotEmpty)
                  THTextEditorLinelessDiagnosticsWidget(
                    diagnostics: linelessDiagnostics,
                  ),
                if (isFindBarVisible)
                  _buildFindBar(
                    context,
                    appLocalizations,
                    findMatches,
                    isReadOnly,
                  ),
                Expanded(child: mainEditor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainTextField(
    BuildContext context,
    AppLocalizations appLocalizations,
    bool isReadOnly,
  ) {
    final Widget textField = TextField(
      key: const ValueKey('THTextEditorWidget|TextField'),
      controller: _textEditingController,
      focusNode: _buffer.textFieldFocusNode,
      undoController: _undoHistoryController,
      scrollController: _textScrollController,
      readOnly: isReadOnly,
      strutStyle: _thTextEditorStrutStyle,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration.collapsed(
        hintText: appLocalizations.textEditorEmptyHint,
      ),
      style: _thTextEditorTextStyle.copyWith(color: Colors.transparent),
      cursorColor: Theme.of(context).colorScheme.primary,
    );

    if (!_isTH2) {
      return textField;
    }

    /// Standard undo/redo intents dispatched in the main field go through
    /// the TH2 history handler too.
    return Actions(
      actions: <Type, Action<Intent>>{
        UndoTextIntent: CallbackAction<UndoTextIntent>(
          onInvoke: (_) {
            _handleHistory(redo: false);

            return null;
          },
        ),
        RedoTextIntent: CallbackAction<RedoTextIntent>(
          onInvoke: (_) {
            _handleHistory(redo: true);

            return null;
          },
        ),
      },
      child: textField,
    );
  }

  /// The TH2 shortcuts of the main editor (gutter and field): Enter and
  /// undo/redo. Find and replace fields are outside them.
  Widget _wrapWithTH2Shortcuts(Widget child) {
    const List<LogicalKeyboardKey> enterKeys = <LogicalKeyboardKey>[
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.numpadEnter,
    ];

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        for (final LogicalKeyboardKey key in enterKeys) ...<
          ShortcutActivator,
          Intent
        >{
          SingleActivator(key): const _THTextEditorEnterIntent(),
          SingleActivator(key, shift: true): const _THTextEditorEnterIntent(),
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            const _THTextEditorUndoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
            const _THTextEditorUndoIntent(),
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ): const _THTextEditorRedoIntent(),
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          meta: true,
          shift: true,
        ): const _THTextEditorRedoIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _THTextEditorEnterIntent: _THTextEditorEnterAction(
            isEnabledCallback: () => !_isComposing(),
            onInvoke: _handleEnter,
          ),
          _THTextEditorUndoIntent: CallbackAction<_THTextEditorUndoIntent>(
            onInvoke: (_) {
              _handleHistory(redo: false);

              return null;
            },
          ),
          _THTextEditorRedoIntent: CallbackAction<_THTextEditorRedoIntent>(
            onInvoke: (_) {
              _handleHistory(redo: true);

              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isRevertEnabled = _buffer.isDirty && !_buffer.isReadOnly;

    return Row(
      children: <Widget>[
        ...widget.leadingToolbarActions,
        IconButton(
          key: const ValueKey('THTextEditorWidget|SaveButton'),
          icon: const Icon(Icons.save),
          tooltip: appLocalizations.textEditorSaveTooltip,
          onPressed: _buffer.canSave ? _handleSaveIntent : null,
        ),
        IconButton(
          key: const ValueKey('THTextEditorWidget|RevertButton'),
          icon: const Icon(Icons.undo),
          tooltip:
              _buffer.revertTooltip ?? appLocalizations.textEditorRevertTooltip,
          onPressed: isRevertEnabled ? _handleRevert : null,
        ),
        IconButton(
          key: const ValueKey('THTextEditorWidget|FindButton'),
          icon: const Icon(Icons.search),
          tooltip: appLocalizations.textEditorFindTooltip,
          onPressed: _handleOpenFindBar,
        ),
        if (_buffer.isDirty)
          Container(
            width: mpTextEditorDiagnosticMarkerSize,
            height: mpTextEditorDiagnosticMarkerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.tertiary,
            ),
          ),
      ],
    );
  }

  Widget _buildFindBar(
    BuildContext context,
    AppLocalizations appLocalizations,
    List<TextRange> findMatches,
    bool isReadOnly,
  ) {
    final int? activeMatchIndex = _find.activeMatchIndex;
    final int matchCount = findMatches.length;
    final int matchPosition = (activeMatchIndex ?? -1) + 1;

    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                key: const ValueKey(
                  'THTextEditorWidget|FindToggleReplaceButton',
                ),
                icon: Icon(
                  _isReplaceRowExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                ),
                tooltip: appLocalizations.textEditorFindToggleReplaceTooltip,
                onPressed: () {
                  setState(() {
                    _isReplaceRowExpanded = !_isReplaceRowExpanded;
                  });
                },
              ),
              Expanded(
                child: TextField(
                  key: const ValueKey('THTextEditorWidget|FindField'),
                  controller: _findEditingController,
                  focusNode: _findFieldFocusNode,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: appLocalizations.textEditorFindHint,
                  ),
                  onSubmitted: (_) => _find.findNext(),
                ),
              ),
              Text(
                key: const ValueKey('THTextEditorWidget|FindMatchCountLabel'),
                appLocalizations.textEditorFindMatchCount(
                  matchPosition,
                  matchCount,
                ),
              ),
              IconButton(
                key: const ValueKey(
                  'THTextEditorWidget|FindCaseSensitiveToggle',
                ),
                icon: Icon(
                  Icons.text_fields,
                  color: _find.findCaseSensitive
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                tooltip: appLocalizations.textEditorFindCaseSensitiveTooltip,
                onPressed: () {
                  _find.setFindCaseSensitive(!_find.findCaseSensitive);
                },
              ),
              IconButton(
                key: const ValueKey('THTextEditorWidget|FindPreviousButton'),
                icon: const Icon(Icons.keyboard_arrow_up),
                tooltip: appLocalizations.textEditorFindPreviousTooltip,
                onPressed: _find.findPrevious,
              ),
              IconButton(
                key: const ValueKey('THTextEditorWidget|FindNextButton'),
                icon: const Icon(Icons.keyboard_arrow_down),
                tooltip: appLocalizations.textEditorFindNextTooltip,
                onPressed: _find.findNext,
              ),
              IconButton(
                key: const ValueKey('THTextEditorWidget|FindCloseButton'),
                icon: const Icon(Icons.close),
                tooltip: appLocalizations.textEditorFindCloseTooltip,
                onPressed: _find.closeFindBar,
              ),
            ],
          ),
          if (_isReplaceRowExpanded)
            Row(
              children: <Widget>[
                const SizedBox(width: mpTextEditorFoldToggleSize * 2),
                Expanded(
                  child: TextField(
                    key: const ValueKey('THTextEditorWidget|ReplaceField'),
                    controller: _replaceEditingController,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: appLocalizations.textEditorReplaceHint,
                    ),
                  ),
                ),
                TextButton(
                  key: const ValueKey('THTextEditorWidget|ReplaceButton'),
                  onPressed: isReadOnly ? null : _find.replaceActiveMatch,
                  child: Text(appLocalizations.textEditorReplaceButton),
                ),
                TextButton(
                  key: const ValueKey('THTextEditorWidget|ReplaceAllButton'),
                  onPressed: isReadOnly ? null : _find.replaceAllMatches,
                  child: Text(appLocalizations.textEditorReplaceAllButton),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// One marker per diagnostic line, with all of that line's diagnostics.
  List<Widget> _buildDiagnosticMarkers(
    List<THTextEditorDiagnostic> diagnostics,
  ) {
    return <Widget>[
      for (final THTextEditorDiagnosticGroup group
          in thTextEditorDiagnosticGroupsByLine(diagnostics))
        Positioned(
          top: group.line! * _lineHeight,
          left: 0,
          right: 0,
          child: THTextEditorDiagnosticMarkerWidget(
            diagnostics: group.diagnostics,
            height: _lineHeight,
          ),
        ),
    ];
  }

  Widget _buildSyntaxOverlay(
    String content,
    List<THTextEditorToken> tokens,
    List<TextRange> findMatches,
    int? activeMatchIndex,
  ) {
    return RichText(
      strutStyle: _thTextEditorStrutStyle,
      textScaler: _textScaler,
      text: TextSpan(
        style: _thTextEditorTextStyle.copyWith(color: Colors.black),
        children: buildTHTextEditorOverlaySpans(
          content: content,
          tokens: tokens,
          tokenColors: _thTextEditorTokenColors,
          findMatches: findMatches,
          activeMatchIndex: activeMatchIndex,
          findMatchColor: _thTextEditorFindMatchColor,
          activeFindMatchColor: _thTextEditorActiveFindMatchColor,
        ),
      ),
    );
  }

  _LineColumn _lineColumnAt(String text, int offset) {
    int line = 0;
    int lineStart = 0;

    for (int index = 0; index < offset && index < text.length; index++) {
      if (text[index] == '\n') {
        line++;
        lineStart = index + 1;
      }
    }

    return _LineColumn(line: line, column: offset - lineStart);
  }
}

class _LineColumn {
  final int line;

  final int column;

  const _LineColumn({required this.line, required this.column});
}

class _THTextEditorSaveIntent extends Intent {
  const _THTextEditorSaveIntent();
}

class _THTextEditorFindIntent extends Intent {
  const _THTextEditorFindIntent();
}

class _THTextEditorEnterIntent extends Intent {
  const _THTextEditorEnterIntent();
}

class _THTextEditorUndoIntent extends Intent {
  const _THTextEditorUndoIntent();
}

class _THTextEditorRedoIntent extends Intent {
  const _THTextEditorRedoIntent();
}

/// Disabled while an IME composition is active, so `Shortcuts` leaves the
/// key to the input method instead of inserting a line.
class _THTextEditorEnterAction extends Action<_THTextEditorEnterIntent> {
  final bool Function() isEnabledCallback;

  final void Function() onInvoke;

  _THTextEditorEnterAction({
    required this.isEnabledCallback,
    required this.onInvoke,
  });

  @override
  bool isEnabled(_THTextEditorEnterIntent intent) => isEnabledCallback();

  @override
  Object? invoke(_THTextEditorEnterIntent intent) {
    onInvoke();

    return null;
  }
}
