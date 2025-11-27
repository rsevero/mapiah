import 'dart:convert';
import 'dart:io';
import 'package:charset/charset.dart';
import 'package:flutter/foundation.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_edit_element_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/errors/th_options_list_wrong_length_error.dart';
import 'package:mapiah/src/exceptions/th_create_object_from_empty_list_exception.dart';
import 'package:mapiah/src/exceptions/th_create_object_from_null_value_exception.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/mp_file_read_write/th_grammar.dart';
import 'package:meta/meta.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';

class THFileParser {
  final THGrammar _grammar = THGrammar();

  late final Parser _areaContentParser;
  late final Parser _lineContentParser;
  late final Parser _multiLineCommentContentParser;
  late final Parser _scrapContentParser;
  late final Parser _th2FileFirstLineParser;
  late final Parser _th2FileParser;

  final List<Parser> _parentParsers = [];

  late Parser _rootParser;
  late Parser _currentParser;

  final List<MPParseableLine> _splittedContents = [];
  String _currentOriginalLine = '';
  String _currentParseableLine = '';
  String _continuationDelimiter = '';
  late Result<dynamic> _parsedContents;
  late List<dynamic>? _commentContentToParse;
  late THIsParentMixin _currentParent;
  late int _currentParentMPID;
  late THElement _currentElement;
  late THHasOptionsMixin _currentHasOptions;
  THLineSegment? _lastLineSegment;
  late List<dynamic> _currentOptions;
  late List<dynamic> _currentSpec;
  bool _runTraceParser = false;
  String _xTherionContent = '';

  late THFile _parsedTHFile;
  late TH2FileEditController _th2FileEditController;
  late TH2FileEditElementEditController _th2FileElementEditController;

  final List<String> _parseErrors = [];

  final RegExp _doubleQuoteRegex = RegExp(thDoubleQuotePair);
  final RegExp _encodingRegex = RegExp(
    r'^\s*encoding\s+([a-zA-Z0-9-]+)',
    caseSensitive: false,
  );
  final RegExp _isoRegex = RegExp(r'^iso([^_-].*)', caseSensitive: false);
  final RegExp singleDateTimeRegex = RegExp(
    r'^(\d{4})(?:\.(\d{1,2})(?:\.(\d{1,2})(?:@(\d{1,2})(?::(\d{1,2})(?::(\d{1,2})(?:\.(\d{1,2}))?)?)?)?)?)?$',
  );
  final RegExp dateTimeRangeRegex = RegExp(
    r'^(\d{4})(?:\.(\d{1,2})(?:\.(\d{1,2})(?:@(\d{1,2})(?::(\d{1,2})(?::(\d{1,2})(?:\.(\d{1,2}))?)?)?)?)?)?(?:\s*-\s*(\d{4})(?:\.(\d{1,2})(?:\.(\d{1,2})(?:@(\d{1,2})(?::(\d{1,2})(?::(\d{1,2})(?:\.(\d{1,2}))?)?)?)?)?)?)?$',
  );
  final RegExp hyphenRegex = RegExp(r'^\s*-\s*$');
  final RegExp lenghtUnitRegex = RegExp(
    r'^(meters?|centimeters?|inch(?:es)?|feets?|yards?|m|cm|in|ft|yd)$',
    caseSensitive: false,
  );
  final RegExp fixNumberLengthUnitRegex = RegExp(
    r'^(?:fix\s*)?([+-]?)(\d+(?:\.\d+)?)(?:\s*(meters?|centimeters?|inch(?:es)?|feets?|yards?|m|cm|in|ft|yd))?$',
    caseSensitive: false,
  );
  final RegExp nanRegex = RegExp(r'^nan$', caseSensitive: false);
  final RegExp hyphenPointRegex = RegExp(r'^\s*[-.]\s*$');
  final RegExp twoNumbersWithOptionalUnitRegex = RegExp(
    r'^(\d+(?:\.\d+)?)\s+(\d+(?:\.\d+)?)(?:\s*(meters?|centimeters?|inch(?:es)?|feets?|yards?|m|cm|in|ft|yd))?$',
    caseSensitive: false,
  );
  final RegExp signedNumberPresumedUnitRegex = RegExp(
    r'^([+-]?)(\d+(?:\.\d+)?)(\?)?(?:\s*(meters?|centimeters?|inch(?:es)?|feets?|yards?|m|cm|in|ft|yd))?$',
    caseSensitive: false,
  );
  final RegExp signedNumberWithOptionalUnitRegex = RegExp(
    r'^([+-]?)(\d+(?:\.\d+)?)(?:\s*(meters?|centimeters?|inch(?:es)?|feets?|yards?|m|cm|in|ft|yd))?$',
    caseSensitive: false,
  );
  final RegExp plusMinusNumbersWithOptionalUnitRegex = RegExp(
    r'^(\+\d+(?:\.\d+)?)\s+(-\d+(?:\.\d+)?)(?:\s*(meters?|centimeters?|inch(?:es)?|feets?|yards?|m|cm|in|ft|yd))?$',
    caseSensitive: false,
  );

  THFileParser() {
    _areaContentParser = _grammar.buildFrom(_grammar.areaStart());
    _lineContentParser = _grammar.buildFrom(_grammar.lineStart());
    _multiLineCommentContentParser = _grammar.buildFrom(
      _grammar.multiLineCommentStart(),
    );
    _scrapContentParser = _grammar.buildFrom(_grammar.scrapStart());
    _th2FileFirstLineParser = _grammar.buildFrom(
      _grammar.th2FileFirstLineStart(),
    );
    _th2FileParser = _grammar.buildFrom(_grammar.thFileStart());
  }

  void _addChildParser(Parser newParser) {
    _parentParsers.add(_currentParser);
    _currentParser = newParser;
  }

  void _returnToParentParser() {
    if (kDebugMode) assert(_parentParsers.isNotEmpty);
    _currentParser = _parentParsers.removeLast();
  }

  void _resetParsersLineage() {
    _parentParsers.clear();
    _currentParser = _rootParser;
  }

  void _newRootParser(Parser newRootParser) {
    _rootParser = newRootParser;
  }

  void _injectContents() {
    bool isFirst = true;

    for (MPParseableLine currentMPParseableLine in _splittedContents) {
      _currentOriginalLine = currentMPParseableLine.originalContent;
      _currentParseableLine = currentMPParseableLine.toParse;

      if (_currentParseableLine.trim().isEmpty) {
        _injectEmptyLine();
        continue;
      }
      if (_runTraceParser) {
        trace(_currentParser).parse(_currentParseableLine);
      }

      _parsedContents = _currentParser.parse(_currentParseableLine);

      if (isFirst) {
        isFirst = false;
        _resetParsersLineage();
      }
      if (_parsedContents is Failure) {
        _addError(
          'petitparser returned a "Failure"',
          '_injectContents()',
          'Line being parsed: "$_currentParseableLine" created from "$_currentOriginalLine"',
        );

        continue;
      }

      /// '_parsedContents' holds the complete result of the grammar parsing on
      /// 'line'.
      /// 'element' holds the the 'command' part of the parsed line, i.e., the
      /// content minus the eventual comment.
      final element = _parsedContents.value[0];

      if (element.isEmpty) {
        _addError(
          'element.isEmpty',
          '_injectContents()',
          'Line being parsed: "$_currentParseableLine" created from "$_currentOriginalLine"',
        );

        continue;
      }

      _commentContentToParse =
          ((_parsedContents.value is List) &&
              ((_parsedContents.value as List).length > 1))
          ? _parsedContents.value[1]
          : null;

      final String elementType = (element[0] as String).toLowerCase();

      switch (elementType) {
        case 'area':
          _injectArea(element);
        case 'areaborderthid':
          _injectAreaBorderTHID(element);
        case 'areacommandlikeoption':
          _injectAreaCommandLikeOption(element);
        case 'beziercurvelinesegment':
          _injectBezierCurveLineSegment(element);

          /// Line data injects same line comment by themselves.
          continue;
        case 'encoding':
          _injectEncoding(element);
        case 'endarea':
          _injectEndArea();
        case 'endmultilinecomment':
          _injectEndMultiLineComment();
        case 'endline':
          _injectEndLine();
        case 'endscrap':
          _injectEndScrap();
        case 'fulllinecomment':
          _commentContentToParse = element;
          _injectComment();

          /// Full line commments have no same line comments.
          continue;
        case 'line':
          _injectLine(element);
        case 'linecommandlikeoption':
          _injectLineCommandLikeOption(element);

          /// Line data injects same line comment by themselves.
          continue;
        case 'multilinecomment':
          _injectStartMultiLineComment();
        case 'multilinecommentline':
          _injectMultiLineCommentContent(element);

          /// Multiline commments have no same line comments.
          continue;
        case 'point':
          _injectPoint(element);
        case 'scrap':
          _injectScrap(element);
        case 'straightlinesegment':
          _injectStraightLineSegment(element);

          /// Line data injects same line comment by themselves.
          continue;
        case '##xtherion##':
          _injectXTherionSetting(element);
        default:
          _injectUnknown(element);
          continue;
      }

      /// The second part of '_parsedContents' holds the comment, if any.
      _injectComment();
    }
  }

  void _injectEmptyLine() {
    _currentElement = THEmptyLine(
      parentMPID: _currentParentMPID,
      originalLineInTH2File: _currentOriginalLine,
    );
    _th2FileElementEditController.executeAddElement(
      newElement: _currentElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
  }

  void _injectMultiLineCommentContent(List<dynamic> element) {
    _currentElement = THMultilineCommentContent(
      parentMPID: _currentParentMPID,
      content: element[1].toString(),
      originalLineInTH2File: _currentOriginalLine,
    );
    _th2FileElementEditController.executeAddElement(
      newElement: _currentElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
  }

  void _injectEndMultiLineComment() {
    _currentElement = THEndcomment(
      parentMPID: _currentParentMPID,
      originalLineInTH2File: _currentOriginalLine,
    );
    _th2FileElementEditController.executeAddElement(
      newElement: _currentElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
    setCurrentParent((_currentParent as THElement).parent(_parsedTHFile));
    _returnToParentParser();
  }

  void _injectStartMultiLineComment() {
    _currentElement = THMultiLineComment(
      parentMPID: _currentParentMPID,
      originalLineInTH2File: _currentOriginalLine,
    );
    _th2FileElementEditController.executeAddElement(
      newElement: _currentElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
    setCurrentParent(_currentElement as THIsParentMixin);
    _addChildParser(_multiLineCommentContentParser);
  }

  void _injectEncoding(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize == 2);
      assert(element[1] is String);
    }

    _currentElement = THEncoding(
      parentMPID: _currentParentMPID,
      encoding: element[1],
      originalLineInTH2File: _currentOriginalLine,
    );
    _th2FileElementEditController.executeAddElement(
      newElement: _currentElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
  }

  void _injectXTherionSetting(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize == 2);
      assert(element[1] is List);
      assert(element[1].length == 2);
    }

    final String xTherionConfigID = element[1][0].toLowerCase();

    if (xTherionConfigID == xTherionImageInsertConfigID) {
      return _injectXTherionImageInsertConfig(element);
    }

    final THXTherionConfig newElement = THXTherionConfig(
      parentMPID: _currentParentMPID,
      name: xTherionConfigID,
      value: element[1][1],
      originalLineInTH2File: _currentOriginalLine,
    );

    _th2FileElementEditController.executeAddElement(
      newElement: newElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
  }

  String _getEnclosedContent(String openDelimiter, String closeDelimiter) {
    _xTherionContent = _xTherionContent.trim();
    if (!_xTherionContent.startsWith(openDelimiter)) {
      return '';
    }

    int closingIndex = -1;

    // If delimiters are the same (e.g., quotes)
    if (openDelimiter == closeDelimiter) {
      // Find the next occurrence of the delimiter
      for (int i = 1; i < _xTherionContent.length; i++) {
        if (_xTherionContent[i] == openDelimiter) {
          closingIndex = i;
          break;
        }
      }

      if (closingIndex != -1) {
        final String enclosedContent = _xTherionContent.substring(
          1,
          closingIndex,
        );

        _xTherionContent = _xTherionContent.substring(closingIndex + 1).trim();

        return enclosedContent;
      }

      return '';
    } else {
      // Standard nested delimiter handling
      int openCount = 0;

      for (int i = 0; i < _xTherionContent.length; i++) {
        if (_xTherionContent[i] == openDelimiter) {
          openCount++;
        } else if (_xTherionContent[i] == closeDelimiter) {
          openCount--;
          if (openCount == 0) {
            closingIndex = i;
            break;
          }
        }
      }

      if (closingIndex != -1) {
        final String enclosedContent = _xTherionContent.substring(
          1,
          closingIndex,
        );

        _xTherionContent = _xTherionContent.substring(closingIndex + 1).trim();

        return enclosedContent;
      }

      return '';
    }
  }

  String _getFirstElement(String delimiterRegexPattern) {
    final List<String> parts = _xTherionContent.split(
      RegExp(delimiterRegexPattern),
    );

    if (parts.isEmpty) {
      return '';
    }

    final String firstElement = parts[0].trim();

    if (firstElement.isEmpty) {
      return '';
    }

    _xTherionContent = _xTherionContent
        .substring(firstElement.length + 1)
        .trim();

    return firstElement;
  }

  String _getElement() {
    String element = _getEnclosedContent('{', '}');

    if (element.isEmpty) {
      element = _getEnclosedContent('[', ']');
      if (element.isEmpty) {
        element = _getEnclosedContent('"', '"');
        if (element.isEmpty) {
          element = _getFirstElement('\\s+');
        }
      }
    }

    return element;
  }

  void _injectXTherionImageInsertConfig(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize == 2);
      assert(element[1] is List);
      assert(element[1].length == 2);
    }

    _xTherionContent = element[1][1].toString().trim();

    if (_xTherionContent.isEmpty) {
      _addError(
        'Content is empty',
        '_injectXTherionImageInsertConfig',
        'Line being parsed: "$_currentParseableLine" created from "$_currentOriginalLine"',
      );
      return;
    }

    String xxContent = _getElement();

    if (xxContent.isEmpty) {
      _addError(
        'xxContent is empty',
        '_injectXTherionImageInsertConfig',
        'Line being parsed: "$_currentParseableLine" created from "$_currentOriginalLine"',
      );

      return;
    }

    String yyContent = _getElement();

    if (yyContent.isEmpty) {
      _addError(
        'yyContent is empty',
        '_injectXTherionImageInsertConfig',
        'Line being parsed: "$_currentParseableLine" created from "$_currentOriginalLine"',
      );

      return;
    }

    String filename = _getElement();

    if (filename.isEmpty) {
      _addError(
        'filename is empty',
        '_injectXTherionImageInsertConfig',
        'Line being parsed: "$_currentOriginalLine"',
      );

      return;
    }

    final int iidx = int.tryParse(_getFirstElement('\\s+')) ?? 0;

    String imgxContent = _getElement();

    List<String> splitData = xxContent.split(RegExp(r'\s+'));

    String vsb = '1';
    String igamma = '1.0';
    String xx = xxContent;

    if (splitData.length > 1) {
      xx = splitData[0];
      vsb = splitData[1];
      if (splitData.length > 2) {
        igamma = splitData[2];
      }
    }

    splitData = yyContent.split(RegExp(r'\s+'));

    String xviRoot = '';
    String yy = yyContent;

    if (splitData.length > 1) {
      yy = splitData[0];
      xviRoot = splitData[1];
    }

    splitData = imgxContent.split(RegExp(r'\s+'));

    String imgx = imgxContent;
    String xData = '';
    bool xImage = false;

    if (splitData.length > 1) {
      imgxContent = splitData[0];
      xImage = true;
      xData = splitData[1];
    }

    _currentElement = THXTherionImageInsertConfig.fromString(
      parentMPID: _currentParentMPID,
      filename: filename,
      xx: xx,
      vsb: vsb,
      igamma: igamma,
      yy: yy,
      xviRoot: xviRoot,
      iidx: iidx,
      imgx: imgx,
      xData: xData,
      xImage: xImage,
      originalLineInTH2File: _currentOriginalLine,
    );

    _th2FileElementEditController.executeAddElement(
      newElement: _currentElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
  }

  void _injectPoint(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize >= 3);
    }

    _checkParsedListAsPoint(element[1]);

    if (kDebugMode) {
      assert(element[2] is List);
      assert(element[2].length == 2);
    }

    if (kDebugMode) {
      assert(element[2] is List);
      assert(element[2].length == 2);
      assert(element[2][0] is String);
    }

    try {
      final THPoint newPoint = THPoint.fromString(
        parentMPID: _currentParentMPID,
        pointDataList: element[1],
        pointTypeString: element[2][0],
        originalLineInTH2File: _currentOriginalLine,
      );
      _th2FileElementEditController.executeAddElement(
        newElement: newPoint,
        parent: _currentParent,
        childPositionInParent: mpAddChildAtEndOfParentChildrenList,
      );

      _currentElement = newPoint;

      try {
        // Including subtype defined with type (type:subtype).
        if (element[2][1] != null) {
          MPEditElementAux.addOptionToElement(
            option: THSubtypeCommandOption(
              parentMPID: newPoint.mpID,
              subtype: element[2][1],
            ),
            element: newPoint,
          );
        }
      } catch (e, s) {
        _addError(
          "$e\n\nTrace:\n\n$s",
          '_injectLine',
          element[2][1].toString(),
        );
      }

      _optionFromElement(element[3], _pointRegularOptions);
    } catch (e, s) {
      _addError("$e\n\nTrace:\n\n$s", '_injectLine', element[2][1].toString());
    }
  }

  void _injectBezierCurveLineSegment(List<dynamic> element) {
    final int elementSize = element.length;
    if (kDebugMode) assert(elementSize == 2);

    final pointList = element[1];
    if (kDebugMode) {
      assert(pointList is List);
      assert(pointList.length == 3);
      assert(pointList[0][0] is String);
      assert(pointList[0][0] == 'controlpoint1');
      assert(pointList[0][1] is List);
      assert(pointList[0][1].length == 2);
      assert(pointList[1][0] is String);
      assert(pointList[1][0] == 'controlpoint2');
      assert(pointList[1][1] is List);
      assert(pointList[1][1].length == 2);
      assert(pointList[2][0] is String);
      assert(pointList[2][0] == 'endpoint');
      assert(pointList[2][1] is List);
      assert(pointList[2][1].length == 2);
    }

    final controlPoint1 = pointList[0][1];
    final controlPoint2 = pointList[1][1];
    final endPoint = pointList[2][1];

    _checkParsedListAsPoint(controlPoint1);
    _checkParsedListAsPoint(controlPoint2);
    _checkParsedListAsPoint(endPoint);

    final newBezierCurveLineSegment = THBezierCurveLineSegment.fromString(
      parentMPID: _currentParentMPID,
      controlPoint1: controlPoint1,
      controlPoint2: controlPoint2,
      endPoint: endPoint,
      originalLineInTH2File: _currentOriginalLine,
    );
    _th2FileElementEditController.executeAddElement(
      newElement: newBezierCurveLineSegment,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );

    _lastLineSegment = newBezierCurveLineSegment;

    /// Same line comments should be inserted in the line segment itself and not
    /// in the line command that includes this line segment.
    _currentElement = newBezierCurveLineSegment;
    _injectComment();
    _currentElement =
        newBezierCurveLineSegment.parent(_parsedTHFile) as THElement;
  }

  void _injectAreaBorderTHID(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize == 2);
    }

    final areaBorderID = element[1];

    if (kDebugMode) {
      assert(areaBorderID is String);
    }

    final THAreaBorderTHID newElement = THAreaBorderTHID(
      parentMPID: _currentParentMPID,
      thID: areaBorderID,
      originalLineInTH2File: _currentOriginalLine,
    );

    _th2FileElementEditController.executeAddElement(
      newElement: newElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
  }

  void _injectStraightLineSegment(List<dynamic> element) {
    final int elementSize = element.length;
    assert(elementSize == 2);

    final pointList = element[1];
    if (kDebugMode) {
      assert(pointList is List);
      assert(pointList.length == 2);
      assert(pointList[0] is String);
      assert(pointList[0] == 'endpoint');
      assert(pointList[1] is List);
      assert(pointList[1].length == 2);
    }

    final endPoint = pointList[1];

    _checkParsedListAsPoint(endPoint);

    final THStraightLineSegment newStraightLineSegment =
        THStraightLineSegment.fromString(
          parentMPID: _currentParentMPID,
          pointDataList: endPoint,
          originalLineInTH2File: _currentOriginalLine,
        );
    _th2FileElementEditController.executeAddElement(
      newElement: newStraightLineSegment,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );

    _lastLineSegment = newStraightLineSegment;

    /// Same line comments should be inserted in the line segment itself and not
    /// in the line command that includes this line segment.
    _currentElement = newStraightLineSegment;
    _injectComment();
    _currentElement = newStraightLineSegment.parent(_parsedTHFile) as THElement;
  }

  void _injectScrap(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) assert(elementSize >= 2);

    final THScrap newScrap = THScrap(
      parentMPID: _currentParentMPID,
      thID: element[1],
      originalLineInTH2File: _currentOriginalLine,
    );
    _th2FileElementEditController.executeAddElement(
      newElement: newScrap,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );

    _currentElement = newScrap;
    setCurrentParent(newScrap);

    // _parsedOptions.clear();
    _optionFromElement(element[2], _scrapRegularOptions);
    _addChildParser(_scrapContentParser);
  }

  void _injectEndScrap() {
    _currentElement = THEndscrap(
      parentMPID: _currentParentMPID,
      originalLineInTH2File: _currentOriginalLine,
    );
    _th2FileElementEditController.executeAddElement(
      newElement: _currentElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
    setCurrentParent((_currentParent as THElement).parent(_parsedTHFile));
    _returnToParentParser();
  }

  void _injectAreaCommandLikeOption(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize == 2);
      assert(element[1] is List);
      assert(element[1].length == 1);
      assert(element[1][0] is List);
    }

    _optionFromElement(element[1], _areaRegularOptions);
  }

  /// All line options (the ones that should be on the "line" line in the .th2
  /// file) can also appear as linepoint options (the ones that appear
  /// intermixed with line segments between the "line" and "endline" lines).
  /// Here we deall with them all, registering the line options that appeared as
  /// linepoint options in the line options list and keeping the linepoint
  /// options registered with the appropriate line segment.
  void _injectLineCommandLikeOption(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize == 2);
      assert(element[1] is List);
      assert(element[1].length == 1);
      assert(element[1][0] is List);
    }

    _optionFromElement(element[1], _lineSegmentRegularOptions);

    /// Same line comments should be inserted in the line segment to which this
    /// line segment option is related if there is a linepoint before it and not
    /// in the line command that includes this line segment option. If there is
    /// no linepoint before it, include it in the line it belongs to.
    if (_lastLineSegment != null) {
      _currentElement = _lastLineSegment!;
    }
    _injectComment();
    if (_lastLineSegment != null) {
      _currentElement = _lastLineSegment!.parent(_parsedTHFile) as THElement;
    }

    /// Reverting the change made by _lineSegmentRegularOptions().
    _currentHasOptions = _currentElement as THHasOptionsMixin;
  }

  void _injectArea(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize >= 2);
      assert(element[1] is List);
      assert(element[1].length == 2);
      assert(element[1][0] is String);
    }

    try {
      final THArea newArea = THArea.fromString(
        parentMPID: _currentParentMPID,
        areaTypeString: element[1][0],
        originalLineInTH2File: _currentOriginalLine,
      );
      _th2FileElementEditController.executeAddElement(
        newElement: newArea,
        parent: _currentParent,
        childPositionInParent: mpAddChildAtEndOfParentChildrenList,
      );

      _currentElement = newArea;
      setCurrentParent(newArea);

      try {
        // Including subtype defined with type (type:subtype).
        if ((element[1][1] != null) && (element[1][0] == 'u')) {
          MPEditElementAux.addOptionToElement(
            option: THSubtypeCommandOption(
              parentMPID: newArea.mpID,
              subtype: element[1][1],
            ),
            element: newArea,
          );
        }
      } catch (e, s) {
        _addError(
          "$e\n\nTrace:\n\n$s",
          '_injectArea',
          element[1][1].toString(),
        );
      }

      _optionFromElement(element[2], _areaRegularOptions);
      _addChildParser(_areaContentParser);
    } catch (e, s) {
      _addError("$e\n\nTrace:\n\n$s", '_injectArea', element[1][1].toString());
    }
  }

  void _injectLine(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize >= 2);
      assert(element[1] is List);
      assert(element[1].length == 2);
      assert(element[1][0] is String);
    }

    try {
      final THLine newLine = THLine.fromString(
        parentMPID: _currentParentMPID,
        lineTypeString: element[1][0],
        originalLineInTH2File: _currentOriginalLine,
      );
      _th2FileElementEditController.executeAddElement(
        newElement: newLine,
        parent: _currentParent,
        childPositionInParent: mpAddChildAtEndOfParentChildrenList,
      );

      _currentElement = newLine;
      setCurrentParent(newLine);

      try {
        // Including subtype defined with type (type:subtype).
        if (element[1][1] != null) {
          MPEditElementAux.addOptionToElement(
            option: THSubtypeCommandOption(
              parentMPID: newLine.mpID,
              subtype: element[1][1],
            ),
            element: newLine,
          );
        }
      } catch (e, s) {
        _addError(
          "$e\n\nTrace:\n\n$s",
          '_injectLine',
          element[1][1].toString(),
        );
      }

      _optionFromElement(element[2], _lineRegularOptions);
      _addChildParser(_lineContentParser);
      _lastLineSegment = null;
    } catch (e, s) {
      _addError("$e\n\nTrace:\n\n$s", '_injectLine', element[1][1].toString());
    }
  }

  void _injectEndArea() {
    _currentElement = THEndarea(
      parentMPID: _currentParentMPID,
      originalLineInTH2File: _currentOriginalLine,
    );
    _th2FileElementEditController.executeAddElement(
      newElement: _currentElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
    setCurrentParent((_currentParent as THElement).parent(_parsedTHFile));
    _returnToParentParser();
  }

  void _injectEndLine() {
    if (_currentParent is! THLine) {
      _addError(
        'endline without a line parent',
        '_injectEndLine',
        'Line being parsed: "$_currentParseableLine" created from "$_currentOriginalLine"',
      );
      setCurrentParent((_currentParent as THElement).parent(_parsedTHFile));

      return;
    }

    final List<int> lineSegmentMPIDs = (_currentParent as THLine)
        .getLineSegmentMPIDs(_parsedTHFile);

    if (lineSegmentMPIDs.length < 2) {
      final THLine lineToRemove = _currentParent as THLine;

      setCurrentParent((lineToRemove).parent(_parsedTHFile));
      _th2FileElementEditController.removeElement(lineToRemove);
    } else {
      _currentElement = THEndline(
        parentMPID: _currentParentMPID,
        originalLineInTH2File: _currentOriginalLine,
      );
      _th2FileElementEditController.executeAddElement(
        newElement: _currentElement,
        parent: _currentParent,
        childPositionInParent: mpAddChildAtEndOfParentChildrenList,
      );
      setCurrentParent((_currentParent as THElement).parent(_parsedTHFile));
    }

    _returnToParentParser();
  }

  void _injectComment() {
    final List<dynamic>? element = _commentContentToParse;

    if (element == null) {
      return;
    }

    if (element.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException('== 2', element);
    }

    if (element[0] is! String) {
      throw THCustomException(
        "Need string as comment type. Received '${element[0]}'.",
      );
    }

    if (element[1] is! String) {
      throw THCustomException(
        "Need string as comment content. Received '${element[1]}'.",
      );
    }

    if (element[1].indexOf('# ') == 0) {
      element[1] = element[1].substring(2);
    } else if (element[1].indexOf('#') == 0) {
      element[1] = element[1].substring(1);
    }

    switch (element[0]) {
      case 'fulllinecomment':
        final THElement newElement = THComment(
          parentMPID: _currentParentMPID,
          content: element[1],
          originalLineInTH2File: _currentOriginalLine,
        );
        _th2FileElementEditController.executeAddElement(
          newElement: newElement,
          parent: _currentParent,
          childPositionInParent: mpAddChildAtEndOfParentChildrenList,
        );
      case 'samelinecomment':
        if ((_currentElement.sameLineComment == null) ||
            _currentElement.sameLineComment!.isEmpty) {
          _currentElement.sameLineComment = element[1];
        } else {
          _currentElement.sameLineComment =
              '${_currentElement.sameLineComment!} | ${element[1]}';
        }
      default:
        final THElement newElement = THUnrecognizedCommand(
          parentMPID: _currentParentMPID,
          value: element,
        );
        _th2FileElementEditController.executeAddElement(
          newElement: newElement,
          parent: _currentParent,
          childPositionInParent: mpAddChildAtEndOfParentChildrenList,
        );
    }
  }

  void _optionFromElement(
    List<dynamic> element,
    Function(String) createRegularOption,
  ) {
    for (_currentOptions in element) {
      if (_currentOptions.length != 2) {
        throw THOptionsListWrongLengthError();
      }

      final String optionType = _currentOptions[0].toString().toLowerCase();

      // This "if null" is here to deal with command options that have optional
      // extra data, i.e, they might be defined alone. In these situations
      // _currentOptions[1] will be simply null. As we need a list in
      // _currentSpec we create a list with a null inside to represent the
      // null value we received from the parser.
      _currentSpec = _currentOptions[1] ?? [null];
      _currentHasOptions = _currentElement as THHasOptionsMixin;

      try {
        if (createRegularOption(optionType)) {
          continue;
        }

        final String errorMessage =
            "Unrecognized command option '$optionType'. This should never happen.";

        if (kDebugMode) {
          assert(false, errorMessage);
        }
        throw UnsupportedError(errorMessage);
      } catch (e, s) {
        _addError(
          "$e\n\nTrace:\n\n$s",
          '_optionFromElement',
          _currentOptions.toString(),
        );
      }
    }
  }

  void _optionParentAsTHLineSegment() {
    if (_lastLineSegment == null) {
      _addError(
        "Line segment option without a line segment.",
        '_optionParentAsTHLineSegment',
        _currentElement.toString(),
      );
      return;
    }

    /// Changing _currentHasOptions to the line segment that is the parent of
    /// of the linepoint option. This change will be reverted by
    /// _injectLineCommandLikeOption().
    _currentHasOptions = _lastLineSegment as THHasOptionsMixin;
  }

  void _optionParentAsCurrentElement() {
    _currentHasOptions = _currentElement as THHasOptionsMixin;
  }

  bool _areaRegularOptions(String optionType) {
    bool optionIdentified = true;

    switch (optionType) {
      case 'clip':
      case 'place':
      case 'visibility':
        _injectMultipleChoiceCommandOption(optionType);
      case 'attr':
        _injectAttrCommandOption();
      case 'context':
        _injectContextCommandOption();
      case 'endarea':
        _injectEndArea();
      case 'id':
        _injectIDCommandOption();
      default:
        optionIdentified = false;
    }

    return optionIdentified;
  }

  bool _lineRegularOptions(String optionType) {
    bool optionIdentified = true;

    switch (optionType) {
      case 'anchors':
      case 'border':
      case 'clip':
      case 'close':
      case 'direction':
      case 'gradient':
      case 'head':
      case 'outline':
      case 'place':
      case 'rebelays':
      case 'reverse':
      case 'visibility':
        _injectMultipleChoiceCommandOption(optionType);
      case 'attr':
        _injectAttrCommandOption();
      case 'context':
        _injectContextCommandOption();
      case 'height':
        _injectHeightCommandOption();
      case 'id':
        _injectIDCommandOption();
      case 'scale':
        _injectLineScaleCommandOption();
      case 'subtype':
        _injectSubtypeCommandOption();
      case 'text':
        _injectTextCommandOption();
      default:
        optionIdentified = false;
    }

    return optionIdentified;
  }

  bool _lineSegmentRegularOptions(String optionType) {
    bool optionIdentified = true;

    switch (optionType) {
      case 'direction':
      case 'gradient':
        _injectMultipleChoiceWithPointChoiceCommandOption(optionType);
      case 'adjust':
      case 'smooth':
        _optionParentAsTHLineSegment();
        _injectMultipleChoiceCommandOption(optionType);
      case 'altitude':
        _injectAltitudeCommandOption();
      case 'l-size':
        _injectLSizeCommandOption();
      case 'mark':
        _injectMarkCommandOption();
      case 'orientation':
        _optionParentAsTHLineSegment();
        _injectOrientationCommandOption();
      case 'subtype':
        _optionParentAsTHLineSegment();
        _injectSubtypeCommandOption();
      default:
        optionIdentified = false;
    }

    if (optionIdentified) {
      return true;
    }

    optionIdentified = _lineRegularOptions(optionType);

    return optionIdentified;
  }

  bool _pointRegularOptions(String optionType) {
    bool optionIdentified = true;

    switch (optionType) {
      case 'align':
      case 'clip':
      case 'place':
      case 'visibility':
        _injectMultipleChoiceCommandOption(optionType);
      case 'attr':
        _injectAttrCommandOption();
      case 'context':
        _injectContextCommandOption();
      case 'dist':
        _injectDistCommandOption();
      case 'id':
        _injectIDCommandOption();
      case 'explored':
        _injectExploredCommandOption();
      case 'extend':
        _injectExtendCommandOption();
      case 'from':
        _injectFromCommandOption();
      case 'name':
        _injectNameCommandOption();
      case 'orientation':
        _injectOrientationCommandOption();
      case 'scale':
        _injectPointScaleCommandOption();
      case 'scrap':
        _injectScrapCommandOption();
      case 'subtype':
        _injectSubtypeCommandOption();
      case 'text':
        _injectTextCommandOption();
      case 'value':
        _injectValueCommandOption();
      default:
        optionIdentified = false;
    }

    return optionIdentified;
  }

  bool _scrapRegularOptions(String optionType) {
    bool optionIdentified = true;

    switch (optionType) {
      case 'flip':
      case 'walls':
        _injectMultipleChoiceCommandOption(optionType);
      case 'attr':
        _injectAttrCommandOption();
      case 'author':
        _injectAuthorCommandOption();
      case 'copyright':
        _injectCopyrightCommandOption();
      case 'cs':
        _injectCSCommandOption();
      case 'projection':
        _injectProjectionCommandOption();
      case 'scale':
        _injectScrapScaleCommandOption();
      case 'sketch':
        _injectSketchCommandOption();
      case 'station-names':
        _injectStationNamesCommandOption();
      case 'stations':
        _injectStationsCommandOption();
      case 'title':
        _injectTitleCommandOption();
      default:
        optionIdentified = false;
    }

    return optionIdentified;
  }

  void setCurrentParent(THIsParentMixin parent) {
    _currentParent = parent;
    _currentParentMPID = parent.mpID;
  }

  void _injectMultipleChoiceWithPointChoiceCommandOption(String optionType) {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
        "One parameter required to create a '$optionType' option for a '${_currentHasOptions.elementType}'",
      );
    }

    if (_currentSpec[0] is! String) {
      throw THCustomException(
        "One string parameter required to create a '$optionType' option for a '${_currentHasOptions.elementType}'",
      );
    }

    if (_currentSpec[0] == 'point') {
      _optionParentAsTHLineSegment();
    } else {
      _optionParentAsCurrentElement();
    }

    switch (optionType) {
      case 'direction':
        MPEditElementAux.addOptionToElement(
          option: THLinePointDirectionCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'gradient':
        MPEditElementAux.addOptionToElement(
          option: THLinePointGradientCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      default:
        throw UnimplementedError();
    }
  }

  void _checkParsedListAsPoint(List<dynamic> list) {
    if (list.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 2',
        _currentSpec[1],
      );
    }
  }

  void _injectMultipleChoiceCommandOption(String type) {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
        "One parameter required to create a '$type' option for a '${_currentHasOptions.elementType}'",
      );
    }

    if (_currentSpec[0] is! String) {
      throw THCustomException(
        "One string parameter required to create a '$type' option for a '${_currentHasOptions.elementType}'",
      );
    }

    switch (type) {
      case 'adjust':
        MPEditElementAux.addOptionToElement(
          option: THAdjustCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'align':
        MPEditElementAux.addOptionToElement(
          option: THAlignCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'anchors':
        MPEditElementAux.addOptionToElement(
          option: THAnchorsCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'border':
        MPEditElementAux.addOptionToElement(
          option: THBorderCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'clip':
        MPEditElementAux.addOptionToElement(
          option: THClipCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'close':
        MPEditElementAux.addOptionToElement(
          option: THCloseCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'direction':
        MPEditElementAux.addOptionToElement(
          option: THLineDirectionCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'flip':
        MPEditElementAux.addOptionToElement(
          option: THFlipCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'gradient':
        MPEditElementAux.addOptionToElement(
          option: THLineGradientCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'head':
        MPEditElementAux.addOptionToElement(
          option: THHeadCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'outline':
        MPEditElementAux.addOptionToElement(
          option: THOutlineCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'place':
        MPEditElementAux.addOptionToElement(
          option: THPlaceCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'rebelays':
        MPEditElementAux.addOptionToElement(
          option: THRebelaysCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'reverse':
        MPEditElementAux.addOptionToElement(
          option: THReverseCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'smooth':
        MPEditElementAux.addOptionToElement(
          option: THSmoothCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'visibility':
        MPEditElementAux.addOptionToElement(
          option: THVisibilityCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'walls':
        MPEditElementAux.addOptionToElement(
          option: THWallsCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            choice: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      default:
        throw UnimplementedError();
    }
  }

  void _injectDistCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
        "One parameter required to create a 'dist' option for a '${_currentHasOptions.elementType}'",
      );
    }

    switch (_currentSpec.length) {
      case 1:
        MPEditElementAux.addOptionToElement(
          option: THDistCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            distance: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 2:
        MPEditElementAux.addOptionToElement(
          option: THDistCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            distance: _currentSpec[0],
            unit: _currentSpec[1],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      default:
        throw THCustomException(
          "Unsupported parameters for a 'point' 'dist' option: '${_currentSpec[0]}'.",
        );
    }
  }

  void _injectExploredCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
        "One parameter required to create a 'explored' option for a '${_currentHasOptions.elementType}'",
      );
    }

    switch (_currentSpec.length) {
      case 1:
        MPEditElementAux.addOptionToElement(
          option: THExploredCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            distance: _currentSpec[0],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 2:
        MPEditElementAux.addOptionToElement(
          option: THExploredCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            distance: _currentSpec[0],
            unit: _currentSpec[1],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      default:
        throw THCustomException(
          "Unsupported parameters for a 'point' 'explored' option: '${_currentSpec[0]}'.",
        );
    }
  }

  void _injectHeightCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
        "One parameter required to create a 'height' option for a '${_currentHasOptions.elementType}'",
      );
    }

    MPEditElementAux.addOptionToElement(
      option: THLineHeightCommandOption.fromString(
        parentMPID: _currentHasOptions.mpID,
        height: _currentSpec[0],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectContextCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCustomException(
        "Two parameteres are required to create a 'context' option for a '${_currentHasOptions.elementType}'",
      );
    }

    MPEditElementAux.addOptionToElement(
      option: THContextCommandOption(
        parentMPID: _currentHasOptions.mpID,
        elementType: _currentSpec[0],
        symbolType: _currentSpec[1],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectFromCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
        "One parameter required to create a 'dist' option for a '${_currentHasOptions.elementType}'",
      );
    }

    MPEditElementAux.addOptionToElement(
      option: THFromCommandOption(
        parentMPID: _currentHasOptions.mpID,
        station: _currentSpec[0],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectExtendCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
        "One parameter required to create a 'extend' option for a '${_currentHasOptions.elementType}'",
      );
    }

    MPEditElementAux.addOptionToElement(
      option: _currentSpec[0] == null
          ? THExtendCommandOption(
              parentMPID: _currentHasOptions.mpID,
              station: '',
            )
          : THExtendCommandOption(
              parentMPID: _currentHasOptions.mpID,
              station: _currentSpec[0],
              originalLineInTH2File: _currentOriginalLine,
            ),
      element: _currentHasOptions,
    );
  }

  void _injectIDCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
        "One parameter required to create a 'id' option for a '${_currentHasOptions.elementType}'",
      );
    }

    MPEditElementAux.addOptionToElement(
      option: THIDCommandOption(
        parentMPID: _currentHasOptions.mpID,
        thID: _currentSpec[0],
      ),
      element: _currentHasOptions,
    );
    _th2FileElementEditController.registerElementWithTHID(
      _currentHasOptions,
      _currentSpec[0],
    );
  }

  void _injectNameCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
        "One parameter required to create a 'name' option for a '${_currentHasOptions.elementType}'",
      );
    }

    MPEditElementAux.addOptionToElement(
      option: THNameCommandOption(
        parentMPID: _currentHasOptions.mpID,
        reference: _currentSpec[0],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectSketchCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 2',
        _currentSpec,
      );
    }

    if (_currentSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THSketchCommandOption (0)');
    }

    _checkParsedListAsPoint(_currentSpec[1]);

    final String filename = _parseTHString(_currentSpec[0]);

    MPEditElementAux.addOptionToElement(
      option: THSketchCommandOption.fromString(
        parentMPID: _currentHasOptions.mpID,
        filename: filename,
        pointList: _currentSpec[1],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectStationNamesCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 2',
        _currentSpec,
      );
    }

    MPEditElementAux.addOptionToElement(
      option: THStationNamesCommandOption(
        parentMPID: _currentHasOptions.mpID,
        prefix: _currentSpec[0],
        suffix: _currentSpec[1],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectStationsCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 1',
        _currentSpec,
      );
    }

    final List<String> stations = _currentSpec[0].toString().split(',');

    if (stations.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException('> 0', stations);
    }

    MPEditElementAux.addOptionToElement(
      option: THStationsCommandOption(
        parentMPID: _currentHasOptions.mpID,
        stations: stations,
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectLSizeCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 2',
        _currentSpec,
      );
    }

    _optionParentAsTHLineSegment();
    MPEditElementAux.addOptionToElement(
      option: THLSizeCommandOption.fromString(
        parentMPID: _currentHasOptions.mpID,
        number: _currentSpec[0],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectMarkCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 2',
        _currentSpec,
      );
    }

    _optionParentAsTHLineSegment();
    MPEditElementAux.addOptionToElement(
      option: THMarkCommandOption(
        parentMPID: _currentHasOptions.mpID,
        mark: _currentSpec[0],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectAuthorCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 2',
        _currentSpec,
      );
    }

    MPEditElementAux.addOptionToElement(
      option: THAuthorCommandOption.fromString(
        parentMPID: _currentHasOptions.mpID,
        datetime: _currentSpec[0],
        person: _currentSpec[1],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectSubtypeCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 1',
        _currentSpec,
      );
    }

    MPEditElementAux.addOptionToElement(
      option: THSubtypeCommandOption(
        parentMPID: _currentHasOptions.mpID,
        subtype: _currentSpec[0],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectPointScaleCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 2',
        _currentSpec,
      );
    }

    switch (_currentSpec[0]) {
      case 'numeric':
        MPEditElementAux.addOptionToElement(
          option: THPLScaleCommandOption.sizeAsNumberFromString(
            parentMPID: _currentHasOptions.mpID,
            numericScaleSize: _currentSpec[1],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'multiplechoice':
        MPEditElementAux.addOptionToElement(
          option: THPLScaleCommandOption.sizeAsNamed(
            parentMPID: _currentHasOptions.mpID,
            textScaleSize: _currentSpec[1],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      default:
        throw THCustomException(
          "Unknown point scale mode '${_currentSpec[0]}'",
        );
    }
  }

  void _injectLineScaleCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 2',
        _currentSpec,
      );
    }

    switch (_currentSpec[0]) {
      case 'numeric':
        MPEditElementAux.addOptionToElement(
          option: THPLScaleCommandOption.sizeAsNumberFromString(
            parentMPID: _currentHasOptions.mpID,
            numericScaleSize: _currentSpec[1],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      case 'multiplechoice':
        MPEditElementAux.addOptionToElement(
          option: THPLScaleCommandOption.sizeAsNamed(
            parentMPID: _currentHasOptions.mpID,
            textScaleSize: _currentSpec[1],
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
      default:
        throw THCustomException(
          "Unknown point scale mode '${_currentSpec[0]}'",
        );
    }
  }

  void _injectScrapCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
        "One parameter required to create a 'scrap' option for a '${_currentHasOptions.elementType}'",
      );
    }

    MPEditElementAux.addOptionToElement(
      option: THScrapCommandOption(
        parentMPID: _currentHasOptions.mpID,
        reference: _currentSpec[0],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectOrientationCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 1',
        _currentSpec,
      );
    }

    MPEditElementAux.addOptionToElement(
      option: THOrientationCommandOption.fromString(
        parentMPID: _currentHasOptions.mpID,
        azimuth: _currentSpec[0],
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectCopyrightCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 2',
        _currentSpec,
      );
    }

    final String message = _parseTHString(_currentSpec[1]);

    MPEditElementAux.addOptionToElement(
      option: THCopyrightCommandOption.fromString(
        parentMPID: _currentHasOptions.mpID,
        datetime: _currentSpec[0],
        copyrightMessage: message,
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectCSCommandOption() {
    if (_currentSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THCSCommandOption');
    }

    MPEditElementAux.addOptionToElement(
      option: THCSCommandOption.fromString(
        parentMPID: _currentHasOptions.mpID,
        csString: _currentSpec[0],
        forOutputOnly: false,
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectAttrCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 2',
        _currentSpec,
      );
    }

    final String name = _parseTHString(_currentSpec[0]);
    final String value = _parseTHString(_currentSpec[1]);

    MPEditElementAux.addOptionToElement(
      option: THAttrCommandOption(
        parentMPID: _currentHasOptions.mpID,
        attrName: name,
        attrValue: value,
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectTitleCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 1',
        _currentSpec,
      );
    }

    final String stringContent = _parseTHString(_currentSpec[0]);

    MPEditElementAux.addOptionToElement(
      option: THTitleCommandOption(
        parentMPID: _currentHasOptions.mpID,
        titleText: stringContent,
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectTextCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
        '== 1',
        _currentSpec,
      );
    }

    final String stringContent = _parseTHString(_currentSpec[0]);

    MPEditElementAux.addOptionToElement(
      option: THTextCommandOption(
        parentMPID: _currentHasOptions.mpID,
        textContent: stringContent,
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectValueCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
        '!= 1',
        _currentSpec,
      );
    }

    final THPointType pointType = (_currentHasOptions as THPoint).pointType;

    switch (pointType) {
      case THPointType.altitude:
        _injectAltitudeValueCommandOption();
      case THPointType.date:
        _injectDateValueCommandOption();
      case THPointType.dimensions:
        _injectDimensionsValueCommandOption();
      case THPointType.height:
        _injectHeightValueCommandOption();
      case THPointType.passageHeight:
        _injectPassageHeightValueCommandOption();
      default:
        throw THCustomException(
          "Unsupported point type '$pointType' for option 'value'.",
        );
    }
  }

  void _injectAltitudeCommandOption() {
    String specs = _currentSpec[0].toString().trim();

    _optionParentAsTHLineSegment();
    if (hyphenPointRegex.hasMatch(specs) || nanRegex.hasMatch(specs)) {
      MPEditElementAux.addOptionToElement(
        option: THAltitudeCommandOption.fromNan(
          parentMPID: _currentHasOptions.mpID,
          originalLineInTH2File: _currentOriginalLine,
        ),
        element: _currentHasOptions,
      );
    } else if (fixNumberLengthUnitRegex.hasMatch(specs)) {
      final bool isFix = specs.trim().toLowerCase().startsWith('fix');

      if (isFix) {
        specs = specs.substring(3).trim();
      }

      final RegExpMatch match = fixNumberLengthUnitRegex.firstMatch(specs)!;
      final String number = "${match.group(1)!}${match.group(2)!}";

      MPEditElementAux.addOptionToElement(
        option: THAltitudeCommandOption.fromString(
          parentMPID: _currentHasOptions.mpID,
          height: number,
          isFix: isFix,
          unit: match.group(3),
          originalLineInTH2File: _currentOriginalLine,
        ),
        element: _currentHasOptions,
      );
    }
  }

  void _injectAltitudeValueCommandOption() {
    String specs = _currentSpec[0].toString().trim();

    if (hyphenPointRegex.hasMatch(specs) || nanRegex.hasMatch(specs)) {
      MPEditElementAux.addOptionToElement(
        option: THAltitudeValueCommandOption.fromNan(
          parentMPID: _currentHasOptions.mpID,
          originalLineInTH2File: _currentOriginalLine,
        ),
        element: _currentHasOptions,
      );
    } else if (fixNumberLengthUnitRegex.hasMatch(specs)) {
      final bool isFix = specs.trim().toLowerCase().startsWith('fix');

      if (isFix) {
        specs = specs.substring(3).trim();
      }

      final RegExpMatch match = fixNumberLengthUnitRegex.firstMatch(specs)!;
      final String height = "${match.group(1)!}${match.group(2)!}";

      MPEditElementAux.addOptionToElement(
        option: THAltitudeValueCommandOption.fromString(
          parentMPID: _currentHasOptions.mpID,
          height: height,
          isFix: isFix,
          unit: match.group(3),
          originalLineInTH2File: _currentOriginalLine,
        ),
        element: _currentHasOptions,
      );
    } else {
      throw THCustomException(
        "Unsuported parse specs '$specs' in '_injectAltitudeValueCommandOption'.",
      );
    }
  }

  void _injectDateValueCommandOption() {
    final List<RegExp> dateValueRegexes = [
      hyphenRegex,
      singleDateTimeRegex,
      dateTimeRangeRegex,
    ];
    final String specs = _currentSpec[0].toString().trim();

    for (final RegExp regex in dateValueRegexes) {
      if (regex.hasMatch(specs)) {
        MPEditElementAux.addOptionToElement(
          option: THDateValueCommandOption.fromString(
            parentMPID: _currentHasOptions.mpID,
            datetime: specs,
            originalLineInTH2File: _currentOriginalLine,
          ),
          element: _currentHasOptions,
        );
        return;
      }
    }

    throw THCustomException(
      "Unsuported value '$specs' in '_injectDateValueCommandOption'.",
    );
  }

  void _injectDimensionsValueCommandOption() {
    final String specs = _currentSpec[0].toString().trim();

    if (twoNumbersWithOptionalUnitRegex.hasMatch(specs)) {
      final RegExpMatch match = twoNumbersWithOptionalUnitRegex.firstMatch(
        specs,
      )!;

      MPEditElementAux.addOptionToElement(
        option: THDimensionsValueCommandOption.fromString(
          parentMPID: _currentHasOptions.mpID,
          above: match.group(1)!,
          below: match.group(2)!,
          unit: match.group(3),
          originalLineInTH2File: _currentOriginalLine,
        ),
        element: _currentHasOptions,
      );
    } else {
      throw THCustomException(
        "Unsuported parse specs '$specs' in '_injectDimensionsValueCommandOption'.",
      );
    }
  }

  void _injectHeightValueCommandOption() {
    final String specs = _currentSpec[0].toString().trim();

    if (signedNumberPresumedUnitRegex.hasMatch(specs)) {
      final RegExpMatch match = signedNumberPresumedUnitRegex.firstMatch(
        specs,
      )!;
      final String number = "${match.group(1)!}${match.group(2)!}";

      MPEditElementAux.addOptionToElement(
        option: THPointHeightValueCommandOption.fromString(
          parentMPID: _currentHasOptions.mpID,
          height: number,
          isPresumed: match.group(3) != null,
          unit: match.group(4),
          originalLineInTH2File: _currentOriginalLine,
        ),
        element: _currentHasOptions,
      );
    } else {
      throw THCustomException(
        "Unsuported parse specs '$specs' in '_injectHeightValueCommandOption'.",
      );
    }
  }

  void _injectPassageHeightValueCommandOption() {
    final String specs = _currentSpec[0].toString().trim();

    if (signedNumberWithOptionalUnitRegex.hasMatch(specs)) {
      final RegExpMatch match = signedNumberWithOptionalUnitRegex.firstMatch(
        specs,
      )!;
      final String number = "${match.group(1)!}${match.group(2)!}";

      MPEditElementAux.addOptionToElement(
        option: THPassageHeightValueCommandOption.fromString(
          parentMPID: _currentHasOptions.mpID,
          plusNumber: number,
          minusNumber: '',
          unit: match.group(3),
          originalLineInTH2File: _currentOriginalLine,
        ),
        element: _currentHasOptions,
      );
    } else if (plusMinusNumbersWithOptionalUnitRegex.hasMatch(specs)) {
      final RegExpMatch match = plusMinusNumbersWithOptionalUnitRegex
          .firstMatch(specs)!;
      MPEditElementAux.addOptionToElement(
        option: THPassageHeightValueCommandOption.fromString(
          parentMPID: _currentHasOptions.mpID,
          plusNumber: match.group(1)!,
          minusNumber: match.group(2)!,
          unit: match.group(3),
          originalLineInTH2File: _currentOriginalLine,
        ),
        element: _currentHasOptions,
      );
    } else {
      throw THCustomException(
        "Unsupported parse specs '$specs' in '_injectPassageHeightValueCommandOption'.",
      );
    }
  }

  String _parseTHString(String stringToParse) {
    final String parsed = stringToParse.replaceAll(
      _doubleQuoteRegex,
      thDoubleQuote,
    );

    return parsed;
  }

  // ignore: unused_element
  void _injectUnrecognizedCommandOption() {
    throw THCustomException(
      "Creating THUnrecognizedCommandOption!!. Parameters available:\n\n'${_currentSpec.toString()}'\n\n",
    );
    // THUnrecognizedCommandOption(_currentHasOptions, aSpec.toString());
  }

  void _addError(String errorMessage, String location, String localInfo) {
    final String completeErrorMessage =
        "'$errorMessage' at '$location' with '$localInfo' local info.";

    _parseErrors.add(completeErrorMessage);
  }

  void _injectScrapScaleCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException('> 0', _currentSpec);
    }

    final List<THDoublePart> values = [];
    THLengthUnitPart unit = THLengthUnitPart.fromString(
      unitString: thDefaultLengthUnitAsString,
    );

    for (final value in _currentSpec) {
      final double? newDouble = double.tryParse(value);

      if (newDouble == null) {
        if (values.isEmpty) {
          throw THCustomException(
            "Can´t create THScaleCommandOption object without any value.",
          );
        }
        unit = THLengthUnitPart.fromString(unitString: value);
      } else {
        values.add(THDoublePart.fromString(valueString: value));
      }
    }

    MPEditElementAux.addOptionToElement(
      option: THScrapScaleCommandOption(
        parentMPID: _currentHasOptions.mpID,
        numericSpecifications: values,
        unitPart: unit,
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectProjectionCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException('> 0', _currentSpec);
    }

    if (_currentSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THProjectionCommandOption');
    }

    Map<String, dynamic> projectionExtraMap = <String, dynamic>{};

    if (_currentSpec[1] is Map) {
      final map = _currentSpec[1] as Map;

      if (map.isNotEmpty) {
        projectionExtraMap = _currentSpec[1] as Map<String, dynamic>;
      }
    }

    final String index = projectionExtraMap.containsKey('index')
        ? projectionExtraMap['index'] as String
        : '';
    final String? elevationAngle = projectionExtraMap.containsKey('angle')
        ? projectionExtraMap['angle'] as String
        : null;
    final String? elevationAngleUnit =
        projectionExtraMap.containsKey('angle_unit')
        ? projectionExtraMap['angle_unit'] as String
        : null;

    MPEditElementAux.addOptionToElement(
      option: THProjectionCommandOption.fromString(
        parentMPID: _currentHasOptions.mpID,
        projectionType: _currentSpec[0],
        index: index,
        elevationAngle: elevationAngle,
        elevationUnit: elevationAngleUnit,
        originalLineInTH2File: _currentOriginalLine,
      ),
      element: _currentHasOptions,
    );
  }

  void _injectUnknown(List<dynamic> element) {
    final THElement newElement = THUnrecognizedCommand(
      parentMPID: _currentParentMPID,
      value: element,
      originalLineInTH2File: _currentOriginalLine,
    );

    _th2FileElementEditController.executeAddElement(
      newElement: newElement,
      parent: _currentParent,
      childPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );
  }

  @useResult
  String _decodeFile(Uint8List fileContentRaw, String encoding) {
    String fileContentDecoded = '';

    switch (encoding) {
      case 'UTF-8':
        fileContentDecoded = utf8.decode(fileContentRaw);
      case 'ASCII':
        fileContentDecoded = ascii.decode(fileContentRaw);
      case 'ISO8859-1':
        fileContentDecoded = latin1.decode(fileContentRaw);
      default:
        // Therion ISO charset names don´t have a hyphen after ISO but
        // charset.dart expects one.
        final RegExpMatch? isoResult = _isoRegex.firstMatch(encoding);

        if (isoResult != null) {
          encoding = 'ISO-${isoResult[1]}';
        }

        final Encoding? encoder = Charset.getByName(encoding);

        if (encoder == null) {
          fileContentDecoded = utf8.decode(fileContentRaw);
        } else {
          fileContentDecoded = encoder.decode(fileContentRaw);
        }
    }

    return fileContentDecoded;
  }

  @useResult
  String _encodingNameFromFile(Uint8List fileContentRaw) {
    String line = '';
    int byte;
    String priorChar = '';
    int charsRead = 0;

    for (
      int i = 0;
      ((i < fileContentRaw.length) && (charsRead < thMaxEncodingLength));
      i++
    ) {
      byte = fileContentRaw[i];

      if (byte == -1) {
        break;
      }

      charsRead++;

      final String char = utf8.decode([byte]);

      if (_isEncodingDelimiter(priorChar, char)) {
        break;
      }

      line += char;
      priorChar = char;
    }
    // mpLocator.mpLog.finer("Line read: '$line'");

    final RegExpMatch? encoding = _encodingRegex.firstMatch(line);

    // mpLocator.mpLog.finer("Encoding object: '$encoding");

    return (encoding == null) ? mpDefaultEncoding : encoding[1]!.toUpperCase();
  }

  @useResult
  bool _isEncodingDelimiter(String priorChar, String char) {
    if (char == thCommentChar) {
      return true;
    }

    if ((priorChar + char) == thWindowsLineBreak) {
      _parsedTHFile.lineEnding = thWindowsLineBreak;
      return true;
    }

    if (char == thUnixLineBreak) {
      _parsedTHFile.lineEnding = thUnixLineBreak;
      return true;
    }

    return false;
  }

  @useResult
  Future<(THFile, bool, List<String>)> parse(
    String filename, {
    Uint8List? fileBytes,
    Parser? alternateStartParser,
    bool trace = false,
    bool forceNewController = true,
  }) async {
    if (alternateStartParser == null) {
      _newRootParser(_th2FileFirstLineParser);
      _resetParsersLineage();
      _newRootParser(_th2FileParser);
    } else {
      _newRootParser(alternateStartParser);
      _resetParsersLineage();
    }
    _runTraceParser = trace;

    _th2FileEditController = mpLocator.mpGeneralController
        .getTH2FileEditController(
          filename: filename,
          forceNewController: forceNewController,
        );
    _th2FileElementEditController =
        _th2FileEditController.elementEditController;
    _parsedTHFile = _th2FileEditController.thFile;
    setCurrentParent(_parsedTHFile);
    _parseErrors.clear();

    try {
      if (fileBytes == null) {
        final File file = File(filename);

        assert(
          await file.exists(),
          'The file to parse does not exist: $filename',
        );

        fileBytes = await file.readAsBytes();
      }

      _parsedTHFile.encoding = _encodingNameFromFile(fileBytes);

      String contents = _decodeFile(fileBytes, _parsedTHFile.encoding);

      fileBytes = null;

      _splitContents(contents);
    } catch (e) {
      mpLocator.mpLog.e('Failed to read file', error: e);
    }

    _injectContents();
    _cleanEmptyAreas(_parsedTHFile);

    if (!(_parsedTHFile).isSameClass(_currentParent) ||
        (_currentParent != _parsedTHFile)) {
      _addError(
        'Multiline commmands left open at end of file',
        'parse',
        'Unclosed multiline command: "${_currentParent.toString()}"',
      );
    }

    return (
      _th2FileElementEditController.thFile,
      _parseErrors.isEmpty,
      _parseErrors,
    );
  }

  (int index, int length) _findLineBreak(String content) {
    final int windowsResult = content.indexOf(thWindowsLineBreak);

    if (windowsResult != -1) {
      return (windowsResult, 2);
    }

    final int unixResult = content.indexOf(thUnixLineBreak);

    if (unixResult != -1) {
      return (unixResult, 1);
    }

    return (-1, 0);
  }

  void _cleanEmptyAreas(THIsParentMixin parent) {
    final List<THElement> children = parent.getChildren(_parsedTHFile).toList();

    for (final THElement child in children) {
      if (child is THArea) {
        final List<int> areaChildrenMPIDs = child.childrenMPIDs.toList();

        int validBorders = 0;

        for (final int areaChildMPID in areaChildrenMPIDs) {
          final THElement areaChild = _parsedTHFile.elementByMPID(
            areaChildMPID,
          );

          if (areaChild is! THAreaBorderTHID) {
            continue;
          }

          if (_parsedTHFile.hasElementByTHID(areaChild.thID) &&
              (_parsedTHFile.elementByTHID(areaChild.thID) is THLine)) {
            validBorders++;
          } else {
            _th2FileElementEditController.removeElement(areaChild);
          }
        }

        if (validBorders == 0) {
          _th2FileElementEditController.removeElement(child);
        }
      } else if (child is THIsParentMixin) {
        _cleanEmptyAreas(child as THIsParentMixin);
      }
    }
  }

  void _splitContents(String contents) {
    _splittedContents.clear();
    _continuationDelimiter = '';

    while (contents.isNotEmpty) {
      var (lineBreakIndex, lineBreakLength) = _findLineBreak(contents);

      if (lineBreakIndex == -1) {
        _splittedContents.add(
          MPParseableLine(toParse: contents, originalContent: contents),
        );

        contents = '';

        break;
      }

      String currentLine = contents.substring(0, lineBreakIndex);
      String newContentOriginal = contents.substring(
        0,
        lineBreakIndex + lineBreakLength,
      );
      updateContinuationDelimiter(currentLine);

      /// If the line is ending with an open double qoute (") or square bracket
      /// (]) the line break should be kept as part of the delimited content.
      /// Otherwise, the line break shouldn't be included in the content to
      /// parse.
      String newContentToParse =
          (_continuationDelimiter == '"' || _continuationDelimiter == ']')
          ? newContentOriginal
          : currentLine;

      contents = contents.substring(lineBreakIndex + lineBreakLength);
      if (currentLine.isEmpty) {
        _splittedContents.add(
          MPParseableLine(
            toParse: newContentToParse,
            originalContent: newContentOriginal,
          ),
        );

        continue;
      }

      /// Joining lines that didn´t end, i.e., that have an open double quote or
      /// square bracket or that ends with a backslash.
      while (_continuationDelimiter.isNotEmpty && contents.isNotEmpty) {
        (lineBreakIndex, lineBreakLength) = _findLineBreak(contents);

        if (lineBreakIndex == -1) {
          newContentOriginal += contents;
          newContentToParse += contents;
          contents = '';

          break;
        }

        currentLine = contents.substring(0, lineBreakIndex);
        String currentContentOriginal = contents.substring(
          0,
          lineBreakIndex + lineBreakLength,
        );
        newContentOriginal += currentContentOriginal;
        if (_continuationDelimiter == '\\') {
          newContentToParse = newContentToParse.substring(
            0,
            newContentToParse.length - 1,
          );
        }

        contents = contents.substring(lineBreakIndex + lineBreakLength);
        if (currentLine.isEmpty) {
          if (_continuationDelimiter == '\\') {
            break;
          }

          continue;
        }

        updateContinuationDelimiter(currentLine);
        newContentToParse +=
            (_continuationDelimiter == '"' || _continuationDelimiter == ']')
            ? currentContentOriginal
            : currentLine;
      }

      _splittedContents.add(
        MPParseableLine(
          toParse: newContentToParse,
          originalContent: newContentOriginal,
        ),
      );
    }
  }

  /// Returns the reason why the line continues:
  /// * " for double quotes;
  /// * ] for square brackets;
  /// * \ for backslash.
  ///
  /// Returns an empty string if the line does not continue.
  String updateContinuationDelimiter(String text) {
    if (_continuationDelimiter == '\\') {
      _continuationDelimiter = '';
    }

    for (int i = 0; i < text.length; i++) {
      final String currentChar = text[i];

      if (_continuationDelimiter.isEmpty) {
        if (currentChar == '"') {
          _continuationDelimiter = '"';
        } else if (currentChar == '[') {
          _continuationDelimiter = ']';
        } else if (currentChar == '\\') {
          if (i == text.trimRight().length - 1) {
            _continuationDelimiter = '\\';

            break;
          }
        }
      } else {
        if (_continuationDelimiter == '"') {
          if (currentChar == '"') {
            if ((i + 1 < text.length) && (text[i + 1] == '"')) {
              i++;
            } else {
              _continuationDelimiter = '';
            }
          }
        } else if (_continuationDelimiter == ']') {
          if (currentChar == ']') {
            _continuationDelimiter = '';
          }
        }
      }
    }

    return _continuationDelimiter;
  }
}

class MPParseableLine {
  final String toParse;
  final String originalContent;

  MPParseableLine({required this.toParse, required this.originalContent});
}
