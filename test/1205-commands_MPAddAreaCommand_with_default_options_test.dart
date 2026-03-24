// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
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

  group('command: MPAddAreaCommand with default options', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test(
      'adding an area when a default option is set must not throw an exception',
      () async {
        final parser = TH2FileParser();
        final writer = TH2FileWriter();
        mpLocator.mpGeneralController.reset();

        final String path = THTestAux.testPath('2025-10-05-001-line.th2');
        final (parsedFile, isSuccessful, errors) = await parser.parse(
          path,
          forceNewController: true,
        );

        expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
        expect(parsedFile, isA<TH2File>());

        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: path);

        controller.setActiveScrap(parsedFile.getScraps().first.mpID);

        // Set a default clip=off option for all area types.
        final THClipCommandOption defaultClipOption = THClipCommandOption(
          parentMPID: -1,
          choice: THOptionChoicesOnOffType.off,
        );

        controller.defaultOptionsController.setDefault(
          THElementType.area,
          defaultClipOption,
        );

        // Replicate MPTH2FileEditStateAddArea.onPrimaryButtonClick: get the
        // new area, build posCommands from defaultOptionsController, then
        // create MPAddAreaCommand with posCommand and combine with the line
        // association command.
        final THArea area = controller.areaLineCreationController.getNewArea();

        final List<THCommandOption> defaultOptions = controller
            .defaultOptionsController
            .getApplicableDefaults(
              elementType: THElementType.area,
              typeString: area.areaType.name,
            );

        final List<MPCommand> posCommands = [];

        for (final THCommandOption defaultOption in defaultOptions) {
          if (defaultOption.type == THCommandOptionType.subtype) {
            continue;
          }
          posCommands.add(
            MPCommandFactory.setOptionOnElements(
              toOption: defaultOption.copyWith(
                parentMPID: area.mpID,
                originalLineInTH2File: '',
              ),
              elements: [area],
              th2File: controller.th2File,
            ),
          );
        }

        final MPCommand? posCommand = posCommands.isEmpty
            ? null
            : MPCommandFactory.multipleCommandsFromList(
                commandsList: posCommands,
                descriptionType: MPCommandDescriptionType.addArea,
                completionType:
                    MPMultipleElementsCommandCompletionType.optionsEdited,
              );

        final List<THElement> areaChildren = area
            .getChildren(controller.th2File)
            .toList();
        final MPCommand addAreaCommand = MPAddAreaCommand.forCWJM(
          newArea: area,
          areaChildren: areaChildren,
          areaPositionInParent: mpAddChildAtEndMinusOneOfParentChildrenList,
          posCommand: posCommand,
        );

        final THLine line = parsedFile.getLines().first;
        final MPCommand addLineToAreaCommand = MPCommandFactory.addLineToArea(
          area: area,
          line: line,
          th2File: controller.th2File,
        );

        final MPCommand combined = MPMultipleElementsCommand.forCWJM(
          commandsList: [addAreaCommand, addLineToAreaCommand],
          completionType:
              MPMultipleElementsCommandCompletionType.elementsEdited,
          descriptionType: MPCommandDescriptionType.addArea,
        );

        expect(
          () => controller.execute(combined),
          returnsNormally,
          reason:
              'Adding an area must not throw when default options are '
              'configured.',
        );

        // The area should have been added with the default clip option.
        final String asFileChanged = writer.serialize(controller.th2File);

        expect(asFileChanged, contains('area water'));
        expect(asFileChanged, contains('clip off'));
      },
    );

    test(
      'adding an area with default options can be undone to the original state',
      () async {
        final parser = TH2FileParser();
        final writer = TH2FileWriter();
        mpLocator.mpGeneralController.reset();

        final String path = THTestAux.testPath('2025-10-05-001-line.th2');
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

        // Set a default clip=off option for all area types.
        final THClipCommandOption defaultClipOption = THClipCommandOption(
          parentMPID: -1,
          choice: THOptionChoicesOnOffType.off,
        );

        controller.defaultOptionsController.setDefault(
          THElementType.area,
          defaultClipOption,
        );

        final THArea area = controller.areaLineCreationController.getNewArea();

        final List<THCommandOption> defaultOptions = controller
            .defaultOptionsController
            .getApplicableDefaults(
              elementType: THElementType.area,
              typeString: area.areaType.name,
            );

        final List<MPCommand> posCommands = [];

        for (final THCommandOption defaultOption in defaultOptions) {
          if (defaultOption.type == THCommandOptionType.subtype) {
            continue;
          }
          posCommands.add(
            MPCommandFactory.setOptionOnElements(
              toOption: defaultOption.copyWith(
                parentMPID: area.mpID,
                originalLineInTH2File: '',
              ),
              elements: [area],
              th2File: controller.th2File,
            ),
          );
        }

        final MPCommand? posCommand = posCommands.isEmpty
            ? null
            : MPCommandFactory.multipleCommandsFromList(
                commandsList: posCommands,
                descriptionType: MPCommandDescriptionType.addArea,
                completionType:
                    MPMultipleElementsCommandCompletionType.optionsEdited,
              );

        final List<THElement> areaChildren = area
            .getChildren(controller.th2File)
            .toList();
        final MPCommand addAreaCommand = MPAddAreaCommand.forCWJM(
          newArea: area,
          areaChildren: areaChildren,
          areaPositionInParent: mpAddChildAtEndMinusOneOfParentChildrenList,
          posCommand: posCommand,
        );

        final THLine line = parsedFile.getLines().first;
        final MPCommand addLineToAreaCommand = MPCommandFactory.addLineToArea(
          area: area,
          line: line,
          th2File: controller.th2File,
        );

        final MPCommand combined = MPMultipleElementsCommand.forCWJM(
          commandsList: [addAreaCommand, addLineToAreaCommand],
          completionType:
              MPMultipleElementsCommandCompletionType.elementsEdited,
          descriptionType: MPCommandDescriptionType.addArea,
        );

        controller.execute(combined);

        // Undo the area creation.
        controller.undo();

        final String asFileUndone = writer.serialize(controller.th2File);

        expect(asFileUndone, asFileOriginal);
        expect(identical(controller.th2File, snapshotOriginal), isFalse);
        expect(controller.th2File == snapshotOriginal, isTrue);
      },
    );
  });
}
