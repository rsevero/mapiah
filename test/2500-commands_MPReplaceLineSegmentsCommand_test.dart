import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
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
  group('command: MPReplaceLineSegmentsCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-27-001-straight_line.th2',
        'length': 22,
        'encoding': 'UTF-8',
        'lineID': 'blaus',
        'asFileOriginal': r'''encoding UTF-8
scrap Trianglinho-1R1-2p -projection plan -scale [ 0 0 39.3701 0 0 0 1 0 m ]
  line wall
    64.21 -61.41
    72.46 -61.74
    80.37 -62.39
    94.52 -63.03
    108.76 -65.62
    122.36 -69.18
    136.13 -72.61
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    182.36 -109.48
    184.3 -123.49
    187.86 -137.32
    189.64 -150.59
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap Trianglinho-1R1-2p -projection plan -scale [ 0 0 39.3701 0 0 0 1 0 m ]
  line wall
    64.21 -61.41
    94.52 -63.03
    149.51 -75.33
    163.77 -75.33
    176.39 -81.51
    181.55 -94.76
    184.3 -123.49
    193.21 -164.67
    207.76 -171.21
  endline
endscrap
''',
      },
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
            final THFile snapshotOriginal = THFile.fromMap(
              controller.thFile.toMap(),
            );

            /// Execution: taken from TH2FileEditElementEditController.simplifySelectedLines()

            final Iterable<THElement> lines = parsedFile.getLines();

            controller.setCanvasScale(1);
            controller.selectionController.setSelectedElements(
              lines,
              setState: true,
            );
            controller.elementEditController.simplifySelectedLines();

            final String asFileChanged = writer.serialize(controller.thFile);
            expect(asFileChanged, success['asFileChanged']);

            // Undo the action
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
