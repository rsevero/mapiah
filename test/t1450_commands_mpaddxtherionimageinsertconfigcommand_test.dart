// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_svg_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:path/path.dart' as p;
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
  group('command: MPAddImageInsertConfigCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-06-004-only_encoding.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
''',
        'asFileChanged': r'''encoding UTF-8
##XTHERION## xth_me_image_insert {-0 1 1} -433 "./xvi/2025-10-07-001-color_as_rgb_hex.xvi" 0 {}
''',
        'imageInsertFile':
            './test/auxiliary/xvi/2025-10-07-001-color_as_rgb_hex.xvi',
      },
      {
        'file': '2025-10-06-004-only_encoding.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
''',
        'asFileChanged': r'''encoding UTF-8
##XTHERION## xth_me_image_insert {-0 1 1} 0 "./jpg/2025-10-07-001.jpg" 0 {}
''',
        'imageInsertFile': './test/auxiliary/jpg/2025-10-07-001.jpg',
      },
      {
        'file': '2025-10-06-004-only_encoding.th2',
        'length': 1,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
''',
        'asFileChanged': r'''encoding UTF-8
##MAPIAH## image_insert_v1 {format=svg;filename=.%2Fsvg%2F2026-04-11-001-sized.svg;xx=-0;yy=0;xScale=1;yScale=1;rotationCenterDx=0;rotationCenterDy=0;rotationDeg=0;pivotSet=false;intrinsicWidth=120.0;intrinsicHeight=60.0;sourceViewBoxLeft=0.0;sourceViewBoxTop=0.0;sourceViewBoxWidth=120.0;sourceViewBoxHeight=60.0}
''',
        'imageInsertFile': './test/auxiliary/svg/2026-04-11-001-sized.svg',
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
              parsedFile.toMap(),
            );

            /// Execution: taken from TH2FileEditElementEditController.addImage()

            controller.setCanvasScale(1);

            final MPCommand addImageCommand =
                MPCommandFactory.addImageInsertConfig(
                  imageFilename: success['imageInsertFile'] as String,
                  th2FileEditController: controller,
                  svgIntrinsicSizeInfo:
                      (success['imageInsertFile'] as String).endsWith('.svg')
                      ? MPSVGAux.parseMetadataInfo(
                          File(
                            success['imageInsertFile']! as String,
                          ).readAsStringSync(),
                        ).resolveIntrinsicSizeInfo()
                      : null,
                );

            controller.execute(addImageCommand);

            final String asFileChanged = writer.serialize(controller.th2File);

            expect(asFileChanged, success['asFileChanged']);

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

    test(
      'new unsaved file keeps inserted raster image path absolute until first save',
      () {
        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditControllerForNewFile(
              scrapTHID: 'scrap-1',
              scrapOptions: const [],
              encoding: 'utf-8',
            );
        final String imagePath = THTestAux.testPath('jpg/2025-10-07-001.jpg');
        final MPCommand addImageCommand = MPCommandFactory.addImageInsertConfig(
          imageFilename: imagePath,
          th2FileEditController: controller,
        );

        controller.execute(addImageCommand);

        final List<MPRuntimeImageInsertConfigMixin> images = controller.th2File
            .getImages()
            .toList();

        expect(images, hasLength(1));
        expect(images.first.filename, p.absolute(imagePath));
      },
    );
  });
}
