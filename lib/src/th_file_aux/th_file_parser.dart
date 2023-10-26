import 'dart:io';
import 'dart:convert';
import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_projection_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_scale_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_unrecognized_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_same_line_comment.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_elements/th_unrezognized_command.dart';
import 'package:meta/meta.dart';
import 'package:charset/charset.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';

import 'package:mapiah/src/th_file_aux/th_grammar.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_definitions.dart';

class THFileParser {
  final grammar = THGrammar();
  late Parser parser;
  var contents = '';
  THFile _parsedTHFile = THFile();
  late THParent _currentParent;
  late THHasOptions _currentElement;

  THFileParser() {
    parser = grammar.buildFrom(grammar.start());
    _currentParent = _parsedTHFile;
  }

  @useResult
  Future<THFile> parse(String aFilePath) async {
    _parsedTHFile = THFile();
    _currentParent = _parsedTHFile;

    try {
      final file = File("./test/auxiliary/$aFilePath");
      final raf = await file.open();

      _parsedTHFile.encoding = await encodingNameFromFile(raf);

      contents = await decodeFile(raf, _parsedTHFile.encoding);
      await raf.close();
    } catch (e) {
      stderr.writeln('failed to read file: \n$e');
    }

    injectContents();

    return _parsedTHFile;
  }

  void injectContents() {
    // trace(parser!).parse(contents);
    final parsedContents = parser.parse(contents);
    // print("parsedContents.value: '${parsedContents.value}");
    // print(
    //     "parsedContents.value.runtime type: '${parsedContents.value.runtimeType}'");
    // print(
    //     "parsedContents.value[0].runtime type: '${parsedContents.value[0].runtimeType}'");
    for (List<dynamic> element in parsedContents.value) {
      // print("element: '$element'");
      if (element.isEmpty) {
        break;
      }
      final elementType = (element[0] as String).toLowerCase();
      switch (elementType) {
        case 'encoding':
          injectEncoding(element);
        case 'scrap':
          injectScrap(element);
        default:
          injectUnknown(element);
      }
    }
  }

  void injectEncoding(List<dynamic> aElement) {
    // Don't do much as encoding has a special parsing procedure inside parse().
    injectSameLineComment(aElement);
  }

  void injectScrap(List<dynamic> aElement) {
    final elementSize = aElement.length - 1;
    assert(elementSize >= 2);
    final newScrap = THScrap(_currentParent, aElement[1]);

    _currentElement = newScrap;
    _currentParent = newScrap;

    var index = 2;
    while (index < elementSize) {
      index = scrapOptionFromElement(aElement, index);
    }

    injectSameLineComment(aElement);
  }

  void injectSameLineComment(List<dynamic> aElement) {
    final lastItem = aElement[aElement.length - 1];
    if (lastItem == null) {
      return;
    }

    THSameLineComment(_currentParent, lastItem);
  }

  int scrapOptionFromElement(List<dynamic> aElement, int current) {
    final optionType = aElement[current].toString().toLowerCase();
    THCommandOption newOption;

    switch (optionType) {
      case ('projection'):
        newOption = THProjectionCommandOption(
            _currentElement, aElement.sublist(current + 1, current + 1));
        current += 2;
      case ('scale'):
        newOption = THScaleCommandOption(
            _currentElement, aElement.sublist(current + 1, current + 1));
        current += 2;
      default:
        newOption = THUnrecognizedCommandOption(
            _currentElement, aElement.sublist(current));
        current = aElement.length;
    }
    _currentElement.addOption(newOption);

    return current;
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
}
