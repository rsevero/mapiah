// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';
import 'package:charset/charset.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_aux.dart';

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
  bool _xTherionConfigWritten = false;

  late TH2File _th2File;

  String serialize(
    TH2File th2File, {
    bool includeEmptyLines = false,
    bool useOriginalRepresentation = false,
    String? lineEnding,
  }) {
    _th2File = th2File;
    _includeEmptyLines = includeEmptyLines;
    _useOriginalRepresentation = useOriginalRepresentation;
    _lineEnding = lineEnding ?? _th2File.lineEnding;
    _insideMultiLineComment = false;
    _xTherionConfigWritten = false;

    String asString = '';

    _prefix = '';
    if (th2File.elementByMPID(th2File.childrenMPIDs.first) is! THEncoding) {
      final String newLine = 'encoding ${th2File.encoding}$_lineEnding';

      asString += newLine;

      asString += _trySerializeXTherionConfig();
    }

    asString += _childrenAsString(th2File);

    return asString;
  }

  String _trySerializeXTherionConfig() {
    if (_xTherionConfigWritten) {
      return '';
    }

    final Iterable<THElement> configBlockElements = _configBlockElements();

    bool onlyNewConfigBlockElements = true;

    for (final THElement element in configBlockElements) {
      if (element.originalLineInTH2File.isNotEmpty) {
        onlyNewConfigBlockElements = false;
        break;
      }
    }

    if (!onlyNewConfigBlockElements) {
      return '';
    }

    return _serializeAllXTherionConfigs();
  }

  String _serializeAllXTherionConfigs() {
    if (_xTherionConfigWritten) {
      return '';
    }

    String asString = '';

    for (final THElement thElement in _configBlockElements()) {
      if (thElement is THXTherionConfig) {
        asString += _serializeXTherionConfig(thElement);
      } else if (thElement is THXTherionImageInsertConfig) {
        asString += _serializeXTherionImageInsertConfig(thElement);
      } else if (thElement is MPImageInsertConfig) {
        asString += _serializeMapiahImageInsertConfig(thElement);
      } else {
        throw THCustomException(
          "At TH2FileWriter._serializeAllXTherionConfigs: thElement with MPID '${thElement.mpID}' is not part of the top-level config block.",
        );
      }
    }

    _xTherionConfigWritten = true;

    return asString;
  }

  Iterable<THElement> _configBlockElements() {
    return _th2File.childrenMPIDs
        .map((int childMPID) => _th2File.elementByMPID(childMPID))
        .where(_isConfigBlockElement);
  }

  bool _isConfigBlockElement(THElement element) {
    return configBlockElementTypes.contains(element.elementType);
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
        ? (_useOriginalRepresentation
              ? thElement.originalLineInTH2File
              : _lineEnding)
        : '';
  }

  String _serializeMultiLineCommmentContent(THElement thElement) {
    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      asString =
          "${(thElement as THMultilineCommentContent).content}$_lineEnding";
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

      asString =
          "$mpXTherionConfigID ${xTC.name.trim()} ${xTC.value.trim()}$_lineEnding";
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
      final String xviRoot = (xTIIC.asXVIImage?.xviRoot ?? '').isEmpty
          ? '{}'
          : xTIIC.asXVIImage!.xviRoot;
      final String yy = "${xTIIC.yy} $xviRoot";
      final String imgx = "${xTIIC.imgx} ${xTIIC.xData}";

      asString =
          """$mpXTherionConfigID $mpXTherionImageInsertConfigID {${xx.trim()}} {${yy.trim()}} "${xTIIC.filename.trim()}" ${xTIIC.iidx} {${imgx.trim()}}$_lineEnding""";
    }

    return asString;
  }

  String _serializeMapiahImageInsertConfig(THElement thElement) {
    String asString = _elementOriginalLineRepresentation(thElement);

    if (asString.isEmpty) {
      final MPImageInsertConfig imageInsertConfig =
          thElement as MPImageInsertConfig;

      asString = "${imageInsertConfig.toMetadataLine()}$_lineEnding";
    }

    return asString;
  }

  String serializeElement(THElement thElement) {
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
        asString += _trySerializeXTherionConfig();
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
      case THElementType.xTherionConfig:
      case THElementType.xTherionImageInsertConfig:
        asString += _serializeAllXTherionConfigs();
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
    return _useOriginalRepresentation ? element.originalLineInTH2File : '';
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

      asString += serializeElement(child);
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
        int breakPos = line.lastIndexOf(' ', maxLength) + 1;
        String part = line.substring(0, breakPos);

        // Dealing with parts that consumed no actual content, i.e., are only
        // spaces. this probably means that there is a token (keyword, etc)
        // longer than maxLength.
        //
        // In this situation, we put a complete token in the line, no matter how
        // big it is.
        if (part.trim() == '') {
          breakPos = line.indexOf(' ', breakPos);
          part = line.substring(0, breakPos);
        }

        // Dealing with parts that broke a quoted string.
        int quoteCount = TH2FileAux.countCharOccurrences(part, mpDoubleQuote);
        if (quoteCount.isOdd) {
          breakPos = line.lastIndexOf(mpDoubleQuote, breakPos);
          part = line.substring(0, breakPos);

          // Dealing with parts that consumed no actual content take 2: quoted
          // strings.
          if (part.trim() == '') {
            breakPos = line.indexOf(mpDoubleQuote, breakPos);
            part = line.substring(0, breakPos);
          }
        }

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

    return newLine;
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
        asString += "$_prefix${newLine.trim()}$_lineEnding";
      } else {
        asString += newLine;
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

    String encoding = th2File.encoding;
    Uint8List fileContentEncoded = Uint8List(0);
    final String fileContent = serialize(
      th2File,
      includeEmptyLines: includeEmptyLines,
      useOriginalRepresentation: useOriginalRepresentation,
    );

    switch (encoding) {
      case 'UTF-8':
        fileContentEncoded = utf8.encode(fileContent);
      case 'ASCII':
        fileContentEncoded = ascii.encode(fileContent);
      case 'ISO8859-1':
        fileContentEncoded = latin1.encode(fileContent);
      default:
        final Encoding? encoder = Charset.getByName(encoding);

        if (encoder == null) {
          fileContentEncoded = utf8.encode(fileContent);
        } else {
          fileContentEncoded = Uint8List.fromList(encoder.encode(fileContent));
        }
    }

    return fileContentEncoded;
  }
}
