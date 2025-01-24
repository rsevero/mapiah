import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/elements/th_area.dart';
import 'package:mapiah/src/elements/th_area_border_thid.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/command_options/th_altitude_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_altitude_value_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_author_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_clip_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_context_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_copyright_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_cs_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_date_value_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_dimensions_value_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_dist_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_explored_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_extend_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_from_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_line_height_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_point_height_value_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_id_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_line_scale_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_lsize_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_mark_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_multiple_choice_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_name_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_orientation_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_passage_height_value_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_point_scale_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_projection_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_scrap_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_scrap_scale_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_sketch_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_station_names_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_stations_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_subtype_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_text_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_title_command_option.dart';
import 'package:mapiah/src/elements/th_comment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_empty_line.dart';
import 'package:mapiah/src/elements/th_encoding.dart';
import 'package:mapiah/src/elements/th_endarea.dart';
import 'package:mapiah/src/elements/th_endcomment.dart';
import 'package:mapiah/src/elements/th_endline.dart';
import 'package:mapiah/src/elements/th_endscrap.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_multiline_comment_content.dart';
import 'package:mapiah/src/elements/th_multilinecomment.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/elements/th_unrecognized_command.dart';
import 'package:mapiah/src/elements/th_xtherion_config.dart';
import 'package:mapiah/src/errors/th_options_list_wrong_length_error.dart';
import 'package:mapiah/src/exceptions/th_create_object_from_empty_list_exception.dart';
import 'package:mapiah/src/exceptions/th_create_object_from_null_value_exception.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/exceptions/th_custom_with_list_parameter_exception.dart';
import 'package:mapiah/src/stores/mp_general_store.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/th_file_read_write/th_file_aux.dart';
import 'package:mapiah/src/th_file_read_write/th_grammar.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:meta/meta.dart';
import 'package:charset/charset.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';

class THFileParser {
  final _grammar = THGrammar();

  late final Parser _areaContentParser;
  late final Parser _lineContentParser;
  late final Parser _multiLineCommentContentParser;
  late final Parser _scrapContentParser;
  late final Parser _th2FileFirstLineParser;
  late final Parser _th2FileParser;

  final List<Parser> _parentParsers = [];

  late Parser _rootParser;
  late Parser _currentParser;

  late List<String> _splittedContents;
  late Result<dynamic> _parsedContents;
  late List<dynamic>? _commentContentToParse;
  late THParent _currentParent;
  late int _currentParentMapiahID;
  late THElement _currentElement;
  late THHasOptions _currentHasOptions;
  THLineSegment? _lastLineSegment;
  late List<dynamic> _currentOptions;
  late List<dynamic> _currentSpec;
  // final _parsedOptions = HashSet<String>();
  bool _runTraceParser = false;

  late THFile _parsedTHFile;
  late THFileStore _thFileStore;

  final List<String> _parseErrors = [];

  final _doubleQuoteRegex = RegExp(thDoubleQuotePair);
  final _encodingRegex =
      RegExp(r'^\s*encoding\s+([a-zA-Z0-9-]+)', caseSensitive: false);
  final _isoRegex = RegExp(r'^iso([^_-].*)', caseSensitive: false);

  THFileParser() {
    _areaContentParser = _grammar.buildFrom(_grammar.areaStart());
    _lineContentParser = _grammar.buildFrom(_grammar.lineStart());
    _multiLineCommentContentParser =
        _grammar.buildFrom(_grammar.multiLineCommentStart());
    _scrapContentParser = _grammar.buildFrom(_grammar.scrapStart());
    _th2FileFirstLineParser =
        _grammar.buildFrom(_grammar.th2FileFirstLineStart());
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

    for (String line in _splittedContents) {
      if (line.trim().isEmpty) {
        _injectEmptyLine();
        continue;
      }
      if (_runTraceParser) {
        trace(_currentParser).parse(line);
      }

      _parsedContents = _currentParser.parse(line);
      // trace(_currentParser).parse(line);
      if (isFirst) {
        isFirst = false;
        _resetParsersLineage();
      }
      if (_parsedContents is Failure) {
        // trace(_currentParser).parse(line);
        _addError('petitparser returned a "Failure"', '_injectContents()',
            'Line being parsed: "$line"');
        continue;
      }

      /// '_parsedContents' holds the complete result of the grammar parsing on
      /// 'line'.
      /// 'element' holds the the 'command' part of the parsed line, i.e., the
      /// content minus the eventual comment.
      final element = _parsedContents.value[0];
      if (element.isEmpty) {
        _addError('element.isEmpty', '_injectContents()',
            'Line being parsed: "$line"');
        continue;
      }

      _commentContentToParse = ((_parsedContents.value is List) &&
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
          _injectEndarea();
        case 'endmultilinecomment':
          _injectEndMultiLineComment();
        case 'endline':
          _injectEndline();
        case 'endscrap':
          _injectEndscrap();
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
        case 'straightlinesegment':
          _injectStraightLineSegment(element);

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
    _currentElement = THEmptyLine(parentMapiahID: _currentParentMapiahID);
    _thFileStore.addElementWithParent(_currentElement, _currentParent);
  }

  void _injectMultiLineCommentContent(List<dynamic> element) {
    final content = (element.isEmpty) ? '' : element[1].toString();
    _currentElement = THMultilineCommentContent(
      parentMapiahID: _currentParentMapiahID,
      content: content,
    );
    _thFileStore.addElementWithParent(_currentElement, _currentParent);
  }

  void _injectEndMultiLineComment() {
    _currentElement = THEndcomment(parentMapiahID: _currentParentMapiahID);
    _thFileStore.addElementWithParent(_currentElement, _currentParent);
    setCurrentParent((_currentParent as THElement).parent(_parsedTHFile));
    _returnToParentParser();
  }

  void _injectStartMultiLineComment() {
    _currentElement =
        THMultiLineComment(parentMapiahID: _currentParentMapiahID);
    _thFileStore.addElementWithParent(_currentElement, _currentParent);
    setCurrentParent(_currentElement as THParent);
    _addChildParser(_multiLineCommentContentParser);
  }

  void _injectEncoding(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize == 2);
      assert(element[1] is String);
    }

    _currentElement = THEncoding(
      parentMapiahID: _currentParentMapiahID,
      encoding: element[1],
    );
    _thFileStore.addElementWithParent(_currentElement, _currentParent);
  }

  void _injectXTherionSetting(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize == 2);
      assert(element[1] is List);
      assert(element[1].length == 2);
    }

    final THXTherionConfig newElement = THXTherionConfig(
      parentMapiahID: _currentParentMapiahID,
      name: element[1][0],
      value: element[1][1],
    );
    _thFileStore.addElementWithParent(newElement, _currentParent);
  }

  void _injectPoint(List<dynamic> element) {
    final int elementSize = element.length;
    if (kDebugMode) assert(elementSize >= 3);

    _checkParsedListAsPoint(element[1]);

    if (kDebugMode) {
      assert(element[2] is List);
      assert(element[2].length == 2);
    }

    final THPoint newPoint = THPoint.fromString(
      parentMapiahID: _currentParentMapiahID,
      pointDataList: element[1],
      pointType: element[2][0],
    );
    _thFileStore.addElementWithParent(newPoint, _currentParent);

    _currentElement = newPoint;
    // _parsedOptions.clear();

    try {
      // Including subtype defined with type (type:subtype).
      if (element[2][1] != null) {
        THSubtypeCommandOption(optionParent: newPoint, subtype: element[2][1]);
        // _parsedOptions.add('subtype');
      }
    } catch (e, s) {
      _addError("$e\n\nTrace:\n\n$s", '_pointOptionFromElement',
          element[2][1].toString());
    }

    _optionFromElement(element[3], _pointRegularOptions);
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
      parentMapiahID: _currentParentMapiahID,
      controlPoint1: controlPoint1,
      controlPoint2: controlPoint2,
      endPoint: endPoint,
    );
    _thFileStore.addElementWithParent(
        newBezierCurveLineSegment, _currentParent);

    // _currentElement = newBezierCurveLineSegment;
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
    if (kDebugMode) assert(elementSize == 2);

    final areaBorderID = element[1];
    if (kDebugMode) assert(areaBorderID is String);

    final THAreaBorderTHID newElement = THAreaBorderTHID(
      parentMapiahID: _currentParentMapiahID,
      id: areaBorderID,
    );
    _thFileStore.addElementWithParent(newElement, _currentParent);
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
      parentMapiahID: _currentParentMapiahID,
      pointDataList: endPoint,
    );
    _thFileStore.addElementWithParent(newStraightLineSegment, _currentParent);

    // _currentElement = newStraightLineSegment;
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
      parentMapiahID: _currentParentMapiahID,
      thID: element[1],
    );
    _thFileStore.addElementWithParent(newScrap, _currentParent);

    _currentElement = newScrap;
    setCurrentParent(newScrap);

    // _parsedOptions.clear();
    _optionFromElement(element[2], _scrapRegularOptions);
    _addChildParser(_scrapContentParser);
  }

  void _injectEndscrap() {
    _currentElement = THEndscrap(parentMapiahID: _currentParentMapiahID);
    _thFileStore.addElementWithParent(_currentElement, _currentParent);
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
    _currentHasOptions = _currentElement as THHasOptions;
  }

  void _injectArea(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize >= 2);
      assert(element[1] is List);
      assert(element[1].length == 2);
      assert(element[1][0] is String);
    }

    final THArea newArea = THArea(
      parentMapiahID: _currentParentMapiahID,
      areaType: element[1][0],
    );
    _thFileStore.addElementWithParent(newArea, _currentParent);

    _currentElement = newArea;
    setCurrentParent(newArea);

    try {
      // Including subtype defined with type (type:subtype).
      if ((element[1][1] != null) && (element[1][0] == 'u')) {
        THSubtypeCommandOption(optionParent: newArea, subtype: element[1][1]);
      }
    } catch (e, s) {
      _addError("$e\n\nTrace:\n\n$s", '_injectArea', element[1][1].toString());
    }

    _optionFromElement(element[2], _areaRegularOptions);
    _addChildParser(_areaContentParser);
  }

  void _injectLine(List<dynamic> element) {
    final int elementSize = element.length;

    if (kDebugMode) {
      assert(elementSize >= 2);
      assert(element[1] is List);
      assert(element[1].length == 2);
      assert(element[1][0] is String);
    }

    final THLine newLine =
        THLine(parentMapiahID: _currentParentMapiahID, lineType: element[1][0]);
    _thFileStore.addElementWithParent(newLine, _currentParent);

    _currentElement = newLine;
    setCurrentParent(newLine);

    try {
      // Including subtype defined with type (type:subtype).
      if (element[1][1] != null) {
        THSubtypeCommandOption(optionParent: newLine, subtype: element[1][1]);
      }
    } catch (e, s) {
      _addError("$e\n\nTrace:\n\n$s", '_injectLine', element[1][1].toString());
    }

    _optionFromElement(element[2], _lineRegularOptions);
    _addChildParser(_lineContentParser);
    _lastLineSegment = null;
  }

  void _injectEndarea() {
    _currentElement = THEndarea(parentMapiahID: _currentParentMapiahID);
    _thFileStore.addElementWithParent(_currentElement, _currentParent);
    setCurrentParent((_currentParent as THElement).parent(_parsedTHFile));
    _returnToParentParser();
  }

  void _injectEndline() {
    _currentElement = THEndline(parentMapiahID: _currentParentMapiahID);
    _thFileStore.addElementWithParent(_currentElement, _currentParent);
    setCurrentParent((_currentParent as THElement).parent(_parsedTHFile));
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
          "Need string as comment type. Received '${element[0]}'.");
    }

    if (element[1] is! String) {
      throw THCustomException(
          "Need string as comment content. Received '${element[1]}'.");
    }

    if (element[1].indexOf('# ') == 0) {
      element[1] = element[1].substring(2);
    } else if (element[1].indexOf('#') == 0) {
      element[1] = element[1].substring(1);
    }

    switch (element[0]) {
      case 'fulllinecomment':
        final THElement newElement = THComment(
          parentMapiahID: _currentParentMapiahID,
          content: element[1],
        );
        _thFileStore.addElementWithParent(newElement, _currentParent);
        break;
      case 'samelinecomment':
        if ((_currentElement.sameLineComment == null) ||
            _currentElement.sameLineComment!.isEmpty) {
          _currentElement.sameLineComment = element[1];
        } else {
          _currentElement.sameLineComment =
              '${_currentElement.sameLineComment!} | ${element[1]}';
        }
        break;
      default:
        final THElement newElement = THUnrecognizedCommand(
          parentMapiahID: _currentParentMapiahID,
          value: element,
        );
        _thFileStore.addElementWithParent(newElement, _currentParent);
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

      // if (_parsedOptions.contains(optionType)) {
      //   final elementType = _currentElement.type;
      //   _addError("Duplicated option '$optionType' in $elementType.",
      //       '_optionFromElement', element.toString());
      //   continue;
      // }

      // This "if null" is here to deal with command options that have optional
      // extra data, i.e, they might be defined alone. In these situations
      // _currentOptions[1] will be simply null. As we need a list in
      // _currentSpec we create a list with a null inside to represent the
      // null value we received from the parser.
      _currentSpec = _currentOptions[1] ?? [null];
      _currentHasOptions = _currentElement as THHasOptions;
      // _parsedOptions.add(optionType);

      try {
        if (createRegularOption(optionType)) {
          continue;
        }

        if (THMultipleChoiceCommandOption.hasOptionType(
            _currentHasOptions, optionType)) {
          _injectMultipleChoiceCommandOption(optionType);
          continue;
        }

        final String errorMessage =
            "Unrecognized command option '$optionType'. This should never happen.";
        if (kDebugMode) assert(false, errorMessage);
        throw UnsupportedError(errorMessage);
      } catch (e, s) {
        _addError("$e\n\nTrace:\n\n$s", '_optionFromElement',
            _currentOptions.toString());
      }
    }
  }

  bool _pointRegularOptions(String optionType) {
    bool optionIdentified = true;

    switch (optionType) {
      case 'clip':
        _injectClipCommandOption();
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

  void _optionParentAsTHLineSegment() {
    if (_lastLineSegment == null) {
      _addError("Line segment option without a line segment.",
          '_optionParentAsTHLineSegment', _currentElement.toString());
      return;
    }

    /// Changing _currentHasOptions to the line segment that is the parent of
    /// of the linepoint option. This change will be reverted by
    /// _injectLineSegmentOption().
    _currentHasOptions = _lastLineSegment as THHasOptions;
  }

  void _optionParentAsCurrentElement() {
    _currentHasOptions = _currentElement as THHasOptions;
  }

  bool _lineSegmentRegularOptions(String optionType) {
    bool optionIdentified = _lineRegularOptions(optionType);

    if (optionIdentified) {
      return true;
    }

    optionIdentified = true;
    switch (optionType) {
      case 'altitude':
        _injectAltitudeCommandOption();
      case 'direction':
        _injectMultipleChoiceWithPointChoiceCommandOption(optionType);
      case 'gradient':
        _injectMultipleChoiceWithPointChoiceCommandOption(optionType);
      case 'l-size':
        _injectLSizeCommandOption();
      case 'mark':
        _injectMarkCommandOption();
      case 'orientation':
        _optionParentAsTHLineSegment();
        _injectOrientationCommandOption();
      default:
        optionIdentified = false;
    }

    if (optionIdentified) {
      return true;
    }

    /// Here we create the options found in [LINE DATA] that, in reality, are
    /// line options, not line segment options.
    /// The actual line segment options are created in _optionFromElement().
    if (THMultipleChoiceCommandOption.hasOptionType(
        _currentHasOptions, optionType)) {
      _optionParentAsCurrentElement();
      _injectMultipleChoiceCommandOption(optionType);
      return true;
    }

    /// Setting optionParent so actual line segment options are properly created
    /// in _optionFromElement(). This change will be reverted by
    /// _injectLineSegmentOption().
    _optionParentAsTHLineSegment();

    return false;
  }

  bool _areaRegularOptions(String optionType) {
    bool optionIdentified = true;

    switch (optionType) {
      case 'clip':
        _injectClipCommandOption();
      case 'context':
        _injectContextCommandOption();
      case 'endarea':
        _injectEndarea();
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
      case 'clip':
        _injectClipCommandOption();
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

  void setCurrentParent(THParent parent) {
    _currentParent = parent;
    _currentParentMapiahID = parent.mapiahID;
  }

  bool _scrapRegularOptions(String optionType) {
    bool optionIdentified = true;

    switch (optionType) {
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

  void _injectMultipleChoiceWithPointChoiceCommandOption(String optionType) {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a '$optionType' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] is! String) {
      throw THCustomException(
          "One string parameter required to create a '$optionType' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] == 'point') {
      _optionParentAsTHLineSegment();
    } else {
      _optionParentAsCurrentElement();
    }
    THMultipleChoiceCommandOption(
      optionParent: _currentHasOptions,
      multipleChoiceType: optionType,
      choice: _currentSpec[0],
    );
  }

  void _injectMultipleChoiceCommandOption(String optionType) {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a '$optionType' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] is! String) {
      throw THCustomException(
          "One string parameter required to create a '$optionType' option for a '${_currentHasOptions.elementType}'");
    }

    THMultipleChoiceCommandOption(
      optionParent: _currentHasOptions,
      multipleChoiceType: optionType,
      choice: _currentSpec[0],
    );
  }

  void _checkParsedListAsPoint(List<dynamic> list) {
    if (list.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec[1]);
    }
  }

  void _injectClipCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'clip' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] is! String) {
      throw THCustomException(
          "One string parameter required to create a 'clip' option for a '${_currentHasOptions.elementType}'");
    }

    THClipCommandOption.fromChoice(
      optionParent: _currentHasOptions,
      choice: _currentSpec[0],
    );
  }

  void _injectDistCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'dist' option for a '${_currentHasOptions.elementType}'");
    }

    switch (_currentSpec.length) {
      case 1:
        THDistCommandOption.fromString(
          optionParent: _currentHasOptions,
          distance: _currentSpec[0],
        );
      case 2:
        THDistCommandOption.fromString(
          optionParent: _currentHasOptions,
          distance: _currentSpec[0],
          unit: _currentSpec[1],
        );
      default:
        throw THCustomException(
            "Unsupported parameters for a 'point' 'dist' option: '${_currentSpec[0]}'.");
    }
  }

  void _injectExploredCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'explored' option for a '${_currentHasOptions.elementType}'");
    }

    switch (_currentSpec.length) {
      case 1:
        THExploredCommandOption.fromString(
          optionParent: _currentHasOptions,
          distance: _currentSpec[0],
        );
      case 2:
        THExploredCommandOption.fromString(
          optionParent: _currentHasOptions,
          distance: _currentSpec[0],
          unit: _currentSpec[1],
        );
      default:
        throw THCustomException(
            "Unsupported parameters for a 'point' 'explored' option: '${_currentSpec[0]}'.");
    }
  }

  void _injectHeightCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'height' option for a '${_currentHasOptions.elementType}'");
    }

    THLineHeightCommandOption.fromString(
      optionParent: _currentHasOptions,
      height: _currentSpec[0],
    );
  }

  void _injectContextCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCustomException(
          "Two parameteres are required to create a 'context' option for a '${_currentHasOptions.elementType}'");
    }

    THContextCommandOption(
      optionParent: _currentHasOptions,
      elementType: _currentSpec[0],
      symbolType: _currentSpec[1],
    );
  }

  void _injectFromCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'dist' option for a '${_currentHasOptions.elementType}'");
    }

    THFromCommandOption(
      optionParent: _currentHasOptions,
      station: _currentSpec[0],
    );
  }

  void _injectExtendCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'extend' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] == null) {
      THExtendCommandOption(optionParent: _currentHasOptions, station: '');
    } else {
      THExtendCommandOption(
        optionParent: _currentHasOptions,
        station: _currentSpec[0],
      );
    }
  }

  void _injectIDCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'id' option for a '${_currentHasOptions.elementType}'");
    }

    THIDCommandOption(optionParent: _currentHasOptions, thID: _currentSpec[0]);
    _thFileStore.registerElementWithTHID(_currentHasOptions, _currentSpec[0]);
  }

  void _injectNameCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'name' option for a '${_currentHasOptions.elementType}'");
    }

    THNameCommandOption(
      optionParent: _currentHasOptions,
      reference: _currentSpec[0],
    );
  }

  void _injectSketchCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    if (_currentSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THSketchCommandOption (0)');
    }

    _checkParsedListAsPoint(_currentSpec[1]);

    final filename = _parseTHString(_currentSpec[0]);

    THSketchCommandOption.fromString(
      optionParent: _currentHasOptions,
      filename: filename,
      pointList: _currentSpec[1],
    );
  }

  void _injectStationNamesCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    THStationNamesCommandOption(
      optionParent: _currentHasOptions,
      prefix: _currentSpec[0],
      suffix: _currentSpec[1],
    );
  }

  void _injectStationsCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 1', _currentSpec);
    }

    final stations = _currentSpec[0].toString().split(',');

    if (stations.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException('> 0', stations);
    }

    THStationsCommandOption(
      optionParent: _currentHasOptions,
      stations: stations,
    );
  }

  void _injectLSizeCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    _optionParentAsTHLineSegment();
    THLSizeCommandOption.fromString(
      optionParent: _currentHasOptions,
      number: _currentSpec[0],
    );
  }

  void _injectMarkCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    _optionParentAsTHLineSegment();
    THMarkCommandOption(
      optionParent: _currentHasOptions,
      mark: _currentSpec[0],
    );
  }

  void _injectAuthorCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    THAuthorCommandOption.fromString(
      optionParent: _currentHasOptions,
      datetime: _currentSpec[0],
      person: _currentSpec[1],
    );
  }

  void _injectSubtypeCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 1', _currentSpec);
    }

    THSubtypeCommandOption(
      optionParent: _currentHasOptions,
      subtype: _currentSpec[0],
    );
  }

  void _injectPointScaleCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    switch (_currentSpec[0]) {
      case 'numeric':
        THPointScaleCommandOption.sizeAsNumberFromString(
          optionParent: _currentHasOptions,
          numericScaleSize: _currentSpec[1],
        );
      case 'multiplechoice':
        THPointScaleCommandOption.sizeAsMultipleChoice(
          optionParent: _currentHasOptions,
          textScaleSize: _currentSpec[1],
        );
      default:
        throw THCustomException(
            "Unknown point scale mode '${_currentSpec[0]}'");
    }
  }

  void _injectLineScaleCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    switch (_currentSpec[0]) {
      case 'numeric':
        THLineScaleCommandOption.sizeAsNumberFromString(
          optionParent: _currentHasOptions,
          numericScaleSize: _currentSpec[1],
        );
      case 'multiplechoice':
        THLineScaleCommandOption.sizeAsMultipleChoice(
          optionParent: _currentHasOptions,
          textScaleSize: _currentSpec[1],
        );
      case 'text':
        THLineScaleCommandOption.sizeAsText(
          optionParent: _currentHasOptions,
          textScale: _currentSpec[1],
        );
      default:
        throw THCustomException(
            "Unknown point scale mode '${_currentSpec[0]}'");
    }
  }

  void _injectScrapCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'scrap' option for a '${_currentHasOptions.elementType}'");
    }

    THScrapCommandOption(
      optionParent: _currentHasOptions,
      reference: _currentSpec[0],
    );
  }

  void _injectOrientationCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 1', _currentSpec);
    }

    THOrientationCommandOption.fromString(
      optionParent: _currentHasOptions,
      azimuth: _currentSpec[0],
    );
  }

  void _injectCopyrightCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    final String message = _parseTHString(_currentSpec[1]);

    THCopyrightCommandOption.fromString(
      optionParent: _currentHasOptions,
      datetime: _currentSpec[0],
      copyrightMessage: message,
    );
  }

  void _injectCSCommandOption() {
    if (_currentSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THCSCommandOption');
    }

    THCSCommandOption.fromString(
      optionParent: _currentHasOptions,
      csString: _currentSpec[0],
      forOutputOnly: false,
    );
  }

  void _injectTitleCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 1', _currentSpec);
    }

    final String stringContent = _parseTHString(_currentSpec[0]);

    THTitleCommandOption(
      optionParent: _currentHasOptions,
      titleText: stringContent,
    );
  }

  void _injectTextCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 1', _currentSpec);
    }

    final String stringContent = _parseTHString(_currentSpec[0]);

    THTextCommandOption(
      optionParent: _currentHasOptions,
      textContent: stringContent,
    );
  }

  void _injectValueCommandOption() {
    if (_currentSpec.length < 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '>= 2', _currentSpec);
    }

    final pointType = (_currentHasOptions as THPoint).plaType;
    switch (pointType) {
      case 'altitude':
        _injectAltitudeValueCommandOption();
      case 'date':
        _injectDateValueCommandOption();
      case 'dimensions':
        _injectDimensionsValueCommandOption();
      case 'height':
        _injectHeightValueCommandOption();
      case 'passage-height':
        _injectPassageHeightValueCommandOption();
      default:
        throw THCustomException(
            "Unsupported point type '$pointType' for option 'value'.");
    }
  }

  void _injectAltitudeCommandOption() {
    final String parseType = _currentSpec[0].toString();
    final specs = _currentSpec[1];

    _optionParentAsTHLineSegment();
    switch (parseType) {
      case 'fix_number':
        if ((specs[1] == null) || (specs[1] is! String)) {
          throw THCustomException("Need a string value.");
        }
        final unit = ((specs[2] != null) &&
                (specs[2] is String) &&
                ((specs[2] as String).isNotEmpty))
            ? specs[2].toString()
            : '';
        THAltitudeCommandOption.fromString(
          optionParent: _currentHasOptions,
          height: specs[1],
          isFix: true,
          unit: unit,
        );
      case 'hyphen':
      case 'nan':
        THAltitudeCommandOption.fromNan(optionParent: _currentHasOptions);
      case 'number_with_something_else':
        if ((specs[0] == null) || (specs[0] is! String)) {
          throw THCustomException("Need a string value.");
        }
        final unit = ((specs[1] != null) &&
                (specs[1] is String) &&
                ((specs[1] as String).isNotEmpty))
            ? specs[1].toString()
            : '';
        THAltitudeCommandOption.fromString(
          optionParent: _currentHasOptions,
          height: specs[0],
          isFix: false,
          unit: unit,
        );
      case 'single_number':
        THAltitudeCommandOption.fromString(
          optionParent: _currentHasOptions,
          height: specs,
          isFix: false,
        );
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectAltitudeCommandOption'.");
    }
  }

  void _injectAltitudeValueCommandOption() {
    final String parseType = _currentSpec[0].toString();
    final specs = _currentSpec[1];

    switch (parseType) {
      case 'fix_number':
        if ((specs[1] == null) || (specs[1] is! String)) {
          throw THCustomException("Need a string value.");
        }

        final unit = ((specs[2] != null) &&
                (specs[2] is String) &&
                ((specs[2] as String).isNotEmpty))
            ? specs[2].toString()
            : '';
        THAltitudeValueCommandOption.fromString(
          optionParent: _currentHasOptions,
          height: specs[1],
          isFix: true,
          unit: unit,
        );
      case 'hyphen':
      case 'nan':
        THAltitudeValueCommandOption.fromNan(optionParent: _currentHasOptions);
      case 'number_with_something_else':
        if ((specs[0] == null) || (specs[0] is! String)) {
          throw THCustomException("Need a string value.");
        }

        final unit = ((specs[1] != null) &&
                (specs[1] is String) &&
                ((specs[1] as String).isNotEmpty))
            ? specs[1].toString()
            : '';
        THAltitudeValueCommandOption.fromString(
            optionParent: _currentHasOptions,
            height: specs[0],
            isFix: false,
            unit: unit);
      case 'single_number':
        THAltitudeValueCommandOption.fromString(
          optionParent: _currentHasOptions,
          height: specs,
          isFix: false,
        );
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectAltitudeValueCommandOption'.");
    }
  }

  void _injectDateValueCommandOption() {
    final String parseType = _currentSpec[0].toString();
    final specs = _currentSpec[1];

    switch (parseType) {
      case 'datetime':
      case 'hyphen':
        if (specs is! String) {
          throw THCustomException("Need a string value.");
        }
        THDateValueCommandOption.fromString(
          optionParent: _currentHasOptions,
          date: specs,
        );
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectDateValueCommandOption'.");
    }
  }

  void _injectDimensionsValueCommandOption() {
    final String parseType = _currentSpec[0].toString();
    final specs = _currentSpec[1];

    switch (parseType) {
      case 'two_numbers_with_optional_unit':
        if ((specs[0] == null) ||
            (specs[0] is! String) ||
            (specs[1] == null) ||
            (specs[1] is! String)) {
          throw THCustomException("Need 2 string values.");
        }

        final unit = ((specs[2] != null) &&
                (specs[2] is String) &&
                ((specs[2] as String).isNotEmpty))
            ? specs[2].toString()
            : '';
        THDimensionsValueCommandOption.fromString(
          optionParent: _currentHasOptions,
          above: specs[0],
          below: specs[1],
          unit: unit,
        );
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectDimensionsValueCommandOption'.");
    }
  }

  void _injectHeightValueCommandOption() {
    final String parseType = _currentSpec[0].toString();
    final specs = _currentSpec[1];

    switch (parseType) {
      case 'number_with_something_else':
        if ((specs[0] == null) || (specs[0] is! String)) {
          throw THCustomException("Need a string value.");
        }
        var isPresumed = false;
        String value = specs[0];
        if (value.contains('?')) {
          isPresumed = true;
          value = value.substring(0, value.length - 1);
        }

        final unit = ((specs[1] != null) &&
                (specs[1] is String) &&
                ((specs[1] as String).isNotEmpty))
            ? specs[1].toString()
            : '';
        THPointHeightValueCommandOption.fromString(
          optionParent: _currentHasOptions,
          height: value,
          isPresumed: isPresumed,
          unit: unit,
        );
      case 'single_number':
        THPointHeightValueCommandOption.fromString(
          optionParent: _currentHasOptions,
          height: specs,
          isPresumed: false,
        );
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectHeightValueCommandOption'.");
    }
  }

  void _injectPassageHeightValueCommandOption() {
    final String parseType = _currentSpec[0].toString();
    final specs = _currentSpec[1];

    switch (parseType) {
      case 'single_number':
        THPassageHeightValueCommandOption.fromString(
          optionParent: _currentHasOptions,
          plusNumber: specs,
          minusNumber: '',
        );
      case 'plus_number_minus_number':
        THPassageHeightValueCommandOption.fromString(
          optionParent: _currentHasOptions,
          plusNumber: specs[0],
          minusNumber: specs[1],
        );
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectPassageHeightValueCommandOption'.");
    }
  }

  String _parseTHString(String stringToParse) {
    final String parsed =
        stringToParse.replaceAll(_doubleQuoteRegex, thDoubleQuote);

    return parsed;
  }

  // ignore: unused_element
  void _injectUnrecognizedCommandOption() {
    throw THCustomException(
        "Creating THUnrecognizedCommandOption!!. Parameters available:\n\n'${_currentSpec.toString()}'\n\n");
    // THUnrecognizedCommandOption(_currentHasOptions, aSpec.toString());
  }

  void _addError(String aErrorMessage, String aLocation, String aLocalInfo) {
    final String errorMessage =
        "'$aErrorMessage' at '$aLocation' with '$aLocalInfo' local info.";
    _parseErrors.add(errorMessage);
  }

  void _injectScrapScaleCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException('> 0', _currentSpec);
    }

    final List<THDoublePart> values = [];
    THLengthUnitPart? unit;
    bool unitFound = false;

    for (final value in _currentSpec) {
      if (unitFound) {
        throw THCustomWithListParameterException(
            "Unknown element after unit found when creating a THScaleCommandOption object.",
            _currentSpec);
      }
      final newDouble = double.tryParse(value);

      if (newDouble == null) {
        if (values.isEmpty) {
          throw THCustomException(
              "Can´t create THScaleCommandOption object without any value.");
        }
        unit = THLengthUnitPart.fromString(unitString: value);
        unitFound = true;
      } else {
        values.add(THDoublePart.fromString(valueString: value));
      }
    }

    THScrapScaleCommandOption(
      optionParent: _currentHasOptions,
      numericSpecifications: values,
      unit: unit,
    );
  }

  void _injectProjectionCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException('> 0', _currentSpec);
    }

    if (_currentSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THProjectionCommandOption');
    }

    final bool currentLengthOnePlus = _currentSpec.length > 1;
    final bool projectionTypeElevation = _currentSpec[0] == 'elevation';

    THProjectionCommandOption.fromString(
      optionParent: _currentHasOptions,
      type: _currentSpec[0],
      index: (currentLengthOnePlus && (_currentSpec[1] != null))
          ? _currentSpec[1]
          : '',
      elevationAngle: (currentLengthOnePlus &&
              projectionTypeElevation &&
              (_currentSpec[2] != null))
          ? _currentSpec[2]
          : null,
      elevationUnit: (currentLengthOnePlus &&
              projectionTypeElevation &&
              (_currentSpec[3] != null))
          ? _currentSpec[3]
          : null,
    );
  }

  void _injectUnknown(List<dynamic> element) {
    final THElement newElement = THUnrecognizedCommand(
      parentMapiahID: _currentParentMapiahID,
      value: element,
    );
    _thFileStore.addElementWithParent(newElement, _currentParent);
  }

  @useResult
  Future<String> _decodeFile(RandomAccessFile raf, String encoding) async {
    await raf.setPosition(0);
    final int fileSize = await raf.length();
    final Uint8List fileContentRaw = await raf.read(fileSize);
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
        final isoResult = _isoRegex.firstMatch(encoding);
        if (isoResult != null) {
          encoding = 'ISO-${isoResult[1]}';
        }
        final encoder = Charset.getByName(encoding);
        if (encoder == null) {
          fileContentDecoded = utf8.decode(fileContentRaw);
        } else {
          fileContentDecoded = encoder.decode(fileContentRaw);
        }
    }

    return fileContentDecoded;
  }

  @useResult
  Future<String> _encodingNameFromFile(RandomAccessFile raf) async {
    String line = '';
    int byte;
    String priorChar = '';
    int charsRead = 0;

    await raf.setPosition(0);
    while ((charsRead < thMaxEncodingLength) &
        ((byte = await raf.readByte()) != -1)) {
      charsRead++;
      getIt<MPLog>().finest("Byte: '$byte'");
      final char = utf8.decode([byte]);

      if (_isEncodingDelimiter(priorChar, char)) {
        break;
      }

      line += char;
      priorChar = char;
    }
    getIt<MPLog>().finer("Line: '$line'");

    final encoding = _encodingRegex.firstMatch(line);
    getIt<MPLog>().finer("Encoding object: '$encoding");
    if (encoding == null) {
      return thDefaultEncoding;
    } else {
      return encoding[1]!.toUpperCase();
    }
  }

  @useResult
  bool _isEncodingDelimiter(String priorChar, String char,
      [String lineDelimiter = '\n']) {
    if (lineDelimiter.length == 1) {
      return ((char == lineDelimiter) | (char == thCommentChar));
    } else {
      return (((priorChar + char) == lineDelimiter) | (char == thCommentChar));
    }
  }

  @useResult
  Future<(THFile, bool, List<String>)> parse(
    String filePath, {
    Parser? alternateStartParser,
    bool trace = false,
    bool forceNewStore = false,
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

    _thFileStore = getIt<MPGeneralStore>()
        .getTHFileStore(filename: filePath, forceNewStore: forceNewStore);
    _parsedTHFile = _thFileStore.thFile;
    _parsedTHFile.filename = filePath;
    setCurrentParent(_parsedTHFile);
    _parseErrors.clear();

    try {
      final File file = File(filePath);
      final RandomAccessFile raf = await file.open();

      _parsedTHFile.encoding = await _encodingNameFromFile(raf);

      String contents = await _decodeFile(raf, _parsedTHFile.encoding);

      _splitContents(contents);

      await raf.close();
    } catch (e) {
      stderr.writeln('failed to read file: \n$e');
    }

    _injectContents();

    if (!(_parsedTHFile).isSameClass(_currentParent) ||
        (_currentParent != _parsedTHFile)) {
      _addError('Multiline commmands left open at end of file', 'parse',
          'Unclosed multiline command: "${_currentParent.toString()}"');
    }

    return (_parsedTHFile, _parseErrors.isEmpty, _parseErrors);
  }

  (int index, int length) _findLineBreak(String content) {
    final int windowsResult = content.indexOf(thWindowsLineBreak);
    if (windowsResult != -1) return (windowsResult, 2);

    final int unixResult = content.indexOf(thUnixLineBreak);
    if (unixResult != -1) return (unixResult, 1);

    return (-1, 0);
  }

  void _splitContents(String contents) {
    _splittedContents = [];
    String lastLine = '';
    while (contents.isNotEmpty) {
      var (lineBreakIndex, lineBreakLength) = _findLineBreak(contents);
      if (lineBreakIndex == -1) {
        lastLine += contents;
        break;
      }
      String newLine = contents.substring(0, lineBreakIndex);
      contents = contents.substring(lineBreakIndex + lineBreakLength);
      if (newLine.isEmpty) {
        _splittedContents.add("$lastLine$newLine");
        lastLine = '';
        continue;
      }
      int quoteCount = THFileAux.countCharOccurrences(newLine, thDoubleQuote);

      // Joining lines that end with a line break inside a quoted string, i.e.,
      // the line break belongs to the string content.
      while (quoteCount.isOdd && contents.isNotEmpty) {
        (lineBreakIndex, lineBreakLength) = _findLineBreak(contents);
        if (lineBreakIndex == -1) {
          newLine += contents;
          break;
        }
        newLine += contents.substring(0, lineBreakIndex);
        contents = contents.substring(lineBreakIndex + lineBreakLength);
        quoteCount = THFileAux.countCharOccurrences(newLine, thDoubleQuote);
      }

      // Joining next line if this line ends with a backslash.
      final String lastChar = newLine.substring(newLine.length - 1);
      if (lastChar == thBackslash) {
        lastLine = newLine.substring(0, newLine.length - 1);
      } else {
        _splittedContents.add("$lastLine$newLine");
        lastLine = '';
      }
    }

    // Dealing with files that don´t finish with a line break or with
    // unterminated quoted strings.
    if (lastLine.isNotEmpty) {
      _splittedContents.add(lastLine);
    }
  }
}
