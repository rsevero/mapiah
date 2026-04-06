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
import 'package:mapiah/src/elements/types/th_point_type.dart';
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
  group('command: MPEditPointTypeCommand', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const successes = [
      {
        'file': '2025-10-07-002-point.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  point 12.2 42.7 station
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  point 12.2 42.7 stalactite
endscrap
''',
        'newPLAType': 'stalactite',
      },
      {
        'file': '2025-10-07-002-point.th2',
        'length': 4,
        'encoding': 'UTF-8',
        'asFileOriginal': r'''encoding UTF-8
scrap test
  point 12.2 42.7 station
endscrap
''',
        'asFileChanged': r'''encoding UTF-8
scrap test
  point 12.2 42.7 stairwaytoheaven
endscrap
''',
        'newPLAType': 'stairwaytoheaven',
      },
    ];

    int count = 1;

    for (var success in successes) {
      test(
        'apply and undo yields original state (equal by value, not identity) : ${success['file']} - ${count++}',
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

            /// Execution: taken from TH2FileEditUserInteractionController.prepareSetPLAType()

            controller.setActiveScrap(parsedFile.getScraps().first.mpID);

            final int pointMPID = parsedFile.getPoints().first.mpID;

            final MPCommand setPLATypeCommand = MPCommandFactory.editPointsType(
              newPointType: THPointType.fromString(
                success['newPLAType'] as String,
              ),
              unknownPLAType: THPointType.unknownPLATypeFromString(
                success['newPLAType'] as String,
              ),
              pointMPIDs: [pointMPID],
            );

            controller.execute(setPLATypeCommand);

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
      'changing a point to station creates a separate undo step for the station name',
      () async {
        final TH2FileParser parser = TH2FileParser();
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

        controller.setActiveScrap(parsedFile.getScraps().first.mpID);
        final THPoint anchorPoint = THPoint.pointTypeFromString(
          parentMPID: parsedFile.getScraps().first.mpID,
          pointTypeString: 'anchor',
          position: THPositionPart(coordinates: const Offset(1, 2)),
        );
        final MPCommand addPointCommand = MPAddPointCommand(
          newPoint: anchorPoint,
          posCommand: null,
        );

        controller.execute(addPointCommand);
        controller.undoRedoController.clearUndoRedoStack();

        final THPoint point = controller.th2File.getPoints().first;

        controller.selectionController.setSelectedElements([point]);
        controller.userInteractionController.prepareSetPLAType(
          elementType: THElementType.point,
          newPLAType: 'station',
        );

        final THPoint stationPoint = controller.th2File.getPoints().first;
        final THStationNameCommandOption? nameOption =
            stationPoint.getOption(THCommandOptionType.station)
                as THStationNameCommandOption?;

        expect(stationPoint.pointType, THPointType.station);
        expect(nameOption, isNotNull);
        expect(nameOption!.reference, '0');

        controller.undo();

        final THPoint pointAfterFirstUndo = controller.th2File
            .getPoints()
            .first;

        expect(pointAfterFirstUndo.pointType, THPointType.station);
        expect(
          pointAfterFirstUndo.hasOption(THCommandOptionType.station),
          isFalse,
        );

        controller.undo();

        final THPoint pointAfterSecondUndo = controller.th2File
            .getPoints()
            .first;

        expect(pointAfterSecondUndo.pointType, THPointType.anchor);
        expect(
          pointAfterSecondUndo.hasOption(THCommandOptionType.station),
          isFalse,
        );
        expect(
          writer.serialize(controller.th2File),
          contains('point 1 2 anchor'),
        );
      },
    );

    test(
      'changing a point to station skips station names already used in the active scrap',
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
        final THPoint anchorPoint = THPoint.pointTypeFromString(
          parentMPID: parsedFile.getScraps().first.mpID,
          pointTypeString: 'anchor',
          position: THPositionPart(coordinates: const Offset(5, 6)),
        );

        controller.execute(
          MPAddPointCommand(newPoint: stationPoint0, posCommand: null),
        );
        controller.execute(
          MPSetOptionToElementCommand(
            toOption: THStationNameCommandOption.fromStringWithParentMPID(
              parentMPID: stationPoint0.mpID,
              reference: '0',
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
              reference: '1',
            ),
          ),
        );

        controller.execute(
          MPSetOptionToElementCommand(
            toOption: THStationNameCommandOption.fromStringWithParentMPID(
              parentMPID: stationPoint0.mpID,
              reference: '0',
            ),
          ),
        );

        controller.execute(
          MPAddPointCommand(newPoint: anchorPoint, posCommand: null),
        );
        controller.undoRedoController.clearUndoRedoStack();

        controller.selectionController.setSelectedElements([anchorPoint]);
        controller.userInteractionController.prepareSetPLAType(
          elementType: THElementType.point,
          newPLAType: 'station',
        );

        final THStationNameCommandOption? nameOption =
            controller.th2File
                    .pointByMPID(anchorPoint.mpID)
                    .getOption(THCommandOptionType.station)
                as THStationNameCommandOption?;

        expect(nameOption, isNotNull);
        expect(nameOption!.reference, '2');
        expect(controller.elementEditController.lastUsedStationName, '2');
      },
    );
  });
}
