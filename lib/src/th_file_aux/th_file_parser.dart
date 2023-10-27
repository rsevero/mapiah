import 'dart:io';
import 'dart:convert';
import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_projection_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_scale_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_unrecognized_command_option.dart';
import 'package:mapiah/src/th_elements/th_comment.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_elements/th_unrecognized_command.dart';
import 'package:meta/meta.dart';
import 'package:charset/charset.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';

import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_definitions.dart';

class THFileParser {
  final _grammar = THGrammar();
  late Parser _parser;
  late List<String> _splittedContents;
  late THFile _parsedTHFile;
  late THParent _currentParent;
  late THHasOptions _currentElement;
  bool _runTraceParser = false;

  void injectContents() {
    for (String line in _splittedContents) {
      if (_runTraceParser) {
        trace(_parser).parse(line);
      }
      final parsedContents = _parser.parse(line);
      if (parsedContents.isFailure) {
        injectUnknown([line]);
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
          // Does nothing as encoding has already been parsed at parsed().
          break;
        case 'scrap':
          injectScrap(element);
        case 'fulllinecomment':
          injectComment(element);
          continue;
        default:
          injectUnknown(element);
          continue;
      }
      injectComment(parsedContents.value[1]);
    }
  }

  void injectScrap(List<dynamic> aElement) {
    final elementSize = aElement.length;
    assert(elementSize >= 2);
    final newScrap = THScrap(_currentParent, aElement[1]);

    _currentElement = newScrap;
    _currentParent = newScrap;

    scrapOptionFromElement(aElement[2]);
  }

  void injectComment(List<dynamic>? aElement) {
    if (aElement == null) {
      return;
    }

    switch (aElement[0]) {
      case 'fulllinecomment':
        THComment(_currentParent, aElement[1], false);
      case 'samelinecomment':
        THComment(_currentParent, aElement[1], true);
      default:
        THUnrecognizedCommand(_currentParent, aElement);
    }
  }

  void scrapOptionFromElement(List<dynamic> aElement) {
    // if (aElement == null) {
    //   return;
    // }
    for (var aOption in aElement) {
      if (aOption == null) {
        continue;
      }
      final optionType = aOption[0].toString().toLowerCase();
      THCommandOption newOption;

      switch (optionType) {
        case ('projection'):
          newOption = THProjectionCommandOption(_currentElement, aOption[1]);
        case ('scale'):
          newOption = THScaleCommandOption(_currentElement, aOption[1]);
        default:
          newOption = THUnrecognizedCommandOption(_currentElement, aOption[1]);
      }
    }
  }

  void injectUnknown(List<dynamic> aElement) {
    THUnrecognizedCommand(_currentParent, aElement);
  }

  @useResult
  Future<String> decodeFile(RandomAccessFile aRaf, String encoding) async {
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
  Future<String> encodingNameFromFile(RandomAccessFile aRaf) async {
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

      if (isEncodingDelimiter(priorChar, char)) {
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
  bool isEncodingDelimiter(String priorChar, String char,
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

      _parsedTHFile.encoding = await encodingNameFromFile(raf);

      var contents = await decodeFile(raf, _parsedTHFile.encoding);

      splitContents(contents);

      await raf.close();
    } catch (e) {
      stderr.writeln('failed to read file: \n$e');
    }

    injectContents();

    return _parsedTHFile;
  }

  void splitContents(String aContents) {
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
      var quoteCount = countCharOccurrences(newLine, thQuote);

      // Joining lines that end with a line break inside a quoted string, i.e.,
      // the line break belongs to the string content.
      while (quoteCount.isOdd & aContents.isNotEmpty) {
        lineBreakIndex = aContents.indexOf(thLineBreak);
        newLine += aContents.substring(0, lineBreakIndex);
        aContents = aContents.substring(lineBreakIndex + 1);
        quoteCount = countCharOccurrences(newLine, thQuote);
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

  int countCharOccurrences(String text, String charToCount) {
    int count = 0;
    for (int i = 0; i < text.length; i++) {
      if (text[i] == charToCount) {
        count++;
      }
    }
    return count;
  }
}
