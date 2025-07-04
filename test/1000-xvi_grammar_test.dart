import 'dart:io';
import 'package:mapiah/src/mp_file_read_write/xvi_grammar.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

Result parseWithOptionalTrace(
  Parser parser,
  String contents, {
  bool enableTrace = false,
}) {
  if (enableTrace) {
    trace(parser).parse(contents);
  }

  return parser.parse(contents);
}

void main() {
  final grammar = XVIGrammar();
  const String testFilesPath = 'test/auxiliary/xvi';

  final List<String> fileNames = [
    '$testFilesPath/2025-07-04-001-xvi-xvigrid_without_space_around_curly_braces.xvi',
    '$testFilesPath/2025-07-04-002-xvi-xvigrid_with_space_around_curly_braces.xvi',
    '$testFilesPath/2025-07-04-003-xvi-xvigrid_without_ending_empty_line.xvi',
  ];

  for (final fileName in fileNames) {
    test('XVIGrammar parses $fileName', () async {
      final File file = File(fileName);
      final String contents = await file.readAsString();
      final Parser parser = grammar.build();

      final Result result = parseWithOptionalTrace(
        parser,
        contents,
        enableTrace: false,
      );

      expect(
        result,
        isA<Success>(),
        reason: 'Failed to parse $fileName: \n\u001b[31m[0m',
      );
    });
  }
}
