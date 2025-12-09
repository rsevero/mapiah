import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
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
  group('command: MPAddAreaBorderTHIDCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-04-001-area_and_line.th2',
        'length': 20,
        'encoding': 'UTF-8',
        'lineID': 'blaus',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  area clay
    l85-3732--20
  endarea
  line border -id l85-3732--20 -close on -visibility off
    3592 208
    3539.45 249.03 3447.39 245.1 3392 208
    3233.22 101.65 3066.45 -131.93 3204 -332
    3266.87 -423.45 3365.54 -513.28 3476 -524
    3929.86 -568.03 3743.42 89.77 3592 208
  endline
  line contour -id blaus -close on -visibility off
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  area clay
    l85-3732--20
    blaus
  endarea
  line border -id l85-3732--20 -close on -visibility off
    3592 208
    3539.45 249.03 3447.39 245.1 3392 208
    3233.22 101.65 3066.45 -131.93 3204 -332
    3266.87 -423.45 3365.54 -513.28 3476 -524
    3929.86 -568.03 3743.42 89.77 3592 208
  endline
  line contour -id blaus -close on -visibility off
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
endscrap
''',
      },
      {
        'file': '2025-10-05-002-area_and_line_without_id.th2',
        'length': 20,
        'encoding': 'UTF-8',
        'lineID': null,
        'asFileOriginal': r'''encoding UTF-8
scrap test
  area clay
    l85-3732--20
  endarea
  line border -id l85-3732--20 -close on -visibility off
    3592 208
    3539.45 249.03 3447.39 245.1 3392 208
    3233.22 101.65 3066.45 -131.93 3204 -332
    3266.87 -423.45 3365.54 -513.28 3476 -524
    3929.86 -568.03 3743.42 89.77 3592 208
  endline
  line contour
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
  endline
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  area clay -id area1
    l85-3732--20
    area1-line1
  endarea
  line border -id l85-3732--20 -close on -visibility off
    3592 208
    3539.45 249.03 3447.39 245.1 3392 208
    3233.22 101.65 3066.45 -131.93 3204 -332
    3266.87 -423.45 3365.54 -513.28 3476 -524
    3929.86 -568.03 3743.42 89.77 3592 208
  endline
  line contour -id area1-line1
    2736.2 -808.5
    2894.3 -202.7
    2264.5 -205.7
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

            /// Execution: taken from MPTH2FileEditStateAddArea.onPrimaryButtonClick()

            THLine? secondLine;
            for (final int mpID in parsedFile.linesMPIDs) {
              final THLine line = parsedFile.lineByMPID(mpID);
              if (success['lineID'] == null) {
                if (!line.hasOption(THCommandOptionType.id)) {
                  secondLine = line;
                  break;
                }
              } else {
                if (line.hasOption(THCommandOptionType.id) &&
                    (line.getOption(THCommandOptionType.id)
                                as THIDCommandOption)
                            .thID ==
                        'blaus') {
                  secondLine = line;
                  break;
                }
              }
            }

            expect(secondLine, isNotNull);

            final THArea area = parsedFile.getAreas().first;
            final MPCommand addLineToAreaCommand =
                MPCommandFactory.addLineToArea(
                  area: area,
                  line: secondLine!,
                  thFile: parsedFile,
                );

            controller.execute(addLineToAreaCommand);

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
  });
}
