// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th_text_editor_lexical_types.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

/// The tokens and fold regions of a TH2 text.
class TH2TextEditorLexResult {
  final List<THTextEditorToken> tokens;

  /// Sorted by start line.
  final List<THTextEditorFoldRegion> foldRegions;

  const TH2TextEditorLexResult({
    required this.tokens,
    required this.foldRegions,
  });
}

const String _th2BlockScrap = 'scrap';
const String _th2BlockLine = 'line';
const String _th2BlockArea = 'area';
const String _th2BlockComment = 'comment';
const String _th2EndComment = 'endcomment';
const String _th2Encoding = 'encoding';

/// Keywords that are commands as the whole first word of a logical line.
/// `encoding`, `comment` and `endcomment` have their own rules.
const Set<String> _th2StructureKeywords = <String>{
  _th2BlockScrap,
  'endscrap',
  'point',
  _th2BlockLine,
  'endline',
  _th2BlockArea,
  'endarea',
};

const Map<String, String> _th2BlockClosers = <String, String>{
  'endscrap': _th2BlockScrap,
  'endline': _th2BlockLine,
  'endarea': _th2BlockArea,
};

/// The grammar's `lineSegmentOptions`.
const Set<String> _th2LineOptionWords = <String>{
  'adjust',
  'altitude',
  'anchors',
  'border',
  'clip',
  'close',
  'context',
  'direction',
  'gradient',
  'head',
  'height',
  'id',
  'scale',
  'l-size',
  'size',
  'mark',
  'orientation',
  'orient',
  'outline',
  'place',
  'rebelays',
  'reverse',
  'smooth',
  'subtype',
  'text',
  'visibility',
};

/// The grammar's `areaCommandLikeOptions`.
const Set<String> _th2AreaOptionWords = <String>{
  'clip',
  'context',
  'id',
  'place',
  'visibility',
};

/// The grammar's `xtherionConfig` and `mapiahConfig`: a prefix, a keyword
/// read greedily, and at least one more non-whitespace character.
final RegExp _th2SettingRegExp = RegExp(
  '^[ \\t]*(?:${RegExp.escape(mpXTherionConfigID)}|'
  '${RegExp.escape(mpMapiahConfigID)})[ \\t]*'
  r'[A-Za-z0-9_/][A-Za-z0-9_/-]*(?![A-Za-z0-9_/-])[ \t]*\S',
  caseSensitive: false,
);

/// The grammar's `number()`.
final RegExp _th2NumberRegExp = RegExp(r'^[-+]?\d+(\.\d+)?$');

final RegExp _th2StationReferenceRegExp = RegExp(
  r'^[A-Za-z0-9_.]+@[A-Za-z0-9_.]+$',
);

final RegExp _th2DashOptionRegExp = RegExp(r'^-[A-Za-z]');

/// One physical line's part of a logical line.
class _TH2Segment {
  /// Offset of the part in the logical line.
  final int logicalStart;

  /// Offset of the part in the source text.
  final int sourceStart;
  final int length;

  /// Whether a trailing `\` continues the logical line after this part. The
  /// `\` is at `sourceStart + length`.
  final bool continues;

  const _TH2Segment({
    required this.logicalStart,
    required this.sourceStart,
    required this.length,
    required this.continues,
  });

  int get logicalEnd => logicalStart + length;
}

/// Tokenizes a TH2 text and computes its fold regions in one scan.
///
/// Physical lines are joined into logical lines as the TH2 parser and
/// Therion's `thinput::read_line` do: a trailing `\` (trailing whitespace
/// and a CR ignored) continues the line and is dropped, and the next line is
/// appended with no separator. Each logical line is then classified as the
/// parser reads it, and its tokens are mapped back to source offsets, split
/// at physical line ends. A token that continues across a `\` also covers
/// that `\`.
///
/// All lexical state is local to one call.
TH2TextEditorLexResult scanTH2EditorText(String text) {
  return _TH2TextEditorLexer(text).scan();
}

class _TH2TextEditorLexer {
  final String _text;
  final List<THTextEditorToken> _tokens = <THTextEditorToken>[];
  final List<THTextEditorFoldRegion> _foldRegions = <THTextEditorFoldRegion>[];

  /// Open blocks: name and start line.
  final List<(String, int)> _openBlocks = <(String, int)>[];

  bool _isInCommentBody = false;
  bool _hasSeenNonBlankLine = false;

  /// The tokens of the current logical line, in logical offsets.
  final List<(int, int, THTextEditorTokenType)> _lineTokens =
      <(int, int, THTextEditorTokenType)>[];

  _TH2TextEditorLexer(this._text);

  TH2TextEditorLexResult scan() {
    final int textLength = _text.length;
    int offset = 0;
    int physicalLine = 0;
    bool isDone = false;

    while (!isDone) {
      final int logicalStartLine = physicalLine;
      final StringBuffer logicalLine = StringBuffer();
      final List<_TH2Segment> segments = <_TH2Segment>[];
      int logicalLength = 0;

      while (true) {
        final int lineBreakIndex = _text.indexOf(mpUnixLineBreak, offset);
        final int lineEnd = (lineBreakIndex == -1) ? textLength : lineBreakIndex;
        final String physicalText = _text
            .substring(offset, lineEnd)
            .trimRight();
        final bool continues = physicalText.endsWith(r'\');
        final String part = continues
            ? physicalText.substring(0, physicalText.length - 1)
            : physicalText;

        segments.add(
          _TH2Segment(
            logicalStart: logicalLength,
            sourceStart: offset,
            length: part.length,
            continues: continues,
          ),
        );
        logicalLine.write(part);
        logicalLength += part.length;

        if (lineBreakIndex == -1) {
          isDone = true;

          break;
        }

        offset = lineBreakIndex + 1;
        physicalLine++;

        if (!continues) {
          break;
        }
      }

      _lineTokens.clear();
      _scanLogicalLine(logicalLine.toString(), logicalStartLine);
      _emitLineTokens(segments);
    }

    _foldRegions.sort(
      (THTextEditorFoldRegion a, THTextEditorFoldRegion b) =>
          a.startLine.compareTo(b.startLine),
    );

    return TH2TextEditorLexResult(
      tokens: _tokens,
      foldRegions: _foldRegions,
    );
  }

  void _scanLogicalLine(String line, int startLine) {
    final int length = line.length;
    int wordStart = 0;

    while ((wordStart < length) && _isWhitespace(line.codeUnitAt(wordStart))) {
      wordStart++;
    }

    if (wordStart == length) {
      return;
    }

    final bool isFirstNonBlankLine = !_hasSeenNonBlankLine;

    _hasSeenNonBlankLine = true;

    /// Comment body: the parser only looks for an `endcomment` prefix.
    if (_isInCommentBody) {
      if (_startsWithIgnoreCase(line, wordStart, _th2EndComment)) {
        final int keywordEnd = wordStart + _th2EndComment.length;

        _addToken(wordStart, keywordEnd, THTextEditorTokenType.keyword);
        _isInCommentBody = false;
        _closeBlock(_th2BlockComment, startLine);
        _scanWords(line, keywordEnd);
      } else {
        _addToken(wordStart, length, THTextEditorTokenType.comment);
      }

      return;
    }

    /// Settings exist only at file level.
    if (_openBlocks.isEmpty && _th2SettingRegExp.hasMatch(line)) {
      _addToken(wordStart, length, THTextEditorTokenType.setting);

      return;
    }

    int wordEnd = wordStart;

    while ((wordEnd < length) && !_isWhitespace(line.codeUnitAt(wordEnd))) {
      wordEnd++;
    }

    final String firstWord = line.substring(wordStart, wordEnd).toLowerCase();

    /// `comment` opens a block only when nothing but an inline comment
    /// follows it.
    if ((firstWord == _th2BlockComment) ||
        firstWord.startsWith('$_th2BlockComment$mpCommentChar')) {
      final int keywordEnd = wordStart + _th2BlockComment.length;
      final String rest = line.substring(keywordEnd).trimLeft();

      if (rest.isEmpty || rest.startsWith(mpCommentChar)) {
        _addToken(wordStart, keywordEnd, THTextEditorTokenType.keyword);
        _openBlocks.add((_th2BlockComment, startLine));
        _isInCommentBody = true;
        _scanWords(line, keywordEnd);

        return;
      }
    } else if ((firstWord == _th2EndComment) ||
        firstWord.startsWith('$_th2EndComment$mpCommentChar')) {
      final int keywordEnd = wordStart + _th2EndComment.length;

      _addToken(wordStart, keywordEnd, THTextEditorTokenType.keyword);
      _scanWords(line, keywordEnd);

      return;
    } else if (((firstWord == _th2Encoding) && isFirstNonBlankLine) ||
        _th2StructureKeywords.contains(firstWord)) {
      _addToken(wordStart, wordEnd, THTextEditorTokenType.keyword);
      _updateStructure(firstWord, startLine);
      _scanWords(line, wordEnd);

      return;
    } else {
      final String? currentBlock = _openBlocks.isEmpty
          ? null
          : _openBlocks.last.$1;
      final bool isOptionLine =
          ((currentBlock == _th2BlockLine) &&
              _th2LineOptionWords.contains(firstWord)) ||
          ((currentBlock == _th2BlockArea) &&
              _th2AreaOptionWords.contains(firstWord));

      if (isOptionLine) {
        _addToken(wordStart, wordEnd, THTextEditorTokenType.option);
        _scanWords(line, wordEnd);

        return;
      }
    }

    _scanWords(line, wordStart);
  }

  void _updateStructure(String keyword, int line) {
    switch (keyword) {
      case _th2BlockScrap:
      case _th2BlockLine:
      case _th2BlockArea:
        _openBlocks.add((keyword, line));
      default:
        final String? block = _th2BlockClosers[keyword];

        if (block != null) {
          _closeBlock(block, line);
        }
    }
  }

  /// Closes the innermost open [block] and every block opened inside it.
  void _closeBlock(String block, int endLine) {
    final int index = _openBlocks.lastIndexWhere(
      ((String, int) entry) => entry.$1 == block,
    );

    if (index == -1) {
      return;
    }

    _foldRegions.add(
      THTextEditorFoldRegion(
        startLine: _openBlocks[index].$2,
        endLine: endLine,
      ),
    );
    _openBlocks.removeRange(index, _openBlocks.length);
  }

  /// Tokenizes the words of [line] from [start], which is at a word start.
  void _scanWords(String line, int start) {
    final int length = line.length;
    int index = start;

    while (index < length) {
      final int char = line.codeUnitAt(index);

      if (_isWhitespace(char)) {
        index++;

        continue;
      }

      /// A `#` at a word start comments out the rest of the logical line.
      if (char == mpCommentCharCode) {
        _addToken(index, length, THTextEditorTokenType.comment);

        return;
      }

      final int valueEnd = (char == mpDoubleQuoteCharCode)
          ? _quotedValueEnd(line, index)
          : (char == mpOpenBracketCharCode)
          ? _bracketValueEnd(line, index)
          : -1;
      int wordEnd = (valueEnd == -1) ? index : valueEnd;

      while ((wordEnd < length) && !_isWhitespace(line.codeUnitAt(wordEnd))) {
        wordEnd++;
      }

      if (valueEnd == -1) {
        _addToken(
          index,
          wordEnd,
          _classifyWord(line.substring(index, wordEnd)),
        );
      } else {
        _addToken(index, valueEnd, THTextEditorTokenType.string);
        _addToken(valueEnd, wordEnd, THTextEditorTokenType.plain);
      }

      index = wordEnd;
    }
  }

  static THTextEditorTokenType _classifyWord(String word) {
    if (_th2DashOptionRegExp.hasMatch(word)) {
      return THTextEditorTokenType.option;
    }
    if (_th2NumberRegExp.hasMatch(word)) {
      return THTextEditorTokenType.number;
    }
    if (_th2StationReferenceRegExp.hasMatch(word)) {
      return THTextEditorTokenType.stationReference;
    }

    return THTextEditorTokenType.plain;
  }

  /// The end of a `"…"` value starting at [start]; `""` escapes a quote. An
  /// open value ends at the end of the logical line.
  static int _quotedValueEnd(String line, int start) {
    final int length = line.length;
    int index = start + 1;

    while (index < length) {
      if (line.codeUnitAt(index) == mpDoubleQuoteCharCode) {
        if (((index + 1) < length) &&
            (line.codeUnitAt(index + 1) == mpDoubleQuoteCharCode)) {
          index += 2;

          continue;
        }

        return index + 1;
      }

      index++;
    }

    return length;
  }

  /// The end of a `[…]` value starting at [start]; brackets nest. An open
  /// value ends at the end of the logical line.
  static int _bracketValueEnd(String line, int start) {
    final int length = line.length;
    int depth = 0;

    for (int index = start; index < length; index++) {
      final int char = line.codeUnitAt(index);

      if (char == mpOpenBracketCharCode) {
        depth++;
      } else if (char == mpCloseBracketCharCode) {
        depth--;

        if (depth == 0) {
          return index + 1;
        }
      }
    }

    return length;
  }

  void _addToken(int start, int end, THTextEditorTokenType type) {
    if (end > start) {
      _lineTokens.add((start, end, type));
    }
  }

  /// Maps the current logical line's tokens to source offsets, one token per
  /// physical line part.
  void _emitLineTokens(List<_TH2Segment> segments) {
    final int segmentCount = segments.length;
    int firstSegment = 0;

    for (final (int start, int end, THTextEditorTokenType type)
        in _lineTokens) {
      while ((firstSegment < (segmentCount - 1)) &&
          (segments[firstSegment].logicalEnd <= start)) {
        firstSegment++;
      }

      for (int index = firstSegment; index < segmentCount; index++) {
        final _TH2Segment segment = segments[index];

        if (segment.logicalStart >= end) {
          break;
        }

        final int partStart = (start > segment.logicalStart)
            ? start
            : segment.logicalStart;
        final int partEnd = (end < segment.logicalEnd)
            ? end
            : segment.logicalEnd;
        final bool crossesContinuation =
            segment.continues &&
            (start < segment.logicalEnd) &&
            (end > segment.logicalEnd);
        final int sourceStart =
            segment.sourceStart + (partStart - segment.logicalStart);
        final int sourceEnd = crossesContinuation
            ? segment.sourceStart + segment.length + 1
            : segment.sourceStart + (partEnd - segment.logicalStart);

        if (sourceEnd > sourceStart) {
          _tokens.add(
            THTextEditorToken(start: sourceStart, end: sourceEnd, type: type),
          );
        }
      }
    }
  }

  static bool _isWhitespace(int char) =>
      (char == mpSpaceByte) || (char == mpTabByte);

  static bool _startsWithIgnoreCase(String line, int start, String prefix) {
    final int end = start + prefix.length;

    return (end <= line.length) &&
        (line.substring(start, end).toLowerCase() == prefix);
  }
}
