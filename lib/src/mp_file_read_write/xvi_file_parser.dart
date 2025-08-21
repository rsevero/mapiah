import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/elements/xvi/xvi_shot.dart';
import 'package:mapiah/src/elements/xvi/xvi_sketchline.dart';
import 'package:mapiah/src/elements/xvi/xvi_station.dart';
import 'package:mapiah/src/mp_file_read_write/xvi_grammar.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';

class XVIFileParser {
  final XVIGrammar _grammar = XVIGrammar();

  late Parser _xviFileParser;

  final List<String> _errors = [];
  Uint8List _fileBytes = Uint8List(0);
  XVIFile _xviFile = XVIFile();

  bool _runTraceParser = false;

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

    _xviFile = XVIFile(filename: file.path);

    final String contents = utf8.decode(_fileBytes);

    if (_runTraceParser) {
      trace(_xviFileParser).parse(contents);
    }

    final Result<dynamic> result = _xviFileParser.parse(contents);

    if (result is Success) {
      _injectContents(result.value);
    } else {
      _errors.add('Error parsing file: ${result.message}');
    }

    return (_xviFile, _errors.isEmpty, _errors);
  }

  void _injectContents(dynamic contents) {
    for (final Map<String, List<dynamic>> content in contents) {
      final String contentType = content.keys.first;
      final dynamic contentValue = content[contentType];

      switch (contentType) {
        case 'XVIGrid':
          _injectXVIGrid(contentValue);
        case 'XVIGridSize':
          _injectXVIGridSize(contentValue);
        case 'XVIShots':
          _injectShots(contentValue);
        case 'XVISketchLines':
          _injectSketchlines(contentValue);
        case 'XVIStations':
          _injectStations(contentValue);
        default:
          _addError(
            'Unknown content type "$contentType"',
            '_injectContents()',
            'Content being injected: "$content"',
          );
      }
    }
  }

  void _injectSketchlines(dynamic contentValue) {
    final List<dynamic> sketchlinesData = contentValue as List<dynamic>;
    final List<XVISketchLine> sketchlines = [];

    for (final Map<String, dynamic> sketchlineData in sketchlinesData) {
      if (sketchlineData.isEmpty) {
        _addError(
          'Invalid sketchline data format',
          '_injectSketchlines()',
          'Expected a non-empty list, got an empty list',
        );
        continue;
      }

      final String color = sketchlineData['color'] as String;
      final List<String> coordinates =
          (sketchlineData['coordinates'] as List<dynamic>).cast<String>();
      final THPositionPart start = positionFromList(coordinates);

      final List<THPositionPart> points = [];

      while (coordinates.length >= 2) {
        points.add(positionFromList(coordinates));
      }

      sketchlines.add(
        XVISketchLine(color: color, start: start, points: points),
      );
    }

    _xviFile.sketchLines = sketchlines;
  }

  void _injectShots(dynamic contentValue) {
    final List<dynamic> shotsData = contentValue as List<dynamic>;
    final List<XVIShot> shots = [];

    for (final List<dynamic> shotData in shotsData) {
      if (shotData.length != 4) {
        _addError(
          'Invalid shot data format',
          '_injectShots()',
          'Expected a list with 4 elements, got ${shotData.length}',
        );
        continue;
      }

      final THPositionPart startPosition = THPositionPart.fromStrings(
        xAsString: shotData[0],
        yAsString: shotData[1],
      );
      final THPositionPart endPosition = THPositionPart.fromStrings(
        xAsString: shotData[2],
        yAsString: shotData[3],
      );

      shots.add(XVIShot(start: startPosition, end: endPosition));
    }

    _xviFile.shots = shots;
  }

  void _injectStations(dynamic contentValue) {
    final List<dynamic> stationsData = contentValue as List<dynamic>;
    final List<XVIStation> stations = [];

    for (final List<dynamic> stationData in stationsData) {
      if (stationData.length != 3) {
        _addError(
          'Invalid station data format',
          '_injectStations()',
          'Expected a list with 3 elements, got ${stationData.length}',
        );
        continue;
      }

      final String name = (stationData[2] as String).trim();
      final THPositionPart position = THPositionPart.fromStrings(
        xAsString: stationData[0].toString(),
        yAsString: stationData[1].toString(),
      );

      stations.add(XVIStation(position: position, name: name));
    }

    _xviFile.stations = stations;
  }

  void _injectXVIGridSize(dynamic contentValue) {
    final List<String> gridSizeValues = (contentValue as List<dynamic>)
        .cast<String>();
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
    final List<String> gridValues = (contentValue as List<dynamic>)
        .cast<String>();

    _xviFile.grid = XVIGrid.fromStringList(gridValues);
  }

  void _addError(String errorMessage, String location, String localInfo) {
    final String completeErrorMessage =
        "'$errorMessage' at '$location' with '$localInfo' local info.";

    _errors.add(completeErrorMessage);
  }

  /// Removes the first two values from [list] and returns a THPositionPart from them.
  THPositionPart positionFromList(List<String> list) {
    if (list.length < 2) {
      throw ArgumentError('List must have at least 2 elements');
    }

    final String x = list.removeAt(0);
    final String y = list.removeAt(0);

    return THPositionPart.fromStrings(xAsString: x, yAsString: y);
  }
}
