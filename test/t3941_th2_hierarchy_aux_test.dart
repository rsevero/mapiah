// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_hierarchy_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';

import 'th_test_aux.dart';

const String _fixture =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    '  # hidden comment\n'
    '  line wall -id l1\n'
    '    10 20\n'
    '    30 40\n'
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
    '  area sand -id a2\n'
    '    b1\n'
    '  endarea\n'
    '  line border -id x1 -close on\n'
    '    20 20\n'
    '    30 20\n'
    '    30 30\n'
    '    20 20\n'
    '  endline\n'
    'endscrap\n'
    'scrap s2\n'
    '  point 5 5 station -id p2\n'
    '  area clay -id a4\n'
    '    x1\n'
    '  endarea\n'
    'endscrap\n'
    'scrap s3\n'
    'endscrap\n';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  late TH2File th2File;

  int id(String thID) => th2File.mpIDByTHID(thID)!;

  int endscrapOf(String scrapTHID) {
    final THScrap scrap = th2File.elementByMPID(id(scrapTHID)) as THScrap;

    return scrap.childrenMPIDs.firstWhere(
      (int childMPID) =>
          th2File.elementByMPID(childMPID).elementType ==
          THElementType.endscrap,
    );
  }

  int commentOf(String scrapTHID) {
    final THScrap scrap = th2File.elementByMPID(id(scrapTHID)) as THScrap;

    return scrap.childrenMPIDs.firstWhere(
      (int childMPID) => th2File.elementByMPID(childMPID) is THComment,
    );
  }

  MPHierarchyMoveCheck check(
    List<int> elementMPIDs,
    int newParentMPID, {
    int? beforeSiblingMPID,
  }) {
    return TH2HierarchyAux.validateMove(
      th2File,
      elementMPIDs: elementMPIDs,
      newParentMPID: newParentMPID,
      beforeSiblingMPID: beforeSiblingMPID,
    );
  }

  void expectRejected(MPHierarchyMoveCheck result, String reasonKey) {
    expect(result.ok, isFalse);
    expect(result.reasonKey, reasonKey);
  }

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();

    final TH2FileEditController controller = mpLocator.mpGeneralController
        .getTH2FileEditController(
          filename: '/tmp/mapiah-t3941.th2',
          fileBytes: Uint8List.fromList(utf8.encode(_fixture)),
        );

    await controller.load();
    expect(controller.isBroken, isFalse);
    th2File = controller.th2File;
  });

  group('parent types', () {
    test('a scrap can only have the file as parent', () {
      expect(check(<int>[id('s1')], th2File.mpID).ok, isTrue);
      expectRejected(
        check(<int>[id('s1')], id('s2')),
        'scrap_parent_must_be_file',
      );
      expectRejected(check(<int>[id('s1')], id('l1')), 'invalid_target_parent');
      expectRejected(check(<int>[id('s1')], id('a1')), 'invalid_target_parent');
    });

    for (final String thID in <String>['p1', 'l1', 'a1']) {
      test('$thID can only have a scrap as parent', () {
        final List<int> validSelection = (thID == 'a1')
            ? <int>[id('a1'), id('a2')]
            : <int>[id(thID)];

        expect(check(validSelection, id('s3')).ok, isTrue);
        expectRejected(
          check(<int>[id(thID)], th2File.mpID),
          'drawable_parent_must_be_scrap',
        );
        expectRejected(
          check(<int>[id(thID)], id('l1')),
          'invalid_target_parent',
        );
        expectRejected(
          check(<int>[id(thID)], id('a2')),
          'invalid_target_parent',
        );
      });
    }

    test('an element cannot be moved into itself', () {
      expectRejected(check(<int>[id('l1')], id('l1')), 'invalid_target_parent');
      expectRejected(check(<int>[id('a1')], id('a1')), 'invalid_target_parent');
    });

    test('only supported element kinds can move', () {
      final THLine line = th2File.elementByMPID(id('l1')) as THLine;
      final int segmentMPID = line.childrenMPIDs.first;

      expectRejected(
        check(<int>[segmentMPID], id('s3')),
        'unsupported_element',
      );
      expectRejected(check(<int>[commentOf('s1')], id('s3')), 'unsupported_element');
      expectRejected(check(<int>[987654321], id('s3')), 'unknown_element');
      expectRejected(check(<int>[], id('s3')), 'empty_selection');
    });
  });

  group('before sibling', () {
    test('must belong to the requested parent', () {
      expectRejected(
        check(<int>[id('p1')], id('s1'), beforeSiblingMPID: id('p2')),
        'target_not_child',
      );
    });

    test('must not be one of the moving elements', () {
      expectRejected(
        check(<int>[id('p1'), id('l1')], id('s1'), beforeSiblingMPID: id('l1')),
        'target_is_moving',
      );
    });

    test('must not be a hidden child', () {
      expectRejected(
        check(<int>[id('p1')], id('s1'), beforeSiblingMPID: commentOf('s1')),
        'target_not_movable',
      );
    });

    test('may be the target scrap endscrap', () {
      expect(
        check(<int>[id('p1')], id('s2'), beforeSiblingMPID: endscrapOf('s2'))
            .ok,
        isTrue,
      );
    });
  });

  group('area border rules', () {
    test('a border line alone cannot leave its area behind', () {
      expectRejected(check(<int>[id('x1')], id('s3')), 'line_border_shared');
    });

    test('a border line may move within its own scrap', () {
      expect(
        check(<int>[id('b1')], id('s1'), beforeSiblingMPID: id('p1')).ok,
        isTrue,
      );
    });

    test('a shared border line needs every area it borders', () {
      expectRejected(
        check(<int>[id('b1'), id('a1')], id('s3')),
        'line_border_shared',
      );
      expect(check(<int>[id('b1'), id('a1'), id('a2')], id('s3')).ok, isTrue);
    });

    test('an area with a shared border line needs the other area', () {
      expectRejected(check(<int>[id('a1')], id('s3')), 'area_border_shared');
      expect(check(<int>[id('a1'), id('a2')], id('s3')).ok, isTrue);
    });

    test('an area whose border line is in another scrap is rejected', () {
      expectRejected(check(<int>[id('a4')], id('s1')), 'area_border_wrong_scrap');
      expectRejected(check(<int>[id('a4')], id('s3')), 'area_border_wrong_scrap');
    });

    test('an area whose border resolves to a non-line is rejected', () {
      final THArea area = th2File.elementByMPID(id('a2')) as THArea;
      final THAreaBorderTHID border = THAreaBorderTHID(
        parentMPID: area.mpID,
        thID: 'p1',
      );

      th2File.addElement(border);
      area.addElementToParent(border, elementPositionInParent: 0);
      area.clearAreaXLineInfo();

      expectRejected(
        check(<int>[id('a1'), id('a2')], id('s3')),
        'area_border_not_line',
      );
    });

    test('an area moved within its scrap ignores border placement', () {
      expect(
        check(<int>[id('a4')], id('s2'), beforeSiblingMPID: id('p2')).ok,
        isTrue,
      );
    });
  });

  group('no-op and multi-selection', () {
    test('a move to the current position is valid but produces no command', () {
      expect(
        check(<int>[id('p1')], id('s1'), beforeSiblingMPID: id('l1')).ok,
        isTrue,
      );
      expect(
        MPCommandFactory.moveElements(
          th2File: th2File,
          elementMPIDs: <int>[id('p1')],
          newParentMPID: id('s1'),
          beforeSiblingMPID: id('l1'),
        ),
        isNull,
      );
    });

    test('explicit border lines do not turn a no-op into a change', () {
      final MPMoveElementsCommand? command = MPCommandFactory.moveElements(
        th2File: th2File,
        elementMPIDs: <int>[id('b1'), id('a1'), id('a2'), id('x1')],
        newParentMPID: id('s1'),
        beforeSiblingMPID: endscrapOf('s1'),
      );

      expect(command, isNull);
    });

    test('a mixed selection from several scraps is accepted', () {
      expect(
        check(
          <int>[id('p1'), id('p2')],
          id('s3'),
          beforeSiblingMPID: endscrapOf('s3'),
        ).ok,
        isTrue,
      );
    });

    test('validation never mutates the file', () {
      final List<int> before = List<int>.of(th2File.childrenMPIDs);
      final List<int> s1Before = List<int>.of(
        (th2File.elementByMPID(id('s1')) as THScrap).childrenMPIDs,
      );

      check(<int>[id('a1'), id('a2')], id('s3'));
      check(<int>[id('x1')], id('s3'));

      expect(th2File.childrenMPIDs, before);
      expect(
        (th2File.elementByMPID(id('s1')) as THScrap).childrenMPIDs,
        s1Before,
      );
    });
  });
}
