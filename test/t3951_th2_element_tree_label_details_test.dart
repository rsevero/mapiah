// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/auxiliary/th2_element_tree_aux.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_flatten_aux.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_visible_row.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'th2_element_tree_test_aux.dart';
import 'th_test_aux.dart';

const String _detailsContents =
    'encoding utf-8\n'
    'scrap s1 -projection plan\n'
    '  point 1 1 station -id st1 -name 1.3@main\n'
    '  point 2 2 station -id st2\n'
    '  point 3 3 station:temporary -id st3 -name 47@39.2002-08\n'
    '  point 4 4 label -id lb1 -text "Main entrance"\n'
    '  point 5 5 remark -id rm1 -text "a<br>b"\n'
    '  point 6 6 label -id lb2 -text "a<br><br>b"\n'
    '  point 7 7 label -id lb3 -text "<center>Main<br>entrance"\n'
    '  point 8 8 label -id e1 -text ""\n'
    '  point 9 9 label -id e2 -text " "\n'
    '  point 10 10 label -id e3 -text "<br>"\n'
    '  point 11 11 continuation -id c1 -text "lead"\n'
    '  point 12 12 altitude -id a1 -value 100\n'
    '  point 13 13 water-flow -id wf1 -name 5\n'
    '  point 14 14 label -text "no id"\n'
    '  line label -id ll1 -text "line text"\n'
    '    0 0\n'
    '    10 10\n'
    '  endline\n'
    '  point 15 15 remark -id rm2 -text "Unsurveyed<br>deep lead"\n'
    'endscrap\n';

const String _widgetContents =
    'encoding utf-8\n'
    'scrap s1 -projection plan\n'
    '  point 1 1 station -id p1 -name 1.3@main\n'
    '  point 2 2 label -id p2 -text "Main<br>entrance"\n'
    '  point 3 3 remark -id p3 -text "Unsurveyed lead"\n'
    'endscrap\n';

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  void resetState() {
    mpLocator.thProjectController.closeProject();
    mpLocator.mpGeneralController.reset();
    mpLocator.thProjectTreeUIController.setFilterText('');
    mpLocator.thProjectTreeUIController.expandedNodeIds.clear();
    mpLocator.thProjectTreeUIController.collapsedTH2ScrapIds.clear();
  }

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    MPTextToUser.initialize();
    resetState();
  });

  THProjectTreeUIController ui() => mpLocator.thProjectTreeUIController;

  group('label model and builder', () {
    late Directory tempDir;
    late TH2FileEditController controller;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('mapiah_t3951_');
      controller = mpLocator.mpGeneralController.getTH2FileEditController(
        filename: p.join(tempDir.path, 'details.th2'),
        fileBytes: Uint8List.fromList(utf8.encode(_detailsContents)),
      );
      await controller.load();
      expect(controller.isFileLoaded, isTrue);
      expect(controller.isBroken, isFalse);
    });

    tearDown(() {
      mpLocator.mpGeneralController.reset();
      tempDir.deleteSync(recursive: true);
    });

    THElement element(String thID) =>
        controller.th2File.elementByMPID(controller.th2File.mpIDByTHID(thID)!);

    TH2ElementTreeLabel label(String thID) =>
        TH2ElementTreeAux.buildLabel(element(thID));

    List<TH2ElementTreeRow> rows({bool filterActive = false}) {
      return TH2ElementTreeAux.rowsForFile(
        th2FilePath: controller.th2File.filename,
        controller: controller,
        fileDepth: 1,
        filterActive: filterActive,
        matchesFilterText: ui().matchesFilterText,
        isScrapCollapsed: ui().isTH2ScrapCollapsed,
      ).rows.cast<TH2ElementTreeRow>();
    }

    String rowText(String thID) {
      final int mpID = controller.th2File.mpIDByTHID(thID)!;

      return rows()
          .firstWhere((TH2ElementTreeRow row) => row.elementMPID == mpID)
          .label
          .plainText;
    }

    test('station names are shown verbatim as the detail', () {
      expect(label('st1').detail, '1.3@main');
      expect(label('st1').tooltipText, isNull);
      expect(label('st2').detail, isNull);
      expect(label('st3').detail, '47@39.2002-08');
      expect(
        label('st3').primaryText,
        'Point ${MPTextToUser.getPointTypeSubtypeFromPoint(element('st3') as THPoint)}',
      );
      expect(label('st3').primaryText, contains(':'));
      expect(label('st3').primaryText, isNot(contains('47')));
    });

    test('label and remark text become the detail', () {
      expect(label('lb1').detail, 'Main entrance');
      expect(label('lb1').tooltipText, isNull);
      expect(label('rm1').detail, 'a b');
      expect(label('rm1').tooltipText, 'a\nb');
      expect(label('lb2').detail, 'a b');
      expect(label('lb2').tooltipText, 'a\nb');
      expect(label('lb3').detail, '<center>Main entrance');
      expect(label('lb3').tooltipText, '<center>Main\nentrance');
    });

    test('empty texts give no detail', () {
      for (final String thID in <String>['e1', 'e2', 'e3']) {
        expect(label(thID).detail, isNull, reason: thID);
        expect(label(thID).tooltipText, isNull, reason: thID);
      }
    });

    test('other elements get no detail', () {
      for (final String thID in <String>['ll1', 'c1', 'a1', 'wf1', 's1']) {
        expect(label(thID).detail, isNull, reason: thID);
        expect(label(thID).tooltipText, isNull, reason: thID);
      }
    });

    test('plain text is kind type, detail, id with single spaces', () {
      expect(label('st1').plainText, 'Point Station 1.3@main st1');
      expect(label('st2').plainText, 'Point Station st2');

      final THScrap scrap = controller.th2File.getScraps().first;
      final THPoint noID = scrap.childrenMPIDs
          .map(controller.th2File.elementByMPID)
          .whereType<THPoint>()
          .firstWhere((THPoint point) => !point.hasOption(THCommandOptionType.id));
      final TH2ElementTreeLabel noIDLabel = TH2ElementTreeAux.buildLabel(noID);

      expect(noIDLabel.thID, isNull);
      expect(noIDLabel.plainText, '${noIDLabel.primaryText} no id');
      expect(
        const TH2ElementTreeLabel(primaryText: 'a', detail: '', thID: '').plainText,
        'a',
      );
    });

    test('building labels never changes the file', () {
      final TH2FileWriter writer = TH2FileWriter();
      final String before = writer.serialize(controller.th2File);
      final Map<int, String> originalLines = <int, String>{
        for (final THElement element in controller.th2File.elements.values)
          element.mpID: element.originalLineInTH2File,
      };

      for (final THElement element in controller.th2File.elements.values) {
        TH2ElementTreeAux.buildLabel(element);
      }
      rows();

      expect(writer.serialize(controller.th2File), before);
      expect(<int, String>{
        for (final THElement element in controller.th2File.elements.values)
          element.mpID: element.originalLineInTH2File,
      }, originalLines);
    });

    test('setting, changing and removing a station name updates the row', () {
      final int st2 = controller.th2File.mpIDByTHID('st2')!;
      int revision = controller.structureRevision;

      controller.execute(
        MPSetOptionToElementCommand(
          toOption: THStationNameCommandOption.fromStringWithParentMPID(
            parentMPID: st2,
            name: 'A1',
          ),
        ),
      );
      expect(controller.structureRevision, greaterThan(revision));
      expect(rowText('st2'), 'Point Station A1 st2');

      revision = controller.structureRevision;
      controller.execute(
        MPSetOptionToElementCommand(
          toOption: THStationNameCommandOption.fromStringWithParentMPID(
            parentMPID: st2,
            name: 'A2',
          ),
        ),
      );
      expect(controller.structureRevision, greaterThan(revision));
      expect(rowText('st2'), 'Point Station A2 st2');

      revision = controller.structureRevision;
      controller.execute(
        MPRemoveOptionFromElementCommand(
          optionType: THCommandOptionType.station,
          parentMPID: st2,
        ),
      );
      expect(controller.structureRevision, greaterThan(revision));
      expect(rowText('st2'), 'Point Station st2');

      controller.undo();
      expect(rowText('st2'), 'Point Station A2 st2');
      controller.undo();
      expect(rowText('st2'), 'Point Station A1 st2');
      controller.undo();
      expect(rowText('st2'), 'Point Station st2');
      controller.redo();
      expect(rowText('st2'), 'Point Station A1 st2');
      controller.redo();
      expect(rowText('st2'), 'Point Station A2 st2');
      controller.redo();
      expect(rowText('st2'), 'Point Station st2');
    });

    test('setting, changing and removing text updates the row', () {
      for (final String thID in <String>['lb1', 'rm1']) {
        final int mpID = controller.th2File.mpIDByTHID(thID)!;
        final String original = rowText(thID);
        final String prefix = label(thID).primaryText;
        int revision = controller.structureRevision;

        controller.execute(
          MPSetOptionToElementCommand(
            toOption: THTextCommandOption(
              parentMPID: mpID,
              textContent: 'New text',
            ),
          ),
        );
        expect(controller.structureRevision, greaterThan(revision));
        expect(rowText(thID), '$prefix New text $thID');

        revision = controller.structureRevision;
        controller.execute(
          MPRemoveOptionFromElementCommand(
            optionType: THCommandOptionType.text,
            parentMPID: mpID,
          ),
        );
        expect(controller.structureRevision, greaterThan(revision));
        expect(rowText(thID), '$prefix $thID');

        controller.undo();
        expect(rowText(thID), '$prefix New text $thID');
        controller.undo();
        expect(rowText(thID), original);
        controller.redo();
        expect(rowText(thID), '$prefix New text $thID');
        controller.redo();
        expect(rowText(thID), '$prefix $thID');
      }
    });

    test('a multiple-elements edit updates every affected row', () {
      final List<String> thIDs = <String>['lb1', 'lb2', 'rm1'];
      final Map<String, String> originals = <String, String>{
        for (final String thID in thIDs) thID: rowText(thID),
      };

      controller.execute(
        MPCommandFactory.multipleCommandsFromList(
          commandsList: <MPCommand>[
            for (final String thID in thIDs)
              MPSetOptionToElementCommand(
                toOption: THTextCommandOption(
                  parentMPID: controller.th2File.mpIDByTHID(thID)!,
                  textContent: 'Shared',
                ),
              ),
          ],
          descriptionType: MPCommandDescriptionType.setOptionToElements,
          completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
        ),
      );

      for (final String thID in thIDs) {
        expect(label(thID).detail, 'Shared');
        expect(rowText(thID), contains(' Shared $thID'));
      }

      controller.undo();

      for (final String thID in thIDs) {
        expect(rowText(thID), originals[thID]);
      }
    });

    test('a type change switches the detail source', () {
      final int st1 = controller.th2File.mpIDByTHID('st1')!;

      controller.execute(
        MPSetOptionToElementCommand(
          toOption: THTextCommandOption(
            parentMPID: st1,
            textContent: 'Entrance',
          ),
        ),
      );
      expect(label('st1').detail, '1.3@main');

      controller.execute(
        MPEditPointTypeCommand(
          pointMPID: st1,
          newPointType: THPointType.label,
          unknownPLAType: '',
        ),
      );
      expect(label('st1').detail, 'Entrance');
      expect(rowText('st1'), contains('Entrance st1'));

      controller.execute(
        MPEditPointTypeCommand(
          pointMPID: st1,
          newPointType: THPointType.station,
          unknownPLAType: '',
        ),
      );
      expect(rowText('st1'), 'Point Station 1.3@main st1');

      controller.undo();
      expect(label('st1').detail, 'Entrance');
      controller.undo();
      expect(rowText('st1'), 'Point Station 1.3@main st1');
    });

    test('filtering matches station names and label or remark text', () {
      String? scrapOf(List<TH2ElementTreeRow> result) =>
          result.first.label.thID;

      for (final (String filter, String thID) in <(String, String)>[
        ('1.3@main', 'st1'),
        ('entrance', 'lb1'),
        ('deep', 'rm2'),
      ]) {
        ui().setFilterText(filter);

        final List<TH2ElementTreeRow> result = rows(filterActive: true);

        expect(scrapOf(result), 's1', reason: filter);
        expect(
          result.map((TH2ElementTreeRow row) => row.label.thID),
          contains(thID),
          reason: filter,
        );
      }

      ui().setFilterText('');
    });
  });

  group('row widget', () {
    late TH2TreeTestProject project;
    late TH2FileEditController controller;

    setUp(() {
      ui().setSidebarCollapsed(false);
      mpLocator.mpSettingsController.setBool(
        MPSettingID.Main_TelemetryConsent,
        false,
      );
      project = TH2TreeTestProject.create(aContents: _widgetContents);
      addTearDown(project.delete);
    });

    String rowIdOf(String thID) => th2ElementTreeRowId(
      th2FilePath: project.pathOf('a.th2'),
      elementMPID: controller.th2File.mpIDByTHID(thID)!,
    );

    Finder row(String thID) =>
        find.byKey(ValueKey('TH2ElementTreeRowWidget|${rowIdOf(thID)}'));

    TH2ElementTreeLabel labelOf(String thID) => TH2ElementTreeAux.buildLabel(
      controller.th2File.elementByMPID(controller.th2File.mpIDByTHID(thID)!),
    );

    List<String> pointOrder() {
      final THScrap scrap = controller.th2File.getScraps().first;

      return scrap.childrenMPIDs
          .where((int id) => controller.th2File.elementByMPID(id) is THPoint)
          .map((int id) => controller.th2File.thidByMPID(id))
          .toList();
    }

    Future<void> pumpTree(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(buildTH2TreeTestApp());
      await openTH2TreeProject(tester, project);
      await tester.tap(
        find.byKey(
          ValueKey(
            'THProjectTreeNodeChevron|${th2NodeOf(project, 'a.th2').id}',
          ),
        ),
      );
      await tester.pump();
      controller = (await settleTH2Load(tester, project.pathOf('a.th2')))!;
      await tester.pump();
    }

    testWidgets('spans are kind/type, italic detail, then muted id', (
      WidgetTester tester,
    ) async {
      await pumpTree(tester);

      final RichText richText = tester.widget<RichText>(
        find.descendant(of: row('p1'), matching: find.byType(RichText)).first,
      );
      final List<InlineSpan> spans = (richText.text as TextSpan).children!
          .cast<TextSpan>()
          .first
          .children!;
      final TextSpan primary = spans[0] as TextSpan;
      final TextSpan detail = spans[1] as TextSpan;
      final TextSpan id = spans[2] as TextSpan;
      final ColorScheme colorScheme = Theme.of(
        tester.element(row('p1')),
      ).colorScheme;

      expect(spans, hasLength(3));
      expect(primary.text, labelOf('p1').primaryText);
      expect(detail.text, ' 1.3@main');
      expect(detail.style?.fontStyle, FontStyle.italic);
      expect(detail.style?.color, isNull);
      expect(id.text, ' p1');
      expect(id.style?.color, colorScheme.onSurfaceVariant);
      expect(primary.style?.color, isNull);
    });

    testWidgets('only multi-line texts get a tooltip, shown on hover', (
      WidgetTester tester,
    ) async {
      await pumpTree(tester);

      final Finder p2Tooltip = find.byKey(
        ValueKey('TH2ElementTreeLabelTooltip|${rowIdOf('p2')}'),
      );

      expect(p2Tooltip, findsOneWidget);
      expect(tester.widget<Tooltip>(p2Tooltip).message, 'Main\nentrance');
      expect(tester.widget<Tooltip>(p2Tooltip).excludeFromSemantics, isTrue);
      for (final String thID in <String>['p1', 'p3']) {
        expect(
          find.descendant(of: row(thID), matching: find.byType(Tooltip)),
          findsNothing,
          reason: thID,
        );
      }

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(p2Tooltip));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Main\nentrance'), findsOneWidget);
    });

    testWidgets('the semantics label equals the plain text', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pumpTree(tester);

      for (final String thID in <String>['p1', 'p2', 'p3']) {
        expect(
          find.bySemanticsLabel(labelOf(thID).plainText),
          findsOneWidget,
          reason: thID,
        );
      }
      expect(find.bySemanticsLabel('Main\nentrance'), findsNothing);

      semantics.dispose();
    });

    testWidgets('tap and right-click on a tooltip row behave as before', (
      WidgetTester tester,
    ) async {
      await pumpTree(tester);

      final int p2 = controller.th2File.mpIDByTHID('p2')!;

      await tester.tap(row('p2'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        controller.selectionController.mpSelectedElementsLogical.keys,
        <int>[p2],
      );

      await tester.tap(row('p3'), buttons: kSecondaryButton);
      await tester.pump();
      await tester.pump();
      expect(
        controller.selectionController.mpSelectedElementsLogical.keys,
        contains(controller.th2File.mpIDByTHID('p3')),
      );
      expect(
        find.byKey(
          ValueKey('THProjectTreeRowContextMenuBringForward|${rowIdOf('p3')}'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a tooltip row can be dragged', (WidgetTester tester) async {
      await pumpTree(tester);
      expect(pointOrder(), <String>['p1', 'p2', 'p3']);

      final Offset target = tester.getCenter(row('p1')) + const Offset(0, -6);

      await tester.dragFrom(
        tester.getCenter(row('p2')),
        target - tester.getCenter(row('p2')),
      );
      await tester.pumpAndSettle();
      expect(pointOrder(), <String>['p2', 'p1', 'p3']);
    });

    testWidgets('holding a tooltip row still, then dragging, still drags', (
      WidgetTester tester,
    ) async {
      await pumpTree(tester);
      expect(pointOrder(), <String>['p1', 'p2', 'p3']);

      final Offset start = tester.getCenter(row('p2'));
      final Offset target = tester.getCenter(row('p1')) + const Offset(0, -6);
      final TestGesture gesture = await tester.startGesture(start);

      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 200));
      for (int step = 1; step <= 5; step++) {
        await gesture.moveTo(Offset.lerp(start, target, step / 5)!);
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(pointOrder(), <String>['p2', 'p1', 'p3']);

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(
        tester.getCenter(
          find.byKey(ValueKey('TH2ElementTreeLabelTooltip|${rowIdOf('p2')}')),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Main\nentrance'), findsOneWidget);
    });
  });
}
