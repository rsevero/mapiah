// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/mp_pla_type_subtype.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
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

  TH2FileEditController buildController() {
    final TH2FileEditController controller = mpLocator.mpGeneralController
        .getTH2FileEditControllerForNewFile(
          scrapTHID: 'scrap-1',
          scrapOptions: const [],
          encoding: 'utf-8',
        );

    controller.setCanvasScale(1);

    return controller;
  }

  THLine committedLine(TH2FileEditController controller) {
    return controller.th2File.getLines().first;
  }

  void drawStroke(
    TH2FileEditController controller, {
    Offset origin = const Offset(0, 0),
  }) {
    controller.freehandLineCreationController.startStroke(
      origin + const Offset(0, 0),
    );
    controller.freehandLineCreationController.appendStrokeSample(
      origin + const Offset(20, 0),
    );
    controller.freehandLineCreationController.appendStrokeSample(
      origin + const Offset(40, 20),
    );
    controller.freehandLineCreationController.finishStroke(
      origin + const Offset(60, 20),
    );
  }

  group('freehand line defaults, subtype, decimal positions, active scrap', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test('committed line carries the current line type and subtype', () {
      final TH2FileEditController controller = buildController();

      controller.elementEditController.setPLATypeSubtypeForNewElement(
        const MPPLATypeSubtype(pla: MPPLAType.line, type: 'wall', subtype: 'pit'),
      );

      drawStroke(controller);

      final THLine line = committedLine(controller);

      expect(line.lineType, THLineType.wall);

      final THSubtypeCommandOption? subtypeOption =
          line.getOption(THCommandOptionType.subtype)
              as THSubtypeCommandOption?;

      expect(subtypeOption, isNotNull);
      expect(subtypeOption!.subtype, 'pit');
    });

    test('applicable default options are attached to the committed line', () {
      final TH2FileEditController controller = buildController();
      final THClipCommandOption defaultClipOption = THClipCommandOption(
        parentMPID: -1,
        choice: THOptionChoicesOnOffType.off,
      );

      controller.defaultOptionsController.setDefault(
        THElementType.line,
        defaultClipOption,
      );

      drawStroke(controller);

      final THLine line = committedLine(controller);
      final THClipCommandOption? clipOption =
          line.getOption(THCommandOptionType.clip) as THClipCommandOption?;

      expect(clipOption, isNotNull);
      expect(clipOption!.choice, THOptionChoicesOnOffType.off);
    });

    test('generated segment endpoints use the controller decimal positions', () {
      final TH2FileEditController controller = buildController();

      // A higher canvas scale drives currentDecimalPositions higher via the
      // controller's own reaction; read it back rather than hard-coding a
      // value so this test tracks that reaction instead of duplicating it.
      controller.setCanvasScale(1000);

      final int expectedDecimalPositions = controller.currentDecimalPositions;

      expect(expectedDecimalPositions, greaterThan(0));

      controller.freehandLineCreationController.startStroke(
        const Offset(0, 0),
      );
      controller.freehandLineCreationController.appendStrokeSample(
        const Offset(20, 0),
      );
      controller.freehandLineCreationController.finishStroke(
        const Offset(60, 20),
      );

      final THLine line = committedLine(controller);
      final List<THStraightLineSegment> segments = line
          .getLineSegments(controller.th2File)
          .cast<THStraightLineSegment>();

      for (final THStraightLineSegment segment in segments) {
        expect(segment.endPoint.decimalPositions, expectedDecimalPositions);
      }
    });

    test('the committed line is added under the active scrap', () async {
      final parser = TH2FileParser();
      final String path = THTestAux.testPath(
        '2026-03-18-002-two_scraps_with_point_line_area.th2',
      );
      final (parsedFile, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
      expect(parsedFile, isA<TH2File>());

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);
      final List<THScrap> scraps = parsedFile.getScraps().toList();

      expect(
        scraps.length >= 2,
        isTrue,
        reason: 'Test file must contain at least two scraps',
      );

      final THScrap secondScrap = scraps[1];
      final Set<int> linesBeforeDraw = controller.th2File
          .getLines()
          .map((THLine line) => line.mpID)
          .toSet();

      controller.setActiveScrap(secondScrap.mpID);
      controller.setCanvasScale(1);
      drawStroke(controller, origin: const Offset(5000, 5000));

      final THLine newLine = controller.th2File
          .getLines()
          .firstWhere((THLine line) => !linesBeforeDraw.contains(line.mpID));

      expect(newLine.parentMPID, secondScrap.mpID);
    });
  });
}
