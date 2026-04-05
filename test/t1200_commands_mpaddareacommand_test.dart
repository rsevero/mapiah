// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
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
  group('command: MPAddAreaCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-05-001-line.th2',

        /// This file has 2 empty lines that are not shown in this sanitized output.
        'length': 10,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  line contour -id blaus
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
  area water
    blaus
  endarea
endscrap
''',
      },
      {
        'file': '2025-10-06-001-line_without_id.th2',
        'length': 8,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  line contour
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  line contour -id area1-line1
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
  area water -id area1
    area1-line1
  endarea
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

            /// Execution: taken from MPTH2FileEditStateAddArea.onPrimaryButtonClick()

            controller.setActiveScrap(parsedFile.getScraps().first.mpID);

            final THArea area = controller.areaLineCreationController
                .getNewArea();
            final MPCommand addAreaCommand =
                MPCommandFactory.addAreaFromExisting(
                  existingArea: area,
                  th2File: controller.th2File,
                );
            final THLine line = parsedFile.getLines().first;
            final MPCommand addLineToAreaCommand =
                MPCommandFactory.addLineToArea(
                  area: area,
                  line: line,
                  th2File: controller.th2File,
                );
            final List<MPCommand> commands = [
              addAreaCommand,
              addLineToAreaCommand,
            ];
            final MPCommand addAreaWithLineCommand =
                MPMultipleElementsCommand.forCWJM(
                  commandsList: commands,
                  completionType:
                      MPMultipleElementsCommandCompletionType.elementsEdited,
                  descriptionType: MPCommandDescriptionType.addArea,
                );

            controller.execute(addAreaWithLineCommand);

            final String asFileChanged = writer.serialize(controller.th2File);

            expect(asFileChanged, success['asFileChanged']);

            // Undo the action
            controller.undo();

            final String asFileUndone = writer.serialize(controller.th2File);

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
