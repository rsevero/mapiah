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
  group('multilinecomment', () {
    const successes = [
      {
        'file': 'th_file_parser-00110-comment_block.th2',
        'length': 5,
        'encoding': 'UTF-8',
        'asFile': '''encoding UTF-8
comment
The scrap below is really complex.
   Take care!!
endcomment
''',
      },
      {
        'file': 'th_file_parser-00111-comment_block_complex.th2',
        'length': 14,
        'encoding': 'UTF-8',
        'asFile': r'''encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 m ]
  comment

Another comment block.

But this one is inside a scrap!

  endcomment
endscrap
''',
      },
    ];

    for (var success in successes) {
      test(success, () async {
        final parser = THFileParser();
        final writer = THFileWriter();
        mpLocator.mpGeneralController.reset();
        final (file, isSuccessful, _) = await parser.parse(
          THTestAux.testPath(success['file'] as String),
        );
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.encoding, (success['encoding'] as String));
        expect(file.countElements(), success['length']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });
}
