// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
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

  group('command: MPAddLineCommand with default options', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test(
      'adding a line when a default option is set must not throw an exception',
      () async {
        final parser = TH2FileParser();
        final writer = TH2FileWriter();
        mpLocator.mpGeneralController.reset();

        final String path = THTestAux.testPath('2025-10-06-002-scrap.th2');
        final (parsedFile, isSuccessful, errors) = await parser.parse(
          path,
          forceNewController: true,
        );

        expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
        expect(parsedFile, isA<TH2File>());

        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: path);

        controller.setActiveScrap(parsedFile.getScraps().first.mpID);
        controller.setCanvasScale(0.5);

        // Set a default clip=off option for all line types.
        final THClipCommandOption defaultClipOption = THClipCommandOption(
          parentMPID: -1,
          choice: THOptionChoicesOnOffType.off,
        );

        controller.defaultOptionsController.setDefault(
          THElementType.line,
          defaultClipOption,
        );

        // addNewLineLineSegment mirrors MPTH2FileEditStateAddLine behaviour:
        // first call stores the start position, second call creates the line
        // (with posCommand that applies the default options).
        expect(
          () {
            controller.areaLineCreationController.addNewLineLineSegment(
              Offset(1, 2),
            );
            controller.areaLineCreationController.addNewLineLineSegment(
              Offset(3, 4),
            );
          },
          returnsNormally,
          reason:
              'addNewLineLineSegment must not throw when default options '
              'are configured.',
        );

        // The line should have been added with the default clip option.
        final String asFileChanged = writer.serialize(controller.th2File);

        expect(asFileChanged, contains('clip off'));

        // The line element itself must carry the clip option.
        final THLine newLine = controller.th2File.getLines().first;
        final THClipCommandOption? clipOption =
            newLine.getOption(THCommandOptionType.clip) as THClipCommandOption?;

        expect(clipOption, isNotNull);
        expect(clipOption!.choice, THOptionChoicesOnOffType.off);
      },
    );

    test(
      'adding a line with default options can be undone to the original state',
      () async {
        final parser = TH2FileParser();
        final writer = TH2FileWriter();
        mpLocator.mpGeneralController.reset();

        final String path = THTestAux.testPath('2025-10-06-002-scrap.th2');
        final (parsedFile, isSuccessful, errors) = await parser.parse(
          path,
          forceNewController: true,
        );

        expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: path);

        final TH2File snapshotOriginal = TH2File.fromMap(
          controller.th2File.toMap(),
        );

        final String asFileOriginal = writer.serialize(controller.th2File);

        controller.setActiveScrap(parsedFile.getScraps().first.mpID);
        controller.setCanvasScale(0.5);

        // Set a default clip=off option for all line types.
        final THClipCommandOption defaultClipOption = THClipCommandOption(
          parentMPID: -1,
          choice: THOptionChoicesOnOffType.off,
        );

        controller.defaultOptionsController.setDefault(
          THElementType.line,
          defaultClipOption,
        );

        // Create the line (two calls mirror the state machine interaction).
        controller.areaLineCreationController.addNewLineLineSegment(
          Offset(1, 2),
        );
        controller.areaLineCreationController.addNewLineLineSegment(
          Offset(3, 4),
        );

        // Undo the line creation.
        controller.undo();

        final String asFileUndone = writer.serialize(controller.th2File);

        expect(asFileUndone, asFileOriginal);
        expect(identical(controller.th2File, snapshotOriginal), isFalse);
        expect(controller.th2File == snapshotOriginal, isTrue);
      },
    );
  });
}
