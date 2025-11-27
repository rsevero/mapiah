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
  group('command: MPMoveBezierLineSegmentCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-11-001-bezier_line.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'originalLineSegmentsMap': 3,
        'deltaOnCanvas': Offset(2.8, 3.5),
        'asFileOriginal': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
      smooth on
    2796.913461 -619.928547 2973.7 -370.9 2886.6 -215.5
      smooth on
    2783.918502 -32.367149 2448.1 -179.8 2264.5 -205.7
      smooth on
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2739 -805
      smooth on
    2799.713461 -616.428547 2976.5 -367.4 2889.4 -212
      smooth on
    2786.718502 -28.867149 2450.9 -176.3 2267.3 -202.2
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

            final asFile = writer.serialize(parsedFile);
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
