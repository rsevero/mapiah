import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/mp_file_read_write/xvi_file_parser.dart';
import 'package:test/test.dart';

void main() {
  group('XVIGrid', () {
    final XVIFileParser parser = XVIFileParser();
    const String testFilesPath = 'test/auxiliary/xvi';

    final List<String> fileNames = [
      '$testFilesPath/2025-07-04-001-xvi-xvigrid_without_space_around_curly_braces.xvi',
      '$testFilesPath/2025-07-04-002-xvi-xvigrid_with_space_around_curly_braces.xvi',
      '$testFilesPath/2025-07-04-003-xvi-xvigrid_without_ending_empty_line.xvi',
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
        final (file, isSuccessful, _) = parser.parse(fileName);

        expect(isSuccessful, true);
        expect(file, isA<XVIFile>());
        expect(file.grid, xviGridResult);
      });
    }
  });
}
