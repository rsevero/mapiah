import 'package:mapiah/src/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/th_elements/th_comment.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_encoding.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
import 'package:mapiah/src/th_elements/th_multiline_comment_content.dart';
import 'package:mapiah/src/th_elements/th_multilinecomment.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_elements/th_straight_line_segment.dart';
import 'package:mapiah/src/th_file_aux/th_file_aux.dart';

class THFileWriter {
  var _prefix = '';

  final _doubleQuotePairEncodedRegex = RegExp(thDoubleQuotePairEncoded);
  final _doubleQuotePairRegex = RegExp(thDoubleQuotePair);

  String serialize(THElement aTHElement) {
    var asString = '';
    final type = aTHElement.type;

    switch (type) {
      case 'beziercurvelinesegment':
        final aTHBezierCurveLineSegment =
            aTHElement as THBezierCurveLineSegment;
        final newLine =
            "${aTHBezierCurveLineSegment.controlPoint1} ${aTHBezierCurveLineSegment.controlPoint2} ${aTHBezierCurveLineSegment.endPoint}";
        asString += _prepareLine(newLine, aTHBezierCurveLineSegment);
      case 'comment':
        asString += '# ${(aTHElement as THComment).content}\n';
      case 'emptyline':
        asString += '\n';
      case 'encoding':
        final newLine = 'encoding ${(aTHElement as THEncoding).encoding}';
        asString += _prepareLine(newLine, aTHElement);
      case 'endcomment':
        _reducePrefix();
        asString += _prepareLine('endcomment', aTHElement);
      case 'endline':
        _reducePrefix();
        asString += _prepareLine('endline', aTHElement);
      case 'endscrap':
        _reducePrefix();
        asString += _prepareLine('endscrap', aTHElement);
      case 'file':
        _prefix = '';
        final aTHFile = aTHElement as THFile;
        if (aTHFile.children[0] is! THEncoding) {
          final newLine = 'encoding ${aTHFile.encoding}\n';
          asString += newLine;
        }
        asString += _childrenAsString(aTHFile);
      case 'line':
        final aTHLine = aTHElement as THLine;
        final newLine =
            "line ${aTHLine.lineType} ${aTHLine.optionsAsString()}".trim();
        asString += _prepareLine(newLine, aTHLine);
        _increasePrefix();
        asString += _childrenAsString(aTHLine);
      case 'multilinecomment':
        asString += _prepareLine('comment', aTHElement);
        _increasePrefix();
        asString += _childrenAsString(aTHElement as THMultiLineComment);
      case 'multilinecommentcontent':
        asString += '${(aTHElement as THMultilineCommentContent).content}\n';
      case 'point':
        final aTHPoint = aTHElement as THPoint;
        final newLine =
            'point ${aTHPoint.point} ${aTHPoint.pointType} ${aTHPoint.optionsAsString()}'
                .trim();
        asString += _prepareLine(newLine, aTHPoint);
      case 'scrap':
        final aTHScrap = aTHElement as THScrap;
        final newLine =
            "scrap ${aTHScrap.thID} ${aTHScrap.optionsAsString()}".trim();
        asString += _prepareLine(newLine, aTHScrap);
        _increasePrefix();
        asString += _childrenAsString(aTHScrap);
      case 'straightlinesegment':
        final aTHStraightLineSegment = aTHElement as THStraightLineSegment;
        final newLine = aTHStraightLineSegment.endPoint.toString();
        asString += _prepareLine(newLine, aTHStraightLineSegment);
      default:
        final newLine = "Unrecognized element: '$aTHElement'";
        asString += _prepareLine(newLine, aTHElement);
    }

    return asString;
  }

  String _childrenAsString(THParent aTHParent) {
    var asString = '';

    for (final aChild in (aTHParent).children) {
      asString += serialize(aChild);
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

  String _prepareLine(String aLine, THElement aTHElement) {
    aLine = _encodeDoubleQuotes(aLine);
    var newLine = '$_prefix$aLine';

    // Breaking long lines
    if (newLine.length > thMaxFileLineLength) {
      var splitLine = '';
      var isFirst = true;
      aLine = aLine.trim();
      var maxLength = thMaxFileLineLength - _prefix.length;

      while ((aLine.isNotEmpty) && (aLine.length > maxLength)) {
        var breakPos = aLine.lastIndexOf(' ', maxLength) + 1;
        var part = aLine.substring(0, breakPos);

        // Dealing with parts that consumed no actual content, i.e., are only
        // spaces. this probably means that there is a token (keyword, etc)
        // longer than maxLength.
        //
        // In this situation, we put a complete token in the line, no matter how
        // big it is.
        if (part.trim() == '') {
          breakPos = aLine.indexOf(' ', breakPos);
          part = aLine.substring(0, breakPos);
        }

        // Dealing with parts that broke a quoted string.
        final quoteCount = THFileAux.countCharOccurrences(part, thDoubleQuote);
        if (quoteCount.isOdd) {
          breakPos = aLine.lastIndexOf(thDoubleQuote, breakPos);
          part = aLine.substring(0, breakPos);

          // Dealing with parts that consumed no actual content take 2: quoted
          // strings.
          if (part.trim() == '') {
            breakPos = aLine.indexOf(thDoubleQuote, breakPos);
            part = aLine.substring(0, breakPos);
          }
        }

        aLine = aLine.substring(breakPos);
        if (isFirst) {
          isFirst = false;
          _increasePrefix();
          _increasePrefix();
          maxLength = thMaxFileLineLength - _prefix.length;
        } else {
          splitLine += _prefix;
        }
        splitLine += part;
        if (aLine.isNotEmpty) {
          splitLine += '\\\n';
        }
      }

      if (aLine.isNotEmpty) {
        splitLine += "$_prefix$aLine";
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
}
