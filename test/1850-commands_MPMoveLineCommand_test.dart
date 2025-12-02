import 'dart:collection';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/mp_command.dart';
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
  group('command: MPMoveLineCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-12-001-bezier_and_straight_line.th2',
        'length': 11,
        'originalLineSegmentsMap': 6,
        'deltaOnCanvas': Offset(-7.6, 13.4),
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap scrap1 -projection plan -scale [ 0.05 m ]
  line wall
    -93.4 466.2
    -102.4 288.4
    -224.9 198.6
    -277.415302 154.397253 -223.6 64.6 -182.3 40.6
      smooth on
    -122.259903 5.561805 -2.07686 6.380264 0.3 66.5
      smooth on
    3.146907 139.772475 44.6 181.1 83.5 205.6
      smooth on
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap scrap1 -projection plan -scale [ 0.05 m ]
  line wall
    -101 479.6
    -110 301.8
    -232.5 212
    -285.015302 167.797253 -231.2 78 -189.9 54
      smooth on
    -129.859903 18.961805 -9.67686 19.780264 -7.3 79.9
      smooth on
    -4.453093 153.172475 37 194.5 75.9 219
      smooth on
  endline
endscrap
''',
      },
    ];

    int count = 1;

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity) : ${success['file']} - ${count++}',
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

            final String asFile = writer.serialize(parsedFile);
            expect(asFile, success['asFileOriginal']);
            final TH2FileEditController controller = mpLocator
                .mpGeneralController
                .getTH2FileEditController(filename: path);

            // Snapshot original state (deep clone via toMap/fromMap)
            final THFile snapshotOriginal = THFile.fromMap(parsedFile.toMap());

            /// Execution: taken from MPMoveLineCommand()

            controller.setActiveScrap(parsedFile.getScraps().first.mpID);

            final THScrap activeScrap = controller.thFile.scrapByMPID(
              controller.activeScrapID,
            );
            final THLine selectedLine = activeScrap.getLines(parsedFile).first;
            final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
                selectedLine.getLineSegmentsMap(parsedFile);

            expect(
              originalLineSegmentsMap.length,
              success['originalLineSegmentsMap'],
            );

            final MPCommand moveLineCommand =
                MPMoveLineCommand.fromDeltaOnCanvas(
                  lineMPID: selectedLine.mpID,
                  deltaOnCanvas: success['deltaOnCanvas'] as Offset,
                  fromLineSegmentsMap: originalLineSegmentsMap,
                );

            controller.execute(moveLineCommand);

            final String asFileChanged = writer.serialize(controller.thFile);

            expect(asFileChanged, success['asFileChanged']);

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
  });
}
