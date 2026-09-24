// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th2_hierarchy_aux.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:material_ui/material_ui.dart';

import 'th_test_aux.dart';

const String _fixture =
    'encoding utf-8\n'
    'scrap s1 -projection plan\n'
    '  point 1 1 station -id p1 -name 1\n'
    '  # hidden comment\n'
    '  line wall -id l1\n'
    '    10 20\n'
    '    30 40\n'
    '    50 60\n'
    '  endline\n'
    '  line border -id b1 -close on\n'
    '    0 0\n'
    '    10 0\n'
    '    10 10\n'
    '    0 0\n'
    '  endline\n'
    '  area water -id a1\n'
    '    b1\n'
    '  endarea\n'
    '  point 7 7 station -id p3 -name 3\n'
    'endscrap\n'
    '# between scraps\n'
    'scrap s2 -projection plan\n'
    '  point 5 5 station -id p2 -name 2\n'
    'endscrap\n'
    '# trailing comment\n';

const String _sharedBorderFixture =
    'encoding utf-8\n'
    'scrap s1\n'
    '  line border -id b1 -close on\n'
    '    0 0\n'
    '    10 0\n'
    '    10 10\n'
    '    0 0\n'
    '  endline\n'
    '  area water -id a1\n'
    '    b1\n'
    '  endarea\n'
    '  area sand -id a2\n'
    '    b1\n'
    '  endarea\n'
    'endscrap\n'
    'scrap s2\n'
    'endscrap\n';

const String _singleScrapFixture =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    'endscrap\n'
    '# trailing comment\n';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  late TH2FileEditController controller;

  TH2File th2File() => controller.th2File;

  TH2FileEditElementEditController edit() => controller.elementEditController;

  int id(String thID) => th2File().mpIDByTHID(thID)!;

  THScrap scrap(String thID) => th2File().elementByMPID(id(thID)) as THScrap;

  int endscrapOf(String scrapTHID) => scrap(scrapTHID).childrenMPIDs
      .firstWhere(
        (int childMPID) =>
            th2File().elementByMPID(childMPID).elementType ==
            THElementType.endscrap,
      );

  /// Describes a child list with thIDs or element type names.
  List<String> describe(List<int> childrenMPIDs) {
    return childrenMPIDs.map((int childMPID) {
      final THElement element = th2File().elementByMPID(childMPID);

      if (element is THScrap) {
        return element.thID;
      }

      if ((element is THPoint) || (element is THLine) || (element is THArea)) {
        return th2File().hasTHIDByElement(element)
            ? th2File().thidByMPID(childMPID)
            : element.elementType.name;
      }

      return element.elementType.name;
    }).toList();
  }

  List<String> childrenOf(String scrapTHID) =>
      describe(scrap(scrapTHID).childrenMPIDs);

  List<String> fileChildren() => describe(th2File().childrenMPIDs);

  Future<void> load(String contents) async {
    mpLocator.mpGeneralController.reset();
    controller = mpLocator.mpGeneralController.getTH2FileEditController(
      filename: '/tmp/mapiah-t2462.th2',
      fileBytes: Uint8List.fromList(utf8.encode(contents)),
    );
    await controller.load();
    expect(controller.isBroken, isFalse);
  }

  String written() => TH2FileWriter().serialize(
    th2File(),
    includeEmptyLines: true,
    useOriginalRepresentation: true,
  );

  /// Snapshot of every parent list and parent id, for undo/redo checks.
  Map<String, Object> structureSnapshot() {
    final Map<String, Object> snapshot = <String, Object>{
      'file': List<int>.of(th2File().childrenMPIDs),
    };

    for (final THScrap currentScrap in th2File().getScraps()) {
      snapshot[currentScrap.thID] = List<int>.of(currentScrap.childrenMPIDs);
    }

    for (final String thID in <String>['p1', 'l1', 'b1', 'a1', 'p3', 'p2']) {
      final int? mpID = th2File().mpIDByTHID(thID);

      if (mpID != null) {
        snapshot['parent:$thID'] = th2File().elementByMPID(mpID).parentMPID;
      }
    }

    return snapshot;
  }

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    await load(_fixture);
  });

  group('reorder within a scrap', () {
    test('a point moves before an area, hidden children keep their slot', () {
      final MPMoveElementsResult result = edit().moveElements(
        elementMPIDs: <int>[id('p1')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: id('a1'),
      );

      expect(result.executed, isTrue);
      expect(childrenOf('s1'), <String>[
        'comment',
        'l1',
        'b1',
        'p1',
        'a1',
        'p3',
        'endscrap',
      ]);
    });

    test('a line and an area reorder as whole blocks', () {
      edit().moveElements(
        elementMPIDs: <int>[id('a1')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: id('l1'),
      );

      expect(childrenOf('s1'), <String>[
        'p1',
        'comment',
        'a1',
        'l1',
        'b1',
        'p3',
        'endscrap',
      ]);
      expect(scrap('s1').childrenMPIDs, contains(id('b1')));
    });

    test('several adjacent siblings move as one command', () {
      final int undoCount = controller.undoRedoController.undoCount;

      edit().moveElements(
        elementMPIDs: <int>[id('l1'), id('b1')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: id('p1'),
      );

      expect(childrenOf('s1'), <String>[
        'l1',
        'b1',
        'p1',
        'comment',
        'a1',
        'p3',
        'endscrap',
      ]);
      expect(controller.undoRedoController.undoCount, undoCount + 1);
    });

    test('an explicit border line in a same-scrap move is ordinary', () {
      edit().moveElements(
        elementMPIDs: <int>[id('b1'), id('a1')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: id('p1'),
      );

      expect(childrenOf('s1'), <String>[
        'b1',
        'a1',
        'p1',
        'comment',
        'l1',
        'p3',
        'endscrap',
      ]);
    });

    test('move to end of scrap through its endscrap', () {
      edit().moveElements(
        elementMPIDs: <int>[id('p1')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: endscrapOf('s1'),
      );

      expect(childrenOf('s1').sublist(childrenOf('s1').length - 2), <String>[
        'p1',
        'endscrap',
      ]);
    });
  });

  group('moves between scraps', () {
    for (final String thID in <String>['p1', 'l1']) {
      test('$thID moves to another scrap', () {
        final int beforeMPID = id(thID);

        edit().moveElements(
          elementMPIDs: <int>[id(thID)],
          newParentMPID: id('s2'),
          beforeSiblingMPID: id('p2'),
        );

        expect(childrenOf('s2'), <String>[thID, 'p2', 'endscrap']);
        expect(childrenOf('s1'), isNot(contains(thID)));
        expect(id(thID), beforeMPID);
        expect(th2File().elementByMPID(id(thID)).parentMPID, id('s2'));
      });
    }

    test('an area carries its border lines, keeping their order', () {
      edit().moveElements(
        elementMPIDs: <int>[id('a1')],
        newParentMPID: id('s2'),
        beforeSiblingMPID: endscrapOf('s2'),
      );

      expect(childrenOf('s2'), <String>['p2', 'b1', 'a1', 'endscrap']);
      expect(childrenOf('s1'), isNot(contains('b1')));
      expect(th2File().elementByMPID(id('b1')).parentMPID, id('s2'));
    });

    test('an area with its explicit border line equals the area alone', () {
      final MPMoveElementsCommand? alone = MPCommandFactory.moveElements(
        th2File: th2File(),
        elementMPIDs: <int>[id('a1')],
        newParentMPID: id('s2'),
      );
      final MPMoveElementsCommand? withLine = MPCommandFactory.moveElements(
        th2File: th2File(),
        elementMPIDs: <int>[id('b1'), id('a1')],
        newParentMPID: id('s2'),
      );

      expect(alone, isNotNull);
      expect(withLine!.moves, alone!.moves);
    });

    test('elements from several scraps keep file order', () {
      edit().moveElements(
        elementMPIDs: <int>[id('p2'), id('p1')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: endscrapOf('s1'),
      );

      final List<String> s1 = childrenOf('s1');

      expect(s1.sublist(s1.length - 3), <String>['p1', 'p2', 'endscrap']);
    });

    test('snap targets follow the new scrap membership', () {
      controller.setActiveScrap(id('s1'));
      controller.snapController.updateSnapTargets();

      final int before = controller.snapController.snapPointTargets.length;

      expect(before, greaterThan(0));

      edit().moveElements(
        elementMPIDs: <int>[id('p2')],
        newParentMPID: id('s1'),
      );

      expect(
        controller.snapController.snapPointTargets.length,
        greaterThan(before),
      );

      edit().moveElements(
        elementMPIDs: <int>[id('p1'), id('p2')],
        newParentMPID: id('s2'),
      );

      expect(controller.snapController.snapPointTargets.length, lessThan(before));
    });

    test('scrap type caches reflect moves, undo and redo', () {
      expect(scrap('s1').getPointsMPIDs(th2File()), contains(id('p1')));
      expect(scrap('s2').getPointsMPIDs(th2File()), isNot(contains(id('p1'))));
      expect(scrap('s1').getLinesMPIDs(th2File()), <int>[id('l1'), id('b1')]);

      edit().moveElements(
        elementMPIDs: <int>[id('p1'), id('a1')],
        newParentMPID: id('s2'),
      );

      expect(scrap('s1').getPointsMPIDs(th2File()), isNot(contains(id('p1'))));
      expect(scrap('s2').getPointsMPIDs(th2File()), contains(id('p1')));
      expect(scrap('s2').getAreasMPIDs(th2File()), <int>[id('a1')]);
      expect(scrap('s1').getLinesMPIDs(th2File()), <int>[id('l1')]);

      controller.undo();

      expect(scrap('s1').getPointsMPIDs(th2File()), contains(id('p1')));
      expect(scrap('s1').getLinesMPIDs(th2File()), <int>[id('l1'), id('b1')]);
      expect(scrap('s2').getAreasMPIDs(th2File()), isEmpty);

      edit().moveElements(
        elementMPIDs: <int>[id('b1')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: id('l1'),
      );

      expect(scrap('s1').getLinesMPIDs(th2File()), <int>[id('b1'), id('l1')]);

      controller.undo();

      expect(scrap('s1').getLinesMPIDs(th2File()), <int>[id('l1'), id('b1')]);

      controller.redo();

      expect(scrap('s1').getLinesMPIDs(th2File()), <int>[id('b1'), id('l1')]);
    });

    test('station names follow a move to a hidden scrap', () {
      controller.updateScreenSize(const Size(1000, 1000));
      controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);

      List<int> stationRecordMPIDs() => controller.userInteractionController
          .getTherionStationPointNameCoordinateCache()
          .map((record) => record.elementMPID!)
          .toList();

      controller.hideElementController.toggleScrapVisibility(id('s2'));

      expect(stationRecordMPIDs(), contains(id('p1')));
      expect(stationRecordMPIDs(), isNot(contains(id('p2'))));

      edit().moveElements(
        elementMPIDs: <int>[id('p1')],
        newParentMPID: id('s2'),
      );

      expect(stationRecordMPIDs(), isNot(contains(id('p1'))));

      edit().moveElements(
        elementMPIDs: <int>[id('p2')],
        newParentMPID: id('s1'),
      );

      expect(stationRecordMPIDs(), contains(id('p2')));
    });
  });

  group('scraps at file level', () {
    test('a scrap moves before another scrap', () {
      edit().moveElements(
        elementMPIDs: <int>[id('s2')],
        newParentMPID: th2File().mpID,
        beforeSiblingMPID: id('s1'),
      );

      expect(fileChildren(), <String>[
        'encoding',
        's2',
        's1',
        'comment',
        'comment',
      ]);
    });

    test('a scrap moves to the end of the file', () {
      edit().moveElements(
        elementMPIDs: <int>[id('s1')],
        newParentMPID: th2File().mpID,
      );

      expect(fileChildren(), <String>[
        'encoding',
        'comment',
        's2',
        's1',
        'comment',
      ]);
    });

    test('the only scrap moving to the end of the file is a no-op', () async {
      await load(_singleScrapFixture);

      final MPMoveElementsResult result = edit().moveElements(
        elementMPIDs: <int>[id('s1')],
        newParentMPID: th2File().mpID,
      );

      expect(result.noOp, isTrue);
    });
  });

  group('shared border lines', () {
    setUp(() async {
      await load(_sharedBorderFixture);
    });

    test('an area alone is rejected, both areas move together', () {
      final MPMoveElementsResult rejected = edit().moveElements(
        elementMPIDs: <int>[id('a1')],
        newParentMPID: id('s2'),
      );

      expect(rejected.executed, isFalse);
      expect(rejected.rejection, MPHierarchyMoveRejection.areaBorderShared);

      final MPMoveElementsResult accepted = edit().moveElements(
        elementMPIDs: <int>[id('a1'), id('a2')],
        newParentMPID: id('s2'),
      );

      expect(accepted.executed, isTrue);
      expect(childrenOf('s2'), <String>['b1', 'a1', 'a2', 'endscrap']);
    });

    test('a selected shared line is emitted once, before the first area', () {
      final MPMoveElementsCommand? command = MPCommandFactory.moveElements(
        th2File: th2File(),
        elementMPIDs: <int>[id('a2'), id('b1'), id('a1')],
        newParentMPID: id('s2'),
      );

      expect(
        command!.moves.map((MPElementMove move) => move.elementMPID).toList(),
        <int>[id('b1'), id('a1'), id('a2')],
      );
    });
  });

  group('bring forward, send backward, front and back', () {
    test('bring forward steps over a whole line block', () {
      edit().bringForward(elementMPIDs: <int>[id('p1')]);

      expect(childrenOf('s1'), <String>[
        'comment',
        'l1',
        'p1',
        'b1',
        'a1',
        'p3',
        'endscrap',
      ]);

      final String text = written();

      expect(
        text.indexOf('point 1 1 station'),
        greaterThan(text.indexOf('    50 60\n  endline')),
      );
    });

    test('send backward steps over a whole area block', () {
      edit().sendBackward(elementMPIDs: <int>[id('p3')]);

      final String text = written();

      expect(
        text.indexOf('point 7 7 station'),
        lessThan(text.indexOf('area water')),
      );
      expect(childrenOf('s1').indexOf('p3'), childrenOf('s1').indexOf('a1') - 1);
    });

    test('send backward steps over a hidden comment', () {
      edit().sendBackward(elementMPIDs: <int>[id('l1')]);

      expect(childrenOf('s1').take(3).toList(), <String>['l1', 'p1', 'comment']);
    });

    test('bring forward of the next-to-last element moves it last', () {
      final MPMoveElementsResult result = edit().bringForward(
        elementMPIDs: <int>[id('a1')],
      );

      expect(result.executed, isTrue);
      expect(childrenOf('s1').sublist(4), <String>['p3', 'a1', 'endscrap']);
    });

    test('bring to front moves to the end, send to back to the start', () {
      edit().bringToFront(elementMPIDs: <int>[id('p1')]);

      expect(childrenOf('s1').sublist(5), <String>['p1', 'endscrap']);

      edit().sendToBack(elementMPIDs: <int>[id('p3')]);

      expect(childrenOf('s1').take(2).toList(), <String>['comment', 'p3']);
    });

    test('boundaries are no-ops', () {
      expect(edit().sendBackward(elementMPIDs: <int>[id('p1')]).noOp, isTrue);
      expect(edit().sendToBack(elementMPIDs: <int>[id('p1')]).noOp, isTrue);
      expect(edit().bringForward(elementMPIDs: <int>[id('p3')]).noOp, isTrue);
      expect(edit().bringToFront(elementMPIDs: <int>[id('p3')]).noOp, isTrue);
    });
  });

  group('invalid and no-op requests', () {
    test('an invalid request is rejected without executing', () {
      final int undoCount = controller.undoRedoController.undoCount;
      final MPMoveElementsResult result = edit().moveElements(
        elementMPIDs: <int>[id('p1')],
        newParentMPID: th2File().mpID,
      );

      expect(result.executed, isFalse);
      expect(result.noOp, isFalse);
      expect(result.rejection, MPHierarchyMoveRejection.drawableParentMustBeScrap);
      expect(controller.undoRedoController.undoCount, undoCount);
    });

    test('a no-op is reported without executing', () {
      final int undoCount = controller.undoRedoController.undoCount;
      final MPMoveElementsResult result = edit().moveElements(
        elementMPIDs: <int>[id('p1')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: id('l1'),
      );

      expect(result.noOp, isTrue);
      expect(controller.undoRedoController.undoCount, undoCount);
    });
  });

  group('undo and redo', () {
    test('restore structure, parents and thIDs exactly', () {
      final Map<String, Object> original = structureSnapshot();

      edit().moveElements(
        elementMPIDs: <int>[id('p1'), id('l1'), id('a1')],
        newParentMPID: id('s2'),
        beforeSiblingMPID: id('p2'),
      );

      final Map<String, Object> moved = structureSnapshot();

      expect(moved, isNot(original));

      controller.undo();

      expect(structureSnapshot(), original);
      expect(th2File().elementByTHID('l1'), isA<THLine>());
      expect(
        (th2File().elementByMPID(id('l1')) as THLine).childrenMPIDs.length,
        4,
      );

      controller.redo();

      expect(structureSnapshot(), moved);

      controller.undo();

      expect(structureSnapshot(), original);
    });

    test('adjacent siblings entering one parent undo exactly', () {
      final Map<String, Object> original = structureSnapshot();

      edit().moveElements(
        elementMPIDs: <int>[id('p1'), id('l1')],
        newParentMPID: id('s2'),
        beforeSiblingMPID: id('p2'),
      );

      expect(childrenOf('s2'), <String>['p1', 'l1', 'p2', 'endscrap']);

      controller.undo();

      expect(structureSnapshot(), original);
    });
  });

  group('selection', () {
    test('a selected element stays consistent after a reorder', () {
      controller.setActiveScrap(id('s1'));
      controller.selectionController.setSelectedElements(<THElement>[
        th2File().elementByMPID(id('l1')),
      ]);

      edit().moveElements(
        elementMPIDs: <int>[id('l1')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: id('p1'),
      );

      expect(
        controller.selectionController.mpSelectedElementsLogical.keys,
        <int>[id('l1')],
      );
    });

    test('a selected element leaving the active scrap is deselected', () {
      controller.setActiveScrap(id('s1'));
      controller.selectionController.setSelectedElements(<THElement>[
        th2File().elementByMPID(id('p1')),
        th2File().elementByMPID(id('p3')),
      ]);

      edit().moveElements(
        elementMPIDs: <int>[id('p1')],
        newParentMPID: id('s2'),
      );

      expect(
        controller.selectionController.mpSelectedElementsLogical.keys,
        <int>[id('p3')],
      );
    });
  });

  group('serialization and writing', () {
    test('toMap/fromMap and JSON round trips', () {
      final MPMoveElementsCommand command = MPCommandFactory.moveElements(
        th2File: th2File(),
        elementMPIDs: <int>[id('a1')],
        newParentMPID: id('s2'),
      )!;
      final MPMoveElementsCommand fromMap = MPMoveElementsCommand.fromMap(
        command.toMap(),
      );
      final MPMoveElementsCommand fromJson = MPMoveElementsCommand.fromJson(
        jsonEncode(command.toMap()),
      );

      expect(fromMap, command);
      expect(fromJson, command);
      expect(MPCommand.fromMap(command.toMap()), command);
    });

    test('the written file differs only in block order', () {
      final String before = written();

      edit().moveElements(
        elementMPIDs: <int>[id('p3')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: id('l1'),
      );

      final String after = written();
      final List<String> beforeLines = before.split('\n')..sort();
      final List<String> afterLines = after.split('\n')..sort();

      expect(after, isNot(before));
      expect(afterLines, beforeLines);
      expect(
        after.indexOf('  point 7 7 station -id p3 -name 3'),
        lessThan(after.indexOf('  line wall -id l1')),
      );
    });
  });
}
