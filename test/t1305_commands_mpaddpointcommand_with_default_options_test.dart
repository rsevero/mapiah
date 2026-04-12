// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
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

  group('command: MPAddPointCommand with default options', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test(
      'adding a point when a default option is set must not throw an exception',
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

        // Set a default clip=off option for all point types.
        final THClipCommandOption defaultClipOption = THClipCommandOption(
          parentMPID: -1,
          choice: THOptionChoicesOnOffType.off,
        );

        controller.defaultOptionsController.setDefault(
          THElementType.point,
          defaultClipOption,
        );

        // This should not throw "No element with index '...' in file".
        final MPCommand command = MPCommandFactory.addPoint(
          screenPosition: Offset(1, 2),
          pointTypeString: controller.elementEditController
              .getPointTypeAndSubtypeForNewPoint()
              .type,
          pointSubtypeString: '',
          th2FileEditController: controller,
        );

        expect(
          () => controller.execute(command),
          returnsNormally,
          reason:
              'addPoint must not throw when default options are configured.',
        );

        // The point should have been added with the default clip option.
        final String asFileChanged = writer.serialize(controller.th2File);

        expect(asFileChanged, contains('clip off'));

        // The point element itself must carry the clip option.
        final THPoint newPoint = controller.th2File.getPoints().first;
        final THClipCommandOption? clipOption =
            newPoint.getOption(THCommandOptionType.clip)
                as THClipCommandOption?;

        expect(clipOption, isNotNull);
        expect(clipOption!.choice, THOptionChoicesOnOffType.off);
      },
    );

    test(
      'adding a point with default options can be undone to the original state',
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

        // Set a default clip=off option for all point types.
        final THClipCommandOption defaultClipOption = THClipCommandOption(
          parentMPID: -1,
          choice: THOptionChoicesOnOffType.off,
        );

        controller.defaultOptionsController.setDefault(
          THElementType.point,
          defaultClipOption,
        );

        final MPCommand command = MPCommandFactory.addPoint(
          screenPosition: Offset(1, 2),
          pointTypeString: controller.elementEditController
              .getPointTypeAndSubtypeForNewPoint()
              .type,
          pointSubtypeString: '',
          th2FileEditController: controller,
        );

        controller.execute(command);

        // Undo the add point.
        controller.undo();

        final String asFileUndone = writer.serialize(controller.th2File);

        expect(asFileUndone, asFileOriginal);
        expect(identical(controller.th2File, snapshotOriginal), isFalse);
        expect(controller.th2File == snapshotOriginal, isTrue);
      },
    );

    test(
      'adding a station point assigns the next station name automatically',
      () async {
        final TH2FileParser parser = TH2FileParser();
        mpLocator.mpGeneralController.reset();

        final String path = THTestAux.testPath('2025-10-06-002-scrap.th2');
        final (parsedFile, isSuccessful, errors) = await parser.parse(
          path,
          forceNewController: true,
        );

        expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: path);

        controller.setActiveScrap(parsedFile.getScraps().first.mpID);
        controller.setCanvasScale(0.5);

        final MPCommand command = MPCommandFactory.addPoint(
          screenPosition: const Offset(1, 2),
          pointTypeString: 'station',
          pointSubtypeString: '',
          th2FileEditController: controller,
        );

        controller.execute(command);

        final THPoint newPoint = controller.th2File.getPoints().first;
        final THStationNameCommandOption? nameOption =
            newPoint.getOption(THCommandOptionType.station)
                as THStationNameCommandOption?;

        expect(nameOption, isNotNull);
        expect(nameOption!.name, '0');
        expect(controller.elementEditController.lastUsedStationName, '0');
      },
    );

    test(
      'getNextStationName updates lastUsedStationName with the returned value',
      () async {
        final TH2FileParser parser = TH2FileParser();
        mpLocator.mpGeneralController.reset();

        final String path = THTestAux.testPath('2025-10-06-002-scrap.th2');
        final (parsedFile, isSuccessful, errors) = await parser.parse(
          path,
          forceNewController: true,
        );

        expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: path);

        controller.setActiveScrap(parsedFile.getScraps().first.mpID);

        final String nextStationName = controller.elementEditController
            .getAndReserveNextAvailableStationName();

        expect(nextStationName, '0');
        expect(controller.elementEditController.lastUsedStationName, '0');
      },
    );

    test(
      'adding a station point skips station names already used in the active scrap',
      () async {
        final TH2FileParser parser = TH2FileParser();
        mpLocator.mpGeneralController.reset();

        final String path = THTestAux.testPath('2025-10-06-002-scrap.th2');
        final (parsedFile, isSuccessful, errors) = await parser.parse(
          path,
          forceNewController: true,
        );

        expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: path);

        controller.setActiveScrap(parsedFile.getScraps().first.mpID);

        final THPoint stationPoint0 = THPoint.pointTypeFromString(
          parentMPID: parsedFile.getScraps().first.mpID,
          pointTypeString: 'station',
          position: THPositionPart(coordinates: const Offset(1, 2)),
        );
        final THPoint stationPoint1 = THPoint.pointTypeFromString(
          parentMPID: parsedFile.getScraps().first.mpID,
          pointTypeString: 'station',
          position: THPositionPart(coordinates: const Offset(3, 4)),
        );

        controller.execute(
          MPAddPointCommand(newPoint: stationPoint0, posCommand: null),
        );
        controller.execute(
          MPSetOptionToElementCommand(
            toOption: THStationNameCommandOption.fromStringWithParentMPID(
              parentMPID: stationPoint0.mpID,
              name: '0',
            ),
          ),
        );

        controller.execute(
          MPAddPointCommand(newPoint: stationPoint1, posCommand: null),
        );
        controller.execute(
          MPSetOptionToElementCommand(
            toOption: THStationNameCommandOption.fromStringWithParentMPID(
              parentMPID: stationPoint1.mpID,
              name: '1',
            ),
          ),
        );

        controller.execute(
          MPSetOptionToElementCommand(
            toOption: THStationNameCommandOption.fromStringWithParentMPID(
              parentMPID: stationPoint0.mpID,
              name: '0',
            ),
          ),
        );

        final MPCommand addStationPointCommand = MPCommandFactory.addPoint(
          screenPosition: const Offset(5, 6),
          pointTypeString: 'station',
          pointSubtypeString: '',
          th2FileEditController: controller,
        );

        controller.execute(addStationPointCommand);

        final THPoint newStationPoint = controller.th2File
            .getPoints()
            .toList()
            .last;
        final THStationNameCommandOption? nameOption =
            newStationPoint.getOption(THCommandOptionType.station)
                as THStationNameCommandOption?;

        expect(nameOption, isNotNull);
        expect(nameOption!.name, '2');
        expect(controller.elementEditController.lastUsedStationName, '2');
      },
    );
  });
}
