// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:path/path.dart' as p;

import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

const String _text =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    '  point 2 2 station -id p2\n'
    '  line wall -id l1\n'
    '    0 0\n'
    '    10 0\n'
    '    10 10\n'
    '  endline\n'
    'endscrap\n'
    'scrap s2\n'
    '  point 5 5 station -id p3\n'
    'endscrap\n';

int _lineOf(String text, String fragment) {
  final List<String> lines = text.split('\n');

  return lines.indexWhere((String line) => line.contains(fragment));
}

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();

  setUp(TH2TextModeTestAux.setUp);

  test('the cursor goes to the selected element nearest the top', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final THElement p1 = controller.th2File.elementByTHID('p1');
    final THElement p2 = controller.th2File.elementByTHID('p2');

    controller.setActiveScrap(p1.parentMPID);
    controller.selectionController.setSelectedElements(<THElement>[
      p2,
      p1,
    ], setState: true);

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    expect(session.content, _text);
    expect(session.cursorLine, _lineOf(_text, '-id p1'));
    expect(session.cursorColumn, 2);
    expect(session.pendingSelectionRange, isNotNull);
    expect(
      _text.substring(session.pendingSelectionRange!.start).startsWith(
        'point 1 1',
      ),
      isTrue,
    );
    expect(controller.undoRedoController.undoCount, 0);
  });

  test('in Line edit mode the cursor goes to the selected line point', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final THLine line = controller.th2File.elementByTHID('l1') as THLine;

    controller.setActiveScrap(line.parentMPID);
    controller.selectionController.setSelectedElements(<THElement>[
      line,
    ], setState: true);
    controller.stateController.setState(MPTH2FileEditStateType.editSingleLine);

    final MPSelectableEndControlPoint endPoint = controller.selectionController
        .getMPSelectableEndControlPoints()
        .firstWhere(
          (MPSelectableEndControlPoint point) =>
              (point.type == MPEndControlPointType.endPointStraight) &&
              (point.position == const Offset(10, 0)),
        );

    controller.selectionController.setSelectedEndControlPoint(endPoint);

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    expect(session.cursorLine, _lineOf(_text, '    10 0'));
    expect(session.cursorColumn, 4);
  });

  test('with no selection the cursor starts at the top', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    expect(session.cursorLine, 0);
    expect(session.pendingSelectionRange, isNull);
  });

  test('a lone carriage return keeps the canvas and changes nothing', () async {
    final List<String> messages = TH2TextModeTestAux.captureUserMessages();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      '$_text# a comment\n',
    );
    final THComment comment = controller.th2File.elements.values
        .whereType<THComment>()
        .single;

    controller.th2File.substituteElement(
      comment.copyWith(originalLineInTH2File: '# a\rcomment\n'),
    );

    final THElement p1 = controller.th2File.elementByTHID('p1');

    controller.setActiveScrap(p1.parentMPID);
    controller.selectionController.setSelectedElements(<THElement>[
      p1,
    ], setState: true);

    final Map<String, dynamic> modelBefore = controller.th2File.toMap();
    final String fileBefore = TH2TextModeTestAux.readFile(controller);
    final MPTH2FileEditStateType stateBefore =
        controller.stateController.state.type;

    await controller.enterTextMode();

    expect(controller.editMode, TH2EditMode.canvas);
    expect(controller.textEditController, isNull);
    expect(messages, <String>[
      locator.appLocalizations.th2TextUnsupportedLineEndingMessage,
    ]);
    expect(controller.stateController.state.type, stateBefore);
    expect(
      controller.selectionController.mpSelectedElementsLogical.keys,
      <int>[p1.mpID],
    );
    expect(controller.th2File.toMap(), modelBefore);
    expect(TH2TextModeTestAux.readFile(controller), fileBefore);
  });

  test('entry needs a loaded file with an open tab', () async {
    final Directory directory = TH2TextModeTestAux.tempDirectory();
    final String path = p.join(directory.path, 'unloaded.th2');

    File(path).writeAsStringSync(_text);

    final TH2FileEditController unloaded = locator.mpGeneralController
        .getTH2FileEditController(filename: path);

    locator.mpGeneralController.addFileTab(path);
    await unloaded.enterTextMode();
    expect(unloaded.editMode, TH2EditMode.canvas);

    final TH2FileEditController tabless = await TH2TextModeTestAux.open(
      _text,
      name: 'tabless.th2',
      openTab: false,
    );

    await tabless.enterTextMode();
    expect(tabless.editMode, TH2EditMode.canvas);
  });

  test('entry while another operation runs, such as the image picker, is '
      'dropped', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final Completer<void> picker = Completer<void>();
    final Future<void> pending = controller.runGatedOperation<void>(
      () => picker.future,
    );

    expect(controller.isOperationBusy, isTrue);
    await controller.enterTextMode();
    expect(controller.editMode, TH2EditMode.canvas);

    picker.complete();
    await pending;
    expect(controller.isOperationBusy, isFalse);
    await TH2TextModeTestAux.enter(controller);
  });

  test('entry closes the overlay windows and leaves the add states', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );

    controller.setActiveScrap(
      controller.th2File.elementByTHID('p1').parentMPID,
    );
    controller.stateController.setState(MPTH2FileEditStateType.addPoint);
    await TH2TextModeTestAux.enter(controller);

    expect(
      controller.stateController.state.type,
      isNot(MPTH2FileEditStateType.addPoint),
    );
    expect(
      controller.overlayWindowController.activeWindow,
      MPWindowType.mainTH2FileEditWindow,
    );
  });
}
