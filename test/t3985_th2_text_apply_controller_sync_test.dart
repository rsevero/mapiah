// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_normalization_analyzer.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_user_interaction_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'auxiliary/th2_text_test_session.dart';
import 'th2_text_apply_test_aux.dart';
import 'th_test_aux.dart';

const String _scrapText =
    'scrap s1\n'
    '  point 1 1 station -name A0\n'
    '  point 2 2 station -id p2\n'
    'endscrap\n';

const String _baseText = 'encoding utf-8\n$_scrapText';

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpGeneralController.reset();
  });

  tearDown(() {
    mpLocator.mpGeneralController.reset();
  });

  int liveOwner(TH2FileEditController controller, String lineText) {
    final (String text, TH2TextLineMap lineMap) = controller
        .serializeForTextMode();
    final List<String> lines = TH2TextNormalizationAnalyzer.lineTexts(text);

    return lineMap.ownerOfLine(lines.indexOf(lineText))!;
  }

  Future<void> apply(TH2FileEditController controller, String text) async {
    final TH2TextTestSession session = TH2TextTestSession.of(controller);

    session.content = text;

    final TH2TextApplyResult result = await controller.applyTextContent(
      text,
      session: session,
    );

    expect(result, isA<TH2TextApplyApplied>());
  }

  /// Every MPID the controller's model-derived state refers to.
  Set<int> referencedMPIDs(TH2FileEditController controller) => <int>{
    ...controller.selectionController.mpSelectedElementsLogical.keys,
    ...controller.selectionController.selectedEndControlPoints.keys,
    ...controller.selectionController.selectedScrapMPIDs,
    ...controller.selectionController.isSelected,
    ...controller.hideElementController.hiddenElementMPIDs,
    ...controller.hideElementController.hiddenScrapMPIDs,
    ...controller.selectionController.getMPSelectableElements().keys,
  };

  List<String> therionStations(TH2FileEditController controller) => <String>[
    for (final MPStationPointNameCoordinateRecord record
        in controller.userInteractionController
            .getTherionStationPointNameCoordinateCache())
      record.name,
  ];

  List<String> xviStations(TH2FileEditController controller) => <String>[
    for (final MPStationPointNameCoordinateRecord record
        in controller.userInteractionController
            .getXVIStationPointNameCoordinateCache())
      record.name,
  ];

  test('undoing an added active scrap activates the first one and shows it', () async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      _baseText,
    );
    final int s1 = controller.activeScrapID;

    await apply(controller, '${_baseText}scrap s2\n  point 9 9 station\nendscrap\n');

    final int s2 = liveOwner(controller, 'scrap s2');

    expect(controller.hasMultipleScraps, isTrue);
    controller.setActiveScrap(s2);
    controller.hideElementController.toggleScrapVisibility(s1);
    expect(controller.hideElementController.isScrapVisible(s1), isFalse);

    controller.undo();

    expect(controller.activeScrapID, s1);
    expect(controller.hasMultipleScraps, isFalse);
    expect(controller.hideElementController.isScrapVisible(s1), isTrue);
    expect(
      controller.selectionController.getMPSelectableElements().keys,
      containsAll(<int>[liveOwner(controller, '  point 2 2 station -id p2')]),
    );
    expect(
      controller.snapController.snapPointTargets.map(
        (dynamic target) => target.coordinates,
      ),
      contains(const Offset(2, 2)),
    );

    controller.redo();

    expect(controller.activeScrapID, s1);
    expect(controller.hasMultipleScraps, isTrue);
    expect(controller.hideElementController.isScrapVisible(s1), isTrue);
  });

  test('the active scrap stays visible through apply, undo and redo', () async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      '${_baseText}scrap s2\n  point 9 9 station\nendscrap\n',
    );
    final int s1 = controller.activeScrapID;
    final int s2 = liveOwner(controller, 'scrap s2');

    controller.hideElementController.toggleScrapVisibility(s2);

    /// Removing s1 makes s2, hidden, the active scrap.
    await apply(controller, 'encoding utf-8\nscrap s2\n  point 9 9 station\nendscrap\n');
    expect(controller.activeScrapID, s2);
    expect(controller.hideElementController.isScrapVisible(s2), isTrue);

    controller.undo();
    expect(controller.activeScrapID, s2);
    expect(controller.hideElementController.isScrapVisible(s2), isTrue);
    expect(controller.hideElementController.isScrapVisible(s1), isTrue);

    controller.redo();
    expect(controller.activeScrapID, s2);
    expect(controller.hideElementController.isScrapVisible(s2), isTrue);
  });

  test('elements removed by undo leave no MPID in the selection or hidden sets', () async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      _baseText,
    );
    final String added = _baseText.replaceFirst(
      'endscrap\n',
      '  point 5 5 station -id pa\n'
          '  point 6 6 station -id pb\n'
          '  line wall -id l\n'
          '    7 7\n'
          '    8 8\n'
          '  endline\n'
          'endscrap\n',
    );

    await apply(controller, added);

    final Map<String, dynamic> appliedState =
        TH2TextApplyTestAux.loadStateSnapshot(controller);
    final THElement pa = controller.th2File.elementByTHID('pa');
    final THElement pb = controller.th2File.elementByTHID('pb');
    final THLine line = controller.th2File.elementByTHID('l') as THLine;
    final List<int> addedMPIDs = <int>[
      pa.mpID,
      pb.mpID,
      line.mpID,
      ...line.childrenMPIDs,
    ];

    controller.selectionController.addSelectedElement(pb);
    controller.hideElementController.performHideSelectedOrClearHidden();
    controller.selectionController.addSelectedElement(pa);
    expect(controller.hideElementController.hiddenElementMPIDs, <int>[pb.mpID]);

    controller.undo();

    expect(referencedMPIDs(controller).intersection(addedMPIDs.toSet()), isEmpty);
    expect(
      controller.stateController.state.type,
      MPTH2FileEditStateType.selectEmptySelection,
    );

    controller.redo();

    expect(
      controller.stateController.state.type,
      MPTH2FileEditStateType.selectEmptySelection,
    );
    expect(TH2TextApplyTestAux.loadStateSnapshot(controller), appliedState);

    final THLine redoneLine = controller.th2File.lineByMPID(line.mpID);
    final THLineSegment segment = controller.th2File.lineSegmentByMPID(
      redoneLine.childrenMPIDs.first,
    );

    controller.selectionController.addSelectedElement(redoneLine);
    controller.selectionController.addSelectedEndControlPoint(
      MPSelectableEndControlPoint(
        lineSegment: segment,
        th2fileEditController: controller,
        position: segment.endPoint.coordinates,
        type: MPEndControlPointType.endPointStraight,
      ),
    );

    controller.undo();

    expect(referencedMPIDs(controller).intersection(addedMPIDs.toSet()), isEmpty);
  });

  test('snap targets and station caches reflect the restored model', () async {
    final String th2Path = p.join(
      Directory.current.path,
      'test',
      'auxiliary',
      't3985_virtual.th2',
    );
    const String text =
        'encoding utf-8\n'
        '##XTHERION## xth_me_image_insert {0 1 1.0} {0 0} '
        '"./xvi/2025-07-09-002-xvi-xvistations.xvi" 0 {}\n'
        '$_scrapText';
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      text,
      filename: th2Path,
    );

    /// The caches only hold stations visible on screen.
    controller.updateScreenSize(const Size(2000, 2000));
    controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);

    expect(therionStations(controller), <String>['A0']);
    expect(xviStations(controller), contains('A1'));

    await apply(
      controller,
      'encoding utf-8\n'
      'scrap s1\n'
      '  point 2 2 station -id p2\n'
      'endscrap\n',
    );

    expect(therionStations(controller), isEmpty);
    expect(xviStations(controller), isEmpty);
    expect(
      controller.snapController.snapPointTargets.map(
        (dynamic target) => target.coordinates,
      ),
      isNot(contains(const Offset(1, 1))),
    );

    controller.undo();

    expect(therionStations(controller), <String>['A0']);
    expect(xviStations(controller), contains('A1'));
    expect(
      controller.snapController.snapPointTargets.map(
        (dynamic target) => target.coordinates,
      ),
      contains(const Offset(1, 1)),
    );

    controller.redo();

    expect(therionStations(controller), isEmpty);
    expect(xviStations(controller), isEmpty);
  });

  test('images keep their view state and parsed XVI files', () async {
    final String th2Path = p.join(
      Directory.current.path,
      'test',
      'auxiliary',
      't3985_virtual.th2',
    );
    const String hiddenImage =
        '##XTHERION## xth_me_image_insert {0 1 1.0} {0 0} '
        '"./xvi/2025-07-09-002-xvi-xvistations.xvi" 0 {}';
    const String hiddenGrid =
        '##XTHERION## xth_me_image_insert {10 1 1.0} {0 0} '
        '"./xvi/2025-07-09-001-xvi-xvigridsize.xvi" 0 {}';
    const String missing =
        '##XTHERION## xth_me_image_insert {20 1 1.0} {0 0} '
        '"./xvi/t3985_missing.xvi" 0 {}';
    const String edited =
        '##XTHERION## xth_me_image_insert {30 1 1.0} {0 0} '
        '"./xvi/2025-07-10-001-xvi-xvishots.xvi" 0 {}';
    const String text =
        'encoding utf-8\n'
        '$hiddenImage\n'
        '$hiddenGrid\n'
        '$missing\n'
        '$edited\n'
        '$_scrapText';
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      text,
      filename: th2Path,
    );
    final int hiddenImageMPID = liveOwner(controller, hiddenImage);
    final int hiddenGridMPID = liveOwner(controller, hiddenGrid);
    final int missingMPID = liveOwner(controller, missing);
    final int editedMPID = liveOwner(controller, edited);
    final XVIFile? hiddenImageXVI = controller.th2File
        .imageByMPID(hiddenImageMPID)
        .asXVIImage!
        .getXVIFile(controller);
    final XVIFile? hiddenGridXVI = controller.th2File
        .imageByMPID(hiddenGridMPID)
        .asXVIImage!
        .getXVIFile(controller);

    expect(hiddenImageXVI, isNotNull);
    expect(hiddenGridXVI, isNotNull);

    controller.selectionController.setImageVisibility(hiddenImageMPID, false);
    controller.selectionController.setImageGridVisibility(hiddenGridMPID, false);
    controller.th2File.imageByMPID(missingMPID).asXVIImage!
        .loadFailureDialogShown = true;

    final List<List<String>> usedTypes = <List<String>>[
      for (final dynamic types in <dynamic>[
        controller.elementEditController.mostUsedPointTypes,
        controller.elementEditController.mostUsedLineTypes,
        controller.elementEditController.mostUsedAreaTypes,
      ])
        <String>[for (final dynamic type in types) '${type.type}:${type.subtype}'],
    ];
    List<List<String>> currentUsedTypes() => <List<String>>[
      for (final dynamic types in <dynamic>[
        controller.elementEditController.mostUsedPointTypes,
        controller.elementEditController.mostUsedLineTypes,
        controller.elementEditController.mostUsedAreaTypes,
      ])
        <String>[for (final dynamic type in types) '${type.type}:${type.subtype}'],
    ];

    void expectImagesKept() {
      final MPRuntimeImageInsertConfigMixin image = controller.th2File
          .imageByMPID(hiddenImageMPID);
      final MPRuntimeImageInsertConfigMixin grid = controller.th2File
          .imageByMPID(hiddenGridMPID);

      expect(image.isVisible, isFalse);
      expect(identical(image.asXVIImage!.getXVIFile(controller), hiddenImageXVI), isTrue);
      expect(grid.asXVIImage!.isGridVisible, isFalse);
      expect(identical(grid.asXVIImage!.getXVIFile(controller), hiddenGridXVI), isTrue);
      expect(
        controller.th2File.imageByMPID(missingMPID).asXVIImage!
            .loadFailureDialogShown,
        isTrue,
      );
      expect(currentUsedTypes(), usedTypes);
    }

    final String appliedText = controller.serializeForTextMode().$1.replaceFirst(
      edited,
      edited.replaceFirst('{30 1 1.0}', '{40 1 1.0}'),
    ).replaceFirst('  point 2 2 station -id p2\n', '  point 3 3 station -id p2\n');

    await apply(controller, appliedText);
    expectImagesKept();
    expect(controller.th2File.hasElementByMPID(editedMPID), isFalse);

    controller.undo();
    expectImagesKept();
    expect(controller.th2File.hasElementByMPID(editedMPID), isTrue);

    controller.redo();
    expectImagesKept();
  });

  test('currentScrapName follows the active scrap', () async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      _baseText,
    );
    final int s1 = controller.activeScrapID;

    expect(controller.currentScrapName, 's1');

    await apply(controller, _baseText.replaceFirst('scrap s1\n', 'scrap s9\n'));

    expect(controller.activeScrapID, s1);
    expect(controller.currentScrapName, 's9');

    await apply(controller, 'encoding utf-8\n');

    expect(controller.activeScrapID, 0);
    expect(controller.currentScrapName, '');
  });
}
