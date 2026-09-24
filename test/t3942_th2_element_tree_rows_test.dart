// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/auxiliary/th2_element_tree_aux.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_flatten_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_missing_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_pt.dart';
import 'package:path/path.dart' as p;

import 'th_test_aux.dart';

const String _validContents =
    'encoding utf-8\n'
    '# a comment\n'
    '##XTHERION## xth_me_area_adjust 0 0 100 100\n'
    'scrap s1 -projection plan\n'
    '\n'
    '  point 1 1 station -id p.1 -name 1.3\n'
    '  # hidden\n'
    '  line wall:blocks -id w12\n'
    '    10 20\n'
    '    30 40\n'
    '  endline\n'
    '  line border -id [b@1] -close on\n'
    '    0 0\n'
    '    10 0\n'
    '    10 10\n'
    '    0 0\n'
    '  endline\n'
    '  area water\n'
    '    [b@1]\n'
    '  endarea\n'
    '  point 2 2 label -id área@ç\n'
    'endscrap\n'
    'scrap s2\n'
    '  point 3 3 station\n'
    'endscrap\n';

const String _brokenContents =
    'encoding utf-8\n'
    'point 1 1 station\n'
    'scrap s1\n'
    'endscrap\n';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  late Directory tempDir;

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    MPTextToUser.initialize();
    mpLocator.thProjectController.closeProject();
    mpLocator.mpGeneralController.reset();
    mpLocator.thProjectTreeUIController.setFilterText('');
    mpLocator.thProjectTreeUIController.expandedNodeIds.clear();
    mpLocator.thProjectTreeUIController.collapsedTH2ScrapIds.clear();
    tempDir = Directory.systemTemp.createTempSync('mapiah_t3942_');
  });

  tearDown(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    MPTextToUser.initialize();
    mpLocator.mpGeneralController.reset();
    tempDir.deleteSync(recursive: true);
  });

  String pathOf(String name) => p.join(tempDir.path, name);

  Future<TH2FileEditController> load(String contents, {String? name}) async {
    final TH2FileEditController controller = mpLocator.mpGeneralController
        .getTH2FileEditController(
          filename: pathOf(name ?? 'file.th2'),
          fileBytes: Uint8List.fromList(utf8.encode(contents)),
        );

    await controller.load();

    return controller;
  }

  THProjectTreeUIController ui() => mpLocator.thProjectTreeUIController;

  TH2ElementRowsResult rowsFor(
    TH2FileEditController? controller, {
    String? path,
    bool filterActive = false,
    Set<String>? needsLoad,
  }) {
    return TH2ElementTreeAux.rowsForFile(
      th2FilePath: path ?? controller!.th2File.filename,
      controller: controller,
      fileDepth: 1,
      filterActive: filterActive,
      matchesFilterText: ui().matchesFilterText,
      isScrapCollapsed: ui().isTH2ScrapCollapsed,
      onNeedsLoad: needsLoad?.add,
    );
  }

  List<String> labelsOf(TH2ElementRowsResult result) => result.rows
      .whereType<TH2ElementTreeRow>()
      .map((TH2ElementTreeRow row) => row.label.plainText)
      .toList();

  String rowIdOf(TH2FileEditController controller, String thID) =>
      th2ElementTreeRowId(
        th2FilePath: controller.th2File.filename,
        elementMPID: controller.th2File.mpIDByTHID(thID)!,
      );

  group('rows of a valid file', () {
    test('file, scraps and PLAs appear in exact source order', () async {
      final TH2FileEditController controller = await load(_validContents);
      final TH2ElementRowsResult result = rowsFor(controller);
      final List<TH2ElementTreeRow> rows = result.rows
          .cast<TH2ElementTreeRow>();

      expect(
        rows.map((TH2ElementTreeRow row) => row.elementType).toList(),
        <THElementType>[
          THElementType.scrap,
          THElementType.point,
          THElementType.line,
          THElementType.line,
          THElementType.area,
          THElementType.point,
          THElementType.scrap,
          THElementType.point,
        ],
      );
      expect(
        rows.map((TH2ElementTreeRow row) => row.depth).toList(),
        <int>[2, 3, 3, 3, 3, 3, 2, 3],
      );
    });

    test('only scraps are expandable and scraps start expanded', () async {
      final TH2FileEditController controller = await load(_validContents);
      final List<TH2ElementTreeRow> rows = rowsFor(
        controller,
      ).rows.cast<TH2ElementTreeRow>();

      for (final TH2ElementTreeRow row in rows) {
        expect(row.isExpandable, row.isScrap);
        expect(row.isExpanded, row.isScrap);
      }
    });

    test('a collapsed scrap emits no child rows, others keep order', () async {
      final TH2FileEditController controller = await load(_validContents);

      ui().toggleTH2ScrapCollapsed(rowIdOf(controller, 's1'));

      final List<TH2ElementTreeRow> rows = rowsFor(
        controller,
      ).rows.cast<TH2ElementTreeRow>();

      expect(
        rows.map((TH2ElementTreeRow row) => row.elementType).toList(),
        <THElementType>[
          THElementType.scrap,
          THElementType.scrap,
          THElementType.point,
        ],
      );
      expect(rows.first.isExpanded, isFalse);
    });

    test('labels follow kind, type[:subtype] and the verbatim id', () async {
      final TH2FileEditController controller = await load(_validContents);
      final List<TH2ElementTreeRow> rows = rowsFor(
        controller,
      ).rows.cast<TH2ElementTreeRow>();
      final THLine wall =
          controller.th2File.elementByMPID(
                controller.th2File.mpIDByTHID('w12')!,
              )
              as THLine;

      for (final TH2ElementTreeRow row in rows) {
        final THElement element = controller.th2File.elementByMPID(
          row.elementMPID,
        );
        final String? storedTHID = (element is THScrap)
            ? element.thID
            : MPCommandOptionAux.getID(element);

        expect(row.label.thID, storedTHID);
      }

      expect(rows[0].label.primaryText, 'Scrap');
      expect(rows[0].label.thID, 's1');
      expect(rows[1].label.thID, isNotNull);
      expect(rows[2].label.primaryText, startsWith('Line '));
      expect(
        rows[2].label.primaryText,
        'Line ${MPTextToUser.getLineTypeSubtypeFromLine(wall)}',
      );
      expect(rows[2].label.primaryText, contains(':'));
      expect(rows[2].label.thID, 'w12');
      expect(rows[1].label.thID, 'p.1');
      expect(rows[3].label.thID, '_b_1_');
      expect(rows[4].elementType, THElementType.area);
      expect(rows[4].label.thID, isNull);
      expect(rows[7].label.thID, isNull);
      expect(rows[7].label.plainText, rows[7].label.primaryText);
    });

    test('a station name never appears in its label', () async {
      final TH2FileEditController controller = await load(_validContents);
      final List<String> labels = labelsOf(rowsFor(controller));

      expect(labels[1], isNot(contains('1.3')));
    });

    test('plain text is the concatenation of the spans', () async {
      final TH2FileEditController controller = await load(_validContents);

      for (final TH2ElementTreeRow row in rowsFor(
        controller,
      ).rows.cast<TH2ElementTreeRow>()) {
        final String? thID = row.label.thID;

        expect(
          row.label.plainText,
          (thID == null) ? row.label.primaryText : '${row.label.primaryText} $thID',
        );
      }
    });

    test('building labels never changes the file', () async {
      final TH2FileEditController controller = await load(_validContents);
      final int elementCount = controller.th2File.elements.length;
      final String newTHID = controller.th2File.getNewTHID(prefix: 'point');
      final int point = controller.th2File.mpIDByTHID(MPCommandOptionAux.getID(controller.th2File.elementByMPID(controller.th2File.getScraps().first.childrenMPIDs.firstWhere((int id) => controller.th2File.elementByMPID(id) is THPoint)))!)!;
      final int optionCount =
          (controller.th2File.elementByMPID(point) as THPoint)
              .optionsMap
              .length;

      rowsFor(controller);
      rowsFor(controller, filterActive: true);

      expect(controller.th2File.elements.length, elementCount);
      expect(controller.th2File.getNewTHID(prefix: 'point'), newTHID);
      expect(
        (controller.th2File.elementByMPID(point) as THPoint).optionsMap.length,
        optionCount,
      );
      expect(controller.enableSaveButton, isFalse);
    });

    test('row ids include the canonical path and are distinct', () async {
      final TH2FileEditController first = await load(
        _validContents,
        name: 'first.th2',
      );
      final TH2FileEditController second = await load(
        _validContents,
        name: 'second.th2',
      );
      final List<String> firstIds = rowsFor(
        first,
      ).rows.map((THProjectTreeVisibleRow row) => row.rowId).toList();
      final List<String> secondIds = rowsFor(
        second,
      ).rows.map((THProjectTreeVisibleRow row) => row.rowId).toList();

      expect(firstIds.first, startsWith('th2el:${pathOf('first.th2')}:'));
      expect(firstIds.toSet().intersection(secondIds.toSet()), isEmpty);
      expect(firstIds.toSet(), hasLength(firstIds.length));
    });
  });

  group('status rows', () {
    test('a broken file produces only one broken status row', () async {
      final TH2FileEditController controller = await load(_brokenContents);
      final TH2ElementRowsResult result = rowsFor(controller);

      expect(result.rows, hasLength(1));
      expect(
        (result.rows.single as TH2FileStatusTreeRow).kind,
        TH2FileStatusTreeRowKind.broken,
      );
      expect(result.rows.single.rowId, 'th2status:${pathOf('file.th2')}:broken');
    });

    test('no controller or an unloaded one is loading and needs a load', () {
      final Set<String> needsLoad = <String>{};
      final String path = pathOf('missing.th2');
      final TH2ElementRowsResult result = rowsFor(
        null,
        path: path,
        needsLoad: needsLoad,
      );

      expect(
        (result.rows.single as TH2FileStatusTreeRow).kind,
        TH2FileStatusTreeRowKind.loading,
      );
      expect(needsLoad, <String>{path});
    });

    test('a loading controller shows loading and needs no load', () async {
      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(
            filename: pathOf('slow.th2'),
            fileBytes: Uint8List.fromList(utf8.encode(_validContents)),
          );
      final Future<TH2FileEditControllerCreateResult> load = controller
          .load();
      final Set<String> needsLoad = <String>{};
      final TH2ElementRowsResult result = rowsFor(
        controller,
        needsLoad: needsLoad,
      );

      expect(
        (result.rows.single as TH2FileStatusTreeRow).kind,
        TH2FileStatusTreeRowKind.loading,
      );
      expect(needsLoad, isEmpty);

      await load;
    });

    test('a failed load shows one load-error row and needs no load', () async {
      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(
            filename: pathOf('throws.th2'),
            fileBytes: Uint8List.fromList(
              utf8.encode(
                'encoding utf-8\nscrap a\nendscrap\nscrap a\nendscrap\n',
              ),
            ),
          );

      await expectLater(controller.load(), throwsA(anything));

      final Set<String> needsLoad = <String>{};
      final TH2ElementRowsResult result = rowsFor(
        controller,
        needsLoad: needsLoad,
      );

      expect(result.rows, hasLength(1));
      expect(
        (result.rows.single as TH2FileStatusTreeRow).kind,
        TH2FileStatusTreeRowKind.loadError,
      );
      expect(needsLoad, isEmpty);
    });
  });

  group('filtering', () {
    test('a matching element shows its scrap, even when collapsed', () async {
      final TH2FileEditController controller = await load(_validContents);

      ui().toggleTH2ScrapCollapsed(rowIdOf(controller, 's1'));
      ui().setFilterText('w12');

      final TH2ElementRowsResult result = rowsFor(
        controller,
        filterActive: true,
      );
      final List<TH2ElementTreeRow> rows = result.rows
          .cast<TH2ElementTreeRow>();

      expect(result.hasMatch, isTrue);
      expect(rows.map((TH2ElementTreeRow row) => row.label.thID).toList(), <
        String?
      >['s1', 'w12']);
      expect(rows.first.isExpanded, isTrue);
      expect(ui().collapsedTH2ScrapIds, <String>{rowIdOf(controller, 's1')});
    });

    test('a scrap matching by its own label hides non-matching children', () async {
      final TH2FileEditController controller = await load(_validContents);

      ui().setFilterText('s2');

      final TH2ElementRowsResult result = rowsFor(
        controller,
        filterActive: true,
      );

      expect(result.hasMatch, isTrue);
      expect(labelsOf(result), <String>['Scrap s2']);
    });

    test('a localized kind or type name finds rows', () async {
      final TH2FileEditController controller = await load(_validContents);

      ui().setFilterText('area');

      final TH2ElementRowsResult result = rowsFor(
        controller,
        filterActive: true,
      );

      expect(
        result.rows
            .cast<TH2ElementTreeRow>()
            .where((TH2ElementTreeRow row) => !row.isScrap)
            .map((TH2ElementTreeRow row) => row.elementType),
        <THElementType>[THElementType.area],
      );
    });

    test('status rows are hidden and no load is requested', () async {
      final TH2FileEditController broken = await load(
        _brokenContents,
        name: 'broken.th2',
      );
      final Set<String> needsLoad = <String>{};

      ui().setFilterText('anything');

      expect(rowsFor(broken, filterActive: true).rows, isEmpty);
      expect(
        rowsFor(
          null,
          path: pathOf('missing.th2'),
          filterActive: true,
          needsLoad: needsLoad,
        ).rows,
        isEmpty,
      );
      expect(needsLoad, isEmpty);
    });

    test('matchesFilterText agrees with matchesFilter on node labels', () {
      final THMissingFileNode node = THMissingFileNode(
        id: 'x',
        label: 'Cave Passage.th',
        sourceFilePath: '/tmp/x.th',
        lineNumber: 0,
        absolutePath: '/tmp/x.th',
        relativePathToProjectRoot: 'x.th',
        encoding: 'UTF-8',
        requestedPath: 'x.th',
      );

      for (final String filter in <String>['', 'cave', 'PASS', 'nope']) {
        ui().setFilterText(filter);

        expect(ui().matchesFilterText(node.label), ui().matchesFilter(node));
      }
    });
  });

  group('flattening with a TH2 file', () {
    late TH2FileEditController controller;
    late THMissingFileNode root;
    late THMissingFileNode survey;
    late TH2FileNode th2Node;
    late THMissingFileNode other;

    setUp(() async {
      controller = await load(_validContents);
      root = THMissingFileNode(
        id: 'root',
        label: 'root.thconfig',
        sourceFilePath: '/tmp/root',
        lineNumber: 0,
        absolutePath: '/tmp/root',
        relativePathToProjectRoot: 'root',
        encoding: 'UTF-8',
        requestedPath: 'root',
      );
      survey = THMissingFileNode(
        id: 'survey',
        label: 'survey.th',
        sourceFilePath: '/tmp/survey.th',
        lineNumber: 0,
        absolutePath: '/tmp/survey.th',
        relativePathToProjectRoot: 'survey.th',
        encoding: 'UTF-8',
        requestedPath: 'survey.th',
      );
      th2Node = TH2FileNode(
        id: 'th2',
        label: 'file.th2',
        sourceFilePath: controller.th2File.filename,
        lineNumber: 0,
        absolutePath: controller.th2File.filename,
        relativePathToProjectRoot: 'file.th2',
        encoding: 'UTF-8',
        isLoaded: false,
      );
      other = THMissingFileNode(
        id: 'other',
        label: 'other.th',
        sourceFilePath: '/tmp/other.th',
        lineNumber: 0,
        absolutePath: '/tmp/other.th',
        relativePathToProjectRoot: 'other.th',
        encoding: 'UTF-8',
        requestedPath: 'other.th',
      );
      survey.addChild(th2Node);
      root.addChild(survey);
      root.addChild(other);
    });

    List<THProjectTreeVisibleRow> flatten({
      required Set<String> expanded,
      required bool filterActive,
    }) {
      return flattenVisibleNodes(
        root: root,
        isExpanded: (THProjectNode node) => expanded.contains(node.id),
        matchesFilter: ui().matchesFilter,
        filterActive: filterActive,
        th2ElementRowsFor:
            (TH2FileNode node, int depth, {required bool filterActive}) =>
                TH2ElementTreeAux.rowsForFile(
                  th2FilePath: node.absolutePath,
                  controller: mpLocator.mpGeneralController
                      .getTH2FileEditControllerIfExists(node.absolutePath),
                  fileDepth: depth,
                  filterActive: filterActive,
                  matchesFilterText: ui().matchesFilterText,
                  isScrapCollapsed: ui().isTH2ScrapCollapsed,
                ),
      );
    }

    List<String> idsOf(List<THProjectTreeVisibleRow> rows) =>
        rows.map((THProjectTreeVisibleRow row) => row.rowId).toList();

    test('expanded file rows are followed by their element rows', () {
      final List<THProjectTreeVisibleRow> rows = flatten(
        expanded: <String>{'root', 'survey', 'th2'},
        filterActive: false,
      );

      expect(idsOf(rows).take(3).toList(), <String>['root', 'survey', 'th2']);
      expect(rows[3], isA<TH2ElementTreeRow>());
      expect(rows[3].depth, 3);
      expect(idsOf(rows).last, 'other');
    });

    test('a file matching only by its own label shows no element rows', () {
      ui().setFilterText('file.th2');

      final List<THProjectTreeVisibleRow> rows = flatten(
        expanded: <String>{},
        filterActive: true,
      );

      expect(idsOf(rows), <String>['root', 'survey', 'th2']);
    });

    test('a matching element keeps its file and ancestors visible', () {
      final Set<String> expanded = <String>{};

      ui().setFilterText('w12');

      final List<THProjectTreeVisibleRow> rows = flatten(
        expanded: expanded,
        filterActive: true,
      );

      expect(idsOf(rows).take(3).toList(), <String>['root', 'survey', 'th2']);
      expect(
        rows
            .skip(3)
            .cast<TH2ElementTreeRow>()
            .map((TH2ElementTreeRow row) => row.label.thID)
            .toList(),
        <String?>['s1', 'w12'],
      );
      expect(expanded, isEmpty);
    });

    test('clearing the filter restores both expansion sets', () {
      final Set<String> expanded = <String>{'root', 'survey', 'th2'};
      final String s1 = rowIdOf(controller, 's1');

      ui().toggleTH2ScrapCollapsed(s1);
      ui().setFilterText('w12');
      flatten(expanded: expanded, filterActive: true);
      ui().setFilterText('');

      final List<THProjectTreeVisibleRow> rows = flatten(
        expanded: expanded,
        filterActive: false,
      );

      expect(expanded, <String>{'root', 'survey', 'th2'});
      expect(ui().collapsedTH2ScrapIds, <String>{s1});
      expect(
        rows.whereType<TH2ElementTreeRow>().map(
          (TH2ElementTreeRow row) => row.label.thID,
        ),
        <String?>['s1', 's2', null],
      );
    });

    test('each file result is computed once per filtered flattening', () {
      ui().setFilterText('w12');

      final int before = TH2ElementTreeAux.debugRowsForFileCallCount;

      flatten(expanded: <String>{}, filterActive: true);

      expect(TH2ElementTreeAux.debugRowsForFileCallCount, before + 1);
    });
  });

  group('label cache', () {
    test('is reused, and rebuilt on revision, controller and locale', () async {
      final TH2FileEditController controller = await load(_validContents);

      rowsFor(controller);

      int builds = TH2ElementTreeAux.debugLabelCacheBuildCount;

      rowsFor(controller);
      expect(TH2ElementTreeAux.debugLabelCacheBuildCount, builds);

      controller.execute(
        MPSetOptionToElementCommand(
          toOption: THSubtypeCommandOption(
            parentMPID: controller.th2File.mpIDByTHID(MPCommandOptionAux.getID(controller.th2File.elementByMPID(controller.th2File.getScraps().first.childrenMPIDs.firstWhere((int id) => controller.th2File.elementByMPID(id) is THPoint)))!)!,
            subtype: 'fixed',
          ),
        ),
      );
      rowsFor(controller);
      expect(TH2ElementTreeAux.debugLabelCacheBuildCount, builds + 1);

      builds = TH2ElementTreeAux.debugLabelCacheBuildCount;
      File(controller.th2File.filename).writeAsStringSync(_validContents);

      final TH2FileEditController reloaded = await mpLocator
          .mpGeneralController
          .reloadTH2File(controller.th2File.filename);

      rowsFor(reloaded, path: controller.th2File.filename);
      expect(TH2ElementTreeAux.debugLabelCacheBuildCount, builds + 1);

      builds = TH2ElementTreeAux.debugLabelCacheBuildCount;
      mpLocator.appLocalizations = AppLocalizationsPt();
      MPTextToUser.initialize();

      final List<String> ptLabels = labelsOf(
        rowsFor(reloaded, path: controller.th2File.filename),
      );

      expect(TH2ElementTreeAux.debugLabelCacheBuildCount, builds + 1);
      expect(ptLabels.first, startsWith('Croqui'));
    });
  });

  group('canonical paths', () {
    test('row ids, TH2FileNode path and controller key match', () async {
      File(pathOf('thconfig')).writeAsStringSync('source cave.th\n');
      Directory(pathOf('sub')).createSync();
      File(
        pathOf('cave.th'),
      ).writeAsStringSync('survey cave\n  input ./sub/../sub/p.th2\nendsurvey\n');
      File(pathOf('sub/p.th2')).writeAsStringSync(_validContents);

      await mpLocator.thProjectController.openProject(pathOf('thconfig'));

      final THProjectFileNode? node = mpLocator.thProjectController
          .nodeByCanonicalPath(pathOf('sub/p.th2'));

      expect(node, isA<TH2FileNode>());

      final String absolutePath = node!.absolutePath;
      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: './sub/../sub/p.th2'.replaceFirst('.', tempDir.path));

      await controller.load();

      final TH2ElementRowsResult result = rowsFor(controller, path: absolutePath);

      expect(controller.th2File.filename, absolutePath);
      expect(
        mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
          absolutePath,
        ),
        same(controller),
      );
      expect(result.rows.first.rowId, startsWith('th2el:$absolutePath:'));

      mpLocator.thProjectController.closeProject();
    });
  });
}
