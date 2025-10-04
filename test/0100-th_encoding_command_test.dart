import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th_test_aux.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp'; // or any fake path
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();
  group('encoding', () {
    const successes = [
      {
        'file': 'th_file_parser-00011-encoding_with_trailing_space.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
''',
      },
      {
        'file': 'th_file_parser-00012-encoding_with_trailing_comment.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8 # end of line comment
''',
      },
      {
        'file': 'th_file_parser-00013-iso8859-1_encoding.th2',
        'length': 2,
        'encoding': 'ISO8859-1',
        'asFile': '''encoding ISO8859-1
# ISO8859-1 comment: àáâãäåç
''',
      },
      {
        'file': 'th_file_parser-00014-iso8859-2_encoding.th2',
        'length': 2,
        'encoding': 'ISO8859-2',
        'asFile': '''encoding ISO8859-2
# ISO8859-2 comment: ŕáâăäĺç
''',
      },
      {
        'file': 'th_file_parser-00015-iso8859-15_encoding.th2',
        'length': 2,
        'encoding': 'ISO8859-15',
        'asFile': '''encoding ISO8859-15
# ISO8859-15 comment: àáâãäåç€
''',
      },
      {
        'file': 'th_file_parser-00019-encoding_only.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
''',
      },
      {
        'file': '2025-06-16-001-scrap_ids_as_extented_keywords.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
scrap 343-plan1.1
  point 980.2776 513.1133 station -name 1.6
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, errors) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
          // trace: true,
        );
        expect(
          isSuccessful,
          true,
          reason: 'Parsing failed with errors: $errors',
        );
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });
}
