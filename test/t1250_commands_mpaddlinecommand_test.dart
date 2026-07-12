// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th2_file.dart';
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
  group('command: MPAddLineCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-06-002-scrap.th2',
        'length': 3,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap test
endscrap
''',
        'asFileIntermediate1': r'''encoding UTF-8
scrap test
  line wall
    2 -4
    6 -8
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  line wall
    2 -4
    6 -8
    2 10
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
            final parser = TH2FileParser();
            final writer = TH2FileWriter();
            mpLocator.mpGeneralController.reset();
            final String path = THTestAux.testPath(success['file']! as String);
            final (parsedFile, isSuccessful, errors) = await parser.parse(
              path,
              forceNewController: true,
            );
            expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
            expect(parsedFile, isA<TH2File>());
            expect(parsedFile.encoding, (success['encoding'] as String));
            expect(parsedFile.countElements(), success['length']);

            final asFile = writer.serialize(parsedFile);
            expect(asFile, success['asFileOriginal']);
            final TH2FileEditController controller = mpLocator
                .mpGeneralController
                .getTH2FileEditController(filename: path);

            // Snapshot original state (deep clone via toMap/fromMap)
            final TH2File snapshotOriginal = TH2File.fromMap(
              controller.th2File.toMap(),
            );

            /// Execution: taken from MPTH2FileEditStateAddLine.onPrimaryButtonPointerDown()

            controller.setActiveScrap(parsedFile.getScraps().first.mpID);
            controller.setCanvasScale(0.5);

            controller.areaLineCreationController.addNewLineLineSegment(
              Offset(1, 2),
            );
            controller.areaLineCreationController.addNewLineLineSegment(
              Offset(3, 4),
            );

            expect(
              parsedFile.getScraps().first.childrenMPIDs.first,
              parsedFile.getLines().first.mpID,
            );
            expect(
              parsedFile.getScraps().first.getChildPosition(
                parsedFile.getLines().first,
              ),
              mpAddChildAtStartOfParentChildrenList,
            );

            final TH2File snapshotIntermediate1 = TH2File.fromMap(
              controller.th2File.toMap(),
            );

            String asFileIntermediate = writer.serialize(controller.th2File);

            expect(asFileIntermediate, success['asFileIntermediate1']);

            controller.areaLineCreationController.addNewLineLineSegment(
              Offset(1, -5),
            );

            final String asFileChanged = writer.serialize(controller.th2File);

            expect(asFileChanged, success['asFileChanged']);

            // Undo last add line segment
            controller.undo();

            String asFileUndone = writer.serialize(controller.th2File);

            expect(asFileUndone, success['asFileIntermediate1']);

            // Assert: final state equals original by value but is not the same object
            expect(
              identical(controller.th2File, snapshotIntermediate1),
              isFalse,
            );
            expect(controller.th2File == snapshotIntermediate1, isTrue);

            // Undo line create
            controller.undo();

            asFileUndone = writer.serialize(controller.th2File);

            expect(asFileUndone, success['asFileOriginal']);

            // Assert: final state equals original by value but is not the same object
            expect(identical(controller.th2File, snapshotOriginal), isFalse);
            expect(controller.th2File == snapshotOriginal, isTrue);
          } catch (e, st) {
            fail('Unexpected exception: $e\n$st');
          }
        },
      );
    }
  });
}
