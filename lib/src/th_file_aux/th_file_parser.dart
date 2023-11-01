import 'dart:collection';
import 'dart:io';
import 'dart:convert';
import 'package:mapiah/src/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_author_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_clip_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_copyright_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_cs_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_dist_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_from_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_multiple_choice_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_orientation_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_projection_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_scrap_scale_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_sketch_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_station_names_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_stations_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_subtype_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_title_command_option.dart';
import 'package:mapiah/src/th_elements/th_comment.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_empty_line.dart';
import 'package:mapiah/src/th_elements/th_encoding.dart';
import 'package:mapiah/src/th_elements/th_endcomment.dart';
import 'package:mapiah/src/th_elements/th_endscrap.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_multiline_comment_content.dart';
import 'package:mapiah/src/th_elements/th_multilinecomment.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_elements/th_point_scale_command_option.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_elements/th_unrecognized_command.dart';
import 'package:mapiah/src/th_errors/th_options_list_wrong_length_error.dart';
import 'package:mapiah/src/th_exceptions/th_create_object_from_empty_list_exception.dart';
import 'package:mapiah/src/th_exceptions/th_create_object_from_null_value_exception.dart';
import 'package:mapiah/src/th_exceptions/th_create_object_without_list.dart';
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

  late final Parser _th2FileParser;
  late final Parser _th2FileFirstLineParser;
  late final Parser _scrapParser;
  late final Parser _multiLineCommentContentParser;

  final List<Parser> _parentParsers = [];

  late Parser _rootParser;
  late Parser _currentParser;

  late List<String> _splittedContents;
  late THFile _parsedTHFile;
  late THParent _currentParent;
  late THElement _currentElement;
  late THHasOptions _currentHasOptions;
  late List<dynamic> _currentOptions;
  late List<dynamic> _currentSpec;
  final _parsedOptions = HashSet<String>();
  bool _runTraceParser = false;

  final List<String> _parseErrors = [];

  final _doubleQuoteRegex = RegExp(thDoubleQuotePair);
  final _encodingRegex =
      RegExp(r'^\s*encoding\s+([a-zA-Z0-9-]+)', caseSensitive: false);
  final _isoRegex = RegExp(r'^iso([^_-].*)', caseSensitive: false);

  THFileParser() {
    _th2FileParser = _grammar.buildFrom(_grammar.thFileStart());
    _th2FileFirstLineParser =
        _grammar.buildFrom(_grammar.th2FileFirstLineStart());
    _scrapParser = _grammar.buildFrom(_grammar.scrapStart());
    _multiLineCommentContentParser =
        _grammar.buildFrom(_grammar.multiLineCommentStart());
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
      if (line.isEmpty) {
        _injectEmptyLine();
        continue;
      }
      if (_runTraceParser) {
        trace(_currentParser).parse(line);
      }

      final parsedContents = _currentParser.parse(line);
      if (isFirst) {
        isFirst = false;
        _resetParsersLineage();
      }
      if (parsedContents is Failure) {
        // trace(_currentParser).parse(line);
        _addError('petitparser returned a "Failure"', '_injectContents()',
            'Line being parsed: "$line"');
        continue;
      }

      final element = parsedContents.value[0];
      if (element.isEmpty) {
        _addError('element.isEmpty', '_injectContents()',
            'Line being parsed: "$line"');
        continue;
      }

      final elementType = (element[0] as String).toLowerCase();
      switch (elementType) {
        case 'encoding':
          _injectEncoding();
        case 'endmultilinecomment':
          _injectEndMultiLineComment();
        case 'endscrap':
          _injectEndscrap(element);
        case 'fulllinecomment':
          _injectComment(element);
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
      _injectComment(parsedContents.value[1]);
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
    _currentParent = _currentParent.parent;
    _currentElement = THEndcomment(_currentParent);
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

    _checkParsedListAsPoint('_injectPoint', aElement[1]);

    assert(aElement[2] is List);
    assert(aElement[2].length == 2);

    final newPoint =
        THPoint.fromString(_currentParent, aElement[1], aElement[2][0]);

    _currentElement = newPoint;

    _parsedOptions.clear();

    try {
      // Including subtype defined with type (type:subtype).
      if (aElement[2][1] != null) {
        THSubtypeCommandOption(newPoint, aElement[2][1]);
        _parsedOptions.add('subtype');
      }
    } catch (e, s) {
      _addError("$e\n\nTrace:\n\n$s", '_pointOptionFromElement',
          aElement[2][1].toString());
    }

    _optionFromElement(aElement[3], _pointRegularOptions);
  }

  void _injectScrap(List<dynamic> aElement) {
    final elementSize = aElement.length;
    assert(elementSize >= 2);
    final newScrap = THScrap(_currentParent, aElement[1]);

    _currentElement = newScrap;
    _currentParent = newScrap;

    _parsedOptions.clear();
    _optionFromElement(aElement[2], _scrapRegularOptions);
    _addChildParser(_scrapParser);
  }

  void _injectEndscrap(List<dynamic> aElement) {
    _currentParent = _currentParent.parent;
    _currentElement = THEndscrap(_currentParent);
    _returnToParentParser();
  }

  void _injectComment(List<dynamic>? aElement) {
    if (aElement == null) {
      return;
    }

    if (aElement.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THComment', '== 2', aElement);
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
        _currentElement.sameLineComment = aElement[1];
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

      if (_parsedOptions.contains(optionType)) {
        final elementType = _currentElement.type;
        _addError("Duplicated option '$optionType' in $elementType.",
            '_optionFromElement', aElement.toString());
        continue;
      }

      _currentSpec = _currentOptions[1];
      _currentHasOptions = _currentElement as THHasOptions;
      _parsedOptions.add(optionType);

      try {
        if (createRegularOption(optionType)) {
          continue;
        }

        if (THMultipleChoiceCommandOption.hasOptionType(
            _currentHasOptions.type, optionType)) {
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
      case 'dist':
        _injectDistCommandOption();
      case 'from':
        _injectFromCommandOption();
      case 'orientation':
        _injectOrientationCommandOption();
      case 'scale':
        _injectPointScaleCommandOption();
      case 'subtype':
        _injectSubtypeCommandOption();
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

  void _injectMultipleChoiceCommandOption(String aOptionType) {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a '$aOptionType' option for a '${_currentHasOptions.type}'");
    }

    if (_currentSpec[0] is! String) {
      throw THCustomException(
          "One string parameter required to create a '$aOptionType' option for a '${_currentHasOptions.type}'");
    }

    THMultipleChoiceCommandOption(
        _currentHasOptions, aOptionType, _currentSpec[0]);
  }

  void _checkParsedListAsPoint(String objectType, List<dynamic> aList) {
    if (aList.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          objectType, '== 2', _currentSpec[1]);
    }
  }

  void _injectClipCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'clip' option for a '${_currentHasOptions.type}'");
    }

    if (_currentSpec[0] is! String) {
      throw THCustomException(
          "One string parameter required to create a 'clip' option for a '${_currentHasOptions.type}'");
    }

    THClipCommandOption(_currentHasOptions, _currentSpec[0]);
  }

  void _injectDistCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'dist' option for a '${_currentHasOptions.type}'");
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

  void _injectFromCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCustomException(
          "One parameter required to create a 'dist' option for a '${_currentHasOptions.type}'");
    }

    THFromCommandOption(_currentHasOptions, _currentSpec[0]);
  }

  void _injectSketchCommandOption() {
    if (_currentSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THSketchCommandOption (0)', '== 2', _currentSpec);
    }

    if (_currentSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THSketchCommandOption (0)');
    }

    _checkParsedListAsPoint('THSketchCommandOption (1)', _currentSpec[1]);

    final filename = _parseTHString(_currentSpec[0]);

    THSketchCommandOption.fromString(
        _currentHasOptions, filename, _currentSpec[1]);
  }

  void _injectStationNamesCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THStationNamesCommandOption', '== 2', _currentSpec);
    }

    THStationNamesCommandOption(
        _currentHasOptions, _currentSpec[0], _currentSpec[1]);
  }

  void _injectStationsCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THStationsCommandOption (0)', '== 1', _currentSpec);
    }

    final stations = _currentSpec[0].toString().split(',');

    if (stations.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THStationsCommandOption (1)', '> 0', stations);
    }

    THStationsCommandOption(_currentHasOptions, stations);
  }

  void _injectAuthorCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THAuthorCommandOption', '== 2', _currentSpec);
    }

    THAuthorCommandOption.fromString(
        _currentHasOptions, _currentSpec[0], _currentSpec[1]);
  }

  void _injectSubtypeCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THSubtypeCommandOption', '== 1', _currentSpec);
    }

    THSubtypeCommandOption((_currentHasOptions as THPoint), _currentSpec[0]);
  }

  void _injectPointScaleCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THPointScaleCommandOption', '== 2', _currentSpec);
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

  void _injectOrientationCommandOption() {
    if (_currentSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THOrientationCommandOption', '== 1', _currentSpec);
    }

    THOrientationCommandOption.fromString(
        (_currentHasOptions as THPoint), _currentSpec[0]);
  }

  void _injectCopyrightCommandOption() {
    if (_currentSpec.length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THCopyrightCommandOption', '== 2', _currentSpec);
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
          'THTitleCommandOption', '== 1', _currentSpec);
    }

    final stringContent = _parseTHString(_currentSpec[0]);

    THTitleCommandOption(_currentHasOptions, stringContent);
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
      throw THCreateObjectFromListWithWrongLengthException(
          'THScaleCommandOption', '> 0', _currentSpec);
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
      throw THCreateObjectFromListWithWrongLengthException(
          'THProjectionCommandOption', '> 0', _currentSpec);
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
