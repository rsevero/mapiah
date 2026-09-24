// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_visible_row.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
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
  Finder row(String thID) {
    final int id = controller.th2File.mpIDByTHID(thID)!;
    return find.byKey(ValueKey('TH2ElementTreeRowWidget|'
      '${th2ElementTreeRowId(th2FilePath: project.pathOf('a.th2'),
        elementMPID: id)}'));
  }
  List<String> movableOrder() {
    final THScrap scrap = controller.th2File.scrapByMPID(
      controller.th2File.mpIDByTHID('s1')!);
    return scrap.childrenMPIDs.where((int id) =>
      (controller.th2File.elementByMPID(id) is THPoint ||
        controller.th2File.elementByMPID(id) is THLine)).map((int id) =>
      controller.th2File.thidByMPID(id)).toList();
  }
  setUp(() async {
    locator.appLocalizations = AppLocalizationsEn();
    await locator.mpSettingsController.initialized;
    MPTextToUser.initialize();
    locator.thProjectController.closeProject();
    locator.mpGeneralController.reset();
    locator.thProjectTreeUIController.setFilterText('');
    locator.thProjectTreeUIController.expandedNodeIds.clear();
    locator.thProjectTreeUIController.collapsedTH2ScrapIds.clear();
    locator.thProjectTreeUIController.setSidebarCollapsed(false);
    locator.mpSettingsController.setBool(
      MPSettingID.Main_TelemetryConsent, false);
    project = TH2TreeTestProject.create();
    addTearDown(project.delete);
  });

  testWidgets('right-click selects and Bring forward is undoable',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TH2FileTabsPage()));
    await openTH2TreeProject(tester, project);
    await tester.tap(find.byKey(ValueKey('THProjectTreeNodeChevron|'
      '${th2NodeOf(project, 'a.th2').id}')));
    await tester.pump();
    controller = (await settleTH2Load(tester, project.pathOf('a.th2')))!;
    expect(movableOrder(), <String>['p1', 'l1', 'p3']);
    await tester.tap(row('p1'), buttons: kSecondaryButton);
    await tester.pump();
    await tester.pump();
    expect(locator.mpGeneralController.openFileOrder, isEmpty);
    expect(controller.selectionController.mpSelectedElementsLogical.keys,
      contains(controller.th2File.mpIDByTHID('p1')));
    final String rowId = th2ElementTreeRowId(
      th2FilePath: project.pathOf('a.th2'),
      elementMPID: controller.th2File.mpIDByTHID('p1')!);
    await tester.tap(find.byKey(ValueKey(
      'THProjectTreeRowContextMenuBringForward|$rowId')));
    await tester.pump();
    expect(movableOrder(), <String>['l1', 'p1', 'p3']);
    expect(locator.mpGeneralController.openFileOrder,
      contains(project.pathOf('a.th2')));
    controller.undo();
    expect(movableOrder(), <String>['p1', 'l1', 'p3']);
  });
}
