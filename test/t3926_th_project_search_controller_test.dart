// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_project_search_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_file_result.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_scope.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

import 'th_project_controller_test_aux.dart';
import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  Directory? tempDir;
  THProjectController? projectController;
  MPGeneralController? generalController;
  THProjectSearchController? searchController;

  String canonical(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  Future<void> openFixture() async {
    tempDir = THProjectControllerTestAux.copyFixtureToTemp('multiple-sources');
    projectController = THProjectController();
    generalController = MPGeneralController();
    await projectController!.openProject(p.join(tempDir!.path, 'thconfig'));
    searchController = THProjectSearchController(
      projectController: projectController,
      generalController: generalController,
    );
  }

  Future<THTextEditorController> openTab(String path) async {
    final THTextEditorController controller = generalController!
        .getTextEditorController(path);
    generalController!.addFileTab(path);
    await controller.loadFile(path);
    return controller;
  }

  setUp(() {
    MPLocator().appLocalizations = AppLocalizationsEn();
  });

  tearDown(() {
    searchController?.dispose();
    searchController = null;
    generalController?.reset();
    generalController = null;
    projectController = null;
    final Directory? dir = tempDir;
    if ((dir != null) && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    tempDir = null;
  });

  group('project-files scope source collection', () {
    test('finds each project file once with correct eligibility', () async {
      await openFixture();
      searchController!.setScope(THProjectSearchScope.projectFiles);
      searchController!.setQuery('survey');
      await searchController!.submitQuery();

      final List<THProjectSearchFileResult> results = searchController!.results;

      // thconfig + cave_one.th + cave_two.th; "survey" appears in the two .th
      // files ("survey"/"endsurvey") and not in thconfig.
      expect(results.map((r) => r.canonicalPath).toSet().length, results.length);
      expect(results.length, 2);
      expect(results.every((r) => r.isReplaceEligible), isTrue);
      expect(searchController!.totalMatchCount, 4);
    });

    test('is deterministically ordered by display path', () async {
      await openFixture();
      searchController!.setScope(THProjectSearchScope.projectFiles);
      searchController!.setQuery('survey');
      await searchController!.submitQuery();

      final List<String> order = searchController!.results
          .map((r) => r.displayPath.toLowerCase())
          .toList();
      final List<String> sorted = List<String>.of(order)..sort();

      expect(order, sorted);
    });

    test('unsaved editor content takes precedence over disk', () async {
      await openFixture();
      final String caveOne = p.join(tempDir!.path, 'cave_one.th');
      final THTextEditorController editor = await openTab(caveOne);
      editor.setContent('survey one\nSURVEYX marker\nendsurvey');
      editor.cancelPendingReparse();

      searchController!.setScope(THProjectSearchScope.projectFiles);
      searchController!.setQuery('SURVEYX');
      await searchController!.submitQuery();

      final THProjectSearchFileResult? hit = searchController!.results
          .where((r) => r.canonicalPath == canonical(caveOne))
          .cast<THProjectSearchFileResult?>()
          .firstWhere((r) => r != null, orElse: () => null);

      expect(hit, isNotNull);
      expect(hit!.matches, hasLength(1));
    });
  });

  group('open-tabs scope source collection', () {
    test('excludes .th2 tabs and reports project-backed eligibility', () async {
      await openFixture();
      final String caveOne = p.join(tempDir!.path, 'cave_one.th');
      await openTab(caveOne);
      generalController!.addFileTab(p.join(tempDir!.path, 'drawing.th2'));

      searchController!.setScope(THProjectSearchScope.openTextTabs);
      searchController!.setQuery('survey');
      await searchController!.submitQuery();

      expect(searchController!.results, hasLength(1));
      expect(searchController!.results.single.canonicalPath, canonical(caveOne));
      expect(searchController!.results.single.isReplaceEligible, isTrue);
    });

    test('a tab outside the project is a search-only result', () async {
      await openFixture();
      final Directory outside = Directory.systemTemp.createTempSync(
        'mapiah_standalone_',
      );
      addTearDown(() => outside.deleteSync(recursive: true));
      final File standalone = File(p.join(outside.path, 'notes.th'))
        ..writeAsStringSync('survey standalone\nendsurvey');

      await openTab(standalone.path);

      searchController!.setScope(THProjectSearchScope.openTextTabs);
      searchController!.setQuery('standalone');
      await searchController!.submitQuery();

      final THProjectSearchFileResult result = searchController!.results.single;
      expect(result.canonicalPath, canonical(standalone.path));
      expect(result.isReplaceEligible, isFalse);
      expect(result.searchedRevision, isNull);
      expect(searchController!.replaceEligibleMatchCount, 0);
      expect(searchController!.standaloneMatchCount, 1);
    });
  });

  group('states', () {
    test('empty query clears results', () async {
      await openFixture();
      searchController!.setScope(THProjectSearchScope.projectFiles);
      searchController!.setQuery('survey');
      await searchController!.submitQuery();
      expect(searchController!.results, isNotEmpty);

      searchController!.setQuery('');
      await searchController!.submitQuery();
      expect(searchController!.results, isEmpty);
    });

    test('no matches yields an empty result set and no failures', () async {
      await openFixture();
      searchController!.setScope(THProjectSearchScope.projectFiles);
      searchController!.setQuery('zzz-not-present');
      await searchController!.submitQuery();

      expect(searchController!.results, isEmpty);
      expect(searchController!.failures, isEmpty);
    });

    test('project close switches project scope to open-tabs', () async {
      await openFixture();
      searchController!.setScope(THProjectSearchScope.projectFiles);
      searchController!.setQuery('survey');
      await searchController!.submitQuery();

      projectController!.closeProject();

      expect(searchController!.scope, THProjectSearchScope.openTextTabs);
      expect(searchController!.results, isEmpty);
      expect(searchController!.query, 'survey');
    });
  });
}
