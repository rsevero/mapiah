// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:material_ui/material_ui.dart';

import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

const String _text =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    '  line wall -id l1\n'
    '    0 0\n'
    '    10 0\n'
    '    10 10\n'
    '  endline\n'
    'endscrap\n'
    'scrap s2\n'
    '  point 5 5 station -id p3\n'
    '  point 1000 1000 station -id far\n'
    'endscrap\n';

int _lineOf(String text, String fragment) =>
    text.split('\n').indexWhere((String line) => line.contains(fragment));

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  setUp(TH2TextModeTestAux.setUp);

  Future<void> leaveAt(
    TH2FileEditController controller,
    TH2TextEditController session,
    int line,
  ) async {
    session.setCursorPosition(line: line, column: 0);
    await controller.leaveTextMode();
    expect(controller.editMode, TH2EditMode.canvas);
  }

  Set<int> selected(TH2FileEditController controller) =>
      controller.selectionController.mpSelectedElementsLogical.keys.toSet();

  test('an element line selects the element and activates its scrap', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final THElement p1 = controller.th2File.elementByTHID('p1');
    final THElement p3 = controller.th2File.elementByTHID('p3');

    controller.setActiveScrap(p1.parentMPID);

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    await leaveAt(controller, session, _lineOf(_text, '-id p3'));

    expect(controller.activeScrapID, p3.parentMPID);
    expect(selected(controller), <int>{p3.mpID});
    expect(
      controller.stateController.state.type,
      MPTH2FileEditStateType.selectNonEmptySelection,
    );
  });

  test('a scrap line activates the scrap with an empty selection', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final int s2 = controller.th2File.mpIDByTHID('s2')!;
    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    await leaveAt(controller, session, _lineOf(_text, 'scrap s2'));

    expect(controller.activeScrapID, s2);
    expect(selected(controller), isEmpty);
    expect(
      controller.stateController.state.type,
      MPTH2FileEditStateType.selectEmptySelection,
    );
  });

  test('a file-level line keeps the active scrap and clears the selection',
      () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final int s2 = controller.th2File.mpIDByTHID('s2')!;

    controller.setActiveScrap(s2);
    controller.selectionController.setSelectedElements(<THElement>[
      controller.th2File.elementByTHID('p3'),
    ], setState: true);

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    await leaveAt(controller, session, 0);

    expect(controller.activeScrapID, s2);
    expect(selected(controller), isEmpty);
  });

  test('a line point round-trips in Line edit mode, also from another scrap',
      () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final THLine line = controller.th2File.elementByTHID('l1') as THLine;

    controller.setActiveScrap(controller.th2File.mpIDByTHID('s2')!);

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    await leaveAt(controller, session, _lineOf(_text, '    10 0'));

    expect(controller.activeScrapID, line.parentMPID);
    expect(
      controller.stateController.state.type,
      MPTH2FileEditStateType.editSingleLine,
    );
    expect(selected(controller), <int>{line.mpID});

    final List<MPSelectedEndControlPoint> points = controller
        .selectionController
        .selectedEndControlPoints
        .values
        .toList();

    expect(points, hasLength(1));
    expect(
      points.single.originalLineSegmentClone.endPoint.coordinates,
      const Offset(10, 0),
    );

    /// Back to text from Line edit mode, then to another point of the line
    /// after an apply.
    final TH2TextEditController again = await TH2TextModeTestAux.enter(
      controller,
    );

    expect(again.cursorLine, _lineOf(_text, '    10 0'));

    final String edited = _text.replaceFirst('    10 10\n', '    10 11\n');

    TH2TextModeTestAux.edit(controller, edited);
    await leaveAt(controller, again, _lineOf(edited, '    10 11'));

    expect(
      controller.stateController.state.type,
      MPTH2FileEditStateType.editSingleLine,
    );

    final MPSelectedEndControlPoint point = controller
        .selectionController
        .selectedEndControlPoints
        .values
        .single;

    expect(
      point.originalLineSegmentClone.endPoint.coordinates,
      const Offset(10, 11),
    );
  });

  test('a cursor on the scrap line after Line edit mode leaves the state '
      'selectEmptySelection', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final THLine line = controller.th2File.elementByTHID('l1') as THLine;

    controller.setActiveScrap(line.parentMPID);
    controller.selectionController.setSelectedElements(<THElement>[
      line,
    ], setState: true);
    controller.stateController.setState(MPTH2FileEditStateType.editSingleLine);

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    await leaveAt(controller, session, _lineOf(_text, 'scrap s1'));

    expect(
      controller.stateController.state.type,
      MPTH2FileEditStateType.selectEmptySelection,
    );

    final TH2TextEditController again = await TH2TextModeTestAux.enter(
      controller,
    );

    await leaveAt(controller, again, 0);
    expect(
      controller.stateController.state.type,
      MPTH2FileEditStateType.selectEmptySelection,
    );
  });

  test('selecting inside a hidden scrap shows it', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final int s1 = controller.th2File.mpIDByTHID('s1')!;
    final int s2 = controller.th2File.mpIDByTHID('s2')!;

    controller.setActiveScrap(s1);
    controller.hideElementController.toggleScrapVisibility(s2);
    expect(controller.hideElementController.isScrapVisible(s2), isFalse);

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    await leaveAt(controller, session, _lineOf(_text, '-id p3'));

    expect(controller.activeScrapID, s2);
    expect(controller.hideElementController.isScrapVisible(s2), isTrue);
    expect(selected(controller), <int>{
      controller.th2File.mpIDByTHID('p3')!,
    });
  });

  test('deleting the active scrap in the text activates the first scrap',
      () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final int s1 = controller.th2File.mpIDByTHID('s1')!;

    controller.setActiveScrap(controller.th2File.mpIDByTHID('s2')!);

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );
    final int s2Start = _text.indexOf('scrap s2\n');

    TH2TextModeTestAux.edit(controller, _text.substring(0, s2Start));
    await leaveAt(controller, session, 0);

    expect(controller.th2File.scrapMPIDs, <int>[s1]);
    expect(controller.activeScrapID, s1);
  });

  test('revealSelection moves the center only when the selection is outside '
      'the view, keeping the scale', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );

    controller.updateScreenSize(const Size(100, 100));
    controller.setCanvasScale(1.0);

    final THElement p3 = controller.th2File.elementByTHID('p3');
    final THElement far = controller.th2File.elementByTHID('far');

    controller.setActiveScrap(p3.parentMPID);
    controller.selectionController.setSelectedElements(<THElement>[
      p3,
    ], setState: true);

    final double centerX = controller.canvasCenterX;
    final double centerY = controller.canvasCenterY;

    controller.revealSelection();
    expect(controller.canvasCenterX, centerX);
    expect(controller.canvasCenterY, centerY);

    controller.selectionController.setSelectedElements(<THElement>[
      far,
    ], setState: true);
    controller.revealSelection();

    expect(controller.canvasScale, 1.0);
    expect(controller.canvasCenterX, closeTo(1000, 1));
    expect(controller.canvasCenterY, closeTo(1000, 1));
  });
}
