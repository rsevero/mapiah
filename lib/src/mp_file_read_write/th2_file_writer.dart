// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:typed_data';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/auxiliary/mp_encoding_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_endings_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/exceptions/th2_unsupported_line_ending_exception.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_output_planner.dart';

/// The part of the writer output that one leaf appended, and its owner.
class TH2LedgerSpan {
  final int mpID;
  final int start;
  final int length;

  const TH2LedgerSpan({
    required this.mpID,
    required this.start,
    required this.length,
  });
}

class TH2FileWriter {
  static const List<THElementType> configBlockElementTypes = <THElementType>[
    THElementType.xTherionConfig,
    THElementType.xTherionImageInsertConfig,
    THElementType.mapiahImageInsertConfig,
  ];

  String _prefix = '';

  final RegExp _doubleQuotePairEncodedRegex = RegExp(mpDoubleQuotePairEncoded);
  final RegExp _doubleQuotePairRegex = RegExp(mpDoubleQuotePair);

  late bool _includeEmptyLines;
  late bool _useOriginalRepresentation;
  String _lineEnding = MPDirectoryAux.getDefaultLineEnding();
  bool _insideMultiLineComment = false;

  /// Output state of the current serialization, reset by [_serializeFile].
  bool _recordLedger = false;
  final List<TH2LedgerSpan> _ledger = <TH2LedgerSpan>[];
  int _outputLength = 0;
  int? _lastChunkOwnerMPID;
  bool _lastChunkTerminated = true;

  /// Owner MPID and output offset of each line ending added after an
  /// unterminated chunk.
  final List<(int, int)> _addedEndings = <(int, int)>[];

  late TH2File _th2File;
  late TH2FileOutputPlan _outputPlan;

  String serialize(
    TH2File th2File, {
    bool includeEmptyLines = false,
    bool useOriginalRepresentation = false,
    String? lineEnding,
  }) {
    return _serializeFile(
      th2File,
      includeEmptyLines: includeEmptyLines,
      useOriginalRepresentation: useOriginalRepresentation,
      lineEnding: lineEnding,
    );
  }

  /// Serializes [th2File] as [serialize] does and maps each line of the
  /// result to the element that wrote it.
  ///
  /// Throws [TH2UnsupportedLineEndingException] when the text would contain a
  /// lone `\r`, which is not a line ending in a line map.
  (String, TH2TextLineMap) serializeWithLineMap(
    TH2File th2File, {
    bool includeEmptyLines = false,
    bool useOriginalRepresentation = false,
    String? lineEnding,
  }) {
    final String text;

    _recordLedger = true;
    try {
      text = _serializeFile(
        th2File,
        includeEmptyLines: includeEmptyLines,
        useOriginalRepresentation: useOriginalRepresentation,
        lineEnding: lineEnding,
      );
    } finally {
      _recordLedger = false;
    }

    assert(_isLedgerContiguous(text.length));

    final List<int> lineStarts = TH2TextLineEndingsAux.lineStartOffsets(text);
    final List<int?> ownerByLine = List<int?>.filled(lineStarts.length, null);

    for (final TH2LedgerSpan span in _ledger) {
      if (span.length == 0) {
        continue;
      }

      final int firstLine = TH2TextLineEndingsAux.lineIndexAtOffset(
        lineStarts,
        span.start,
      );
      final int lastLine = TH2TextLineEndingsAux.lineIndexAtOffset(
        lineStarts,
        span.start + span.length - 1,
      );

      for (int line = firstLine; line <= lastLine; line++) {
        assert(
          (ownerByLine[line] == null) || (ownerByLine[line] == span.mpID),
          "Line '$line' written by MPIDs '${ownerByLine[line]}' and '${span.mpID}'.",
        );
        ownerByLine[line] = span.mpID;
      }
    }

    final List<TH2TextRelocation> relocations = <TH2TextRelocation>[];

    for (final int mpID in _outputPlan.relocatedSettingMPIDs) {
      final int destinationLine = ownerByLine.indexOf(mpID);

      if (destinationLine >= 0) {
        relocations.add(
          TH2TextRelocation(mpID: mpID, destinationLine: destinationLine),
        );
      }
    }

    final List<TH2TextAddedEnding> addedEndings = _addedEndings
        .map(
          ((int, int) addedEnding) => TH2TextAddedEnding(
            ownerMPID: addedEnding.$1,
            line: TH2TextLineEndingsAux.lineIndexAtOffset(
              lineStarts,
              addedEnding.$2,
            ),
          ),
        )
        .toList();

    final TH2TextLineMap lineMap = TH2TextLineMap.fromWriterLedger(
      ownerByLine: ownerByLine,
      th2File: th2File,
      relocations: relocations,
      addedEndings: addedEndings,
    );

    return (text, lineMap);
  }

  bool _isLedgerContiguous(int textLength) {
    int expectedStart = 0;

    for (final TH2LedgerSpan span in _ledger) {
      if (span.start != expectedStart) {
        return false;
      }
      expectedStart += span.length;
    }

    return expectedStart == textLength;
  }

  String _serializeFile(
    TH2File th2File, {
    required bool includeEmptyLines,
    required bool useOriginalRepresentation,
    required String? lineEnding,
  }) {
    _th2File = th2File;
    _includeEmptyLines = includeEmptyLines;
    _useOriginalRepresentation = useOriginalRepresentation;
    _lineEnding = lineEnding ?? _th2File.lineEnding;
    _insideMultiLineComment = false;
    _prefix = '';
    _ledger.clear();
    _outputLength = 0;
    _lastChunkOwnerMPID = null;
    _lastChunkTerminated = true;
    _addedEndings.clear();

    if (_recordLedger) {
      assert(
        (_lineEnding == mpUnixLineBreak) ||
            (_lineEnding == mpWindowsLineBreak),
      );
    }

    _outputPlan = TH2FileOutputPlanner.plan(
      th2File.childrenMPIDs
          .map(
            (int childMPID) =>
                (childMPID, th2File.elementByMPID(childMPID).elementType),
          )
          .toList(),
    );

    String asString = '';

    if (_outputPlan.synthesizeEncoding) {
      asString += _emit(
        th2File.mpID,
        'encoding ${th2File.encoding}$_lineEnding',
      );
    }

    for (final int childMPID in _outputPlan.orderedChildMPIDs) {
      asString += _serializeElement(th2File.elementByMPID(childMPID));
    }

    return asString;
  }

  /// Appends [chunk], written by the element [mpID], to the output.
  ///
  /// Only leaves (the methods that produce text) call it: a leaf's result is
  /// appended to the output exactly once, in the order the leaf was called,
  /// and never discarded or reordered. Composers only concatenate.
  ///
  /// When the previous chunk didn't end with a line ending, the selected one
  /// is added before [chunk], owned by the previous chunk's element.
  String _emit(int mpID, String chunk) {
    if (chunk.isEmpty) {
      return '';
    }

    final String separator = _lastChunkTerminated ? '' : _lineEnding;

    if (_recordLedger) {
      assert(
        (mpID == _th2File.mpID) || _th2File.hasElementByMPID(mpID),
        "MPID '$mpID' names no element of the file.",
      );

      final int? loneCarriageReturnOffset =
          TH2TextLineEndingsAux.loneCarriageReturnOffset(chunk);

      if (loneCarriageReturnOffset != null) {
        throw TH2UnsupportedLineEndingException(
          offset: _outputLength + separator.length + loneCarriageReturnOffset,
          mpID: mpID,
        );
      }
    }

    if (separator.isNotEmpty) {
      final int separatorOwnerMPID = _lastChunkOwnerMPID!;

      _addedEndings.add((separatorOwnerMPID, _outputLength));
      _recordSpan(separatorOwnerMPID, separator.length);
    }

    _recordSpan(mpID, chunk.length);
    _lastChunkOwnerMPID = mpID;
    _lastChunkTerminated = chunk.endsWith(mpUnixLineBreak);

    return '$separator$chunk';
  }

  void _recordSpan(int mpID, int length) {
    if (_recordLedger) {
      _ledger.add(
        TH2LedgerSpan(mpID: mpID, start: _outputLength, length: length),
      );
    }
    _outputLength += length;
  }

  String _prepareLineWithOriginalRepresentation(
    String newText,
    THElement thElement,
  ) {
    String newLine = _elementOriginalLineRepresentation(thElement);

    if (newLine.isEmpty) {
      newLine = _prepareLine(newText, thElement);
    }

    return newLine;
  }

  String _serializeComment(THElement thElement) {
    final THComment thComment = thElement as THComment;
    final String newLine = '# ${thComment.content}';

    return _prepareLineWithOriginalRepresentation(newLine, thElement);
  }

  String _serializeEmptyLine(THElement thElement) {
    return (_includeEmptyLines || _insideMultiLineComment)
        ? _emit(
            thElement.mpID,
            _useOriginalRepresentation
                ? thElement.originalLineInTH2File
                : _lineEnding,
          )
        : '';
  }

  String _serializeMultiLineCommmentContent(THElement thElement) {
    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      asString = _emit(
        thElement.mpID,
        "${(thElement as THMultilineCommentContent).content}$_lineEnding",
      );
    }

    return asString;
  }

  String _serializeScrap(THElement thElement) {
    final THScrap thScrap = thElement as THScrap;

    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      final String scrapOptions = thScrap.optionsAsString();
      final String newLine = "scrap ${thScrap.thID} $scrapOptions".trim();

      asString = _prepareLine(newLine, thScrap);
    }

    _increasePrefix();

    asString += _childrenAsString(thScrap);

    return asString;
  }

  String _serializeXTherionConfig(THElement thElement) {
    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      final THXTherionConfig xTC = thElement as THXTherionConfig;

      asString = _emit(
        thElement.mpID,
        "$mpXTherionConfigID ${xTC.name.trim()} ${xTC.value.trim()}$_lineEnding",
      );
    }

    return asString;
  }

  String _serializeXTherionImageInsertConfig(THElement thElement) {
    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      final THXTherionImageInsertConfig xTIIC =
          thElement as THXTherionImageInsertConfig;

      final String xx =
          "${xTIIC.xx} ${xTIIC.isVisible ? '1' : '0'} ${xTIIC.igamma}";
      final String xviRoot = xTIIC.asXVIImage?.xviRoot ?? '';
      final String yy = xviRoot.isEmpty
          ? "${xTIIC.yy}"
          : "${xTIIC.yy} $xviRoot";
      final String imgx = "${xTIIC.imgx} ${xTIIC.xData}";
      final String serializedYY = xviRoot.isEmpty
          ? yy.trim()
          : "{${yy.trim()}}";

      asString = _emit(
        thElement.mpID,
        """$mpXTherionConfigID $mpXTherionImageInsertConfigID {${xx.trim()}} $serializedYY "${xTIIC.filename.trim()}" ${xTIIC.iidx} {${imgx.trim()}}$_lineEnding""",
      );
    }

    return asString;
  }

  String _serializeMapiahImageInsertConfig(THElement thElement) {
    final MPImageInsertConfig imageInsertConfig =
        thElement as MPImageInsertConfig;

    /// Images whose transform is a pure translation are always saved in the
    /// XTherion format to keep the file interoperable with XTherion, even if
    /// they were read as ##MAPIAH## lines.
    if (imageInsertConfig.isXTherionRepresentable) {
      return _serializeXTherionImageInsertConfig(
        THXTherionImageInsertConfig.fromMapiahImageInsertConfig(
          mapiahImageInsertConfig: imageInsertConfig,
        ),
      );
    }

    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      asString = _emit(
        thElement.mpID,
        "${imageInsertConfig.toMetadataLine()}$_lineEnding",
      );
    }

    return asString;
  }

  String _serializeElement(THElement thElement) {
    final THElementType type = thElement.elementType;

    String asString = '';

    switch (type) {
      case THElementType.area:
        asString += _serializeArea(thElement);
      case THElementType.areaBorderTHID:
        final String newLine = (thElement as THAreaBorderTHID).thID;

        asString += _prepareLineWithOriginalRepresentation(newLine, thElement);
      case THElementType.comment:
        asString += _serializeComment(thElement);
      case THElementType.emptyLine:
        asString += _serializeEmptyLine(thElement);
      case THElementType.encoding:
        final String newLine = 'encoding ${(thElement as THEncoding).encoding}';

        asString += _prepareLineWithOriginalRepresentation(newLine, thElement);
      case THElementType.endarea:
        _reducePrefix();
        asString += _prepareLineWithOriginalRepresentation(
          'endarea',
          thElement,
        );
      case THElementType.endcomment:
        _reducePrefix();
        _insideMultiLineComment = false;
        asString += _prepareLineWithOriginalRepresentation(
          'endcomment',
          thElement,
        );
      case THElementType.endline:
        _reducePrefix();
        asString += _prepareLineWithOriginalRepresentation(
          'endline',
          thElement,
        );
      case THElementType.endscrap:
        _reducePrefix();
        asString += _prepareLineWithOriginalRepresentation(
          'endscrap',
          thElement,
        );
      case THElementType.line:
        asString += _serializeLine(thElement);
      case THElementType.bezierCurveLineSegment:
      case THElementType.lineSegment:
      case THElementType.straightLineSegment:
        asString += _serializeLineSegment(thElement);
      case THElementType.mapiahImageInsertConfig:
        asString += _serializeMapiahImageInsertConfig(thElement);
      case THElementType.xTherionConfig:
        asString += _serializeXTherionConfig(thElement);
      case THElementType.xTherionImageInsertConfig:
        asString += _serializeXTherionImageInsertConfig(thElement);
      case THElementType.multilineComment:
        asString += _prepareLineWithOriginalRepresentation(
          'comment',
          thElement,
        );
        _increasePrefix();
        _insideMultiLineComment = true;
        asString += _childrenAsString(thElement as THMultiLineComment);
      case THElementType.multilineCommentContent:
        asString += _serializeMultiLineCommmentContent(thElement);
      case THElementType.point:
        asString += _serializePoint(thElement);
      case THElementType.scrap:
        asString += _serializeScrap(thElement);
      case THElementType.unrecognizedCommand:
        final String newLine = "Unrecognized element: '$thElement'";

        asString += _prepareLineWithOriginalRepresentation(newLine, thElement);
    }

    return asString;
  }

  String _elementOriginalLineRepresentation(THElement element) {
    return _useOriginalRepresentation
        ? _emit(element.mpID, element.originalLineInTH2File)
        : '';
  }

  String _serializeArea(THElement thElement) {
    final THArea thArea = thElement as THArea;

    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      String newLine = "area ${thArea.plaType}";

      if (thArea.hasOption(THCommandOptionType.subtype)) {
        newLine +=
            ":${thArea.getOption(THCommandOptionType.subtype)!.specToFile()}";
      }
      newLine += " ${thArea.optionsAsString()}";
      newLine = newLine.trim();
      asString = _prepareLine(newLine, thArea);
    }

    _increasePrefix();

    asString += _childrenAsString(thArea);

    return asString;
  }

  String _serializeLine(THElement thElement) {
    final THLine thLine = thElement as THLine;

    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      String newLine = "line ${thLine.plaType}";

      if (thLine.hasOption(THCommandOptionType.subtype)) {
        newLine +=
            ":${thLine.getOption(THCommandOptionType.subtype)!.specToFile()}";
      }
      newLine += " ${thLine.optionsAsString()}";
      newLine = newLine.trim();
      asString = _prepareLine(newLine, thLine);
    }

    _increasePrefix();

    asString += _childrenAsString(thLine);

    return asString;
  }

  String _serializePoint(THElement thElement) {
    final THPoint thPoint = thElement as THPoint;

    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      String newLine =
          "point ${thPoint.position.toString()} ${thPoint.plaType}";

      if (thPoint.hasOption(THCommandOptionType.subtype)) {
        newLine +=
            ":${thPoint.getOption(THCommandOptionType.subtype)!.specToFile()}";
      }
      newLine += " ${thPoint.optionsAsString()}";
      newLine = newLine.trim();
      asString = _prepareLine(newLine, thPoint);
    }

    return asString;
  }

  String _serializeLineSegment(THElement thElement) {
    final THElementType type = thElement.elementType;

    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      switch (type) {
        case THElementType.bezierCurveLineSegment:
          final THBezierCurveLineSegment thBezierCurveLineSegment =
              thElement as THBezierCurveLineSegment;
          final String newLine =
              "${thBezierCurveLineSegment.controlPoint1} ${thBezierCurveLineSegment.controlPoint2} ${thBezierCurveLineSegment.endPoint}";

          asString += _prepareLine(newLine, thBezierCurveLineSegment);
          asString += _linePointOptionsAsString(thBezierCurveLineSegment);
        case THElementType.straightLineSegment:
          final THStraightLineSegment thStraightLineSegment =
              thElement as THStraightLineSegment;
          final String newLine = thStraightLineSegment.endPoint.toString();

          asString += _prepareLine(newLine, thStraightLineSegment);
          asString += _linePointOptionsAsString(thStraightLineSegment);
        default:
          throw THCustomException(
            "Unrecognized line segment type: '${type.name}'.",
          );
      }
    } else {
      asString += _linePointOptionsAsString(thElement as THLineSegment);
    }

    return asString;
  }

  String _childrenAsString(THIsParentMixin thParent) {
    String asString = '';

    for (final int childMPID in thParent.childrenMPIDs) {
      final THElement child = _th2File.elementByMPID(childMPID);

      asString += _serializeElement(child);
    }

    return asString;
  }

  void _increasePrefix() {
    _prefix += mpIndentation;
  }

  void _reducePrefix() {
    _prefix = _prefix.substring(mpIndentation.length);
  }

  String _encodeDoubleQuotes(String aString) {
    final String encoded = aString.replaceAll(
      _doubleQuotePairRegex,
      mpDoubleQuotePairEncoded,
    );

    return encoded;
  }

  String _decodeDoubleQuotes(String aString) {
    final String decoded = aString.replaceAll(
      _doubleQuotePairEncodedRegex,
      mpDoubleQuotePair,
    );

    return decoded;
  }

  String _prepareLine(String line, THElement thElement) {
    line = _encodeDoubleQuotes(line);
    String newLine = '$_prefix$line';

    // Breaking long lines
    if (newLine.length > mpMaxFileLineLength) {
      String splitLine = '';
      bool isFirst = true;
      line = line.trim();
      int maxLength = mpMaxFileLineLength - _prefix.length;

      while ((line.isNotEmpty) && (line.length > maxLength)) {
        final int breakPos = _lineBreakPosition(line, maxLength);
        final String part = line.substring(0, breakPos);

        line = line.substring(breakPos);
        splitLine += _prefix;

        if (isFirst) {
          isFirst = false;
          _increasePrefix();
          _increasePrefix();
          maxLength = mpMaxFileLineLength - _prefix.length;
        }

        splitLine += part;
        if (line.isNotEmpty) {
          splitLine += '\\$_lineEnding';
        }
      }

      if (line.isNotEmpty) {
        splitLine += "$_prefix$line";
      }

      newLine = splitLine;
      _reducePrefix();
      _reducePrefix();
    }

    if (thElement.sameLineComment != null) {
      newLine += " # ${thElement.sameLineComment}";
    }

    newLine += _lineEnding;
    newLine = _decodeDoubleQuotes(newLine);

    return _emit(thElement.mpID, newLine);
  }

  /// Where to break [line], which is longer than [maxLength]: right after the
  /// last space outside quoted strings that fits in [maxLength] and leaves
  /// some content before it. When there is none, a token or quoted string
  /// longer than [maxLength] is kept whole, breaking after the first such
  /// space past it, or at the end of [line] when there is no such space.
  /// Always greater than zero, so every break consumes content.
  int _lineBreakPosition(String line, int maxLength) {
    final int lineLength = line.length;
    bool isInsideQuotes = false;
    bool hasContent = false;
    int lastBreakPos = 0;

    for (int index = 0; index < lineLength; index++) {
      final String char = line[index];

      if (char == mpDoubleQuote) {
        isInsideQuotes = !isInsideQuotes;
      }

      if ((char != ' ') || isInsideQuotes) {
        hasContent = true;
        continue;
      }

      if (!hasContent) {
        continue;
      }

      if (index > maxLength) {
        return (lastBreakPos > 0) ? lastBreakPos : index + 1;
      }

      lastBreakPos = index + 1;
    }

    return (lastBreakPos > 0) ? lastBreakPos : lineLength;
  }

  String _commandOptionOriginalLineRepresentation(THCommandOption option) {
    return _useOriginalRepresentation ? option.originalLineInTH2File : '';
  }

  String _linePointOptionsAsString(THLineSegment lineSegment) {
    final THHasOptionsMixin thHasOptions = lineSegment as THHasOptionsMixin;
    final Iterable<THCommandOptionType> optionTypeList =
        thHasOptions.optionsMap.keys;
    String asString = '';

    _increasePrefix();

    for (THCommandOptionType linePointOptionType in optionTypeList) {
      final THCommandOption option = thHasOptions.getOption(
        linePointOptionType,
      )!;

      String newLine = _commandOptionOriginalLineRepresentation(option);

      if (newLine.isEmpty) {
        newLine = "${option.typeToFile()} ";
        newLine += option.specToFile().trim();
        asString += _emit(
          lineSegment.mpID,
          "$_prefix${newLine.trim()}$_lineEnding",
        );
      } else {
        asString += _emit(lineSegment.mpID, newLine);
      }
    }

    _reducePrefix();

    return asString;
  }

  Uint8List toBytes(
    TH2File th2File, {
    bool includeEmptyLines = false,
    bool useOriginalRepresentation = false,
  }) {
    _th2File = th2File;

    final String fileContent = serialize(
      th2File,
      includeEmptyLines: includeEmptyLines,
      useOriginalRepresentation: useOriginalRepresentation,
    );

    return MPEncodingAux.encode(fileContent, th2File.encoding);
  }
}
