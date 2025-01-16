import 'dart:convert';

import 'package:charset/charset.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/th_area.dart';
import 'package:mapiah/src/elements/th_area_border_thid.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_comment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_encoding.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_multiline_comment_content.dart';
import 'package:mapiah/src/elements/th_multilinecomment.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/elements/th_xtherion_config.dart';
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
    final String type = thElement.elementType;

    switch (type) {
      case 'area':
        asString += _serializeArea(thElement);
      case 'areaborderthid':
        final newLine = (thElement as THAreaBorderTHID).id;
        asString += _prepareLine(newLine, thElement);
      case 'comment':
        asString += '# ${(thElement as THComment).content}\n';
      case 'emptyline':
        if (_includeEmptyLines || _insideMultiLineComment) {
          asString += '\n';
        }
      case 'encoding':
        final newLine = 'encoding ${(thElement as THEncoding).encoding}';
        asString += _prepareLine(newLine, thElement);
      case 'endarea':
        _reducePrefix();
        asString += _prepareLine('endarea', thElement);
      case 'endcomment':
        _reducePrefix();
        _insideMultiLineComment = false;
        asString += _prepareLine('endcomment', thElement);
      case 'endline':
        _reducePrefix();
        asString += _prepareLine('endline', thElement);
      case 'endscrap':
        _reducePrefix();
        asString += _prepareLine('endscrap', thElement);
      case 'line':
        asString += _serializeLine(thElement);
      case 'linesegment':
        asString += _serializeLineSegment(thElement);
      case 'multilinecomment':
        asString += _prepareLine('comment', thElement);
        _increasePrefix();
        _insideMultiLineComment = true;
        asString += _childrenAsString(thElement as THMultiLineComment);
      case 'multilinecommentcontent':
        asString += '${(thElement as THMultilineCommentContent).content}\n';
      case 'point':
        asString += _serializePoint(thElement);
      case 'scrap':
        final THScrap aTHScrap = thElement as THScrap;
        final String newLine =
            "scrap ${aTHScrap.thID} ${aTHScrap.optionsAsString()}".trim();
        asString += _prepareLine(newLine, aTHScrap);
        _increasePrefix();
        asString += _childrenAsString(aTHScrap);
      case 'xtherionconfig':
        final THXTherionConfig xtherionconfig = thElement as THXTherionConfig;
        asString +=
            "##XTHERION## ${xtherionconfig.name.trim()} ${xtherionconfig.value.trim()}\n";
      default:
        final String newLine = "Unrecognized element: '$thElement'";
        asString += _prepareLine(newLine, thElement);
    }

    return asString;
  }

  String _serializeArea(THElement aTHElement) {
    final aTHArea = aTHElement as THArea;
    var newLine = "area ${aTHArea.plaType}";
    if (aTHArea.optionIsSet('subtype')) {
      newLine += ":${aTHArea.optionByType('subtype')!.specToFile()}";
    }
    newLine += " ${aTHArea.optionsAsString()}";
    newLine = newLine.trim();
    var asString = _prepareLine(newLine, aTHArea);
    _increasePrefix();
    asString += _childrenAsString(aTHArea);

    return asString;
  }

  String _serializeLine(THElement aTHElement) {
    final aTHLine = aTHElement as THLine;
    var newLine = "line ${aTHLine.plaType}";
    if (aTHLine.optionIsSet('subtype')) {
      newLine += ":${aTHLine.optionByType('subtype')!.specToFile()}";
    }
    newLine += " ${aTHLine.optionsAsString()}";
    newLine = newLine.trim();
    var asString = _prepareLine(newLine, aTHLine);
    _increasePrefix();
    asString += _childrenAsString(aTHLine);

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

  String _serializeLineSegment(THElement aTHElement) {
    final thType = aTHElement.runtimeType.toString();
    var asString = '';

    switch (thType) {
      case 'THBezierCurveLineSegment':
        final THBezierCurveLineSegment aTHBezierCurveLineSegment =
            aTHElement as THBezierCurveLineSegment;
        final String newLine =
            "${aTHBezierCurveLineSegment.controlPoint1} ${aTHBezierCurveLineSegment.controlPoint2} ${aTHBezierCurveLineSegment.endPoint}";
        asString += _prepareLine(newLine, aTHBezierCurveLineSegment);
        asString += _linePointOptionsAsString(aTHBezierCurveLineSegment);
      case 'THStraightLineSegment':
        final THStraightLineSegment aTHStraightLineSegment =
            aTHElement as THStraightLineSegment;
        final String newLine = aTHStraightLineSegment.endPoint.toString();
        asString += _prepareLine(newLine, aTHStraightLineSegment);
        asString += _linePointOptionsAsString(aTHStraightLineSegment);
      default:
        throw THCustomException("Unrecognized line segment type: '$thType'.");
    }

    return asString;
  }

  String _childrenAsString(THParent thParent) {
    String asString = '';

    for (final int aChildMapiahID in (thParent).childrenMapiahID) {
      asString += serializeElement(_thFile.elementByMapiahID(aChildMapiahID));
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
    final encoded =
        aString.replaceAll(_doubleQuotePairRegex, thDoubleQuotePairEncoded);

    return encoded;
  }

  String _decodeDoubleQuotes(String aString) {
    final decoded =
        aString.replaceAll(_doubleQuotePairEncodedRegex, thDoubleQuotePair);

    return decoded;
  }

  String _prepareLine(String line, THElement aTHElement) {
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

    if (aTHElement.sameLineComment != null) {
      newLine += " # ${aTHElement.sameLineComment}";
    }

    newLine += '\n';
    newLine = _decodeDoubleQuotes(newLine);

    return newLine;
  }

  String _linePointOptionsAsString(THLineSegment lineSegment) {
    final THHasOptions thHasOptions = lineSegment as THHasOptions;
    final Iterable<String> optionTypeList = thHasOptions.optionsMap.keys;
    String asString = '';

    _increasePrefix();

    for (String linePointOptionType in optionTypeList) {
      String newLine = "$linePointOptionType ";
      newLine +=
          thHasOptions.optionByType(linePointOptionType)!.specToFile().trim();
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
