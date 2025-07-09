import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/mp_file_read_write/xvi_grammar.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';

class XVIFileParser {
  final XVIGrammar _grammar = XVIGrammar();

  late Parser _xviFileParser;
  final List<Parser> _parentParsers = [];
  late Parser _currentParser;

  final List<String> _errors = [];
  Uint8List _fileBytes = Uint8List(0);
  List<String> _splittedContents = [];
  XVIFile _xviFile = XVIFile();

  bool _runTraceParser = false;
  late Result<dynamic> _parsedContents;

  XVIFileParser() {
    _xviFileParser = _grammar.buildFrom(_grammar.xviFileStart());
  }

  (XVIFile, bool, List<String>) parse(
    String name, {
    Uint8List? fileBytes,
    bool runTraceParser = false,
  }) {
    final File file = File(name);

    _runTraceParser = runTraceParser;
    _errors.clear();

    if (fileBytes == null) {
      if (file.existsSync()) {
        _fileBytes = file.readAsBytesSync();
      } else {
        throw Exception('File does not exist: $name');
      }
    } else {
      _fileBytes = fileBytes;
    }

    _xviFile = XVIFile(
      filename: file.path,
    );
    _splitContentsIntoLines();

    _currentParser = _xviFileParser;
    _injectContents();

    return (_xviFile, _errors.isEmpty, _errors);
  }

  void _splitContentsIntoLines() {
    final String contents = utf8.decode(_fileBytes);

    _splittedContents = contents.split(RegExp(r'\r?\n'));
  }

  void _injectContents() {
    for (final String currentLine in _splittedContents) {
      if (currentLine.trim().isEmpty) {
        continue;
      }

      if (_runTraceParser) {
        trace(_currentParser).parse(currentLine);
      }

      _parsedContents = _currentParser.parse(currentLine);

      if (_parsedContents is Failure) {
        _addError('petitparser returned a "Failure"', '_injectContents()',
            'Line being parsed: "$currentLine"');
        continue;
      }

      final String contentType =
          (_parsedContents.value[0] as Map<String, List<dynamic>>).keys.first;
      final dynamic contentValue =
          (_parsedContents.value[0] as Map<String, List<dynamic>>)[contentType];

      switch (contentType) {
        case 'XVIGrid':
          _injectXVIGrid(contentValue);
        case 'XVIGridSize':
          _injectXVIGridSize(contentValue);
        default:
          _addError(
            'Unknown content type "$contentType"',
            '_injectContents()',
            'Line being parsed: "$currentLine"',
          );
      }
    }
  }

  void _injectXVIGridSize(dynamic contentValue) {
    final List<String> gridSizeValues =
        (contentValue as List<dynamic>).cast<String>();
    if (gridSizeValues.length != 2) {
      _addError(
        'Invalid grid size format',
        '_injectXVIGridSize()',
        'Expected 2 values, got ${gridSizeValues.length}',
      );
      return;
    }

    final double gridSizeLength = double.tryParse(gridSizeValues[0]) ?? 0.0;
    final String gridSizeUnit = gridSizeValues[1].trim();

    _xviFile.gridSizeLength = gridSizeLength;
    _xviFile.gridSizeUnit = THLengthUnitPart.fromString(
      unitString: gridSizeUnit,
    );
  }

  void _injectXVIGrid(dynamic contentValue) {
    final List<String> gridValues =
        (contentValue as List<dynamic>).cast<String>();
    final List<double> gridValuesAsDoubles =
        gridValues.map((value) => double.tryParse(value) ?? 0.0).toList();

    _xviFile.grid = XVIGrid.fromList(gridValuesAsDoubles);
  }

  void _addError(String errorMessage, String location, String localInfo) {
    final String completeErrorMessage =
        "'$errorMessage' at '$location' with '$localInfo' local info.";

    _errors.add(completeErrorMessage);
  }
}
