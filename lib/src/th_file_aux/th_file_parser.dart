import 'dart:io';
import 'dart:convert';
import 'package:mapiah/src/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_projection_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_scale_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_unrecognized_command_option.dart';
import 'package:mapiah/src/th_elements/th_comment.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_encoding.dart';
import 'package:mapiah/src/th_elements/th_endscrap.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_elements/th_unrecognized_command.dart';
import 'package:mapiah/src/th_file_aux/th_file_aux.dart';
import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:mapiah/src/th_parts/th_angle_unit_part.dart';
import 'package:mapiah/src/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_parts/th_length_unit_part.dart';
import 'package:meta/meta.dart';
import 'package:charset/charset.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';

class THFileParser {
  final _grammar = THGrammar();
  late Parser _parser;
  late List<String> _splittedContents;
  late THFile _parsedTHFile;
  late THParent _currentParent;
  late THElement _currentElement;
  bool _runTraceParser = false;

  void _injectContents() {
    for (String line in _splittedContents) {
      if (_runTraceParser) {
        trace(_parser).parse(line);
      }
      final parsedContents = _parser.parse(line);
      if (parsedContents.isFailure) {
        _injectUnknown([line]);
        continue;
      }
      // print("parsedContents.value: '${parsedContents.value}");
      // print(
      //     "parsedContents.value.runtime type: '${parsedContents.value.runtimeType}'");
      final element = parsedContents.value[0];
      // print("element: '$element'");
      if (element.isEmpty) {
        break;
      }
      // print("element[0]: '${element[0]}'");
      final elementType = (element[0] as String).toLowerCase();
      switch (elementType) {
        case 'encoding':
          _injectEncoding();
        case 'endscrap':
          _injectEndscrap(element);
        case 'fulllinecomment':
          _injectComment(element);
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
        case 'projection':
          _specProjectionCommandOption(
              newOption as THProjectionCommandOption, aOption[1]);
        case 'scale':
          _specScaleCommandOption(
              newOption as THScaleCommandOption, aOption[1]);
        default:
          _specUnrecognizedCommandOption(
              newOption as THUnrecognizedCommandOption, aOption[1]);
      }
    }
  }

  void _specUnrecognizedCommandOption(
      THUnrecognizedCommandOption aCommandOption, List<dynamic> aSpec) {
    aCommandOption.value = aSpec.toString();
  }

  void _specScaleCommandOption(
      THScaleCommandOption aCommandOption, List<dynamic> aSpec) {
    aCommandOption.numericSpecifications.clear();
    aCommandOption.unitValue = null;

    var hasUnit = false;
    for (var aValue in aSpec) {
      if (hasUnit) {
        throw 'Unsupported scale option parameter after unit.';
      }

      var isDouble = double.tryParse(aValue);
      if ((isDouble == null) && !hasUnit) {
        if (!THLengthUnitPart.isUnit(aValue)) {
          throw 'Unknown length unit.';
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
  Future<THFile> parse(String aFilePath, {Parser? startParser}) async {
    if (startParser == null) {
      _parser = _grammar.buildFrom(_grammar.start());
      _runTraceParser = false;
    } else {
      _parser = _grammar.buildFrom(startParser);
      _runTraceParser = true;
    }

    _parsedTHFile = THFile();
    _currentParent = _parsedTHFile;

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

    return _parsedTHFile;
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
