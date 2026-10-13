// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_identity_matcher.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_normalization_analyzer.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/painters/types/mp_selection_handle_type.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:material_ui/material_ui.dart';

import 'auxiliary/th2_text_test_session.dart';
import 'th2_text_apply_test_aux.dart';
import 'th2_text_line_map_test_aux.dart';
import 'th_test_aux.dart';

const String _lineText =
    'encoding utf-8\n'
    'scrap s1\n'
    '  line wall -id w\n'
    '    0 0\n'
    '    10 0\n'
    '    20 0\n'
    '  endline\n'
    '  line wall -id other\n'
    '    100 100\n'
    '    110 110\n'
    '  endline\n'
    'endscrap\n';

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

  int liveOwner(
    TH2FileEditController controller,
    String lineText, {
    int occurrence = 0,
  }) {
    final (String text, TH2TextLineMap lineMap) = controller
        .serializeForTextMode();
    final List<String> lines = TH2TextNormalizationAnalyzer.lineTexts(text);
    int seen = 0;

    for (int line = 0; line < lines.length; line++) {
      if (lines[line] == lineText) {
        if (seen == occurrence) {
          return lineMap.ownerOfLine(line)!;
        }
        seen++;
      }
    }

    throw StateError('No line "$lineText" #$occurrence.');
  }

  Future<TH2TextApplyResult> apply(
    TH2FileEditController controller,
    String text,
  ) async {
    final TH2TextTestSession session = TH2TextTestSession.of(controller);

    session.content = text;

    final TH2TextApplyResult result = await controller.applyTextContent(
      text,
      session: session,
    );

    expect(result, isA<TH2TextApplyApplied>());

    return result;
  }

  /// Every element and option of [file] points at [file], and every parent
  /// and child reference is consistent.
  void expectConsistentFile(TH2File file) {
    for (final THElement element in file.elements.values) {
      expect(identical(element.th2File, file), isTrue, reason: '$element');

      if (element is THHasOptionsMixin) {
        for (final THCommandOption option in <THCommandOption>[
          ...element.optionsMap.values,
          ...element.attrOptionsMap.values,
        ]) {
          expect(identical(option.th2File, file), isTrue, reason: '$option');
          expect(option.parentMPID, element.mpID);
        }
      }

      final THIsParentMixin parent = (element.parentMPID == file.mpID)
          ? file
          : file.elementByMPID(element.parentMPID) as THIsParentMixin;

      expect(parent.childrenMPIDs, contains(element.mpID));

      if (element is THIsParentMixin) {
        for (final int childMPID in (element as THIsParentMixin).childrenMPIDs) {
          expect(file.elementByMPID(childMPID).parentMPID, element.mpID);
        }
      }

      if (element is THAreaBorderTHID) {
        expect(file.elementByTHID(element.thID), isA<THLine>());
      }
    }

    for (final int childMPID in file.childrenMPIDs) {
      expect(file.elementByMPID(childMPID).parentMPID, file.mpID);
    }
  }

  test('matched unchanged elements keep their MPIDs through apply and redo', () async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      _lineText,
    );
    final int w = liveOwner(controller, '  line wall -id w');
    final int other = liveOwner(controller, '  line wall -id other');
    final int segment = liveOwner(controller, '    100 100');
    final String edited = _lineText.replaceFirst('    10 0\n', '    15 0\n');

    await apply(controller, edited);

    expect(liveOwner(controller, '  line wall -id w'), w);
    expect(liveOwner(controller, '  line wall -id other'), other);
    expect(liveOwner(controller, '    100 100'), segment);

    controller.undo();
    controller.redo();

    expect(liveOwner(controller, '  line wall -id w'), w);
    expect(liveOwner(controller, '    100 100'), segment);
  });

  test('added elements are consistent after apply, undo and redo', () async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      _lineText,
    );
    final TH2File liveFile = controller.th2File;
    final String edited =
        '${_lineText}scrap s2\n'
        '  point 5 5 station -id p5\n'
        '  line border -id b -close on\n'
        '    0 0\n'
        '    5 0\n'
        '    5 5\n'
        '    0 0\n'
        '  endline\n'
        '  area water\n'
        '    b\n'
        '  endarea\n'
        'endscrap\n';

    await apply(controller, edited);
    expect(identical(controller.th2File, liveFile), isTrue);
    expectConsistentFile(liveFile);
    expect(liveFile.getAreas(), hasLength(1));

    controller.undo();
    expectConsistentFile(liveFile);
    expect(liveFile.getAreas(), isEmpty);

    controller.redo();
    expectConsistentFile(liveFile);
    expect(liveFile.getAreas(), hasLength(1));
  });

  group('replaceContentsFrom', () {
    test('rejects a source whose elements belong to a file', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _lineText,
      );
      final TH2File liveFile = controller.th2File;
      final TH2TextValidationResult result = await TH2TextValidator.validate(
        content: _lineText,
        filename: liveFile.filename,
        th2FileMPID: liveFile.mpID,
        lineEnding: liveFile.lineEnding,
      );

      expect(
        () => liveFile.replaceContentsFrom(result.detachedFile),
        throwsA(isA<AssertionError>()),
      );

      final TH2File attached = TH2File.fromMap(liveFile.toMap());

      for (final THElement element in attached.elements.values) {
        element.setTH2File(attached);
      }

      /// A scratch file can be == to the live file.
      expect(attached == liveFile, isTrue);

      expect(
        () => liveFile.replaceContentsFrom(attached),
        throwsA(isA<AssertionError>()),
      );
      expectConsistentFile(liveFile);
    });

    test('keeps the file identity and takes the encoding', () {
      final String otherEnding =
          (MPDirectoryAux.getDefaultLineEnding() == mpUnixLineBreak)
          ? mpWindowsLineBreak
          : mpUnixLineBreak;
      final TH2File file = TH2File()
        ..filename = '/tmp/t3967.th2'
        ..fileBytes = Uint8List.fromList(<int>[1, 2, 3])
        ..isNewFile = true
        ..lineEnding = otherEnding;
      final int mpID = file.mpID;
      final Map<String, dynamic> sourceMap = file.toMap()
        ..['filename'] = '/tmp/other.th2'
        ..['encoding'] = 'ISO8859-2';

      file.replaceContentsFrom(TH2File.fromMap(sourceMap));

      expect(file.filename, '/tmp/t3967.th2');
      expect(file.fileBytes, <int>[1, 2, 3]);
      expect(file.isNewFile, isTrue);
      expect(file.mpID, mpID);
      expect(file.lineEnding, otherEnding);
      expect(file.encoding, 'ISO8859-2');
    });

    test('the drawable-children cache follows apply, undo and redo', () async {
      const String text =
          'encoding utf-8\n'
          'scrap s1\n'
          'endscrap\n'
          'scrap s2\n'
          'endscrap\n';
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        text,
      );
      final TH2File file = controller.th2File;

      expect(file.getDrawableChildrenMPIDs(), file.scrapMPIDs);

      await apply(
        controller,
        'encoding utf-8\n'
        'scrap s2\n'
        'endscrap\n'
        'scrap s3\n'
        'endscrap\n',
      );
      expect(file.getDrawableChildrenMPIDs(), file.scrapMPIDs);
      expect(file.scrapMPIDs, hasLength(2));

      controller.undo();
      expect(file.getDrawableChildrenMPIDs(), file.scrapMPIDs);

      controller.redo();
      expect(file.getDrawableChildrenMPIDs(), file.scrapMPIDs);
    });
  });

  group('selection refresh', () {
    THLine selectLine(TH2FileEditController controller, String thID) {
      final THLine line = controller.th2File.elementByTHID(thID) as THLine;

      controller.selectionController.addSelectedElement(line);

      return line;
    }

    void selectEndPoint(
      TH2FileEditController controller,
      int lineSegmentMPID, {
      MPEndControlPointType type = MPEndControlPointType.endPointStraight,
    }) {
      final THLineSegment lineSegment = controller.th2File.lineSegmentByMPID(
        lineSegmentMPID,
      );

      controller.selectionController.addSelectedEndControlPoint(
        MPSelectableEndControlPoint(
          lineSegment: lineSegment,
          th2fileEditController: controller,
          position: lineSegment.endPoint.coordinates,
          type: type,
        ),
      );
    }

    /// The selected line's clone mirrors the live line.
    void expectCloneOfLive(TH2FileEditController controller, int lineMPID) {
      final TH2FileEditSelectionController selection =
          controller.selectionController;
      final MPSelectedLine selected =
          selection.mpSelectedElementsLogical[lineMPID]! as MPSelectedLine;
      final THLine live = controller.th2File.lineByMPID(lineMPID);
      final List<int> liveSegmentMPIDs = live.childrenMPIDs
          .where(
            (int mpID) => controller.th2File.elementByMPID(mpID) is THLineSegment,
          )
          .toList();

      expect(selected.originalLineClone.childrenMPIDs, live.childrenMPIDs);
      expect(
        selected.originalLineSegmentsMapClone.keys.toList(),
        liveSegmentMPIDs,
      );
      for (final int mpID in liveSegmentMPIDs) {
        expect(
          selected.originalLineSegmentsMapClone[mpID]!.endPoint.coordinates,
          controller.th2File.lineSegmentByMPID(mpID).endPoint.coordinates,
        );
      }
      expect(selection.getSelectedLineLineSegmentsMPIDs(), liveSegmentMPIDs);
    }

    test('a selected line follows the live children on apply, undo and redo', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _lineText,
      );
      final TH2FileEditSelectionController selection =
          controller.selectionController;
      final int w = selectLine(controller, 'w').mpID;
      final int kept = liveOwner(controller, '    20 0');

      selectEndPoint(controller, kept);
      selection.getSelectedLineLineSegmentsMPIDs();

      final String edited = _lineText
          .replaceFirst('    10 0\n', '    12 3\n')
          .replaceFirst('    0 0\n', '')
          .replaceFirst('    20 0\n', '    20 0\n    30 0\n');

      await apply(controller, edited);

      expect(liveOwner(controller, '  line wall -id w'), w);
      expect(liveOwner(controller, '    20 0'), kept);
      expectCloneOfLive(controller, w);

      final MPSelectedEndControlPoint keptPoint =
          selection.selectedEndControlPoints[kept]!;

      expect(
        identical(
          keptPoint.originalLineSegmentClone,
          controller.th2File.lineSegmentByMPID(kept),
        ),
        isFalse,
      );
      expect(
        keptPoint.originalLineSegmentClone.endPoint.coordinates,
        controller.th2File.lineSegmentByMPID(kept).endPoint.coordinates,
      );
      expect(keptPoint.type, MPEndControlPointType.endPointStraight);

      /// The undo's own refresh, before undo clears the selection.
      controller.undoRedoController.undosForTesting.last.undoCommand.execute(
        controller,
      );

      expect(controller.serializeForTextMode().$1, _lineText);
      expectCloneOfLive(controller, w);
      expect(selection.selectedEndControlPoints.keys, <int>[kept]);
    });

    test('undo and redo give the live order to a reselected line', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _lineText,
      );
      final TH2FileEditSelectionController selection =
          controller.selectionController;
      final int w = selectLine(controller, 'w').mpID;

      selection.getSelectedLineLineSegmentsMPIDs();
      await apply(
        controller,
        _lineText.replaceFirst('    20 0\n', '    20 0\n    30 0\n'),
      );
      expectCloneOfLive(controller, w);

      controller.undo();
      expect(selection.mpSelectedElementsLogical, isEmpty);
      selectLine(controller, 'w');
      selection.getSelectedLineLineSegmentsMPIDs();

      /// The redo's own refresh, before redo clears the selection.
      controller.undoRedoController.redosForTesting.last.undoCommand.execute(
        controller,
      );
      expectCloneOfLive(controller, w);
    });

    test('a line point matched into another line is dropped', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _lineText,
      );
      final TH2FileEditSelectionController selection =
          controller.selectionController;

      selectLine(controller, 'w');

      final int moving = liveOwner(controller, '    20 0');

      selectEndPoint(controller, moving);

      await apply(
        controller,
        _lineText
            .replaceFirst('    20 0\n', '')
            .replaceFirst('    100 100\n', '    100 100\n    20 0\n'),
      );

      expect(liveOwner(controller, '    20 0'), moving);
      expect(
        controller.th2File.elementByMPID(moving).parentMPID,
        liveOwner(controller, '  line wall -id other'),
      );
      expect(selection.selectedEndControlPoints, isEmpty);
    });

    test('a control point whose segment became straight is dropped', () async {
      const String text =
          'encoding utf-8\n'
          'scrap s1\n'
          '  line wall -id w\n'
          '    0 0\n'
          '    3 3 6 6 10 0\n'
          '  endline\n'
          'endscrap\n';
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        text,
      );
      final TH2FileEditSelectionController selection =
          controller.selectionController;

      selectLine(controller, 'w');

      final int bezier = liveOwner(controller, '    3 3 6 6 10 0');

      selectEndPoint(
        controller,
        bezier,
        type: MPEndControlPointType.controlPoint1,
      );
      expect(selection.selectedEndControlPoints.keys, <int>[bezier]);

      final TH2TextValidationResult straight = await TH2TextValidator.validate(
        content: text.replaceFirst('    3 3 6 6 10 0\n', '    10 0\n'),
        filename: controller.th2File.filename,
        th2FileMPID: controller.th2File.mpID,
        lineEnding: controller.th2File.lineEnding,
      );
      final THElement straightSegment = straight.detachedFile.elements.values
          .firstWhere((THElement element) => element is THStraightLineSegment);
      final Map<String, dynamic> snapshot = controller.th2File.toMap();
      final Map<dynamic, dynamic> elements =
          snapshot['elementByMPID'] as Map<dynamic, dynamic>;

      elements[bezier] = straightSegment.toMap()
        ..['mpID'] = bezier
        ..['parentMPID'] = liveOwner(controller, '  line wall -id w')
        ..['originalLineInTH2File'] = '';
      controller.elementEditController.executeReplaceTH2FileContents(snapshot);

      expect(controller.th2File.elementByMPID(bezier), isA<THStraightLineSegment>());
      expect(selection.selectedEndControlPoints, isEmpty);
    });

    test('the selection bounding box follows the live geometry', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _lineText,
      );
      final TH2FileEditSelectionController selection =
          controller.selectionController;

      selectLine(controller, 'w');

      final Rect before = selection.selectedElementsBoundingBox;
      final Map<MPSelectionHandleType, Offset> centersBefore =
          Map<MPSelectionHandleType, Offset>.of(
            selection.getSelectionHandleCenters(),
          );

      await apply(controller, _lineText.replaceFirst('    20 0\n', '    50 40\n'));

      final Rect after = selection.selectedElementsBoundingBox;

      expect(after, isNot(before));
      expect(after.right, greaterThan(before.right));
      expect(after.bottom, greaterThan(before.bottom));
      expect(selection.getSelectionHandleCenters(), isNot(centersBefore));
    });
  });

  group('remapper key guard', () {
    Set<String> mpIDKeys(dynamic value) {
      final Set<String> keys = <String>{};

      if (value is Map) {
        for (final MapEntry<dynamic, dynamic> entry in value.entries) {
          if ((entry.key is String) &&
              (entry.key as String).toLowerCase().contains('mpid')) {
            keys.add(entry.key as String);
          }
          keys.addAll(mpIDKeys(entry.value));
        }
      } else if (value is List) {
        for (final dynamic item in value) {
          keys.addAll(mpIDKeys(item));
        }
      }

      return keys;
    }

    test('only mpID, parentMPID and childrenMPIDs hold MPIDs', () async {
      final Map<Type, Set<String>> keysByElementType = <Type, Set<String>>{};
      final Map<Type, Set<String>> keysByOptionType = <Type, Set<String>>{};

      for (final File fixture in TH2TextLineMapTestAux.fixtures()) {
        final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseBytes(
          fixture.readAsBytesSync(),
          filename: fixture.path,
        );

        expect(
          mpIDKeys(<String, dynamic>{
            for (final MapEntry<String, dynamic> entry
                in parsed.file.toMap().entries)
              if (entry.key != 'elementByMPID') entry.key: entry.value,
          })..add('elementByMPID'),
          <String>{'mpID', 'childrenMPIDs', 'elementByMPID'},
        );

        for (final THElement element in parsed.file.elements.values) {
          keysByElementType.putIfAbsent(
            element.runtimeType,
            () => mpIDKeys(element.toMap()),
          );

          if (element is THHasOptionsMixin) {
            for (final THCommandOption option in <THCommandOption>[
              ...element.optionsMap.values,
              ...element.attrOptionsMap.values,
            ]) {
              keysByOptionType.putIfAbsent(
                option.runtimeType,
                () => mpIDKeys(option.toMap()),
              );
            }
          }
        }
      }

      expect(keysByElementType.length, greaterThan(10));
      expect(keysByOptionType.length, greaterThan(10));
      expect(
        keysByElementType.values.expand((Set<String> keys) => keys).toSet(),
        <String>{'mpID', 'parentMPID', 'childrenMPIDs'},
      );
      for (final MapEntry<Type, Set<String>> entry
          in keysByElementType.entries) {
        expect(
          entry.value.difference(<String>{
            'mpID',
            'parentMPID',
            'childrenMPIDs',
          }),
          isEmpty,
          reason: '${entry.key}',
        );
      }
      for (final MapEntry<Type, Set<String>> entry in keysByOptionType.entries) {
        expect(entry.value, <String>{'parentMPID'}, reason: '${entry.key}');
      }
    });

    test('the remapped snapshot names matched top-level elements by live MPID', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _lineText,
      );
      final TH2TextTestSession session = TH2TextTestSession.of(controller);
      final String edited = '${_lineText}scrap s2\nendscrap\n';
      final TH2TextValidationResult result = await TH2TextValidator.validate(
        content: edited,
        filename: controller.th2File.filename,
        th2FileMPID: controller.th2File.mpID,
        lineEnding: controller.th2File.lineEnding,
      );
      final Map<int, int> matching = TH2TextIdentityMatcher.match(
        live: (controller.th2File, session.initialContent, session.initialLineMap),
        detached: (result.detachedFile, result.normalizedText, result.writerMap),
      );
      final Map<String, dynamic> detachedMap = result.detachedFile.toMap();
      final Map<String, dynamic> after = TH2TextMPIDRemapper.remap(
        detachedMap,
        matching,
      );
      final List<int> children = List<int>.from(after['childrenMPIDs'] as List);
      int matchedTopLevel = 0;

      expect(detachedMap, result.detachedFile.toMap());
      for (final int detachedMPID in result.detachedFile.childrenMPIDs) {
        final int? liveMPID = matching[detachedMPID];

        if (liveMPID == null) {
          expect(children, contains(detachedMPID));
          continue;
        }

        matchedTopLevel++;
        expect(children, contains(liveMPID));
        if (liveMPID != detachedMPID) {
          expect(children, isNot(contains(detachedMPID)));
        }
      }
      expect(matchedTopLevel, 2);
    });
  });

  test('copyWith and fromMap keep a non-default line ending', () {
    final String otherEnding =
        (MPDirectoryAux.getDefaultLineEnding() == mpUnixLineBreak)
        ? mpWindowsLineBreak
        : mpUnixLineBreak;
    final TH2File file = TH2File()..lineEnding = otherEnding;

    expect(file.copyWith().lineEnding, otherEnding);
    expect(TH2File.fromMap(file.toMap()).lineEnding, otherEnding);
  });
}
