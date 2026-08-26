// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  final String fixtureRoot = p.join(
    Directory.current.path,
    'test',
    'auxiliary',
    'th_project',
  );

  String fixturePath(String relativePath) => p.join(fixtureRoot, relativePath);

  String canonicalPath(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  Future<BuildContext> pumpAndGetContext(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
    await tester.pump();

    return tester.element(find.byType(Scaffold));
  }

  setUpAll(() async {
    await mpLocator.mpSettingsController.initialized;
  });

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
    mpLocator.thProjectController.closeProject();
  });

  tearDown(() {
    mpLocator.mpGeneralController.reset();
    mpLocator.thProjectController.closeProject();
  });

  group('MPDialogAux.closeOpenProject', () {
    testWidgets('no-ops when no project is loaded', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpAndGetContext(tester);

      MPDialogAux.closeOpenProject(context);
      await tester.pump();

      expect(mpLocator.thProjectController.rootConfigPath, isEmpty);
    });

    testWidgets(
      'resets project state and closes project tabs, leaving unrelated tabs open',
      (WidgetTester tester) async {
        final BuildContext context = await pumpAndGetContext(tester);
        final String thconfigPath = fixturePath('multiple-sources/thconfig');
        final String caveOnePath = canonicalPath(
          fixturePath('multiple-sources/cave_one.th'),
        );

        await tester.runAsync(() async {
          await mpLocator.thProjectController.openProject(thconfigPath);
          await mpLocator.mpGeneralController
              .getTextEditorController(caveOnePath)
              .loadFile(caveOnePath);
        });
        await tester.pump();

        expect(mpLocator.thProjectController.rootConfigPath, isNotEmpty);

        mpLocator.mpGeneralController.addFileTab(caveOnePath);

        final String standaloneTH2Path = canonicalPath(
          p.join(Directory.systemTemp.path, 'unrelated_standalone.th2'),
        );

        mpLocator.mpGeneralController.addFileTab(standaloneTH2Path);

        expect(
          mpLocator.mpGeneralController.openFileOrder,
          containsAll(<String>[caveOnePath, standaloneTH2Path]),
        );

        MPDialogAux.closeOpenProject(context);
        await tester.pump();

        expect(mpLocator.thProjectController.rootConfigPath, isEmpty);
        expect(mpLocator.thProjectController.projectRootNode, isNull);
        expect(
          mpLocator.mpGeneralController.openFileOrder,
          isNot(contains(caveOnePath)),
        );
        expect(
          mpLocator.mpGeneralController.openFileOrder,
          contains(standaloneTH2Path),
        );
      },
    );
  });
}
