// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller_operations.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mapiah/src/widgets/mp_therion_run_dialog_widget.dart';
import 'package:path/path.dart' as p;

import 'th_test_aux.dart';

class _FakeTherionRunner extends MPTherionRunner {
  _FakeTherionRunner() : super(thConfigFilePath: '/tmp/dummy');

  @override
  Future<void> start() async {
    statusNotifier.value = MPTherionRunStatus.error;
    outputLinesNotifier.value = <String>[
      'first line',
      'warning happened here',
      'error happened here',
    ];
    issuesNotifier.value = <MPTherionIssue>[
      MPTherionIssue(
        kind: MPTherionIssueKind.warning,
        lineIndex: 1,
        lineText: 'warning happened here',
      ),
      MPTherionIssue(
        kind: MPTherionIssueKind.error,
        lineIndex: 2,
        lineText: 'error happened here',
      ),
    ];
    isRunningNotifier.value = false;
  }

  @override
  void stop() {}
}

/// A runner that only records its starts and finishes at once.
class _CountingTherionRunner extends _FakeTherionRunner {
  int startCount = 0;

  @override
  Future<void> start() {
    startCount++;

    return super.start();
  }
}

const String _brokenTH2Contents =
    'encoding utf-8\n'
    'point 1 1 station\n';

/// Duplicate scrap ids make the load throw, recording a load error.
const String _loadErrorTH2Contents =
    'encoding utf-8\n'
    'scrap a\n'
    'endscrap\n'
    'scrap a\n'
    'endscrap\n';

const String _validTH2Contents =
    'encoding utf-8\n'
    'scrap s1 -projection plan\n'
    'endscrap\n';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  // Create the settings controller outside any fake-async test zone, so
  // its initialization completes for every test.
  setUpAll(() async {
    await mpLocator.mpSettingsController.initialized;
  });

  group('UI: therion run dialog', () {
    tearDown(() {
      mpLocator.thProjectController.closeProject();
    });

    testWidgets(
      'keeps multiline selection setup and issue jump list available',
      (WidgetTester tester) async {
        mpLocator.appLocalizations = AppLocalizationsEn();

        final _FakeTherionRunner fakeRunner = _FakeTherionRunner();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MPRunTherionDialogWidget(
                therionExecutablePath: 'therion',
                thConfigFilePath: '/tmp/test-project.thconfig',
                therionRunner: fakeRunner,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('THConfig file: test-project.thconfig'),
          findsOneWidget,
        );
        expect(find.byType(SelectionArea), findsOneWidget);
        expect(find.byType(SelectableText), findsNothing);

        final Finder outputTextFinder = find.byWidgetPredicate((Widget widget) {
          if (widget is! Text) {
            return false;
          }

          final InlineSpan? textSpan = widget.textSpan;
          if (textSpan == null) {
            return false;
          }

          final String plainText = textSpan.toPlainText();

          return plainText.contains('first line\nwarning happened here');
        });
        expect(outputTextFinder, findsOneWidget);

        expect(find.text('warning: warning happened here'), findsOneWidget);
        expect(find.text('error: error happened here'), findsOneWidget);

        final Finder errorStatusContainerFinder = find.byWidgetPredicate((
          Widget widget,
        ) {
          if (widget is! Container) {
            return false;
          }

          final Decoration? decoration = widget.decoration;

          if (decoration is! BoxDecoration) {
            return false;
          }

          return decoration.color == mpTherionRunStatusBackgroundErrorColor;
        });

        expect(errorStatusContainerFinder, findsOneWidget);

        await tester.tap(find.text('warning: warning happened here'));
        await tester.pumpAndSettle();

        expect(outputTextFinder, findsOneWidget);
      },
    );

    testWidgets('stops the elapsed timer when the first run finishes quickly', (
      WidgetTester tester,
    ) async {
      mpLocator.appLocalizations = AppLocalizationsEn();

      final _FakeTherionRunner fakeRunner = _FakeTherionRunner();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MPRunTherionDialogWidget(
              therionExecutablePath: 'therion',
              thConfigFilePath: '/tmp/dummy',
              therionRunner: fakeRunner,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Elapsed time:'), findsOneWidget);

      final Text initialElapsedText = tester.widget<Text>(
        find.textContaining('Elapsed time:'),
      );
      final String initialElapsedValue = initialElapsedText.data!;

      await tester.pump(const Duration(seconds: 2));

      final Text finalElapsedText = tester.widget<Text>(
        find.textContaining('Elapsed time:'),
      );
      final String finalElapsedValue = finalElapsedText.data!;

      expect(finalElapsedValue, initialElapsedValue);
    });

    for (final LogicalKeyboardKey modifier in <LogicalKeyboardKey>[
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.metaLeft,
    ]) {
      testWidgets('$modifier+T does not close the dialog', (
        WidgetTester tester,
      ) async {
        mpLocator.appLocalizations = AppLocalizationsEn();
        mpLocator.thProjectController.rootConfigPath = '/tmp/dummy';

        final _FakeTherionRunner fakeRunner = _FakeTherionRunner();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MPRunTherionDialogWidget(
                therionExecutablePath: 'therion',
                thConfigFilePath: '/tmp/dummy',
                therionRunner: fakeRunner,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyDownEvent(modifier);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
        await tester.sendKeyUpEvent(modifier);
        await tester.pump();

        expect(find.byType(MPRunTherionDialogWidget), findsOneWidget);
      });
    }
  });

  group('UI: therion run dialog broken-file warning', () {
    final Finder warningFinder = find.byKey(
      const ValueKey<String>('MPRunTherionDialogBrokenFilesWarning'),
    );
    late Directory tempDir;

    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      mpLocator.thProjectController.closeProject();
      tempDir = Directory.systemTemp.createTempSync('mapiah_t3610_');
    });

    tearDown(() {
      mpLocator.mpGeneralController.reset();
      mpLocator.thProjectController.closeProject();
      mpLocator.thProjectController.setOperationsForTesting(
        THProjectControllerOperations.defaults(),
      );
      tempDir.deleteSync(recursive: true);
    });

    String canonical(String path) =>
        THProjectPathResolver.canonicalize(p.absolute(path));

    /// Writes [relativePath] under the temporary directory and returns its
    /// canonical path.
    String writeFile(String relativePath, String contents) {
      final File file = File(p.join(tempDir.path, relativePath));

      file.parent.createSync(recursive: true);
      file.writeAsStringSync(contents);

      return canonical(file.path);
    }

    /// Writes a project in [directory] whose survey inputs [th2Files]
    /// (written too, unless their contents are null) and returns its config.
    String writeProject(String directory, Map<String, String?> th2Files) {
      final StringBuffer survey = StringBuffer('survey main\n');

      for (final MapEntry<String, String?> entry in th2Files.entries) {
        survey.writeln('  input ${entry.key}');
        if (entry.value != null) {
          writeFile(p.join(directory, entry.key), entry.value!);
        }
      }
      survey.writeln('endsurvey');
      writeFile(p.join(directory, 'main.th'), survey.toString());

      return writeFile(
        p.join(directory, 'thconfig'),
        'encoding UTF-8\nsource main.th\n',
      );
    }

    String projectTH2Path(String directory, String name) =>
        canonical(p.join(tempDir.path, directory, name));

    Future<void> openProject(WidgetTester tester, String configPath) async {
      await tester.runAsync(
        () => mpLocator.thProjectController.openProject(configPath),
      );
      await tester.pump();
      expect(mpLocator.thProjectController.rootConfigPath, configPath);
    }

    /// Loads [path] in a tab-less controller, as expanding its tree row does.
    Future<TH2FileEditController> loadTH2(
      WidgetTester tester,
      String path,
    ) async {
      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      await tester.runAsync(() async {
        try {
          await controller.load();
        } on Object {
          // A load error stays recorded in the controller.
        }
      });

      return controller;
    }

    /// A window large enough for the dialog's fixed size, as on desktop.
    void useDesktopSurface(WidgetTester tester) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 900);
      addTearDown(tester.view.reset);
    }

    Future<_CountingTherionRunner> pumpDialog(
      WidgetTester tester,
      String configPath,
    ) async {
      final _CountingTherionRunner runner = _CountingTherionRunner();

      useDesktopSurface(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MPRunTherionDialogWidget(
              key: UniqueKey(),
              therionExecutablePath: 'therion',
              thConfigFilePath: configPath,
              therionRunner: runner,
            ),
          ),
        ),
      );
      await tester.pump();

      return runner;
    }

    List<String> warningPaths(WidgetTester tester) {
      return tester
          .widgetList<Text>(
            find.descendant(of: warningFinder, matching: find.byType(Text)),
          )
          .map((Text text) => text.data ?? '')
          .where((String text) => text.startsWith('/'))
          .toList();
    }

    testWidgets('no warning when no loaded project file is broken', (
      WidgetTester tester,
    ) async {
      final String config = writeProject('a', <String, String?>{
        'good.th2': _validTH2Contents,
      });

      await openProject(tester, config);
      await loadTH2(tester, projectTH2Path('a', 'good.th2'));

      expect(
        mpLocator.mpGeneralController.loadedBrokenProjectTH2FilePaths(),
        isEmpty,
      );

      final _CountingTherionRunner runner = await pumpDialog(tester, config);

      expect(runner.startCount, 1);
      expect(warningFinder, findsNothing);
    });

    testWidgets('lists a tab-less broken file while the run starts and ends', (
      WidgetTester tester,
    ) async {
      final String config = writeProject('a', <String, String?>{
        'bad.th2': _brokenTH2Contents,
        'good.th2': _validTH2Contents,
      });
      final String brokenPath = projectTH2Path('a', 'bad.th2');

      await openProject(tester, config);
      await loadTH2(tester, brokenPath);
      await loadTH2(tester, projectTH2Path('a', 'good.th2'));

      final _CountingTherionRunner runner = await pumpDialog(tester, config);

      expect(runner.startCount, 1);
      expect(warningFinder, findsOneWidget);
      expect(
        find.descendant(
          of: warningFinder,
          matching: find.text(
            'This loaded file of the project is broken. Therion may fail:',
          ),
        ),
        findsOneWidget,
      );
      expect(warningPaths(tester), <String>[brokenPath]);
      expect(
        find.descendant(of: warningFinder, matching: find.byType(SelectionArea)),
        findsOneWidget,
      );

      await tester.pumpAndSettle();

      expect(runner.isRunningNotifier.value, isFalse);
      expect(find.textContaining('error: error happened here'), findsOneWidget);
      expect(warningFinder, findsOneWidget);
    });

    testWidgets(
      'lists broken project files sorted, including open tabs, and excludes '
      'valid, load-error and standalone files',
      (WidgetTester tester) async {
        final String config = writeProject('a', <String, String?>{
          'zeta.th2': _brokenTH2Contents,
          'alpha.th2': _brokenTH2Contents,
          'good.th2': _validTH2Contents,
          'throws.th2': _loadErrorTH2Contents,
        });
        final String zetaPath = projectTH2Path('a', 'zeta.th2');
        final String alphaPath = projectTH2Path('a', 'alpha.th2');
        final String loadErrorPath = projectTH2Path('a', 'throws.th2');
        final String standalonePath = writeFile(
          'standalone.th2',
          _brokenTH2Contents,
        );

        await openProject(tester, config);
        await loadTH2(tester, zetaPath);
        await loadTH2(tester, alphaPath);
        await loadTH2(tester, projectTH2Path('a', 'good.th2'));

        final TH2FileEditController loadError = await loadTH2(
          tester,
          loadErrorPath,
        );
        final TH2FileEditController standalone = await loadTH2(
          tester,
          standalonePath,
        );

        mpLocator.mpGeneralController.addFileTab(zetaPath);

        expect(
          mpLocator.thProjectController.isProjectFile(loadErrorPath),
          isTrue,
        );
        expect(loadError.loadError, isNotNull);
        expect(standalone.isBroken, isTrue);
        expect(
          mpLocator.thProjectController.isProjectFile(standalonePath),
          isFalse,
        );

        await pumpDialog(tester, config);

        expect(
          find.descendant(
            of: warningFinder,
            matching: find.text(
              'These 2 loaded files of the project are broken. Therion may '
              'fail:',
            ),
          ),
          findsOneWidget,
        );
        expect(warningPaths(tester), <String>[alphaPath, zetaPath]);
      },
    );

    testWidgets('no warning when the run targets another config', (
      WidgetTester tester,
    ) async {
      final String config = writeProject('a', <String, String?>{
        'bad.th2': _brokenTH2Contents,
      });
      final String otherConfig = writeProject('b', <String, String?>{});

      await openProject(tester, config);
      await loadTH2(tester, projectTH2Path('a', 'bad.th2'));
      expect(
        mpLocator.mpGeneralController.loadedBrokenProjectTH2FilePaths(),
        hasLength(1),
      );

      final _CountingTherionRunner runner = await pumpDialog(
        tester,
        otherConfig,
      );

      expect(runner.startCount, 1);
      expect(warningFinder, findsNothing);
    });

    testWidgets('a long list stays bounded and leaves the output usable', (
      WidgetTester tester,
    ) async {
      const int fileCount = 40;
      final Map<String, String?> files = <String, String?>{
        for (int i = 0; i < fileCount; i++)
          'bad_${i.toString().padLeft(2, '0')}.th2': _brokenTH2Contents,
      };
      final String config = writeProject('a', files);

      await openProject(tester, config);
      for (final String name in files.keys) {
        await loadTH2(tester, projectTH2Path('a', name));
      }

      await pumpDialog(tester, config);
      await tester.pumpAndSettle();

      expect(
        tester.getSize(warningFinder).height,
        lessThanOrEqualTo(mpTherionRunBrokenFilesWarningMaxHeight),
      );
      expect(find.text('Output:'), findsOneWidget);
      expect(find.textContaining('error: error happened here'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a later dialog reflects a file that became valid', (
      WidgetTester tester,
    ) async {
      final String config = writeProject('a', <String, String?>{
        'bad.th2': _brokenTH2Contents,
      });
      final String brokenPath = projectTH2Path('a', 'bad.th2');

      await openProject(tester, config);
      await loadTH2(tester, brokenPath);
      await pumpDialog(tester, config);
      expect(warningPaths(tester), <String>[brokenPath]);

      File(brokenPath).writeAsStringSync(_validTH2Contents);
      await tester.runAsync(
        () => mpLocator.mpGeneralController.reloadTH2File(brokenPath),
      );

      // The open dialog keeps its opening snapshot.
      await tester.pump();
      expect(warningPaths(tester), <String>[brokenPath]);

      final TH2FileEditController reloaded = mpLocator.mpGeneralController
          .getTH2FileEditControllerIfExists(brokenPath)!;

      expect(reloaded.isBroken, isFalse);

      await pumpDialog(tester, config);
      expect(warningFinder, findsNothing);
    });

    testWidgets(
      'pick-and-run shows no warning for the outgoing project or a new one',
      (WidgetTester tester) async {
        final THProjectControllerOperations defaults =
            THProjectControllerOperations.defaults();
        int loadCount = 0;

        mpLocator.thProjectController.setOperationsForTesting(
          THProjectControllerOperations(
            loadProject:
                (
                  String rootFilePath, {
                  THProjectShape? expectedShape,
                  String? projectRootDirectory,
                  Map<String, THProjectContentOverride> contentOverrides =
                      const <String, THProjectContentOverride>{},
                }) {
                  loadCount++;
                  if (loadCount == 1) {
                    return defaults.loadProject(
                      rootFilePath,
                      expectedShape: expectedShape,
                      projectRootDirectory: projectRootDirectory,
                      contentOverrides: contentOverrides,
                    );
                  }

                  // Later loads never finish: the dialog must not wait for
                  // them or see the new project's files.
                  return Completer<THProjectLoadResult>().future;
                },
            parseFileContent: defaults.parseFileContent,
            spliceFileNodeChildren: defaults.spliceFileNodeChildren,
            readFileContent: defaults.readFileContent,
            serializeNode: defaults.serializeNode,
            writeBytes: defaults.writeBytes,
          ),
        );
        mpLocator.mpSettingsController.setTherionAvailableForTesting(true);

        final String configA = writeProject('a', <String, String?>{
          'bad.th2': _brokenTH2Contents,
        });
        final String configB = writeProject('b', <String, String?>{
          'bad.th2': _brokenTH2Contents,
        });
        final String brokenPath = projectTH2Path('a', 'bad.th2');

        await openProject(tester, configA);
        await loadTH2(tester, brokenPath);
        expect(
          mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
            brokenPath,
          ),
          isNotNull,
        );
        expect(
          mpLocator.mpGeneralController.loadedBrokenProjectTH2FilePaths(),
          <String>[brokenPath],
        );

        useDesktopSurface(tester);
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
        );

        final BuildContext context = tester.element(find.byType(Scaffold));

        for (final String pickedConfig in <String>[configA, configB]) {
          int starterCount = 0;

          await MPDialogAux.runTherionAndOpenProjectInBackground(
            context,
            pickedConfig,
            runTherionStarter:
                (
                  BuildContext runContext, {
                  required String thConfigFilePath,
                }) async {
                  starterCount++;
                  unawaited(
                    showDialog<void>(
                      context: runContext,
                      builder: (BuildContext dialogContext) =>
                          MPRunTherionDialogWidget(
                            therionExecutablePath: 'therion',
                            thConfigFilePath: thConfigFilePath,
                            therionRunner: _CountingTherionRunner(),
                          ),
                    ),
                  );
                },
          );
          await tester.pump();

          expect(starterCount, 1);
          expect(find.byType(MPRunTherionDialogWidget), findsOneWidget);
          expect(mpLocator.thProjectController.rootConfigPath, pickedConfig);
          expect(
            mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
              brokenPath,
            ),
            isNull,
          );
          expect(
            mpLocator.mpGeneralController.loadedBrokenProjectTH2FilePaths(),
            isEmpty,
          );
          expect(warningFinder, findsNothing);

          Navigator.of(
            tester.element(find.byType(MPRunTherionDialogWidget)),
          ).pop();
          await tester.pumpAndSettle();
        }

        expect(loadCount, 3);
      },
    );
  });
}
