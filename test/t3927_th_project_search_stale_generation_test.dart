// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_project_search_controller.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_scope.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path/path.dart' as p;

import 'th_project_controller_test_aux.dart';
import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  Directory? tempDirA;
  Directory? tempDirB;
  THProjectController? projectController;
  MPGeneralController? generalController;
  THProjectSearchController? searchController;

  Future<void> boot() async {
    tempDirA = THProjectControllerTestAux.copyFixtureToTemp('multiple-sources');
    projectController = THProjectController();
    generalController = MPGeneralController();
    await projectController!.openProject(p.join(tempDirA!.path, 'thconfig'));
    searchController = THProjectSearchController(
      projectController: projectController,
      generalController: generalController,
    );
    searchController!.setScope(THProjectSearchScope.projectFiles);
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
    for (final Directory? dir in <Directory?>[tempDirA, tempDirB]) {
      if ((dir != null) && dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    }
    tempDirA = null;
    tempDirB = null;
  });

  test('an immediate submit reflects the latest query, not an earlier one', () async {
    await boot();
    searchController!.setQuery('survey'); // schedules a debounce
    searchController!.setQuery('endsurvey'); // supersedes it
    await searchController!.submitQuery();

    expect(searchController!.query, 'endsurvey');
    expect(searchController!.totalMatchCount, 2); // "endsurvey" once per .th
  });

  test('a search in flight when the project closes does not publish', () async {
    await boot();
    searchController!.setQuery('survey');

    final Future<void> inFlight = searchController!.runSearch();
    projectController!.closeProject();
    await inFlight;

    expect(searchController!.results, isEmpty);
    expect(searchController!.isSearching, isFalse);
  });

  test('no result or failure from project A leaks into project B', () async {
    await boot();
    searchController!.setQuery('survey');
    await searchController!.submitQuery();
    expect(searchController!.results, isNotEmpty);

    tempDirB = THProjectControllerTestAux.copyFixtureToTemp('multiple-sources');
    await projectController!.openProject(p.join(tempDirB!.path, 'thconfig'));

    // The lifecycle reaction cleared results; a stale late search must not
    // repopulate them.
    expect(searchController!.results, isEmpty);
    expect(searchController!.failures, isEmpty);
    expect(searchController!.query, 'survey');

    await searchController!.submitQuery();
    expect(
      searchController!.results.every(
        (r) => r.canonicalPath.startsWith(tempDirB!.path),
      ),
      isTrue,
    );
  });

  test('clearForProjectChange invalidates replacement eligibility', () async {
    await boot();
    searchController!.setQuery('survey');
    await searchController!.submitQuery();
    expect(searchController!.canReplaceAll, isTrue);

    projectController!.closeProject();

    expect(searchController!.canReplaceAll, isFalse);
  });
}
