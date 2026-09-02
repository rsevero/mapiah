// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_project_search_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_preflight.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_replace_result.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_scope.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path/path.dart' as p;

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  // The Replace All pipeline drives real `THTextEditorController`s, which bind
  // to `MPLocator().thProjectController`, so the project must be opened on that
  // singleton (not an injected copy).
  final THProjectController projectController = MPLocator().thProjectController;
  final MPGeneralController generalController = MPLocator().mpGeneralController;

  Directory? tempDir;
  Directory? outsideDir;
  THProjectSearchController? searchController;

  Future<void> boot() async {
    tempDir = Directory.systemTemp.createTempSync('mapiah_replace_all_');
    File(p.join(tempDir!.path, 'thconfig')).writeAsStringSync(
      'encoding UTF-8\nsource a.th\nsource b.th\n# marker line\n',
    );
    File(
      p.join(tempDir!.path, 'a.th'),
    ).writeAsStringSync('survey a\n# marker here\nendsurvey\n');
    File(
      p.join(tempDir!.path, 'b.th'),
    ).writeAsStringSync('survey b\n# another marker line\nendsurvey\n');

    await projectController.openProject(p.join(tempDir!.path, 'thconfig'));
    searchController = THProjectSearchController();
  }

  Future<THTextEditorController> openTab(String path) async {
    final THTextEditorController controller = generalController
        .getTextEditorController(path);
    generalController.addFileTab(path);
    await controller.loadFile(path);
    return controller;
  }

  setUp(() {
    MPLocator().appLocalizations = AppLocalizationsEn();
  });

  tearDown(() {
    searchController?.dispose();
    searchController = null;
    projectController.closeProject();
    generalController.reset();
    for (final Directory? dir in <Directory?>[tempDir, outsideDir]) {
      if ((dir != null) && dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    }
    tempDir = null;
    outsideDir = null;
  });

  test('replaces every eligible match across project files and saves', () async {
    await boot();
    searchController!.setScope(THProjectSearchScope.projectFiles);
    searchController!.setQuery('marker');
    searchController!.setReplacement('flag');
    await searchController!.submitQuery();

    expect(searchController!.replaceEligibleMatchCount, 3);
    expect(searchController!.replaceEligibleFileCount, 3);

    final THProjectSearchReplacePreflight? preflight = await searchController!
        .prepareReplaceAll();
    expect(preflight, isNotNull);
    expect(preflight!.eligibleFileCount, 3);
    expect(preflight.eligibleMatchCount, 3);

    final THProjectSearchReplaceReport report = await searchController!
        .executeReplaceAll(preflight);

    expect(report.completedFileCount, 3);
    expect(report.completedMatchCount, 3);
    expect(report.failed, isEmpty);
    expect(report.skipped, isEmpty);

    expect(
      File(p.join(tempDir!.path, 'thconfig')).readAsStringSync(),
      contains('# flag line'),
    );
    expect(
      File(p.join(tempDir!.path, 'a.th')).readAsStringSync(),
      contains('# flag here'),
    );
    expect(
      File(p.join(tempDir!.path, 'b.th')).readAsStringSync(),
      contains('# another flag line'),
    );

    await searchController!.submitQuery();
    expect(searchController!.totalMatchCount, 0);
  });

  test('standalone tab excluded; project-backed open tab replaced', () async {
    await boot();
    final String aPath = p.join(tempDir!.path, 'a.th');
    await openTab(aPath);

    outsideDir = Directory.systemTemp.createTempSync('mapiah_standalone_');
    final File standalone = File(p.join(outsideDir!.path, 'notes.th'))
      ..writeAsStringSync('# marker standalone\n');
    await openTab(standalone.path);

    searchController!.setScope(THProjectSearchScope.openTextTabs);
    searchController!.setQuery('marker');
    searchController!.setReplacement('flag');
    await searchController!.submitQuery();

    expect(searchController!.standaloneFileCount, 1);
    expect(searchController!.replaceEligibleMatchCount, 1);

    final THProjectSearchReplacePreflight preflight =
        (await searchController!.prepareReplaceAll())!;
    expect(preflight.eligibleFileCount, 1);
    expect(preflight.excludedStandaloneFileCount, 1);

    final THProjectSearchReplaceReport report = await searchController!
        .executeReplaceAll(preflight);

    expect(report.completedFileCount, 1);
    expect(File(aPath).readAsStringSync(), contains('# flag here'));
    expect(standalone.readAsStringSync(), '# marker standalone\n');
  });

  test('a concurrent edit after preflight skips the target as contentChanged', () async {
    await boot();
    searchController!.setScope(THProjectSearchScope.projectFiles);
    searchController!.setQuery('marker');
    searchController!.setReplacement('flag');
    await searchController!.submitQuery();

    final THProjectSearchReplacePreflight preflight =
        (await searchController!.prepareReplaceAll())!;

    projectController.registerTextContentChange(
      canonicalPath: p.join(tempDir!.path, 'a.th'),
      content: 'survey a\n# marker here changed\nendsurvey\n',
      expectedProjectEpoch: projectController.projectEpoch,
      expectedRootPath: projectController.rootConfigPath,
    );

    final THProjectSearchReplaceReport report = await searchController!
        .executeReplaceAll(preflight);

    expect(
      report.skipped.any(
        (THProjectSearchReplaceOutcome o) =>
            o.canonicalPath.endsWith('a.th') &&
            o.skipReason == THProjectSearchReplaceSkipReason.contentChanged,
      ),
      isTrue,
    );
    expect(report.completedFileCount, 2);
  });

  test('prepareReplaceAll returns null when only standalone matches exist', () async {
    await boot();
    outsideDir = Directory.systemTemp.createTempSync('mapiah_standalone_only_');
    final File standalone = File(p.join(outsideDir!.path, 'only.th'))
      ..writeAsStringSync('# marker only\n');
    await openTab(standalone.path);

    searchController!.setScope(THProjectSearchScope.openTextTabs);
    searchController!.setQuery('marker only');
    await searchController!.submitQuery();

    expect(searchController!.replaceEligibleMatchCount, 0);
    expect(await searchController!.prepareReplaceAll(), isNull);
  });
}
