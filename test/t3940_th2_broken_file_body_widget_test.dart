// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:mapiah/src/widgets/th2_broken_file_body_widget.dart';
import 'package:mapiah/src/widgets/th2_file_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'th2_file_tabs_page_test_aux.dart';
import 'th_test_aux.dart';

const String _brokenContents =
    'encoding utf-8\n'
    'point 10 20 station -name 1\n'
    'scrap s1\n'
    '  point 30 40 station -name 2\n'
    '  poin 150 250 station -name 3\n'
    'endscrap\n';

const String _fixedContents =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 30 40 station -name 2\n'
    'endscrap\n';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  late Directory tempDir;
  late String filename;

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
    await mpLocator.mpSettingsController.initialized;
    tempDir = Directory.systemTemp.createTempSync('mapiah_t3940_');
    filename = p.join(tempDir.path, 'broken.th2');
    File(filename).writeAsStringSync(_brokenContents);
  });

  tearDown(() {
    mpLocator.mpGeneralController.reset();
    tempDir.deleteSync(recursive: true);
  });

  /// Loads the broken file and mounts it in a tab of the tabs page.
  Future<TH2FileEditController> pumpBrokenTab(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final TH2FileEditController controller = mpLocator.mpGeneralController
        .getTH2FileEditController(filename: filename);

    await tester.runAsync(() => controller.load());
    await tester.pumpWidget(
      buildTH2FileTabsPageTestApp(th2FileEditController: controller),
    );
    await tester.pump();
    await tester.pump();

    return controller;
  }

  /// Lets the real file I/O started by a Reload finish and rebuilds.
  Future<void> pumpUntilLoaded(WidgetTester tester) async {
    for (int attempt = 0; attempt < 20; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();

      final TH2FileEditController? controller = mpLocator.mpGeneralController
          .getTH2FileEditControllerIfExists(filename);

      if ((controller != null) && controller.isFileLoaded) {
        break;
      }
    }

    await tester.pump();
  }

  testWidgets('a broken file shows the panel and not the canvas', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = await pumpBrokenTab(tester);

    expect(controller.isBroken, isTrue);
    expect(find.byType(TH2BrokenFileBodyWidget), findsOneWidget);
    expect(find.byType(TH2FileWidget), findsNothing);
    expect(
      controller.problems.map((TH2FileProblem problem) => problem.kind),
      <TH2FileProblemKind>[
        TH2FileProblemKind.plaOutsideScrap,
        TH2FileProblemKind.parseError,
      ],
    );
    expect(find.textContaining('Line 2:'), findsOneWidget);
    expect(find.textContaining('Line 5:'), findsOneWidget);
    expect(find.text(mpLocator.appLocalizations.parsingWarnings), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('a broken file is never dirty and Save As is disabled', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = await pumpBrokenTab(tester);
    final Finder saveAsButton = find.ancestor(
      of: find.byIcon(Icons.save_as_outlined),
      matching: find.byType(IconButton),
    );

    expect(controller.enableSaveButton, isFalse);
    expect(
      mpLocator.thProjectController.dirtyFilePaths,
      isNot(contains(filename)),
    );
    expect(saveAsButton, findsOneWidget);
    expect(tester.widget<IconButton>(saveAsButton).onPressed, isNull);
  });

  testWidgets('closing a broken tab does not prompt', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = await pumpBrokenTab(tester);

    controller.close();
    await tester.pump();
    await tester.pump();

    expect(find.byType(AlertDialog), findsNothing);
    expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
  });

  testWidgets('Reload after fixing the file mounts the canvas', (
    WidgetTester tester,
  ) async {
    await pumpBrokenTab(tester);

    File(filename).writeAsStringSync(_fixedContents);

    await tester.tap(find.text('Reload'));
    await pumpUntilLoaded(tester);

    final TH2FileEditController reloaded = mpLocator.mpGeneralController
        .getTH2FileEditControllerIfExists(filename)!;

    expect(reloaded.isBroken, isFalse);
    expect(reloaded.activeScrapID, greaterThan(0));
    expect(reloaded.currentScrapName, 's1');
    expect(find.byType(TH2BrokenFileBodyWidget), findsNothing);
    expect(find.byType(TH2FileWidget), findsOneWidget);
  });
}
