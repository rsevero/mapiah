import 'dart:io';
import 'dart:convert';
import 'package:charset/charset.dart';

import 'package:mapiah/src/th_grammar.dart';

Future<String> readTestFile(String aFilePath) async {
  try {
    // var currentDir = Directory.current.path;
    // print(currentDir);

    var file = File("./test/auxiliary/$aFilePath");
    var raf = await file.open();

    var encoding = await encodingNameFromFile(raf);

    var contents = await decodeFile(raf, encoding);
    await raf.close();

    return contents;
  } catch (e) {
    stderr.writeln('failed to read file: \n$e');
  }
  throw '';
}

Future<String> decodeFile(RandomAccessFile aRaf, String encoding) async {
  await aRaf.setPosition(0);
  var fileSize = await aRaf.length();
  var fileContentRaw = await aRaf.read(fileSize);
  String fileContentDecoded = '';

  switch (encoding) {
    case 'UTF-8':
      fileContentDecoded = utf8.decode(fileContentRaw);
    case 'ASCII':
      fileContentDecoded = ascii.decode(fileContentRaw);
    case 'ISO8859-1':
      fileContentDecoded = latin1.decode(fileContentRaw);
    default:
      // Therion ISO charset names don´t have a hiphen after ISO but charset.dart
      // expects one.
      var isoRegex = RegExp(r'^iso([^_-].*)', caseSensitive: false);
      var isoResult = isoRegex.firstMatch(encoding);
      if (isoResult != null) {
        encoding = 'ISO-${isoResult[1]}';
      }
      var encoder = Charset.getByName(encoding);
      if (encoder == null) {
        fileContentDecoded = utf8.decode(fileContentRaw);
      } else {
        fileContentDecoded = encoder.decode(fileContentRaw);
      }
  }

  return fileContentDecoded;
}

Future<String> encodingNameFromFile(RandomAccessFile aRaf) async {
  var line = '';
  int byte;
  var priorChar = '';

  await aRaf.setPosition(0);
  while ((byte = await aRaf.readByte()) != -1) {
    // print("Byte: '$byte'");
    var char = utf8.decode([byte]);

    if (isEncodingDelimiter(priorChar, char)) {
      break;
    }

    line += char;
    priorChar = char;
  }
  // print("Line: '$line'");

  final encodingRegex =
      RegExp(r'^\s*encoding\s+([a-zA-Z0-9-]+)', caseSensitive: false);

  var encoding = encodingRegex.firstMatch(line);
  // print("Encoding object: '$encoding");
  if (encoding == null) {
    return thDefaultEncoding;
  } else {
    return encoding[1]!.toUpperCase();
  }
}

bool isEncodingDelimiter(String priorChar, String char,
    [String lineDelimiter = '\n']) {
  if (lineDelimiter.length == 1) {
    return ((char == lineDelimiter) | (char == thCommentChar));
  } else {
    return (((priorChar + char) == lineDelimiter) | (char == thCommentChar));
  }
}
