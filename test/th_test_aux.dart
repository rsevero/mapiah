import 'dart:io';
import 'dart:convert';
import 'package:charset/charset.dart';

import 'package:mapiah/src/th_grammar.dart';

Future<String> readTestFile(String aFilePath) async {
  try {
    // var currentDir = Directory.current.path;
    // print(currentDir);

    final file = File("./test/auxiliary/$aFilePath");
    final raf = await file.open();

    final encoding = await encodingNameFromFile(raf);

    final contents = await decodeFile(raf, encoding);
    await raf.close();

    return contents;
  } catch (e) {
    stderr.writeln('failed to read file: \n$e');
  }
  throw '';
}

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

Future<String> encodingNameFromFile(RandomAccessFile aRaf) async {
  var line = '';
  int byte;
  var priorChar = '';

  await aRaf.setPosition(0);
  while ((byte = await aRaf.readByte()) != -1) {
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

bool isEncodingDelimiter(String priorChar, String char,
    [String lineDelimiter = '\n']) {
  if (lineDelimiter.length == 1) {
    return ((char == lineDelimiter) | (char == thCommentChar));
  } else {
    return (((priorChar + char) == lineDelimiter) | (char == thCommentChar));
  }
}
