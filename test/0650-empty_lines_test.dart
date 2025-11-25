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
  group('empty lines', () {
    const successes = [
      {
        'file': '2025-11-25-001-empty_lines.th2',
        'length': 18,
        'encoding': 'UTF-8',
        'asFile':
            'encoding utf-8\ncomment\nThe scrap below is really complex.\nTake care!!\nendcomment\n\nscrap poco_surubim_SCP01 -scale [-164.0 -2396.0 3308.0 -2396.0 0.0 0.0 88.1888 0.0 m]\n\tpoint 42.1 -5448.8 guano -visibility off -id P1\n\t\n\tcomment\n\t\n\tAnother comment block.\n\t\n\tBut this one is inside a scrap!\n\tendcomment\n\t\n\tpoint 322.4 431.7 station -name A1\nendscrap\n',
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

        final String asFile = writer.serialize(
          file,
          includeEmptyLines: true,
          useOriginalRepresentation: true,
        );
        expect(asFile, success['asFile']);
      });
    }
  });
}
