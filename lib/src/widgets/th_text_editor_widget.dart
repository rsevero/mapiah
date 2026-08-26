// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_syntax_highlighter.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/th_text_editor_diagnostic_marker_widget.dart';
import 'package:mapiah/src/widgets/th_text_editor_line_number_gutter_widget.dart';
import 'package:material_ui/material_ui.dart';

const Set<String> _thTextEditorBlockOpeners = <String>{
  'survey',
  'centreline',
  'map',
  'scrap',
  'layout',
};

final RegExp _thTextEditorLeadingWhitespaceRegExp = RegExp(r'^[ \t]*');
final RegExp _thTextEditorFirstWordRegExp = RegExp(r'^([a-z]+)');

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
      THTextEditorTokenType.plain: Color(0xFF000000),
    };

/// Editor surface for one `thconfig`/`.th` file: a line-number gutter, an
/// editable text area with a lexical syntax-highlighting overlay, and
/// diagnostic markers for [THProjectParseError]s attached to the file.
///
/// Reads and writes go through [controller]; this widget owns only local
/// text-field wiring (scroll sync, cursor tracking, keyboard shortcuts).
class THTextEditorWidget extends StatefulWidget {
  final THTextEditorController controller;

  const THTextEditorWidget({super.key, required this.controller});

  @override
  State<THTextEditorWidget> createState() => _THTextEditorWidgetState();
}

class _THTextEditorWidgetState extends State<THTextEditorWidget> {
  late final TextEditingController _textEditingController;
  late final ScrollController _textScrollController;
  late final ScrollController _gutterScrollController;
  bool _isSyncingFromController = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(
      text: widget.controller.content,
    );
    _textEditingController.addListener(_onTextEditingChanged);
    _textScrollController = ScrollController();
    _textScrollController.addListener(_onTextScrolled);
    _gutterScrollController = ScrollController();
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onTextEditingChanged);
    _textEditingController.dispose();
    _textScrollController.removeListener(_onTextScrolled);
    _textScrollController.dispose();
    _gutterScrollController.dispose();
    super.dispose();
  }

  void _onTextEditingChanged() {
    if (_isSyncingFromController) {
      return;
    }

    TextEditingValue value = _textEditingController.value;
    final String previousText = widget.controller.content;

    if (value.selection.isCollapsed &&
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
        _isSyncingFromController = true;
        _textEditingController.value = value;
        _isSyncingFromController = false;
      }
    }

    if (value.text != widget.controller.content) {
      widget.controller.setContent(value.text);
    }

    if (value.selection.isValid) {
      final _LineColumn position = _lineColumnAt(
        value.text,
        value.selection.baseOffset,
      );

      widget.controller.setCursorPosition(
        line: position.line,
        column: position.column,
      );
    }
  }

  String? _computeAutoIndent(String text, int newlineOffset) {
    final int newlineIndex = newlineOffset - 1;
    final int previousLineStart =
        text.lastIndexOf('\n', newlineIndex - 1) + 1;

    if (previousLineStart > newlineIndex) {
      return null;
    }

    final String previousLine = text.substring(
      previousLineStart,
      newlineIndex,
    );
    String indent =
        _thTextEditorLeadingWhitespaceRegExp.firstMatch(previousLine)?.group(0) ??
        '';
    final RegExpMatch? wordMatch = _thTextEditorFirstWordRegExp.firstMatch(
      previousLine.trim().toLowerCase(),
    );

    if (wordMatch != null &&
        _thTextEditorBlockOpeners.contains(wordMatch.group(1))) {
      indent += '  ';
    }

    return indent.isEmpty ? null : indent;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.tab) {
      _handleTabKey(outdent: HardwareKeyboard.instance.isShiftPressed);

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleTabKey({required bool outdent}) {
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
    if (_gutterScrollController.hasClients) {
      _gutterScrollController.jumpTo(
        _textScrollController.offset.clamp(
          _gutterScrollController.position.minScrollExtent,
          _gutterScrollController.position.maxScrollExtent,
        ),
      );
    }
  }

  Future<void> _handleSaveIntent() async {
    await widget.controller.save();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Observer(
      builder: (_) {
        if (_textEditingController.text != widget.controller.content) {
          _isSyncingFromController = true;
          final TextSelection previousSelection =
              _textEditingController.selection;

          _textEditingController.text = widget.controller.content;
          _textEditingController.selection = previousSelection.end <=
                  widget.controller.content.length
              ? previousSelection
              : TextSelection.collapsed(
                  offset: widget.controller.content.length,
                );
          _isSyncingFromController = false;
        }

        final List<THTextEditorToken> tokens = tokenizeTherionText(
          widget.controller.content,
        );
        final List<THProjectParseError> diagnostics =
            widget.controller.diagnostics;
        final int lineCount =
            '\n'.allMatches(widget.controller.content).length + 1;

        return Shortcuts(
          shortcuts: <ShortcutActivator, Intent>{
            const SingleActivator(LogicalKeyboardKey.keyS, control: true):
                const _THTextEditorSaveIntent(),
            const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
                const _THTextEditorSaveIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              _THTextEditorSaveIntent: CallbackAction<_THTextEditorSaveIntent>(
                onInvoke: (_) {
                  _handleSaveIntent();

                  return null;
                },
              ),
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildToolbar(context, appLocalizations),
                Expanded(
                  child: Focus(
                    autofocus: true,
                    onKeyEvent: _handleKeyEvent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        THTextEditorLineNumberGutterWidget(
                          lineCount: lineCount,
                          currentLine: widget.controller.cursorLine,
                          diagnosticLines: thTextEditorDiagnosticLines(
                            diagnostics,
                          ),
                          scrollController: _gutterScrollController,
                        ),
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              _buildDiagnosticBackground(diagnostics),
                              IgnorePointer(
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: _buildSyntaxOverlay(tokens),
                                ),
                              ),
                              TextField(
                                key: const ValueKey(
                                  'THTextEditorWidget|TextField',
                                ),
                                controller: _textEditingController,
                                scrollController: _textScrollController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: appLocalizations.textEditorEmptyHint,
                                ),
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: mpTextEditorFontSize,
                                  height: mpTextEditorLineHeight,
                                  color: Colors.transparent,
                                ),
                                cursorColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        IconButton(
          key: const ValueKey('THTextEditorWidget|SaveButton'),
          icon: const Icon(Icons.save),
          tooltip: appLocalizations.textEditorSaveTooltip,
          onPressed: widget.controller.isDirty ? _handleSaveIntent : null,
        ),
        IconButton(
          key: const ValueKey('THTextEditorWidget|RevertButton'),
          icon: const Icon(Icons.undo),
          tooltip: appLocalizations.textEditorRevertTooltip,
          onPressed: widget.controller.isDirty
              ? widget.controller.revert
              : null,
        ),
        if (widget.controller.isDirty)
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

  Widget _buildDiagnosticBackground(List<THProjectParseError> diagnostics) {
    if (diagnostics.isEmpty) {
      return const SizedBox.shrink();
    }

    final double lineHeight = mpTextEditorFontSize * mpTextEditorLineHeight;
    final Map<int, THProjectParseError> byLine = <int, THProjectParseError>{};

    for (final THProjectParseError diagnostic in diagnostics) {
      byLine[diagnostic.lineNumber - 1] = diagnostic;
    }

    return Positioned.fill(
      child: Stack(
        children: byLine.entries
            .map(
              (MapEntry<int, THProjectParseError> entry) => Positioned(
                top: entry.key * lineHeight,
                left: 0,
                right: 0,
                child: THTextEditorDiagnosticMarkerWidget(
                  diagnostic: entry.value,
                  height: lineHeight,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSyntaxOverlay(List<THTextEditorToken> tokens) {
    final String content = widget.controller.content;
    final List<InlineSpan> spans = <InlineSpan>[];
    int cursor = 0;

    for (final THTextEditorToken token in tokens) {
      if (token.start > cursor) {
        spans.add(TextSpan(text: content.substring(cursor, token.start)));
      }

      spans.add(
        TextSpan(
          text: content.substring(token.start, token.end),
          style: TextStyle(
            color: _thTextEditorTokenColors[token.type],
          ),
        ),
      );
      cursor = token.end;
    }

    if (cursor < content.length) {
      spans.add(TextSpan(text: content.substring(cursor)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: mpTextEditorFontSize,
          height: mpTextEditorLineHeight,
          color: Colors.black,
        ),
        children: spans,
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
