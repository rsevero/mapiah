import 'dart:collection';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:mapiah/src/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_altitude_value_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_author_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_clip_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_context_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_copyright_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_cs_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_date_value_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_dimensions_value_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_dist_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_explored_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_extend_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_from_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_height_value_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_id_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_multiple_choice_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_name_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_orientation_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_passage_height_value_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_projection_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_scrap_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_scrap_scale_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_sketch_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_station_names_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_stations_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_subtype_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_text_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_title_command_option.dart';
import 'package:mapiah/src/th_elements/th_comment.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_empty_line.dart';
import 'package:mapiah/src/th_elements/th_encoding.dart';
import 'package:mapiah/src/th_elements/th_endcomment.dart';
import 'package:mapiah/src/th_elements/th_endline.dart';
import 'package:mapiah/src/th_elements/th_endscrap.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
import 'package:mapiah/src/th_elements/th_line_segment.dart';
import 'package:mapiah/src/th_elements/th_multiline_comment_content.dart';
import 'package:mapiah/src/th_elements/th_multilinecomment.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_point_scale_command_option.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_elements/th_straight_line_segment.dart';
import 'package:mapiah/src/th_elements/th_unrecognized_command.dart';
import 'package:mapiah/src/th_errors/th_options_list_wrong_length_error.dart';
import 'package:mapiah/src/th_exceptions/th_create_object_from_empty_list_exception.dart';
import 'package:mapiah/src/th_exceptions/th_create_object_from_null_value_exception.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';
import 'package:mapiah/src/th_exceptions/th_custom_with_list_parameter_exception.dart';
import 'package:mapiah/src/th_file_aux/th_file_aux.dart';
import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_parts/th_length_unit_part.dart';
import 'package:meta/meta.dart';
import 'package:charset/charset.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';

class THFileParser {
  final _grammar = THGrammar();

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
  late THFile _parsedTHFile;
  late THParent _currentParent;
  late THElement _currentElement;
  late THHasOptions _currentHasOptions;
  THLineSegment? _lastLineSegment;
  late List<dynamic> _currentOptions;
  late List<dynamic> _currentSpec;
  // final _parsedOptions = HashSet<String>();
  bool _runTraceParser = false;

  final List<String> _parseErrors = [];

  final _doubleQuoteRegex = RegExp(thDoubleQuotePair);
  final _encodingRegex =
      RegExp(r'^\s*encoding\s+([a-zA-Z0-9-]+)', caseSensitive: false);
  final _isoRegex = RegExp(r'^iso([^_-].*)', caseSensitive: false);

  THFileParser() {
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
    assert(_parentParsers.isNotEmpty);
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
    var isFirst = true;
    for (String line in _splittedContents) {
      if (line.trim().isEmpty) {
        _injectEmptyLine();
        continue;
      }
      if (_runTraceParser) {
        trace(_currentParser).parse(line);
      }

      _parsedContents = _currentParser.parse(line);
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

      final elementType = (element[0] as String).toLowerCase();
      switch (elementType) {
        case 'beziercurvelinesegment':
          _injectBezierCurveLineSegment(element);

          /// Line data injects same line comment by themselves.
          continue;
        case 'encoding':
          _injectEncoding();
        case 'endmultilinecomment':
          _injectEndMultiLineComment();
        case 'endline':
          _injectEndline(element);
        case 'endscrap':
          _injectEndscrap(element);
        case 'fulllinecomment':
          _commentContentToParse = element;
          _injectComment();
          continue;
        case 'line':
          _injectLine(element);
        case 'linesegmentoption':
          _injectLineSegmentOption(element);

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
          continue;
        case 'point':
          _injectPoint(element);
        case 'scrap':
          _injectScrap(element);
        default:
          _injectUnknown(element);
          continue;
      }

      /// The second part of '_parsedContents' holds the comment, if any.
      _injectComment();
    }
  }

  void _injectEmptyLine() {
    _currentElement = THEmptyLine(_currentParent);
  }

  void _injectMultiLineCommentContent(List<dynamic> aElement) {
    final content = (aElement.isEmpty) ? '' : aElement[1].toString();
    _currentElement = THMultilineCommentContent(_currentParent, content);
  }

  void _injectEndMultiLineComment() {
    _currentElement = THEndcomment(_currentParent);
    _currentParent = _currentParent.parent;
    _returnToParentParser();
  }

  void _injectStartMultiLineComment() {
    _currentParent = THMultiLineComment(_currentParent);
    _currentElement = _currentParent;
    _addChildParser(_multiLineCommentContentParser);
  }

  void _injectEncoding() {
    _currentElement = THEncoding(_currentParent);
  }

  void _injectPoint(List<dynamic> aElement) {
    final elementSize = aElement.length;
    assert(elementSize >= 3);

    _checkParsedListAsPoint(aElement[1]);

    assert(aElement[2] is List);
    assert(aElement[2].length == 2);

    final newPoint =
        THPoint.fromString(_currentParent, aElement[1], aElement[2][0]);

    _currentElement = newPoint;
    // _parsedOptions.clear();

    try {
      // Including subtype defined with type (type:subtype).
      if (aElement[2][1] != null) {
        THSubtypeCommandOption(newPoint, aElement[2][1]);
        // _parsedOptions.add('subtype');
      }
    } catch (e, s) {
      _addError("$e\n\nTrace:\n\n$s", '_pointOptionFromElement',
          aElement[2][1].toString());
    }

    _optionFromElement(aElement[3], _pointRegularOptions);
  }

  void _injectBezierCurveLineSegment(List<dynamic> aElement) {
    final elementSize = aElement.length;
    assert(elementSize == 2);

    final pointList = aElement[1];
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

    final controlPoint1 = pointList[0][1];
    final controlPoint2 = pointList[1][1];
    final endPoint = pointList[2][1];

    _checkParsedListAsPoint(controlPoint1);
    _checkParsedListAsPoint(controlPoint2);
    _checkParsedListAsPoint(endPoint);

    final newBezierCurveLineSegment = THBezierCurveLineSegment.fromString(
        _currentParent, controlPoint1, controlPoint2, endPoint);

    // _currentElement = newBezierCurveLineSegment;
    _lastLineSegment = newBezierCurveLineSegment;

    /// Same line comments should be inserted in the line segment itself and not
    /// in the line command that includes this line segment.
    _currentElement = newBezierCurveLineSegment;
    _injectComment();
    _currentElement = newBezierCurveLineSegment.parent;
  }

  void _injectStraightLineSegment(List<dynamic> aElement) {
    final elementSize = aElement.length;
    assert(elementSize == 2);

    final pointList = aElement[1];
    assert(pointList is List);
    assert(pointList.length == 2);
    assert(pointList[0] is String);
    assert(pointList[0] == 'endpoint');
    assert(pointList[1] is List);
    assert(pointList[1].length == 2);

    final endPoint = pointList[1];

    _checkParsedListAsPoint(endPoint);

    final newStraightLineSegment =
        THStraightLineSegment.fromString(_currentParent, endPoint);

    // _currentElement = newStraightLineSegment;
    _lastLineSegment = newStraightLineSegment;

    /// Same line comments should be inserted in the line segment itself and not
    /// in the line command that includes this line segment.
    _currentElement = newStraightLineSegment;
    _injectComment();
    _currentElement = newStraightLineSegment.parent;
  }

  void _injectScrap(List<dynamic> aElement) {
    final elementSize = aElement.length;
    assert(elementSize >= 2);
    final newScrap = THScrap(_currentParent, aElement[1]);

    _currentElement = newScrap;
    _currentParent = newScrap;

    // _parsedOptions.clear();
    _optionFromElement(aElement[2], _scrapRegularOptions);
    _addChildParser(_scrapContentParser);
  }

  void _injectEndscrap(List<dynamic> aElement) {
    _currentElement = THEndscrap(_currentParent);
    _currentParent = _currentParent.parent;
    _returnToParentParser();
  }

  /// All line options (the ones that should be on the "line" line in the .th2
  /// file) can also appear as linepoint options (the ones that appear
  /// intermixed with line segments between the "line" and "endline" lines).
  /// Here we deall with them all, registering the line options that appeared as
  /// linepoint options in the line options list and keeping the linepoint
  /// options registered with the appropriate line segment.
  void _injectLineSegmentOption(List<dynamic> aElement) {
    if (_lastLineSegment == null) {
      _addError("Line segment option without a line segment.",
          '_injectLineSegmentOption', aElement.toString());
      return;
    }

    final elementSize = aElement.length;

    assert(elementSize == 2);
    assert(aElement[1] is List);
    assert(aElement[1].length == 1);
    assert(aElement[1][0] is List);

    _optionFromElement(aElement[1], _lineSegmentRegularOptions);

    /// Same line comments should be inserted in the line segment to which this
    /// line segment option is related and not in the line command that includes
    /// this line segment option.
    _currentElement = _lastLineSegment!;
    _injectComment();
    _currentElement = _lastLineSegment!.parent;

    /// Reverting the change made by _lineSegmentRegularOptions().
    _currentHasOptions = _currentElement as THHasOptions;
  }

  void _injectLine(List<dynamic> aElement) {
    final elementSize = aElement.length;

    assert(elementSize >= 2);
    assert(aElement[1] is List);
    assert(aElement[1].length == 2);
    assert(aElement[1][0] is String);

    final newLine = THLine(_currentParent, aElement[1][0]);

    _currentElement = newLine;
    _currentParent = newLine;

    // _parsedOptions.clear();

    try {
      // Including subtype defined with type (type:subtype).
      if (aElement[1][1] != null) {
        THSubtypeCommandOption(newLine, aElement[1][1]);
        // _parsedOptions.add('subtype');
      }
    } catch (e, s) {
      _addError("$e\n\nTrace:\n\n$s", '_injectLine', aElement[1][1].toString());
    }

    _optionFromElement(aElement[2], _lineRegularOptions);
    _addChildParser(_lineContentParser);
    _lastLineSegment = null;
  }

  void _injectEndline(List<dynamic> aElement) {
    _currentElement = THEndline(_currentParent);
    _currentParent = _currentParent.parent;
    _returnToParentParser();
  }

  void _injectComment() {
    final aElement = _commentContentToParse;
    if (aElement == null) {
      return;
    }

    if (aElement.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException('== 2', aElement);
    }

    if (aElement[0] is! String) {
      throw THCustomException(
          "Need string as comment type. Received '${aElement[0]}'.");
    }

    if (aElement[1] is! String) {
      throw THCustomException(
          "Need string as comment content. Received '${aElement[1]}'.");
    }

    if (aElement[1].indexOf('# ') == 0) {
      aElement[1] = aElement[1].substring(2);
    } else if (aElement[1].indexOf('#') == 0) {
      aElement[1] = aElement[1].substring(1);
    }

    switch (aElement[0]) {
      case 'fulllinecomment':
        THComment(_currentParent, aElement[1]);
      case 'samelinecomment':
        if ((_currentElement.sameLineComment == null) ||
            _currentElement.sameLineComment!.isEmpty) {
          _currentElement.sameLineComment = aElement[1];
        } else {
          _currentElement.sameLineComment =
              '${_currentElement.sameLineComment!} | ${aElement[1]}';
        }
      default:
        THUnrecognizedCommand(_currentParent, aElement);
    }
  }

  void _optionFromElement(
      List<dynamic> aElement, Function(String) createRegularOption) {
    for (_currentOptions in aElement) {
      if (_currentOptions.length != 2) {
        throw THOptionsListWrongLengthError();
      }

      final optionType = _currentOptions[0].toString().toLowerCase();

      // if (_parsedOptions.contains(optionType)) {
      //   final elementType = _currentElement.type;
      //   _addError("Duplicated option '$optionType' in $elementType.",
      //       '_optionFromElement', aElement.toString());
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

        final errorMessage =
            "Unrecognized command option '$optionType'. This should never happen.";
        assert(false, errorMessage);
        throw UnsupportedError(errorMessage);
      } catch (e, s) {
        _addError("$e\n\nTrace:\n\n$s", '_optionFromElement',
            _currentOptions.toString());
      }
    }
  }

  bool _pointRegularOptions(String aOptionType) {
    var optionIdentified = true;

    switch (aOptionType) {
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

  bool _lineSegmentRegularOptions(String aOptionType) {
    var optionIdentified = _lineRegularOptions(aOptionType);

    if (optionIdentified) {
      return true;
    }

    /// Changing _currentHasOptions to the line segment that is the parent of
    /// of the linepoint option. This change will be reverted by
    /// _injectLineSegmentOption().
    _currentHasOptions = _lastLineSegment as THHasOptions;
    optionIdentified = true;
    switch (aOptionType) {
      case 'direction':
        _injectDirectionCommandOption();
      case 'gradient':
        _injectGradientCommandOption();
      default:
        optionIdentified = false;
    }
    _currentHasOptions = _currentElement as THHasOptions;

    if (optionIdentified) {
      return true;
    }

    if (THMultipleChoiceCommandOption.hasOptionType(
        _currentHasOptions, aOptionType)) {
      _injectMultipleChoiceCommandOption(aOptionType);
      return true;
    }

    /// Changing _currentHasOptions to the line segment that is the parent of
    /// of the linepoint option. This change will be reverted by
    /// _injectLineSegmentOption().
    _currentHasOptions = _lastLineSegment as THHasOptions;

    return optionIdentified;
  }

  bool _lineRegularOptions(String aOptionType) {
    var optionIdentified = true;

    switch (aOptionType) {
      case 'clip':
        _injectClipCommandOption();
      default:
        optionIdentified = false;
    }

    return optionIdentified;
  }

  bool _scrapRegularOptions(String aOptionType) {
    var optionIdentified = true;

    switch (aOptionType) {
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

  void _injectDirectionCommandOption() {
    final aOptionType = 'direction';

    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a '$aOptionType' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] is! String) {
      throw THCustomException(
          "One string parameter required to create a '$aOptionType' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] == 'point') {
      _currentHasOptions = _lastLineSegment as THHasOptions;
      THMultipleChoiceCommandOption(
          _currentHasOptions, aOptionType, _currentSpec[0]);
    } else {
      _currentHasOptions = _currentElement as THHasOptions;
      THMultipleChoiceCommandOption(
          _currentHasOptions, aOptionType, _currentSpec[0]);
    }
  }

  void _injectGradientCommandOption() {
    final aOptionType = 'gradient';

    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a '$aOptionType' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] is! String) {
      throw THCustomException(
          "One string parameter required to create a '$aOptionType' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] == 'point') {
      _currentHasOptions = _lastLineSegment as THHasOptions;
      THMultipleChoiceCommandOption(
          _currentHasOptions, aOptionType, _currentSpec[0]);
    } else {
      _currentHasOptions = _currentElement as THHasOptions;
      THMultipleChoiceCommandOption(
          _currentHasOptions, aOptionType, _currentSpec[0]);
    }
  }

  void _injectMultipleChoiceCommandOption(String aOptionType) {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a '$aOptionType' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] is! String) {
      throw THCustomException(
          "One string parameter required to create a '$aOptionType' option for a '${_currentHasOptions.elementType}'");
    }

    THMultipleChoiceCommandOption(
        _currentHasOptions, aOptionType, _currentSpec[0]);
  }

  void _checkParsedListAsPoint(List<dynamic> aList) {
    if (aList.length != 2) {
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

    THClipCommandOption(_currentHasOptions, _currentSpec[0]);
  }

  void _injectDistCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'dist' option for a '${_currentHasOptions.elementType}'");
    }

    switch (_currentSpec.length) {
      case 1:
        THDistCommandOption.fromString(_currentHasOptions, _currentSpec[0]);
      case 2:
        THDistCommandOption.fromString(
            _currentHasOptions, _currentSpec[0], _currentSpec[1]);
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
        THExploredCommandOption.fromString(_currentHasOptions, _currentSpec[0]);
      case 2:
        THExploredCommandOption.fromString(
            _currentHasOptions, _currentSpec[0], _currentSpec[1]);
      default:
        throw THCustomException(
            "Unsupported parameters for a 'point' 'explored' option: '${_currentSpec[0]}'.");
    }
  }

  void _injectContextCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'context' option for a '${_currentHasOptions.elementType}'");
    }

    THContextCommandOption(
        _currentHasOptions, _currentSpec[0], _currentSpec[1]);
  }

  void _injectFromCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'dist' option for a '${_currentHasOptions.elementType}'");
    }

    THFromCommandOption(_currentHasOptions, _currentSpec[0]);
  }

  void _injectExtendCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'extend' option for a '${_currentHasOptions.elementType}'");
    }

    if (_currentSpec[0] == null) {
      THExtendCommandOption(_currentHasOptions, '');
    } else {
      THExtendCommandOption(_currentHasOptions, _currentSpec[0]);
    }
  }

  void _injectIDCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'id' option for a '${_currentHasOptions.elementType}'");
    }

    THIDCommandOption(_currentHasOptions, _currentSpec[0]);
  }

  void _injectNameCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'name' option for a '${_currentHasOptions.elementType}'");
    }

    THNameCommandOption(_currentHasOptions, _currentSpec[0]);
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
        _currentHasOptions, filename, _currentSpec[1]);
  }

  void _injectStationNamesCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    THStationNamesCommandOption(
        _currentHasOptions, _currentSpec[0], _currentSpec[1]);
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

    THStationsCommandOption(_currentHasOptions, stations);
  }

  void _injectAuthorCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    THAuthorCommandOption.fromString(
        _currentHasOptions, _currentSpec[0], _currentSpec[1]);
  }

  void _injectSubtypeCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 1', _currentSpec);
    }

    THSubtypeCommandOption((_currentHasOptions as THPoint), _currentSpec[0]);
  }

  void _injectPointScaleCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    switch (_currentSpec[0]) {
      case 'numeric':
        THPointScaleCommandOption.sizeAsNumberFromString(
            (_currentHasOptions as THPoint), _currentSpec[1]);
      case 'text':
        THPointScaleCommandOption.sizeAsText(
            (_currentHasOptions as THPoint), _currentSpec[1]);
      default:
        throw THCustomException("Unknown point scale mode '_currentSpec[0]'");
    }
  }

  void _injectScrapCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'scrap' option for a '${_currentHasOptions.elementType}'");
    }

    THScrapCommandOption(_currentHasOptions, _currentSpec[0]);
  }

  void _injectOrientationCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 1', _currentSpec);
    }

    THOrientationCommandOption.fromString(
        (_currentHasOptions as THPoint), _currentSpec[0]);
  }

  void _injectCopyrightCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 2', _currentSpec);
    }

    final message = _parseTHString(_currentSpec[1]);

    THCopyrightCommandOption.fromString(
        _currentHasOptions, _currentSpec[0], message);
  }

  void _injectCSCommandOption() {
    if (_currentSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THCSCommandOption');
    }

    THCSCommandOption(_currentHasOptions, _currentSpec[0], false);
  }

  void _injectTitleCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 1', _currentSpec);
    }

    final stringContent = _parseTHString(_currentSpec[0]);

    THTitleCommandOption(_currentHasOptions, stringContent);
  }

  void _injectTextCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          '== 1', _currentSpec);
    }

    final stringContent = _parseTHString(_currentSpec[0]);

    THTextCommandOption(_currentHasOptions, stringContent);
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

  void _injectAltitudeValueCommandOption() {
    final parseType = _currentSpec[0].toString();
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
            _currentHasOptions, specs[1], true, unit);
      case 'hyphen':
      case 'nan':
        THAltitudeValueCommandOption.fromNan(_currentHasOptions);
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
            _currentHasOptions, specs[0], false, unit);
      case 'single_number':
        THAltitudeValueCommandOption.fromString(
            _currentHasOptions, specs, false);
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectAltitudeValueCommandOption'.");
    }
  }

  void _injectDateValueCommandOption() {
    final parseType = _currentSpec[0].toString();
    final specs = _currentSpec[1];

    switch (parseType) {
      case 'datetime':
      case 'hyphen':
        if (specs is! String) {
          throw THCustomException("Need a string value.");
        }
        THDateValueCommandOption.fromString(_currentHasOptions, specs);
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectDateValueCommandOption'.");
    }
  }

  void _injectDimensionsValueCommandOption() {
    final parseType = _currentSpec[0].toString();
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
            _currentHasOptions, specs[0], specs[1], unit);
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectDimensionsValueCommandOption'.");
    }
  }

  void _injectHeightValueCommandOption() {
    final parseType = _currentSpec[0].toString();
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
        THHeightValueCommandOption.fromString(
            _currentHasOptions, value, isPresumed, unit);
      case 'single_number':
        THHeightValueCommandOption.fromString(_currentHasOptions, specs, false);
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectHeightValueCommandOption'.");
    }
  }

  void _injectPassageHeightValueCommandOption() {
    final parseType = _currentSpec[0].toString();
    final specs = _currentSpec[1];

    switch (parseType) {
      case 'single_number':
        THPassageHeightValueCommandOption.fromString(
            _currentHasOptions, specs, '');
      case 'plus_number_minus_number':
        THPassageHeightValueCommandOption.fromString(
            _currentHasOptions, specs[0], specs[1]);
      default:
        throw THCustomException(
            "Unsuported parse type '$parseType' in '_injectPassageHeightValueCommandOption'.");
    }
  }

  String _parseTHString(String aString) {
    final parsed = aString.replaceAll(_doubleQuoteRegex, thDoubleQuote);

    return parsed;
  }

  void _injectUnrecognizedCommandOption() {
    throw THCustomException(
        "Creating THUnrecognizedCommandOption!!. Parameters available:\n\n'${_currentSpec.toString()}'\n\n");
    // THUnrecognizedCommandOption(_currentHasOptions, aSpec.toString());
  }

  void _addError(String aErrorMessage, String aLocation, String aLocalInfo) {
    var errorMessage =
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

    for (final aValue in _currentSpec) {
      if (unitFound) {
        throw THCustomWithListParameterException(
            "Unknown element after unit found when creating a THScaleCommandOption object.",
            _currentSpec);
      }
      final newDouble = double.tryParse(aValue);

      if (newDouble == null) {
        if (values.isEmpty) {
          throw THCustomException(
              "Can´t create THScaleCommandOption object without any value.");
        }
        unit = THLengthUnitPart.fromString(aValue);
        unitFound = true;
      } else {
        values.add(THDoublePart.fromString(aValue));
      }
    }

    THScrapScaleCommandOption(_currentHasOptions, values, unit);
  }

  void _injectProjectionCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException('> 0', _currentSpec);
    }

    if (_currentSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THProjectionCommandOption');
    }

    final newProjectionOption = THProjectionCommandOption.fromString(
        _currentHasOptions, _currentSpec[0]);

    if (_currentSpec.length == 1) {
      return;
    }

    if (_currentSpec[1] != null) {
      newProjectionOption.index = _currentSpec[1];
    }
    if (newProjectionOption.type == THProjectionTypes.elevation) {
      if (_currentSpec[2] != null) {
        newProjectionOption.elevationAngleFromString(_currentSpec[2]);
      }

      if (_currentSpec[3] != null) {
        newProjectionOption.elevationUnitFromString(_currentSpec[3]);
      }
    }
  }

  void _injectUnknown(List<dynamic> aElement) {
    THUnrecognizedCommand(_currentParent, aElement);
  }

  @useResult
  Future<String> _decodeFile(RandomAccessFile aRaf, String encoding) async {
    await aRaf.setPosition(0);
    final fileSize = await aRaf.length();
    final fileContentRaw = await aRaf.read(fileSize);
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
  Future<String> _encodingNameFromFile(RandomAccessFile aRaf) async {
    var line = '';
    int byte;
    var priorChar = '';
    var charsRead = 0;

    await aRaf.setPosition(0);
    while ((charsRead < thMaxEncodingLength) &
        ((byte = await aRaf.readByte()) != -1)) {
      charsRead++;
      // print("Byte: '$byte'");
      final char = utf8.decode([byte]);

      if (_isEncodingDelimiter(priorChar, char)) {
        break;
      }

      line += char;
      priorChar = char;
    }
    // print("Line: '$line'");

    final encoding = _encodingRegex.firstMatch(line);
    // print("Encoding object: '$encoding");
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
  Future<(THFile, bool, List<String>)> parse(String aFilePath,
      {Parser? alternateStartParser}) async {
    if (alternateStartParser == null) {
      _newRootParser(_th2FileFirstLineParser);
      _resetParsersLineage();
      _newRootParser(_th2FileParser);
      _runTraceParser = false;
    } else {
      _newRootParser(alternateStartParser);
      _resetParsersLineage();
      _runTraceParser = true;
    }

    _parsedTHFile = THFile();
    _parsedTHFile.filename = aFilePath;
    _currentParent = _parsedTHFile;
    _parseErrors.clear();

    try {
      final file = File("./test/auxiliary/$aFilePath");
      final raf = await file.open();

      _parsedTHFile.encoding = await _encodingNameFromFile(raf);

      var contents = await _decodeFile(raf, _parsedTHFile.encoding);

      _splitContents(contents);

      await raf.close();
    } catch (e) {
      stderr.writeln('failed to read file: \n$e');
    }

    _injectContents();

    if (_currentParent != _parsedTHFile) {
      _addError('Multiline commmands left open at end of file', 'parse',
          'Unclosed multiline command: "${_currentParent.toString()}"');
    }

    return (_parsedTHFile, _parseErrors.isEmpty, _parseErrors);
  }

  void _splitContents(String aContents) {
    _splittedContents = [];
    var lastLine = '';
    while (aContents.isNotEmpty) {
      var lineBreakIndex = aContents.indexOf(thLineBreak);
      if (lineBreakIndex == -1) {
        lastLine += aContents;
        break;
      }
      var newLine = aContents.substring(0, lineBreakIndex);
      aContents = aContents.substring(lineBreakIndex + 1);
      if (newLine.isEmpty) {
        _splittedContents.add("$lastLine$newLine");
        lastLine = '';
        continue;
      }
      var quoteCount = THFileAux.countCharOccurrences(newLine, thDoubleQuote);

      // Joining lines that end with a line break inside a quoted string, i.e.,
      // the line break belongs to the string content.
      while (quoteCount.isOdd && aContents.isNotEmpty) {
        lineBreakIndex = aContents.indexOf(thLineBreak);
        newLine += aContents.substring(0, lineBreakIndex);
        aContents = aContents.substring(lineBreakIndex + 1);
        quoteCount = THFileAux.countCharOccurrences(newLine, thDoubleQuote);
      }

      // Joining next line if this line ends with a backslash.
      final lastChar = newLine.substring(newLine.length - 1);
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
