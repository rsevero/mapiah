import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  group('actions: simplify tight lines using provided pre/pos files', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test(
      'simplifySelectedLines transforms pre into expected pos6 and undo restores',
      () async {
        final parser = THFileParser();
        final writer = THFileWriter();

        final String preFilename = THTestAux.testPath(
          '2026-03-08-001-tight_lines_pre.th2',
        );
        final String posFilename = THTestAux.testPath(
          '2026-03-08-002-tight_lines_pos6.th2',
        );

        final (parsedPre, preSuccess, preErrors) = await parser.parse(
          preFilename,
          forceNewController: true,
        );
        expect(preSuccess, isTrue, reason: 'Parser errors pre: $preErrors');
        expect(parsedPre, isA<THFile>());

        final (parsedPos, posSuccess, posErrors) = await parser.parse(
          posFilename,
          forceNewController: false,
        );
        expect(posSuccess, isTrue, reason: 'Parser errors pos: $posErrors');
        expect(parsedPos, isA<THFile>());

        final String preSerialized = writer.serialize(parsedPre);
        final String expectedPosSerialized = writer.serialize(parsedPos);

        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: preFilename);

        // Snapshot original state
        final THFile snapshotOriginal = THFile.fromMap(
          controller.thFile.toMap(),
        );

        // Select the single line in the file
        final line = controller.thFile.getLines().first;

        controller.selectionController.addSelectedElement(line);
        controller.setCanvasScale(1.0);
        controller.elementEditController.setLineSimplificationMethod(
          MPLineSimplificationMethod.forceBezier,
        );
        controller.elementEditController.simplifySelectedLines();

        final String afterSerialized = writer.serialize(controller.thFile);

        expect(afterSerialized, expectedPosSerialized);

        // Undo and verify original restored
        controller.undo();
        final String undoneSerialized = writer.serialize(controller.thFile);
        expect(undoneSerialized, preSerialized);
        expect(controller.thFile == snapshotOriginal, isTrue);
        expect(identical(controller.thFile, snapshotOriginal), isFalse);
      },
    );
  });
}
