import 'dart:io';
import 'dart:convert';
import 'package:mapiah/src/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_cs_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_flip_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_projection_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_scale_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_sketch_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_stations_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_unrecognized_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_walls_command_option.dart';
import 'package:mapiah/src/th_elements/th_comment.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_empty_line.dart';
import 'package:mapiah/src/th_elements/th_encoding.dart';
import 'package:mapiah/src/th_elements/th_endcomment.dart';
import 'package:mapiah/src/th_elements/th_endscrap.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_multiline_comment_content.dart';
import 'package:mapiah/src/th_elements/th_multilinecomment.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_elements/th_unrecognized_command.dart';
import 'package:mapiah/src/th_exceptions/th_create_object_from_empty_list_exception.dart';
import 'package:mapiah/src/th_exceptions/th_create_object_from_null_value_exception.dart';
import 'package:mapiah/src/th_exceptions/th_create_object_without_list.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';
import 'package:mapiah/src/th_exceptions/th_custom_with_list_parameter_exception.dart';
import 'package:mapiah/src/th_file_aux/th_file_aux.dart';
import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:mapiah/src/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_parts/th_length_unit_part.dart';
import 'package:meta/meta.dart';
import 'package:charset/charset.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';

class THFileParser {
  final _grammar = THGrammar();
  late Parser _parserMain;
  late Parser _parserFirst;
  late Parser _currentParser;
  late Parser _multiLineCommentContentParser;
  late List<String> _splittedContents;
  late THFile _parsedTHFile;
  late THParent _currentParent;
  late THElement _currentElement;
  late THHasOptions _currentHasOptions;
  bool _runTraceParser = false;
  final List<String> _parseErrors = [];

  void _injectContents() {
    var isFirst = true;
    _currentParser = _parserFirst;
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
        _currentParser = _parserMain;
      }
      if (parsedContents is Failure) {
        _addError('petitparser returned a "Failure"', '_injectContents()',
            'Line being parsed: "$line"');
        continue;
      }
      // print("parsedContents.value: '${parsedContents.value}");
      // print(
      //     "parsedContents.value.runtime type: '${parsedContents.value.runtimeType}'");
      final element = parsedContents.value[0];
      // print("element: '$element'");
      if (element.isEmpty) {
        _addError('element.isEmpty', '_injectContents()',
            'Line being parsed: "$line"');
        continue;
      }
      // print("element[0]: '${element[0]}'");
      final elementType = (element[0] as String).toLowerCase();
      switch (elementType) {
        case 'comment':
          _injectMultiLineComment();
        case 'encoding':
          _injectEncoding();
        case 'endcomment':
          _injectEndComment();
        case 'endscrap':
          _injectEndscrap(element);
        case 'fulllinecomment':
          _injectComment(element);
          continue;
        case 'multilinecommentline':
          _injectMultiLineCommentContent(element);
          continue;
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

  void _injectEndComment() {
    _currentParent = _currentParent.parent;
    _currentElement = THEndcomment(_currentParent);
    _currentParser = _parserMain;
  }

  void _injectMultiLineComment() {
    _currentParent = THMultiLineComment(_currentParent);
    _currentElement = _currentParent;
    _currentParser = _multiLineCommentContentParser;
  }

  void _injectEncoding() {
    _currentElement = THEncoding(_currentParent);
  }

  void _injectScrap(List<dynamic> aElement) {
    final elementSize = aElement.length;
    assert(elementSize >= 2);
    final newScrap = THScrap(_currentParent, aElement[1]);

    _currentElement = newScrap;
    _currentParent = newScrap;

    _scrapOptionFromElement(aElement[2]);
  }

  void _injectEndscrap(List<dynamic> aElement) {
    _currentParent = _currentParent.parent;
    _currentElement = THEndscrap(_currentParent);
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

  void _scrapOptionFromElement(List<dynamic> aElement) {
    // if (aElement == null) {
    //   return;
    // }
    for (var aOption in aElement) {
      if (aOption == null) {
        continue;
      }
      final optionType = aOption[0].toString().toLowerCase();

      // final newOption = THCommandOption.scrapOption(
      //     optionType, _currentElement as THHasOptions);
      _currentHasOptions = _currentElement as THHasOptions;

      try {
        switch (optionType) {
          case 'cs':
            _injectCSCommandOption(aOption[1]);
          case 'flip':
            _injectFlipCommandOption(aOption[1]);
          case 'projection':
            _injectProjectionCommandOption(aOption[1]);
          case 'scale':
            _injectScaleCommandOption(aOption[1]);
          case 'sketch':
            _injectSketchCommandOption(aOption[1]);
          case 'stations':
            _injectStationsCommandOption(aOption[1]);
          case 'walls':
            _injectWallsCommandOption(aOption[1]);
          default:
            _injectUnrecognizedCommandOption(aOption[1]);
        }
      } catch (e, s) {
        _addError("$e\n\nTrace:\n\n$s", '_scrapOptionFromElement',
            aOption.toString());
      }
    }
  }

  void _injectFlipCommandOption(List<dynamic> aSpec) {
    if (aSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THFlipCommandOption', '> 0', aSpec);
    }

    if (aSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THFlipCommandOption');
    }

    THFlipCommandOption.fromString(_currentHasOptions, aSpec[0]);
  }

  void _injectWallsCommandOption(List<dynamic> aSpec) {
    if (aSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THWallsCommandOption', '> 0', aSpec);
    }

    if (aSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THWallsCommandOption');
    }

    THWallsCommandOption.fromString(_currentHasOptions, aSpec[0]);
  }

  void _injectSketchCommandOption(List<dynamic> aSpec) {
    if (aSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THSketchCommandOption (0)', '== 2', aSpec);
    }

    if (aSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THSketchCommandOption (0)');
    }

    if (aSpec[1] == null) {
      throw THCreateObjectFromNullValueException('THSketchCommandOption (1)');
    }

    if (aSpec[1] is! List) {
      throw THCreateObjectWithoutListException(
          'THSketchCommandOption', aSpec[1]);
    }

    if ((aSpec[1] as List).length != 2) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THSketchCommandOption (1)', '== 2', aSpec[1]);
    }

    THSketchCommandOption.fromString(_currentHasOptions, aSpec[0], aSpec[1]);
  }

  void _injectStationsCommandOption(List<dynamic> aSpec) {
    if (aSpec.length != 1) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THStationsCommandOption (0)', '== 1', aSpec);
    }

    final stations = aSpec[0].toString().split(',');

    if (stations.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THStationsCommandOption (1)', '> 0', stations);
    }

    THStationsCommandOption(_currentHasOptions, stations);
  }

  void _injectCSCommandOption(List<dynamic> aSpec) {
    if (aSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THCSCommandOption');
    }

    THCSCommandOption(_currentHasOptions, aSpec[0], false);
  }

  void _injectUnrecognizedCommandOption(List<dynamic> aSpec) {
    // throw THCustomException(
    //     "Creating THUnrecognizedCommandOption!!. Parameters available:\n\n'${aSpec.toString()}'\n\n");
    THUnrecognizedCommandOption(_currentHasOptions, aSpec.toString());
  }

  void _addError(String aErrorMessage, String aLocation, String aLocalInfo) {
    var errorMessage =
        "'$aErrorMessage' at '$aLocation' with '$aLocalInfo' local info.";
    _parseErrors.add(errorMessage);
  }

  void _injectScaleCommandOption(List<dynamic> aSpec) {
    if (aSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THScaleCommandOption', '> 0', aSpec);
    }

    final List<THDoublePart> values = [];
    THLengthUnitPart? unit;
    bool unitFound = false;

    for (final aValue in aSpec) {
      if (unitFound) {
        throw THCustomWithListParameterException(
            "Unknown element after unit found when creating a THScaleCommandOption object.",
            aSpec);
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

    THScaleCommandOption(_currentHasOptions, values, unit);
  }

  void _injectProjectionCommandOption(List<dynamic> aSpec) {
    if (aSpec.isEmpty) {
      throw THCreateObjectFromListWithWrongLengthException(
          'THProjectionCommandOption', '> 0', aSpec);
    }

    if (aSpec[0] == null) {
      throw THCreateObjectFromNullValueException('THProjectionCommandOption');
    }

    final newProjectionOption =
        THProjectionCommandOption.fromString(_currentHasOptions, aSpec[0]);

    if (aSpec.length == 1) {
      return;
    }

    if (aSpec[1] != null) {
      newProjectionOption.index = aSpec[1];
    }
    if (newProjectionOption.type == THProjectionTypes.elevation) {
      if (aSpec[2] != null) {
        newProjectionOption.elevationAngleFromString(aSpec[2]);
      }

      if (aSpec[3] != null) {
        newProjectionOption.elevationUnitFromString(aSpec[3]);
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
        final isoRegex = RegExp(r'^iso([^_-].*)', caseSensitive: false);
        final isoResult = isoRegex.firstMatch(encoding);
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

    final encodingRegex =
        RegExp(r'^\s*encoding\s+([a-zA-Z0-9-]+)', caseSensitive: false);

    final encoding = encodingRegex.firstMatch(line);
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
      {Parser? startParser}) async {
    if (startParser == null) {
      _parserMain = _grammar.buildFrom(_grammar.start());
      _parserFirst = _grammar.buildFrom(_grammar.startFirst());
      _runTraceParser = false;
    } else {
      _parserMain = _grammar.buildFrom(startParser);
      _parserFirst = _parserMain;
      _runTraceParser = true;
    }
    _multiLineCommentContentParser =
        _grammar.buildFrom(_grammar.multiLineCommentContent());

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
      var quoteCount = THFileAux.countCharOccurrences(newLine, thQuote);

      // Joining lines that end with a line break inside a quoted string, i.e.,
      // the line break belongs to the string content.
      while (quoteCount.isOdd && aContents.isNotEmpty) {
        lineBreakIndex = aContents.indexOf(thLineBreak);
        newLine += aContents.substring(0, lineBreakIndex);
        aContents = aContents.substring(lineBreakIndex + 1);
        quoteCount = THFileAux.countCharOccurrences(newLine, thQuote);
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
