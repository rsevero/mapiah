// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/controllers/mp_default_options_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('MPDefaultOptionsController unit tests', () {
    late TH2FileEditController th2Controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();

      final String path = THTestAux.testPath('2025-10-05-001-line.th2');

      th2Controller = mpLocator.mpGeneralController.getTH2FileEditController(
        filename: path,
      );

      await th2Controller.load();

      // Clear any defaults that may have been cached in the settings controller
      // from a previous test.
      th2Controller.defaultOptionsController.clearAll();
    });

    test(
      'setDefault stores option and getDefaultsForElementType returns it',
      () {
        final MPDefaultOptionsController controller =
            th2Controller.defaultOptionsController;

        final THClipCommandOption clipOption = THClipCommandOption(
          parentMPID: -1,
          choice: THOptionChoicesOnOffType.off,
        );

        controller.setDefault(THElementType.area, clipOption);

        final Map<THCommandOptionType, THCommandOption> defaults = controller
            .getDefaultsForElementType(THElementType.area);

        expect(defaults.containsKey(THCommandOptionType.clip), isTrue);
        expect(
          (defaults[THCommandOptionType.clip] as THClipCommandOption).choice,
          THOptionChoicesOnOffType.off,
        );
      },
    );

    test('hasAnyDefaults and hasDefaultsForType reflect stored defaults', () {
      final MPDefaultOptionsController controller =
          th2Controller.defaultOptionsController;

      expect(controller.hasAnyDefaults, isFalse);
      expect(controller.hasDefaultsForType(THElementType.area), isFalse);

      final THClipCommandOption clipOption = THClipCommandOption(
        parentMPID: -1,
        choice: THOptionChoicesOnOffType.off,
      );

      controller.setDefault(THElementType.area, clipOption);

      expect(controller.hasAnyDefaults, isTrue);
      expect(controller.hasDefaultsForType(THElementType.area), isTrue);
      expect(controller.hasDefaultsForType(THElementType.point), isFalse);
      expect(controller.hasDefaultsForType(THElementType.line), isFalse);
    });

    test('getApplicableDefaults returns options applicable to given type', () {
      final MPDefaultOptionsController controller =
          th2Controller.defaultOptionsController;

      final THClipCommandOption clipOption = THClipCommandOption(
        parentMPID: -1,
        choice: THOptionChoicesOnOffType.off,
      );

      controller.setDefault(THElementType.area, clipOption);

      // clip is supported for all area types
      final List<THCommandOption> waterDefaults = controller
          .getApplicableDefaults(
            elementType: THElementType.area,
            typeString: 'water',
          );

      expect(waterDefaults.length, 1);
      expect(waterDefaults.first.type, THCommandOptionType.clip);

      // Defaults for area should not appear when querying point type
      final List<THCommandOption> pointDefaults = controller
          .getApplicableDefaults(
            elementType: THElementType.point,
            typeString: 'station',
          );

      expect(pointDefaults.isEmpty, isTrue);
    });

    test('removeDefault removes the stored option', () {
      final MPDefaultOptionsController controller =
          th2Controller.defaultOptionsController;

      final THClipCommandOption clipOption = THClipCommandOption(
        parentMPID: -1,
        choice: THOptionChoicesOnOffType.off,
      );

      controller.setDefault(THElementType.area, clipOption);
      expect(controller.hasDefaultsForType(THElementType.area), isTrue);

      controller.removeDefault(THElementType.area, THCommandOptionType.clip);
      expect(controller.hasDefaultsForType(THElementType.area), isFalse);
    });

    test('clearForElementType removes all options for given type', () {
      final MPDefaultOptionsController controller =
          th2Controller.defaultOptionsController;

      final THClipCommandOption clipOption = THClipCommandOption(
        parentMPID: -1,
        choice: THOptionChoicesOnOffType.off,
      );
      final THClipCommandOption lineClipOption = THClipCommandOption(
        parentMPID: -1,
        choice: THOptionChoicesOnOffType.off,
      );

      controller.setDefault(THElementType.area, clipOption);
      controller.setDefault(THElementType.line, lineClipOption);

      expect(controller.hasDefaultsForType(THElementType.area), isTrue);
      expect(controller.hasDefaultsForType(THElementType.line), isTrue);

      controller.clearForElementType(THElementType.area);

      expect(controller.hasDefaultsForType(THElementType.area), isFalse);
      expect(controller.hasDefaultsForType(THElementType.line), isTrue);
    });

    test('default options state map excludes point -name option', () {
      th2Controller.optionEditController.setDefaultOptionsElementType(
        THElementType.point,
      );
      th2Controller.optionEditController.updateDefaultOptionsStateMap();

      expect(
        th2Controller.optionEditController.optionStateMap.containsKey(
          THCommandOptionType.name,
        ),
        isFalse,
      );
    });
  });

  group('Area creation with posCommand (subtype and default options)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test(
      'area created with clip:off posCommand writes -clip off to file',
      () async {
        try {
          final TH2FileParser parser = TH2FileParser();
          final TH2FileWriter writer = TH2FileWriter();

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

          final THArea area = controller.areaLineCreationController
              .getNewArea();
          final List<THElement> areaChildren = area
              .getChildren(controller.th2File)
              .toList();

          // Build a posCommand that sets clip to off on the new area.
          final THClipCommandOption clipOption = THClipCommandOption(
            parentMPID: area.mpID,
            choice: THOptionChoicesOnOffType.off,
          );
          final MPCommand clipCommand = MPCommandFactory.setOptionOnElements(
            toOption: clipOption,
            elements: [area],
            th2File: controller.th2File,
          );

          final MPCommand addAreaCommand = MPAddAreaCommand.forCWJM(
            newArea: area,
            areaChildren: areaChildren,
            areaPositionInParent: mpAddChildAtEndMinusOneOfParentChildrenList,
            posCommand: clipCommand,
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

          final String asFileChanged = writer.serialize(controller.th2File);

          expect(asFileChanged, contains('area water'));
          expect(asFileChanged, contains('-clip off'));

          // Undo should restore original state.
          controller.undo();

          final String asFileUndone = writer.serialize(controller.th2File);

          expect(asFileUndone, isNot(contains('area water')));
          expect(asFileUndone, isNot(contains('-clip off')));
        } catch (e, st) {
          fail('Unexpected exception: $e\n$st');
        }
      },
    );

    test(
      'area created with subtype posCommand writes -subtype to file',
      () async {
        try {
          final TH2FileParser parser = TH2FileParser();
          final TH2FileWriter writer = TH2FileWriter();

          mpLocator.mpGeneralController.reset();

          final String path = THTestAux.testPath('2025-10-05-001-line.th2');
          final (parsedFile, isSuccessful, errors) = await parser.parse(
            path,
            forceNewController: true,
          );

          expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

          final TH2FileEditController controller = mpLocator.mpGeneralController
              .getTH2FileEditController(filename: path);

          controller.setActiveScrap(parsedFile.getScraps().first.mpID);

          // Use ice:crystals to test subtype injection.
          controller.elementEditController.setUsedAreaType(
            areaType: 'ice',
            areaSubtype: 'crystals',
          );

          final THArea area = controller.areaLineCreationController
              .getNewArea();
          final List<THElement> areaChildren = area
              .getChildren(controller.th2File)
              .toList();

          // Build posCommand for subtype (mirrors MPTH2FileEditStateAddArea logic).
          final THSubtypeCommandOption subtypeOption = THSubtypeCommandOption(
            parentMPID: area.mpID,
            subtype: 'crystals',
          );
          final MPCommand subtypeCommand = MPCommandFactory.setOptionOnElements(
            toOption: subtypeOption,
            elements: [area],
            th2File: controller.th2File,
          );

          final MPCommand addAreaCommand = MPAddAreaCommand.forCWJM(
            newArea: area,
            areaChildren: areaChildren,
            areaPositionInParent: mpAddChildAtEndMinusOneOfParentChildrenList,
            posCommand: subtypeCommand,
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

          final String asFileChanged = writer.serialize(controller.th2File);

          // The writer embeds subtype into the type string as "ice:crystals".
          expect(asFileChanged, contains('area ice:crystals'));

          // Undo should restore original state.
          controller.undo();

          final String asFileUndone = writer.serialize(controller.th2File);

          expect(asFileUndone, isNot(contains('area ice')));
          expect(asFileUndone, isNot(contains('-subtype crystals')));
        } catch (e, st) {
          fail('Unexpected exception: $e\n$st');
        }
      },
    );
  });
}
