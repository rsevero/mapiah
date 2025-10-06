import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th_test_aux.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();
  group('command: MPAddScrapCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-06-004-no_scrap.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
''',
        'asFileChanged': r'''encoding UTF-8
scrap scrap1
endscrap
''',
      },
      //       {
      //         'file': '2025-10-06-003-line_mixed.th2',
      //         'length': 9,
      //         'encoding': 'UTF-8',
      //         'asFileOriginal': r'''encoding UTF-8
      // scrap scrap1 -projection plan
      //   line wall
      //     -112.6398 155.7781
      //     30.6251 132.406
      //     94.8295 93.0684 99.2447 54.1784 43.8707 15.7361
      //     -23.5472 -51.5453
      //   endline
      // endscrap
      // ''',
      //         'asFileChanged': r'''encoding UTF-8
      // scrap scrap1 -projection plan
      //   line wall
      //     -112.6398 155.7781
      //     -41.00735 144.09205
      //     30.6251 132.406
      //     60.439879675246 114.138686903811 77.361588548345 95.967895227729 \
      //         81.390226619298 77.893634985588
      //     86.037027138871 57.046023359799 73.530518265772 36.326839908952 43.8707 \
      //         15.7361
      //     10.16175 -17.9046
      //     -23.5472 -51.5453
      //   endline
      // endscrap
      // ''',
      //       },
    ];

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity) : ${success['file']}',
        () async {
          try {
            final parser = THFileParser();
            final writer = THFileWriter();
            mpLocator.mpGeneralController.reset();
            final String path = THTestAux.testPath(success['file']! as String);
            final (parsedFile, isSuccessful, errors) = await parser.parse(
              path,
              forceNewController: true,
            );
            expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
            expect(parsedFile, isA<THFile>());
            expect(parsedFile.encoding, (success['encoding'] as String));
            expect(parsedFile.countElements(), success['length']);

            final asFile = writer.serialize(parsedFile);
            expect(asFile, success['asFileOriginal']);
            final TH2FileEditController controller = mpLocator
                .mpGeneralController
                .getTH2FileEditController(filename: path);

            // Snapshot original state (deep clone via toMap/fromMap)
            final THFile snapshotOriginal = THFile.fromMap(parsedFile.toMap());

            /// Execution: taken from _MPAddScrapDialogOverlayWindowWidgetState._createScrap()

            controller.setCanvasScale(1);

            controller.elementEditController.createScrap(thID: 'scrap1');

            final String asFileChanged = writer.serialize(controller.thFile);

            expect(asFileChanged, success['asFileChanged']);

            // Undo line create
            controller.undo();

            final String asFileUndone = writer.serialize(controller.thFile);

            expect(asFileUndone, success['asFileOriginal']);

            // Assert: final state equals original by value but is not the same object
            expect(identical(controller.thFile, snapshotOriginal), isFalse);
            expect(controller.thFile == snapshotOriginal, isTrue);
          } catch (e, st) {
            fail('Unexpected exception: $e\n$st');
          }
        },
      );
    }
    ;
  });
}
