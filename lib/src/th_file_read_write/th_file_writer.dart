import 'dart:convert';

import 'package:charset/charset.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_parent_mixin.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/th_file_read_write/th_file_aux.dart';

class THFileWriter {
  String _prefix = '';

  final RegExp _doubleQuotePairEncodedRegex = RegExp(thDoubleQuotePairEncoded);
  final RegExp _doubleQuotePairRegex = RegExp(thDoubleQuotePair);

  bool _includeEmptyLines = false;
  bool _insideMultiLineComment = false;

  late THFile _thFile;

  String serialize(THFile thFile, {bool? includeEmptyLines}) {
    _thFile = thFile;
    String asString = '';

    if (includeEmptyLines != null) {
      _includeEmptyLines = includeEmptyLines;
    }

    _prefix = '';
    if (thFile.elementByMapiahID(thFile.childrenMapiahID[0]) is! THEncoding) {
      final String newLine = 'encoding ${thFile.encoding}\n';
      asString += newLine;
    }
    asString += _childrenAsString(thFile);

    return asString;
  }

  String serializeElement(THElement thElement) {
    String asString = '';
    final THElementType type = thElement.elementType;

    switch (type) {
      case THElementType.area:
        asString += _serializeArea(thElement);
      case THElementType.areaBorderTHID:
        final String newLine = (thElement as THAreaBorderTHID).id;
        asString += _prepareLine(newLine, thElement);
      case THElementType.comment:
        asString += '# ${(thElement as THComment).content}\n';
      case THElementType.emptyLine:
        if (_includeEmptyLines || _insideMultiLineComment) {
          asString += '\n';
        }
      case THElementType.encoding:
        final String newLine = 'encoding ${(thElement as THEncoding).encoding}';
        asString += _prepareLine(newLine, thElement);
      case THElementType.endarea:
        _reducePrefix();
        asString += _prepareLine('endarea', thElement);
      case THElementType.endcomment:
        _reducePrefix();
        _insideMultiLineComment = false;
        asString += _prepareLine('endcomment', thElement);
      case THElementType.endline:
        _reducePrefix();
        asString += _prepareLine('endline', thElement);
      case THElementType.endscrap:
        _reducePrefix();
        asString += _prepareLine('endscrap', thElement);
      case THElementType.line:
        asString += _serializeLine(thElement);
      case THElementType.bezierCurveLineSegment:
      case THElementType.lineSegment:
      case THElementType.straightLineSegment:
        asString += _serializeLineSegment(thElement);
      case THElementType.multilineComment:
        asString += _prepareLine('comment', thElement);
        _increasePrefix();
        _insideMultiLineComment = true;
        asString += _childrenAsString(thElement as THMultiLineComment);
      case THElementType.multilineCommentContent:
        asString += '${(thElement as THMultilineCommentContent).content}\n';
      case THElementType.point:
        asString += _serializePoint(thElement);
      case THElementType.scrap:
        final THScrap thScrap = thElement as THScrap;
        final String scrapOptions = thScrap.optionsAsString();
        final String newLine = "scrap ${thScrap.thID} $scrapOptions".trim();
        asString += _prepareLine(newLine, thScrap);
        _increasePrefix();
        asString += _childrenAsString(thScrap);
      case THElementType.xTherionConfig:
        final THXTherionConfig xtherionconfig = thElement as THXTherionConfig;
        asString +=
            "##XTHERION## ${xtherionconfig.name.trim()} ${xtherionconfig.value.trim()}\n";
      case THElementType.unrecognizedCommand:
        final String newLine = "Unrecognized element: '$thElement'";
        asString += _prepareLine(newLine, thElement);
    }

    return asString;
  }

  String _serializeArea(THElement thElement) {
    final THArea thArea = thElement as THArea;
    String newLine = "area ${thArea.plaType}";
    if (thArea.optionIsSet('subtype')) {
      newLine += ":${thArea.optionByType('subtype')!.specToFile()}";
    }
    newLine += " ${thArea.optionsAsString()}";
    newLine = newLine.trim();
    String asString = _prepareLine(newLine, thArea);
    _increasePrefix();
    asString += _childrenAsString(thArea);

    return asString;
  }

  String _serializeLine(THElement thElement) {
    final THLine thLine = thElement as THLine;
    String newLine = "line ${thLine.plaType}";
    if (thLine.optionIsSet('subtype')) {
      newLine += ":${thLine.optionByType('subtype')!.specToFile()}";
    }
    newLine += " ${thLine.optionsAsString()}";
    newLine = newLine.trim();
    String asString = _prepareLine(newLine, thLine);
    _increasePrefix();
    asString += _childrenAsString(thLine);

    return asString;
  }

  String _serializePoint(THElement thElement) {
    final THPoint thPoint = thElement as THPoint;
    String newLine = "point ${thPoint.position.toString()} ${thPoint.plaType}";
    if (thPoint.optionIsSet('subtype')) {
      newLine += ":${thPoint.optionByType('subtype')!.specToFile()}";
    }
    newLine += " ${thPoint.optionsAsString()}";
    newLine = newLine.trim();

    return _prepareLine(newLine, thPoint);
  }

  String _serializeLineSegment(THElement thElement) {
    final String thType = thElement.runtimeType.toString();
    String asString = '';

    switch (thType) {
      case 'THBezierCurveLineSegment':
        final THBezierCurveLineSegment thBezierCurveLineSegment =
            thElement as THBezierCurveLineSegment;
        final String newLine =
            "${thBezierCurveLineSegment.controlPoint1} ${thBezierCurveLineSegment.controlPoint2} ${thBezierCurveLineSegment.endPoint}";
        asString += _prepareLine(newLine, thBezierCurveLineSegment);
        asString += _linePointOptionsAsString(thBezierCurveLineSegment);
      case 'THStraightLineSegment':
        final THStraightLineSegment thStraightLineSegment =
            thElement as THStraightLineSegment;
        final String newLine = thStraightLineSegment.endPoint.toString();
        asString += _prepareLine(newLine, thStraightLineSegment);
        asString += _linePointOptionsAsString(thStraightLineSegment);
      default:
        throw THCustomException("Unrecognized line segment type: '$thType'.");
    }

    return asString;
  }

  String _childrenAsString(THParentMixin thParent) {
    String asString = '';

    for (final int childMapiahID in thParent.childrenMapiahID) {
      asString += serializeElement(_thFile.elementByMapiahID(childMapiahID));
    }

    return asString;
  }

  void _increasePrefix() {
    _prefix += thIndentation;
  }

  void _reducePrefix() {
    _prefix = _prefix.substring(thIndentation.length);
  }

  String _encodeDoubleQuotes(String aString) {
    final String encoded =
        aString.replaceAll(_doubleQuotePairRegex, thDoubleQuotePairEncoded);

    return encoded;
  }

  String _decodeDoubleQuotes(String aString) {
    final String decoded =
        aString.replaceAll(_doubleQuotePairEncodedRegex, thDoubleQuotePair);

    return decoded;
  }

  String _prepareLine(String line, THElement thElement) {
    line = _encodeDoubleQuotes(line);
    String newLine = '$_prefix$line';

    // Breaking long lines
    if (newLine.length > thMaxFileLineLength) {
      String splitLine = '';
      bool isFirst = true;
      line = line.trim();
      int maxLength = thMaxFileLineLength - _prefix.length;

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
        int quoteCount = THFileAux.countCharOccurrences(part, thDoubleQuote);
        if (quoteCount.isOdd) {
          breakPos = line.lastIndexOf(thDoubleQuote, breakPos);
          part = line.substring(0, breakPos);

          // Dealing with parts that consumed no actual content take 2: quoted
          // strings.
          if (part.trim() == '') {
            breakPos = line.indexOf(thDoubleQuote, breakPos);
            part = line.substring(0, breakPos);
          }
        }

        line = line.substring(breakPos);
        splitLine += _prefix;

        if (isFirst) {
          isFirst = false;
          _increasePrefix();
          _increasePrefix();
          maxLength = thMaxFileLineLength - _prefix.length;
        }

        splitLine += part;
        if (line.isNotEmpty) {
          splitLine += '\\\n';
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

    newLine += '\n';
    newLine = _decodeDoubleQuotes(newLine);

    return newLine;
  }

  String _linePointOptionsAsString(THLineSegment lineSegment) {
    final THHasOptionsMixin thHasOptions = lineSegment as THHasOptionsMixin;
    final Iterable<String> optionTypeList = thHasOptions.optionsMap.keys;
    String asString = '';

    _increasePrefix();

    for (String linePointOptionType in optionTypeList) {
      final THCommandOption option =
          thHasOptions.optionByType(linePointOptionType)!;
      String newLine = "${option.typeToFile()} ";
      newLine += option.specToFile().trim();
      asString += "$_prefix${newLine.trim()}\n";
    }

    _reducePrefix();

    return asString;
  }

  Future<List<int>> toBytes(THFile thFile,
      {bool includeEmptyLines = false}) async {
    _thFile = thFile;
    String encoding = thFile.encoding;
    late List<int> fileContentEncoded;
    String fileContent =
        serialize(thFile, includeEmptyLines: includeEmptyLines);
    switch (encoding) {
      case 'UTF-8':
        fileContentEncoded = utf8.encode(fileContent);
      case 'ASCII':
        fileContentEncoded = ascii.encode(fileContent);
      case 'ISO8859-1':
        fileContentEncoded = latin1.encode(fileContent);
      default:
        final encoder = Charset.getByName(encoding);
        if (encoder == null) {
          fileContentEncoded = utf8.encode(fileContent);
        } else {
          fileContentEncoded = encoder.encode(fileContent);
        }
    }
    return fileContentEncoded;
  }
}
