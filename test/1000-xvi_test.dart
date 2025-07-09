import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/mp_file_read_write/xvi_file_parser.dart';
import 'package:test/test.dart';

const String testFilesPath = 'test/auxiliary/xvi';
const String extension = '.xvi';

String _getFilePath(String fileName) {
  return '$testFilesPath/$fileName$extension';
}

void main() {
  group('XVIGrid', () {
    final XVIFileParser parser = XVIFileParser();
    final List<String> fileNames = [
      '2025-07-04-001-xvi-xvigrid_without_space_around_curly_braces',
      '2025-07-04-002-xvi-xvigrid_with_space_around_curly_braces',
      '2025-07-04-003-xvi-xvigrid_without_ending_empty_line',
    ];

    final XVIGrid xviGridResult = XVIGrid.fromList([
      -5043.25302884,
      -6120.73899649,
      78.7401574803,
      0.0,
      0.0,
      78.7401574803,
      85.0,
      88.0,
    ]);

    for (final fileName in fileNames) {
      test('XVIGrammar parses $fileName', () {
        final (file, isSuccessful, _) = parser.parse(
          _getFilePath(fileName),
          // runTraceParser: true,
        );

        expect(isSuccessful, true);
        expect(file, isA<XVIFile>());
        expect(file.grid, xviGridResult);
      });
    }
  });

  group('XVIGridSize', () {
    final XVIFileParser parser = XVIFileParser();
    final List<String> fileNames = [
      '2025-07-09-001-xvi-xvigridsize',
    ];

    final double gridSizeLength = 1.0;
    final THLengthUnitPart gridSizeUnit = THLengthUnitPart(
      unit: THLengthUnitType.meter,
    );

    for (final fileName in fileNames) {
      test('XVIGrammar parses $fileName', () {
        final (file, isSuccessful, _) = parser.parse(
          _getFilePath(fileName),
          // runTraceParser: true,
        );

        expect(isSuccessful, true);
        expect(file, isA<XVIFile>());
        expect(file.gridSizeLength, gridSizeLength);
        expect(file.gridSizeUnit, gridSizeUnit);
      });
    }
  });
}
