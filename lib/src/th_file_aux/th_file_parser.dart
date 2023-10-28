import 'dart:io';
import 'dart:convert';
import 'package:dart_numerics/dart_numerics.dart';
import 'package:mapiah/src/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_cs_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_projection_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_scale_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_sketch_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_stations_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_unrecognized_command_option.dart';
import 'package:mapiah/src/th_elements/th_comment.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_empty_line.dart';
import 'package:mapiah/src/th_elements/th_encoding.dart';
import 'package:mapiah/src/th_elements/th_endcomment.dart';
import 'package:mapiah/src/th_elements/th_endscrap.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_multilinecomment.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_elements/th_unrecognized_command.dart';
import 'package:mapiah/src/th_file_aux/th_file_aux.dart';
import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:mapiah/src/th_parts/th_angle_unit_part.dart';
import 'package:mapiah/src/th_parts/th_cs_part.dart';
import 'package:mapiah/src/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_parts/th_length_unit_part.dart';
import 'package:mapiah/src/th_parts/th_point_part.dart';
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
    _currentElement = THComment(_currentParent, content);
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

      final newOption = THCommandOption.scrapOption(
          optionType, _currentElement as THHasOptions);

      switch (optionType) {
        case 'cs':
          _specCSCommandOption(newOption as THCSCommandOption, aOption[1]);
        case 'projection':
          _specProjectionCommandOption(
              newOption as THProjectionCommandOption, aOption[1]);
        case 'scale':
          _specScaleCommandOption(
              newOption as THScaleCommandOption, aOption[1]);
        case 'sketch':
          _specSketchCommandOption(
              newOption as THSketchCommandOption, aOption[1]);
        case 'stations':
          _specStationsCommandOption(
              newOption as THStationsCommandOption, aOption[1]);
        default:
          _specUnrecognizedCommandOption(
              newOption as THUnrecognizedCommandOption, aOption[1]);
      }
    }
  }

  void _specSketchCommandOption(
      THSketchCommandOption aCommandOption, List<dynamic> aSpec) {
    if (aSpec.isEmpty) {
      return;
    }

    if ((aSpec[0] == null) ||
        (aSpec[1] == null) ||
        (aSpec[1] is! List) ||
        ((aSpec[1] as List).length != 2)) {
      return;
    }

    aCommandOption.filename = aSpec[0];

    final aPoint = THPointPart.fromStringList(aSpec[1]);

    aCommandOption.point = aPoint;
  }

  void _specStationsCommandOption(
      THStationsCommandOption aCommandOption, List<dynamic> aSpec) {
    if (aSpec.isEmpty) {
      return;
    }
    var stations = aSpec[0].toString().split(',');

    for (final station in stations) {
      aCommandOption.stations.add(station);
    }
  }

  void _specCSCommandOption(
      THCSCommandOption aCommandOption, List<dynamic> aSpec) {
    if (aSpec[0] != null) {
      if (THCSPart.isCS(aSpec[0])) {
        final aCS = THCSPart(aSpec[0]);
        aCommandOption.coordinateSystem = aCS;
      }
    }
  }

  void _specUnrecognizedCommandOption(
      THUnrecognizedCommandOption aCommandOption, List<dynamic> aSpec) {
    aCommandOption.value = aSpec.toString();
  }

  void _addError(String aErrorMessage, String aLocation, String aLocalInfo) {
    var errorMessage =
        "'$aErrorMessage' at '$aLocation' with '$aLocalInfo' local info.";
    _parseErrors.add(errorMessage);
  }

  void _specScaleCommandOption(
      THScaleCommandOption aCommandOption, List<dynamic> aSpec) {
    aCommandOption.numericSpecifications.clear();
    aCommandOption.unitValue = null;

    var hasUnit = false;
    for (var aValue in aSpec) {
      if (hasUnit) {
        _addError('Unsupported scale option parameter after unit',
            '_specScaleCommandOption', aSpec.toString());
      }

      var isDouble = double.tryParse(aValue);
      if ((isDouble == null) && !hasUnit) {
        if (!THLengthUnitPart.isUnit(aValue)) {
          _addError('Unknown length unit', '_specScaleCommandOption',
              aSpec.toString());
        }

        final newUnit = THLengthUnitPart.fromString(aValue);
        aCommandOption.unitValue = newUnit;
        hasUnit = true;
        continue;
      }

      final newDouble = THDoublePart.fromString(aValue);
      aCommandOption.numericSpecifications.add(newDouble);
    }
  }

  void _specProjectionCommandOption(
      THProjectionCommandOption aCommandOption, List<dynamic> aSpec) {
    aCommandOption.projectionType = null;
    aCommandOption.projectionIndex = null;
    aCommandOption.elevationAngleValue = null;
    aCommandOption.elevationAngleUnit = null;

    if (aSpec.isEmpty) {
      return;
    }

    final String type = aSpec[0];
    if (!THProjectionCommandOption.typeNames.containsKey(type)) {
      return;
    }

    aCommandOption.projectionType = THProjectionCommandOption.typeNames[type];

    if (aSpec.length == 1) {
      return;
    }

    if (aSpec[1] != null) {
      aCommandOption.projectionIndex = aSpec[1];
    }
    if (aCommandOption.projectionType == THProjectionTypes.elevation) {
      if (aSpec[2] != null) {
        var newDouble = double.tryParse(aSpec[2]);
        if (newDouble != null) {
          aCommandOption.elevationAngleValue =
              THDoublePart.fromString(aSpec[2]);
        }
      }

      if ((aSpec[3] != null) && (THAngleUnitPart.isUnit(aSpec[3]))) {
        aCommandOption.elevationAngleUnit =
            THAngleUnitPart.fromString(aSpec[3]);
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
