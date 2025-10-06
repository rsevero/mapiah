import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
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
      {
        'file': '2025-10-06-004-no_scrap.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
''',
        'asFileChanged': r'''encoding UTF-8
scrap scrap1 -projection plan -scale [ 0.15 m ]
  point -2.073 0.042 station
endscrap
''',
        'scrapOptions': [
          r'{"optionType":"projection","parentMPID":0,"originalLineInTH2File":"","mode":"plan","index":""}',
          r'{"optionType":"scrapScale","parentMPID":0,"originalLineInTH2File":"","numericSpecifications":[{"partType":"double","value":0.15,"decimalPositions":2}],"unit":{"partType":"lengthUnit","unit":"m"}}',
        ],
        'scrapChildren': [
          '{"elementType":"point","mpID":4,"parentMPID":0,"sameLineComment":null,"originalLineInTH2File":"","position":{"partType":"position","coordinates":{"dx":-2.073076837713069,"dy":0.04164428710937518},"decimalPositions":3},"pointType":"station","unknownPLAType":"","optionsMap":{},"attrOptionsMap":{}}',
        ],
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
            final THFile snapshotOriginal = THFile.fromMap(parsedFile.toMap());

            /// Execution: taken from _MPAddScrapDialogOverlayWindowWidgetState._createScrap()

            controller.setCanvasScale(1);

            final List<THCommandOption>? scrapOptions =
                (success['scrapOptions'] != null)
                ? (success['scrapOptions'] as List<dynamic>)
                      .map(
                        (s) => THCommandOption.fromMap(jsonDecode(s as String)),
                      )
                      .toList()
                : null;
            final List<THElement>? scrapChildren =
                (success['scrapChildren'] != null)
                ? (success['scrapChildren'] as List<dynamic>)
                      .map((s) => THElement.fromMap(jsonDecode(s as String)))
                      .toList()
                : null;

            controller.elementEditController.createScrap(
              thID: 'scrap1',
              scrapChildren: scrapChildren,
              scrapOptions: scrapOptions,
            );

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
