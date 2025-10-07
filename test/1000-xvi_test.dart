import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/elements/xvi/xvi_shot.dart';
import 'package:mapiah/src/elements/xvi/xvi_sketchline.dart';
import 'package:mapiah/src/elements/xvi/xvi_station.dart';
import 'package:mapiah/src/mp_file_read_write/xvi_file_parser.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

const String testFilesPath = 'test/auxiliary/xvi';
const String extension = '.xvi';

String _getFilePath(String fileName) {
  return '$testFilesPath/$fileName$extension';
}

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp'; // or any fake path
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  group('XVIGrid', () {
    final List<String> fileNames = [
      '2025-07-04-001-xvi-xvigrid_without_space_around_curly_braces',
      '2025-07-04-002-xvi-xvigrid_with_space_around_curly_braces',
      '2025-07-04-003-xvi-xvigrid_without_ending_empty_line',
    ];

    final XVIGrid xviGridResult = XVIGrid.fromStringList([
      '-5043.25302884',
      '-6120.73899649',
      '78.7401574803',
      '0.0',
      '0.0',
      '78.7401574803',
      '85.0',
      '88.0',
    ]);

    for (final fileName in fileNames) {
      test('XVIGrammar parses $fileName', () {
        final XVIFileParser parser = XVIFileParser();
        final (file, isSuccessful, _) = parser.parse(
          _getFilePath(fileName),
          // runTraceParser: true,
        );

        expect(isSuccessful, true);
        expect(file, isA<XVIFile>());
        if (file is XVIFile) {
          expect(file.grid, xviGridResult);
        }
      });
    }
  });

  group('XVIGridSize', () {
    final List<String> fileNames = ['2025-07-09-001-xvi-xvigridsize'];
    final double gridSizeLength = 1.0;
    final THLengthUnitPart gridSizeUnit = THLengthUnitPart(
      unit: THLengthUnitType.meter,
    );

    for (final fileName in fileNames) {
      test('XVIGrammar parses $fileName', () {
        final XVIFileParser parser = XVIFileParser();
        final (file, isSuccessful, _) = parser.parse(
          _getFilePath(fileName),
          // runTraceParser: true,
        );

        expect(isSuccessful, true);
        expect(file, isA<XVIFile>());
        if (file is XVIFile) {
          expect(file.gridSizeLength, gridSizeLength);
          expect(file.gridSizeUnit, gridSizeUnit);
        }
      });
    }
  });

  group('XVIstations', () {
    final XVIStation stationA1 = XVIStation(
      position: THPositionPart.fromStrings(
        xAsString: '-505.14',
        yAsString: '-1814.83',
      ),
      name: 'A1',
    );
    final XVIStation station5_22 = XVIStation(
      position: THPositionPart.fromStrings(
        xAsString: '231.4',
        yAsString: '237.33',
      ),
      name: '5.22',
    );
    final List<Map> testFiles = [
      {
        'file': '2025-07-09-002-xvi-xvistations',
        'stations': [stationA1],
      },
      {
        'file': '2025-07-09-004-xvi-xvistations',
        'stations': [stationA1],
      },
      {
        'file': '2025-07-09-005-xvi-xvistations',
        'stations': [stationA1],
      },
      {
        'file': '2025-07-09-006-xvi-xvistations',
        'stations': [stationA1, station5_22],
      },
    ];

    for (final testFile in testFiles) {
      test('XVIGrammar parses ${testFile['file']}', () {
        final XVIFileParser parser = XVIFileParser();
        final (file, isSuccessful, _) = parser.parse(
          _getFilePath(testFile['file']),
          // runTraceParser: true,
        );

        expect(isSuccessful, true);
        expect(file, isA<XVIFile>());
        if (file is XVIFile) {
          expect(file.stations.length, testFile['stations'].length);
          expect(file.stations, testFile['stations']);
        }
      });
    }
  });

  group('XVIShots', () {
    final XVIShot shot1 = XVIShot(
      start: THPositionPart.fromStrings(
        xAsString: '-3536.69',
        yAsString: '-2929.39',
      ),
      end: THPositionPart.fromStrings(
        xAsString: '-4181.13',
        yAsString: '-2579.54',
      ),
    );
    final XVIShot shot2 = XVIShot(
      start: THPositionPart.fromStrings(
        xAsString: '-2492.51',
        yAsString: '-3346.85',
      ),
      end: THPositionPart.fromStrings(
        xAsString: '-3536.69',
        yAsString: '-2929.39',
      ),
    );
    final List<Map<String, dynamic>> testFiles = [
      {
        'file': '2025-07-10-001-xvi-xvishots',
        'shots': [shot1],
      },
      {
        'file': '2025-07-10-002-xvi-xvishots',
        'shots': [shot1, shot2],
      },
    ];

    for (final testFile in testFiles) {
      test('XVIGrammar parses ${testFile['file']}', () {
        final XVIFileParser parser = XVIFileParser();
        final (file, isSuccessful, _) = parser.parse(
          _getFilePath(testFile['file']),
          // runTraceParser: true,
        );

        expect(isSuccessful, true);
        expect(file, isA<XVIFile>());
        if (file is XVIFile) {
          expect(file.shots.length, (testFile['shots'] as List).length);
          expect(file.shots, testFile['shots']);
        }
      });
    }
  });

  group('XVISkethLines', () {
    final XVIFileParser parser = XVIFileParser();
    // {gray -1097.48 -1886.46 -1091.57 -1898.27 -1079.76 -1898.27 -1067.95 -1904.17 -1050.24 -1904.17}
    final XVISketchLine xviSketchLineGray = XVISketchLine(
      color: 'gray',
      start: THPositionPart.fromStrings(
        xAsString: '-1097.48',
        yAsString: '-1886.46',
      ),
      points: [
        THPositionPart.fromStrings(
          xAsString: '-1091.57',
          yAsString: '-1898.27',
        ),
        THPositionPart.fromStrings(
          xAsString: '-1079.76',
          yAsString: '-1898.27',
        ),
        THPositionPart.fromStrings(
          xAsString: '-1067.95',
          yAsString: '-1904.17',
        ),
        THPositionPart.fromStrings(
          xAsString: '-1050.24',
          yAsString: '-1904.17',
        ),
      ],
    );
    // {green -1380.94 -841.18 -1392.76 -852.99 -1392.76 -876.61 -1386.85 -906.14 -1386.85 -941.57}
    final xviSketchLineGreen = XVISketchLine(
      color: 'green',
      start: THPositionPart.fromStrings(
        xAsString: '-1380.94',
        yAsString: '-841.18',
      ),
      points: [
        THPositionPart.fromStrings(xAsString: '-1392.76', yAsString: '-852.99'),
        THPositionPart.fromStrings(xAsString: '-1392.76', yAsString: '-876.61'),
        THPositionPart.fromStrings(xAsString: '-1386.85', yAsString: '-906.14'),
        THPositionPart.fromStrings(xAsString: '-1386.85', yAsString: '-941.57'),
      ],
    );
    // {black -1062.05 -687.64 -1097.48 -705.35 -1109.29 -705.35 -1156.54 -717.17 -1180.16 -711.26 -1191.97 -711.26 -1197.87 -699.45 -1197.87 -575.43 -1203.78 -563.62 -1203.78 -534.09 -1221.5 -475.04 -1227.4 -463.23 -1227.4 -475.04 -1245.12 -498.66 -1245.12 -510.47 -1256.93 -534.09 -1256.93 -569.53 -1262.83 -599.06 -1262.83 -634.49 -1321.89 -699.45 -1333.7 -699.45 -1339.61 -711.26 -1351.42 -711.26 -1357.32 -723.07 -1369.13 -723.07 -1392.76 -758.5 -1404.57 -764.41 -1416.38 -788.03 -1422.28 -776.22}
    final XVISketchLine xviSketchLineBlack = XVISketchLine(
      color: 'black',
      start: THPositionPart.fromStrings(
        xAsString: '-1062.05',
        yAsString: '-687.64',
      ),
      points: [
        THPositionPart.fromStrings(xAsString: '-1097.48', yAsString: '-705.35'),
        THPositionPart.fromStrings(xAsString: '-1109.29', yAsString: '-705.35'),
        THPositionPart.fromStrings(xAsString: '-1156.54', yAsString: '-717.17'),
        THPositionPart.fromStrings(xAsString: '-1180.16', yAsString: '-711.26'),
        THPositionPart.fromStrings(xAsString: '-1191.97', yAsString: '-711.26'),
        THPositionPart.fromStrings(xAsString: '-1197.87', yAsString: '-699.45'),
        THPositionPart.fromStrings(xAsString: '-1197.87', yAsString: '-575.43'),
        THPositionPart.fromStrings(xAsString: '-1203.78', yAsString: '-563.62'),
        THPositionPart.fromStrings(xAsString: '-1203.78', yAsString: '-534.09'),
        THPositionPart.fromStrings(xAsString: '-1221.5', yAsString: '-475.04'),
        THPositionPart.fromStrings(xAsString: '-1227.4', yAsString: '-463.23'),
        THPositionPart.fromStrings(xAsString: '-1227.4', yAsString: '-475.04'),
        THPositionPart.fromStrings(xAsString: '-1245.12', yAsString: '-498.66'),
        THPositionPart.fromStrings(xAsString: '-1245.12', yAsString: '-510.47'),
        THPositionPart.fromStrings(xAsString: '-1256.93', yAsString: '-534.09'),
        THPositionPart.fromStrings(xAsString: '-1256.93', yAsString: '-569.53'),
        THPositionPart.fromStrings(xAsString: '-1262.83', yAsString: '-599.06'),
        THPositionPart.fromStrings(xAsString: '-1262.83', yAsString: '-634.49'),
        THPositionPart.fromStrings(xAsString: '-1321.89', yAsString: '-699.45'),
        THPositionPart.fromStrings(xAsString: '-1333.7', yAsString: '-699.45'),
        THPositionPart.fromStrings(xAsString: '-1339.61', yAsString: '-711.26'),
        THPositionPart.fromStrings(xAsString: '-1351.42', yAsString: '-711.26'),
        THPositionPart.fromStrings(xAsString: '-1357.32', yAsString: '-723.07'),
        THPositionPart.fromStrings(xAsString: '-1369.13', yAsString: '-723.07'),
        THPositionPart.fromStrings(xAsString: '-1392.76', yAsString: '-758.5'),
        THPositionPart.fromStrings(xAsString: '-1404.57', yAsString: '-764.41'),
        THPositionPart.fromStrings(xAsString: '-1416.38', yAsString: '-788.03'),
        THPositionPart.fromStrings(xAsString: '-1422.28', yAsString: '-776.22'),
      ],
    );
    final List<Map<String, dynamic>> testFiles = [
      {
        'file': '2025-07-10-003-xvi-xvisketchlines',
        'sketchLines': [xviSketchLineGray],
      },
      {
        'file': '2025-07-10-004-xvi-xvisketchlines',
        'sketchLines': [
          xviSketchLineGray,
          xviSketchLineGreen,
          xviSketchLineBlack,
        ],
      },
    ];
    for (final testFile in testFiles) {
      test('XVIGrammar parses ${testFile['file']}', () {
        final (file, isSuccessful, _) = parser.parse(
          _getFilePath(testFile['file']),
          // runTraceParser: true,
        );

        expect(isSuccessful, true);
        expect(file, isA<XVIFile>());
        if (file is XVIFile) {
          expect(
            file.sketchLines.length,
            (testFile['sketchLines'] as List).length,
          );
          expect(file.sketchLines, testFile['sketchLines']);
        }
      });
    }
  });

  group('XVIGridSize and XVIGrid', () {
    final String fileName = '2025-07-09-003-xvi-xvigridsize_and_xvigrid';

    final double gridSizeLength = 1.0;
    final THLengthUnitPart gridSizeUnit = THLengthUnitPart(
      unit: THLengthUnitType.meter,
    );

    final XVIGrid xviGridResult = XVIGrid.fromStringList([
      '-5043.25302884',
      '-6120.73899649',
      '78.7401574803',
      '0.0',
      '0.0',
      '78.7401574803',
      '85.0',
      '88.0',
    ]);

    test('XVIGrammar parses $fileName', () {
      final XVIFileParser parser = XVIFileParser();
      final (file, isSuccessful, _) = parser.parse(
        _getFilePath(fileName),
        // runTraceParser: true,
      );

      expect(isSuccessful, true);
      expect(file, isA<XVIFile>());
      if (file is XVIFile) {
        expect(file.gridSizeLength, gridSizeLength);
        expect(file.gridSizeUnit, gridSizeUnit);
        expect(file.grid, xviGridResult);
      }
    });
  });

  group('Complete XVI File', () {
    final String fileName = '2025-07-10-005-xvi-complete_file';

    final double gridSizeLength = 1.0;
    final THLengthUnitPart gridSizeUnit = THLengthUnitPart(
      unit: THLengthUnitType.meter,
    );

    final XVIGrid xviGridResult = XVIGrid.fromStringList([
      '-5043.25302884',
      '-6120.73899649',
      '78.7401574803',
      '0.0',
      '0.0',
      '78.7401574803',
      '85.0',
      '88.0',
    ]);

    final List<XVIStation> expectedStations = [
      XVIStation(
        position: THPositionPart.fromStrings(
          xAsString: '-505.14',
          yAsString: '-1814.83',
        ),
        name: '5.22',
      ),
      XVIStation(
        position: THPositionPart.fromStrings(
          xAsString: '-1363.36',
          yAsString: '-1501.71',
        ),
        name: '5.21',
      ),
    ];

    final List<XVIShot> expectedShots = [
      XVIShot(
        start: THPositionPart.fromStrings(xAsString: '0.0', yAsString: '0.0'),
        end: THPositionPart.fromStrings(xAsString: '0.0', yAsString: '0.0'),
      ),
      XVIShot(
        start: THPositionPart.fromStrings(xAsString: '0.0', yAsString: '0.0'),
        end: THPositionPart.fromStrings(
          xAsString: '-80.25',
          yAsString: '-448.11',
        ),
      ),
      XVIShot(
        start: THPositionPart.fromStrings(
          xAsString: '-80.25',
          yAsString: '-448.11',
        ),
        end: THPositionPart.fromStrings(
          xAsString: '43.22',
          yAsString: '-769.44',
        ),
      ),
      XVIShot(
        start: THPositionPart.fromStrings(
          xAsString: '43.22',
          yAsString: '-769.44',
        ),
        end: THPositionPart.fromStrings(
          xAsString: '94.9',
          yAsString: '-1270.43',
        ),
      ),
      XVIShot(
        start: THPositionPart.fromStrings(
          xAsString: '94.9',
          yAsString: '-1270.43',
        ),
        end: THPositionPart.fromStrings(
          xAsString: '-228.63',
          yAsString: '-1224.58',
        ),
      ),
    ];

    test('XVIGrammar parses complete file $fileName', () {
      final XVIFileParser parser = XVIFileParser();
      final (file, isSuccessful, _) = parser.parse(
        _getFilePath(fileName),
        // runTraceParser: true,
      );

      expect(isSuccessful, true);
      expect(file, isA<XVIFile>());

      if (file is XVIFile) {
        // Test grid size
        expect(file.gridSizeLength, gridSizeLength);
        expect(file.gridSizeUnit, gridSizeUnit);

        // Test grid
        expect(file.grid, xviGridResult);

        // Test stations
        expect(file.stations.length, 2);
        expect(file.stations, expectedStations);

        // Test shots
        expect(file.shots.length, 5);
        expect(file.shots, expectedShots);

        // Test sketch lines - there should be 10 sketch lines (including connect lines)
        expect(file.sketchLines.length, 10);

        // Test specific sketch lines from the file
        // First line: {gray -1097.48 -1886.46 -1091.57 -1898.27 -1079.76 -1898.27 -1067.95 -1904.17 -1050.24 -1904.17}
        final firstSketchLine = file.sketchLines[0];
        expect(firstSketchLine.start.x, -1097.48);
        expect(firstSketchLine.start.y, -1886.46);
        expect(firstSketchLine.points.length, 4);
        expect(firstSketchLine.points[0].x, -1091.57);
        expect(firstSketchLine.points[0].y, -1898.27);
        expect(firstSketchLine.points[3].x, -1050.24);
        expect(firstSketchLine.points[3].y, -1904.17);

        // Second line: {green -1386.85 -941.57 -1351.42 -971.1 -1345.51 -982.91}
        final secondSketchLine = file.sketchLines[1];
        expect(secondSketchLine.start.x, -1386.85);
        expect(secondSketchLine.start.y, -941.57);
        expect(secondSketchLine.points.length, 2);
        expect(secondSketchLine.points[0].x, -1351.42);
        expect(secondSketchLine.points[0].y, -971.1);
        expect(secondSketchLine.points[1].x, -1345.51);
        expect(secondSketchLine.points[1].y, -982.91);

        // Last line should be a connect line: {connect 175.75 -524.25 43.22 -769.44}
        final lastSketchLine = file.sketchLines[9];
        expect(lastSketchLine.start.x, 175.75);
        expect(lastSketchLine.start.y, -524.25);
        expect(lastSketchLine.points.length, 1);
        expect(lastSketchLine.points[0].x, 43.22);
        expect(lastSketchLine.points[0].y, -769.44);
      }
    });
  });

  group('Complete file from JSON', () {
    final List<Map<String, dynamic>> testFiles = [
      {
        'file': '2025-10-07-001-color_as_rgb_hex',
        'asJSON':
            '{"filename":"/home/rodrigo/devel/mapiah/test/auxiliary/xvi/2025-10-07-001-color_as_rgb_hex.xvi","gridSizeLength":1.0,"gridSizeUnit":{"partType":"lengthUnit","unit":"m"},"stations":[{"position":{"partType":"position","coordinates":{"dx":196.85,"dy":-236.22},"decimalPositions":2},"name":"1"},{"position":{"partType":"position","coordinates":{"dx":195.48,"dy":-275.47},"decimalPositions":2},"name":"0"}],"shots":[{"start":{"partType":"position","coordinates":{"dx":195.48,"dy":-275.47},"decimalPositions":2},"end":{"partType":"position","coordinates":{"dx":196.85,"dy":-236.22},"decimalPositions":2}}],"sketchLines":[{"color":"#FF0000","start":{"partType":"position","coordinates":{"dx":173.9,"dy":-231.72},"decimalPositions":2},"points":[{"partType":"position","coordinates":{"dx":172.36,"dy":-232.71},"decimalPositions":2},{"partType":"position","coordinates":{"dx":170.69,"dy":-233.93},"decimalPositions":2},{"partType":"position","coordinates":{"dx":169.36,"dy":-235.55},"decimalPositions":2},{"partType":"position","coordinates":{"dx":166.59,"dy":-238.93},"decimalPositions":2},{"partType":"position","coordinates":{"dx":164.73,"dy":-243.82},"decimalPositions":2},{"partType":"position","coordinates":{"dx":165.21,"dy":-248.22},"decimalPositions":2},{"partType":"position","coordinates":{"dx":165.64,"dy":-252.13},"decimalPositions":2},{"partType":"position","coordinates":{"dx":167.16,"dy":-256.64},"decimalPositions":2},{"partType":"position","coordinates":{"dx":166.75,"dy":-261.55},"decimalPositions":2},{"partType":"position","coordinates":{"dx":166.59,"dy":-263.5},"decimalPositions":2},{"partType":"position","coordinates":{"dx":166.39,"dy":-265.45},"decimalPositions":2},{"partType":"position","coordinates":{"dx":166.36,"dy":-267.4},"decimalPositions":2},{"partType":"position","coordinates":{"dx":166.28,"dy":-271.72},"decimalPositions":2},{"partType":"position","coordinates":{"dx":166.54,"dy":-276.84},"decimalPositions":2},{"partType":"position","coordinates":{"dx":169.2,"dy":-280.5},"decimalPositions":2},{"partType":"position","coordinates":{"dx":177.45,"dy":-291.88},"decimalPositions":2},{"partType":"position","coordinates":{"dx":198.79,"dy":-302.66},"decimalPositions":2},{"partType":"position","coordinates":{"dx":211.77,"dy":-294.24},"decimalPositions":2},{"partType":"position","coordinates":{"dx":212.85,"dy":-293.21},"decimalPositions":2},{"partType":"position","coordinates":{"dx":213.94,"dy":-292.19},"decimalPositions":2},{"partType":"position","coordinates":{"dx":215.02,"dy":-291.16},"decimalPositions":2},{"partType":"position","coordinates":{"dx":215.86,"dy":-290.34},"decimalPositions":2},{"partType":"position","coordinates":{"dx":216.69,"dy":-289.51},"decimalPositions":2},{"partType":"position","coordinates":{"dx":217.53,"dy":-288.69},"decimalPositions":2},{"partType":"position","coordinates":{"dx":218.17,"dy":-288.06},"decimalPositions":2},{"partType":"position","coordinates":{"dx":218.82,"dy":-287.43},"decimalPositions":2},{"partType":"position","coordinates":{"dx":219.46,"dy":-286.8},"decimalPositions":2},{"partType":"position","coordinates":{"dx":219.91,"dy":-286.36},"decimalPositions":2},{"partType":"position","coordinates":{"dx":220.29,"dy":-285.83},"decimalPositions":2},{"partType":"position","coordinates":{"dx":220.8,"dy":-285.46},"decimalPositions":2},{"partType":"position","coordinates":{"dx":221.18,"dy":-285.19},"decimalPositions":2},{"partType":"position","coordinates":{"dx":221.75,"dy":-285.21},"decimalPositions":2},{"partType":"position","coordinates":{"dx":222.11,"dy":-284.89},"decimalPositions":2},{"partType":"position","coordinates":{"dx":225.96,"dy":-281.43},"decimalPositions":2},{"partType":"position","coordinates":{"dx":224.43,"dy":-271.9},"decimalPositions":2},{"partType":"position","coordinates":{"dx":224.51,"dy":-267.77},"decimalPositions":2},{"partType":"position","coordinates":{"dx":224.75,"dy":-255.58},"decimalPositions":2},{"partType":"position","coordinates":{"dx":229.82,"dy":-240.33},"decimalPositions":2},{"partType":"position","coordinates":{"dx":223.17,"dy":-228.97},"decimalPositions":2}]},{"color":"#FF0000","start":{"partType":"position","coordinates":{"dx":173.9,"dy":-231.72},"decimalPositions":2},"points":[{"partType":"position","coordinates":{"dx":183.98,"dy":-225.86},"decimalPositions":2},{"partType":"position","coordinates":{"dx":176.08,"dy":-210.24},"decimalPositions":2},{"partType":"position","coordinates":{"dx":176.1,"dy":-202.69},"decimalPositions":2},{"partType":"position","coordinates":{"dx":176.1,"dy":-202.05},"decimalPositions":2},{"partType":"position","coordinates":{"dx":176.41,"dy":-201.42},"decimalPositions":2},{"partType":"position","coordinates":{"dx":176.8,"dy":-200.92},"decimalPositions":2},{"partType":"position","coordinates":{"dx":184.51,"dy":-191.12},"decimalPositions":2},{"partType":"position","coordinates":{"dx":207.16,"dy":-180.77},"decimalPositions":2},{"partType":"position","coordinates":{"dx":219.57,"dy":-180.4},"decimalPositions":2},{"partType":"position","coordinates":{"dx":219.87,"dy":-178.02},"decimalPositions":2},{"partType":"position","coordinates":{"dx":219.17,"dy":-166.62},"decimalPositions":2},{"partType":"position","coordinates":{"dx":216.61,"dy":-158.12},"decimalPositions":2},{"partType":"position","coordinates":{"dx":210.45,"dy":-154.13},"decimalPositions":2},{"partType":"position","coordinates":{"dx":199.37,"dy":-153.13},"decimalPositions":2},{"partType":"position","coordinates":{"dx":185.55,"dy":-153.91},"decimalPositions":2},{"partType":"position","coordinates":{"dx":175.4,"dy":-152.5},"decimalPositions":2},{"partType":"position","coordinates":{"dx":168.72,"dy":-148.83},"decimalPositions":2},{"partType":"position","coordinates":{"dx":164.42,"dy":-145.53},"decimalPositions":2},{"partType":"position","coordinates":{"dx":162.61,"dy":-145.15},"decimalPositions":2}]},{"color":"#FF0000","start":{"partType":"position","coordinates":{"dx":223.17,"dy":-228.97},"decimalPositions":2},"points":[{"partType":"position","coordinates":{"dx":223.09,"dy":-228.4},"decimalPositions":2},{"partType":"position","coordinates":{"dx":223.46,"dy":-227.46},"decimalPositions":2},{"partType":"position","coordinates":{"dx":222.92,"dy":-227.26},"decimalPositions":2},{"partType":"position","coordinates":{"dx":215.83,"dy":-224.67},"decimalPositions":2},{"partType":"position","coordinates":{"dx":203.16,"dy":-220.81},"decimalPositions":2},{"partType":"position","coordinates":{"dx":202.15,"dy":-211.0},"decimalPositions":2},{"partType":"position","coordinates":{"dx":202.07,"dy":-210.23},"decimalPositions":2},{"partType":"position","coordinates":{"dx":202.03,"dy":-209.45},"decimalPositions":2},{"partType":"position","coordinates":{"dx":202.09,"dy":-208.68},"decimalPositions":2},{"partType":"position","coordinates":{"dx":202.2,"dy":-207.32},"decimalPositions":2},{"partType":"position","coordinates":{"dx":202.8,"dy":-205.8},"decimalPositions":2},{"partType":"position","coordinates":{"dx":203.85,"dy":-204.81},"decimalPositions":2},{"partType":"position","coordinates":{"dx":210.08,"dy":-198.95},"decimalPositions":2},{"partType":"position","coordinates":{"dx":217.53,"dy":-193.42},"decimalPositions":2},{"partType":"position","coordinates":{"dx":222.57,"dy":-186.02},"decimalPositions":2}]}],"grid":{"gx":{"partType":"double","value":101.59,"decimalPositions":2},"gy":{"partType":"double","value":-441.88,"decimalPositions":2},"gxx":{"partType":"double","value":39.37,"decimalPositions":2},"gxy":{"partType":"double","value":0.0,"decimalPositions":1},"gyx":{"partType":"double","value":0.0,"decimalPositions":1},"gyy":{"partType":"double","value":39.37,"decimalPositions":2},"ngx":{"partType":"double","value":4.0,"decimalPositions":0},"ngy":{"partType":"double","value":11.0,"decimalPositions":0}}}',
      },
    ];
    for (final testFile in testFiles) {
      test('XVIGrammar parses ${testFile['file']}', () {
        final XVIFileParser parser = XVIFileParser();
        final (file, isSuccessful, _) = parser.parse(
          _getFilePath(testFile['file']),
          // runTraceParser: true,
        );

        expect(isSuccessful, true);
        expect(file, isA<XVIFile>());
        if (file is XVIFile) {
          final XVIFile fileFromJSON = XVIFile.fromJson(testFile['asJSON']);

          expect(file == fileFromJSON, isTrue);
        }
      });
    }
  });
}
