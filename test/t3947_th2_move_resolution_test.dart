// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_hierarchy_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';

import 'th_test_aux.dart';

const String _fixture = 'encoding utf-8\n'
    'scrap s1\n'
    '  point 0 0 station -id a\n'
    '  point 1 1 station -id b\n'
    '  point 2 2 station -id c\n'
    '  # between c and d\n'
    '  point 3 3 station -id d\n'
    '  point 4 4 station -id e\n'
    'endscrap\n'
    'scrap s2\n'
    'endscrap\n';

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }
  final MPLocator locator = MPLocator();
  late TH2FileEditController controller;
  int id(String name) => controller.th2File.mpIDByTHID(name)!;
  List<String> order() {
    final THScrap scrap = controller.th2File.scrapByMPID(id('s1'));
    return scrap.childrenMPIDs.where((int mpID) =>
      controller.th2File.elementByMPID(mpID) is THPoint).map((int mpID) =>
      controller.th2File.thidByMPID(mpID)).toList();
  }
  setUp(() async {
    locator.appLocalizations = AppLocalizationsEn();
    locator.mpGeneralController.reset();
    controller = locator.mpGeneralController.getTH2FileEditController(
      filename: '/tmp/mapiah-t3947.th2',
      fileBytes: Uint8List.fromList(utf8.encode(_fixture)));
    await controller.load();
  });

  test('non-adjacent runs step independently and one undo restores order', () {
    final TH2FileEditElementEditController edit =
        controller.elementEditController;
    final List<int> selection = <int>[id('d'), id('b')];
    final MPMoveElementsPreview preview = edit.previewDrawingOrderAction(
      MPDrawingOrderAction.bringForward, elementMPIDs: selection);
    expect(preview.rejection, isNull);
    expect(preview.noOp, isFalse);
    expect(order(), <String>['a', 'b', 'c', 'd', 'e']);
    expect(edit.bringForward(elementMPIDs: selection).executed, isTrue);
    expect(order(), <String>['a', 'c', 'b', 'e', 'd']);
    controller.undo();
    expect(order(), <String>['a', 'b', 'c', 'd', 'e']);
  });

  test('last selected run stays and remains an anchor', () {
    final TH2FileEditElementEditController edit =
        controller.elementEditController;
    expect(edit.bringForward(elementMPIDs: <int>[id('b'), id('e')]).executed,
      isTrue);
    expect(order(), <String>['a', 'c', 'b', 'd', 'e']);
  });

  test('backward runs keep their gap', () {
    expect(controller.elementEditController.sendBackward(
      elementMPIDs: <int>[id('b'), id('d')]).executed, isTrue);
    expect(order(), <String>['b', 'a', 'd', 'c', 'e']);
  });

  test('mixed kinds and malformed groups are rejected before commands', () {
    final int scrap = id('s1');
    final int point = id('a');
    expect(TH2HierarchyAux.validateMove(controller.th2File,
      elementMPIDs: <int>[scrap, point], newParentMPID: scrap).rejection,
      MPHierarchyMoveRejection.mixedScrapsAndDrawables);
    expect(controller.elementEditController.previewDrawingOrderAction(
      MPDrawingOrderAction.bringToFront,
      elementMPIDs: <int>[scrap, point]).rejection,
      MPHierarchyMoveRejection.mixedScrapsAndDrawables);
    expect(() => MPMoveGroup(elementMPIDs: <int>[point],
      placement: MPMoveGroupPlacement.beforeSibling), throwsAssertionError);
    final List<MPMoveGroup> groups = <MPMoveGroup>[
      MPMoveGroup(elementMPIDs: <int>[point, point],
        placement: MPMoveGroupPlacement.end),
    ];
    expect(TH2HierarchyAux.validateMoveGroups(controller.th2File,
      parentMPID: scrap, groups: groups).rejection,
      MPHierarchyMoveRejection.duplicateElement);
    expect(MPCommandFactory.moveElementGroups(th2File: controller.th2File,
      parentMPID: scrap, groups: groups), isNull);
  });

  test('after anchor leaves the hidden comment in place', () {
    final THScrap scrap = controller.th2File.scrapByMPID(id('s1'));
    final int comment = scrap.childrenMPIDs.firstWhere((int mpID) =>
      controller.th2File.elementByMPID(mpID) is THComment);
    final List<MPMoveGroup> groups = <MPMoveGroup>[
      MPMoveGroup(elementMPIDs: <int>[id('b')],
        placement: MPMoveGroupPlacement.afterSibling,
        siblingMPID: id('c')),
    ];
    final command = MPCommandFactory.moveElementGroups(
      th2File: controller.th2File, parentMPID: scrap.mpID, groups: groups);
    expect(command, isNotNull);
    controller.execute(command!);
    expect(order(), <String>['a', 'c', 'b', 'd', 'e']);
    expect(scrap.childrenMPIDs.indexOf(comment),
      lessThan(scrap.childrenMPIDs.indexOf(id('b'))));
  });
}
