// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_visible_row.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';

import 'th2_element_tree_test_aux.dart';
import 'th_test_aux.dart';

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }
  final MPLocator locator = MPLocator();
  late TH2TreeTestProject project;
  late TH2FileEditController controller;
  late String path;

  setUp(() async {
    locator.appLocalizations = AppLocalizationsEn();
    await locator.mpSettingsController.initialized;
    MPTextToUser.initialize();
    locator.thProjectController.closeProject();
    locator.mpGeneralController.reset();
    locator.thProjectTreeUIController.setFilterText('');
    locator.thProjectTreeUIController.expandedStandaloneTH2FileIds.clear();
    locator.thProjectTreeUIController.expandedNodeIds.clear();
    locator.thProjectTreeUIController.setSidebarCollapsed(false);
    locator.mpSettingsController.setBool(
      MPSettingID.Main_TelemetryConsent, false);
    project = TH2TreeTestProject.create();
    addTearDown(project.delete);
    path = project.pathOf('a.th2');
    controller = locator.mpGeneralController.getTH2FileEditController(
      filename: path);
    await controller.load();
  });

  Finder scrapRow(String thID) {
    final int id = controller.th2File.mpIDByTHID(thID)!;
    final String rowId = th2ElementTreeRowId(
      th2FilePath: path, elementMPID: id);
    return find.byKey(ValueKey('TH2ElementTreeRowWidget|$rowId'));
  }

  testWidgets('standalone row offers scrap actions and duplicate is undoable',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    locator.mpGeneralController.addFileTab(path);
    await tester.pumpWidget(buildTH2TreeTestApp());
    await tester.pump();
    expect(find.byKey(const ValueKey('TH2OutsideProjectHeaderRow')),
        findsOneWidget);
    expect(find.byKey(ValueKey(
      'THProjectTreeNodeWidget|${standaloneTH2FileRowId(path)}')),
      findsOneWidget);
    locator.thProjectTreeUIController.expand(standaloneTH2FileRowId(path));
    await tester.pump();
    await tester.tap(scrapRow('s1'), buttons: kSecondaryButton);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Duplicate'));
    await tester.pump();
    expect(controller.th2File.scrapMPIDs.length, 3);
    controller.undo();
    expect(controller.th2File.scrapMPIDs.length, 2);
    controller.redo();
    expect(controller.th2File.scrapMPIDs.length, 3);
  });

  test('visibility keeps the last scrap visible and ignores deleted scraps', () {
    final int first = controller.th2File.mpIDByTHID('s1')!;
    final int second = controller.th2File.mpIDByTHID('s2')!;
    controller.setActiveScrap(first);
    controller.hideElementController.setScrapsHidden(<int>[first, second], true);
    expect(controller.hideElementController.isScrapVisible(first), isTrue);
    expect(controller.hideElementController.isScrapVisible(second), isFalse);
    expect(controller.hideElementController.visibleScrapCount, 1);
    expect(controller.hideElementController.allScrapsVisible, isFalse);
    controller.elementEditController.removeScraps(<int>[second]);
    expect(controller.hideElementController.allScrapsVisible, isTrue);
    controller.undo();
    expect(controller.hideElementController.isScrapVisible(second), isFalse);
  });

  test('multi-scrap copy and duplicate preserve scrap selection', () {
    final int first = controller.th2File.mpIDByTHID('s1')!;
    final int second = controller.th2File.mpIDByTHID('s2')!;
    controller.selectionController.toggleSelectedScrap(first);
    controller.selectionController.toggleSelectedScrap(second);

    controller.copyPasteController.copyScraps(<int>[first, second]);
    expect(locator.mpGeneralController.getClipboard(), hasLength(2));
    expect(controller.selectionController.selectedScrapMPIDs,
        <int>{first, second});
    controller.copyPasteController.duplicateScraps(<int>[first, second]);
    expect(controller.th2File.scrapMPIDs.length, 4);
    expect(controller.selectionController.selectedScrapMPIDs,
        <int>{first, second});
    controller.undo();
    expect(controller.th2File.scrapMPIDs.length, 2);
    controller.redo();
    expect(controller.th2File.scrapMPIDs.length, 4);
  });

  test('multi-scrap deletion is one undo step with the original order', () {
    final int first = controller.th2File.mpIDByTHID('s1')!;
    final int second = controller.th2File.mpIDByTHID('s2')!;
    controller.elementEditController.removeScraps(<int>[first, second]);
    expect(controller.th2File.scrapMPIDs, isEmpty);
    controller.undo();
    expect(controller.th2File.scrapMPIDs, <int>[first, second]);
    controller.redo();
    expect(controller.th2File.scrapMPIDs, isEmpty);
  });

  testWidgets('scrap options edit the row target and reset on close',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    locator.mpGeneralController.addFileTab(path);
    await tester.pumpWidget(buildTH2TreeTestApp());
    locator.thProjectTreeUIController.expand(standaloneTH2FileRowId(path));
    await tester.pump();
    final int first = controller.th2File.mpIDByTHID('s1')!;
    final int pointID = controller.th2File.mpIDByTHID('p1')!;
    final THPoint point = controller.th2File.pointByMPID(pointID);
    controller.selectionController.setSelectedElements(<THElement>[point]);
    await tester.tap(scrapRow('s1'), buttons: kSecondaryButton);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Options…'));
    await tester.pump();
    expect(controller.optionEditController.optionsScrapMPID, first);
    expect(controller.overlayWindowController
        .getIsOverlayWindowShown(MPWindowType.scrapOptions), isTrue);

    controller.userInteractionController.prepareSetOption(
      option: THTitleCommandOption(parentMPID: first, titleText: 'Tree target'),
      optionType: THCommandOptionType.title);
    expect(controller.th2File.scrapByMPID(first)
        .hasOption(THCommandOptionType.title), isTrue);
    controller.userInteractionController.prepareSetOption(
      option: THAttrCommandOption(parentMPID: first,
        attrName: 'tree', attrValue: 'scrap'),
      optionType: THCommandOptionType.attr);
    expect(controller.th2File.scrapByMPID(first).hasAttrOption('tree'), isTrue);
    expect(controller.th2File.pointByMPID(pointID).hasAttrOption('tree'), isFalse);
    controller.userInteractionController.prepareUnsetAttrOption(attrName: 'tree');
    expect(controller.th2File.scrapByMPID(first).hasAttrOption('tree'), isFalse);
    controller.userInteractionController.prepareSetMultipleOptionChoice(
      optionType: THCommandOptionType.flip, choice: 'horizontal');
    expect(controller.th2File.scrapByMPID(first)
        .hasOption(THCommandOptionType.flip), isTrue);
    controller.userInteractionController.prepareSetMultipleOptionChoice(
      optionType: THCommandOptionType.flip, choice: mpUnsetOptionID);
    expect(controller.th2File.scrapByMPID(first)
        .hasOption(THCommandOptionType.flip), isFalse);
    expect(controller.selectionController.mpSelectedElementsLogical.keys,
        contains(pointID));
    controller.overlayWindowController.setShowOverlayWindow(
      MPWindowType.scrapOptions, false);
    expect(controller.optionEditController.optionsScrapMPID, -1);
    controller.userInteractionController.prepareSetOption(
      option: THAttrCommandOption(parentMPID: pointID,
        attrName: 'tree', attrValue: 'point'),
      optionType: THCommandOptionType.attr);
    expect(controller.th2File.pointByMPID(pointID).hasAttrOption('tree'), isTrue);
    expect(controller.th2File.scrapByMPID(first).hasAttrOption('tree'), isFalse);
  });

  test('project open migrates a standalone row and its selection', () async {
    final String standaloneId = standaloneTH2FileRowId(path);
    locator.mpGeneralController.addFileTab(path);
    locator.thProjectTreeUIController.expand(standaloneId);
    expect(locator.thProjectController.activeSelectedNodeId, standaloneId);

    await locator.thProjectController.openProject(project.configPath);
    final String projectId = th2NodeOf(project, 'a.th2').id;
    expect(locator.thProjectController.activeSelectedNodeId, projectId);
    expect(locator.thProjectTreeUIController.isExpanded(projectId), isTrue);
    expect(locator.thProjectTreeUIController.isExpanded(standaloneId), isFalse);
  });

  test('Save As migrates standalone expansion and collapsed scrap rows', () {
    final String newPath = project.pathOf('renamed.th2');
    final String oldId = standaloneTH2FileRowId(path);
    final String newId = standaloneTH2FileRowId(newPath);
    final int scrapID = controller.th2File.mpIDByTHID('s1')!;
    final String oldScrapId = th2ElementTreeRowId(
      th2FilePath: path, elementMPID: scrapID);
    final String newScrapId = th2ElementTreeRowId(
      th2FilePath: newPath, elementMPID: scrapID);
    locator.mpGeneralController.addFileTab(path);
    locator.thProjectTreeUIController.expand(oldId);
    locator.thProjectTreeUIController.toggleTH2ScrapCollapsed(oldScrapId);

    locator.mpGeneralController.renameFileController(
      oldFilename: path, newFilename: newPath);
    expect(locator.thProjectTreeUIController.isExpanded(oldId), isFalse);
    expect(locator.thProjectTreeUIController.isExpanded(newId), isTrue);
    expect(locator.thProjectTreeUIController.isTH2ScrapCollapsed(oldScrapId),
      isFalse);
    expect(locator.thProjectTreeUIController.isTH2ScrapCollapsed(newScrapId),
      isTrue);
    expect(locator.thProjectController.activeSelectedNodeId, newId);

    locator.mpGeneralController.removeFileTab(filename: newPath);
    expect(locator.thProjectTreeUIController.isExpanded(newId), isFalse);
    expect(locator.thProjectTreeUIController.isTH2ScrapCollapsed(newScrapId),
      isFalse);
  });

  test('outside tab keeps expansion, selection and scrap collapse across '
      'project changes', () async {
    final TH2TreeTestProject otherProject = TH2TreeTestProject.create();
    addTearDown(otherProject.delete);
    final String standaloneId = standaloneTH2FileRowId(path);
    final int scrapID = controller.th2File.mpIDByTHID('s1')!;
    final String scrapRowId = th2ElementTreeRowId(
      th2FilePath: path, elementMPID: scrapID);
    locator.mpGeneralController.addFileTab(path);
    locator.thProjectTreeUIController.expand(standaloneId);
    locator.thProjectTreeUIController.toggleTH2ScrapCollapsed(scrapRowId);

    await locator.thProjectController.openProject(otherProject.configPath);
    expect(locator.thProjectController.activeSelectedNodeId, standaloneId);
    expect(locator.thProjectTreeUIController.isExpanded(standaloneId), isTrue);
    expect(locator.thProjectTreeUIController.isTH2ScrapCollapsed(scrapRowId),
        isTrue);

    await locator.thProjectController.reloadProject();
    expect(locator.thProjectController.activeSelectedNodeId, standaloneId);
    expect(locator.thProjectTreeUIController.isExpanded(standaloneId), isTrue);
    expect(locator.thProjectTreeUIController.isTH2ScrapCollapsed(scrapRowId),
        isTrue);

    locator.thProjectController.closeProject();
    expect(locator.thProjectController.activeSelectedNodeId, standaloneId);
    expect(locator.thProjectTreeUIController.isExpanded(standaloneId), isTrue);
    expect(locator.thProjectTreeUIController.isTH2ScrapCollapsed(scrapRowId),
        isTrue);
  });
}
