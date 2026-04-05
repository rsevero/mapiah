// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
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

  group('command: MPAddAreaCommand with multiple clicked border lines', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test('keeps all previously clicked lines as area borders', () async {
      final TH2FileParser parser = TH2FileParser();
      final String path = THTestAux.testPath(
        '2026-04-05-011-two_lines_without_area.th2',
      );
      final (parsedFile, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      controller.setActiveScrap(parsedFile.getScraps().first.mpID);

      final List<THLine> lines = parsedFile.getLines().toList();

      for (final THLine line in lines) {
        final THArea area = controller.areaLineCreationController.getNewArea();
        final MPCommand addLineToAreaCommand = MPCommandFactory.addLineToArea(
          area: area,
          line: line,
          th2File: controller.th2File,
        );
        final List<THElement> areaChildren = area
            .getChildren(controller.th2File)
            .toList();
        final MPCommand addAreaCommand = MPAddAreaCommand.forCWJM(
          newArea: area,
          areaChildren: areaChildren,
          areaPositionInParent: mpAddChildAtEndMinusOneOfParentChildrenList,
          posCommand: null,
        );
        final MPCommand addAreaWithLineCommand =
            MPCommandFactory.multipleCommandsFromList(
              commandsList: <MPCommand>[addAreaCommand, addLineToAreaCommand],
              completionType:
                  MPMultipleElementsCommandCompletionType.elementsEdited,
              descriptionType: MPCommandDescriptionType.addArea,
            );

        controller.execute(addAreaWithLineCommand);
      }

      final THArea createdArea = controller.th2File.getAreas().first;

      expect(createdArea.getLineTHIDs(controller.th2File), <String>{
        'line1',
        'line2',
      });
      expect(
        createdArea.getAreaBorderTHIDMPIDs(controller.th2File).length,
        lines.length,
      );
    });

    test('selection-driven addArea flow keeps all clicked lines', () async {
      final TH2FileParser parser = TH2FileParser();
      final String path = THTestAux.testPath(
        '2026-04-05-012-two_lines_without_ids_without_area.th2',
      );
      final (parsedFile, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      controller.updateScreenSize(const Size(1280, 720));
      controller.zoomOneToOne();
      controller.setActiveScrap(parsedFile.getScraps().first.mpID);

      final List<THLine> lines = parsedFile.getLines().toList();

      for (final THLine line in lines) {
        final List<THLineSegment> lineSegments = line.getLineSegments(
          controller.th2File,
        );
        final Offset start = lineSegments.first.endPoint.coordinates;
        final Offset end = lineSegments.last.endPoint.coordinates;
        final Offset midpoint = Offset(
          (start.dx + end.dx) / 2,
          (start.dy + end.dy) / 2,
        );
        final Offset clickPosition = controller.offsetCanvasToScreen(midpoint);
        final Map<int, THElement> clickedLines = controller.selectionController
            .getSelectableElementsClickedWithoutDialog(
              screenCoordinates: clickPosition,
              selectionType: THSelectionType.line,
            );

        expect(clickedLines.length, 1);

        final THArea area = controller.areaLineCreationController.getNewArea();
        final THLine clickedLine = clickedLines.values.first as THLine;
        final MPCommand addLineToAreaCommand = MPCommandFactory.addLineToArea(
          area: area,
          line: clickedLine,
          th2File: controller.th2File,
        );
        final bool isFirstClickedBorder = area
            .getAreaBorderTHIDMPIDs(controller.th2File)
            .isEmpty;

        if (isFirstClickedBorder) {
          final List<THElement> areaChildren = area
              .getChildren(controller.th2File)
              .toList();
          final MPCommand addAreaCommand = MPAddAreaCommand.forCWJM(
            newArea: area,
            areaChildren: areaChildren,
            areaPositionInParent: mpAddChildAtEndMinusOneOfParentChildrenList,
            posCommand: null,
          );
          final MPCommand addAreaWithLineCommand =
              MPCommandFactory.multipleCommandsFromList(
                commandsList: <MPCommand>[addAreaCommand, addLineToAreaCommand],
                completionType:
                    MPMultipleElementsCommandCompletionType.elementsEdited,
                descriptionType: MPCommandDescriptionType.addArea,
              );

          controller.execute(addAreaWithLineCommand);
        } else {
          controller.execute(addLineToAreaCommand);
        }
      }

      final THArea createdArea = controller.th2File.getAreas().first;

      expect(createdArea.getLineMPIDs(controller.th2File).length, lines.length);
      expect(
        createdArea.getAreaBorderTHIDMPIDs(controller.th2File).length,
        lines.length,
      );
    });
  });
}
