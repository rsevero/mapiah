// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mapiah/src/widgets/mp_therion_run_dialog_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

class _FakeTherionRunner extends MPTherionRunner {
  _FakeTherionRunner(String thConfigFilePath, this._outputLines)
    : super(thConfigFilePath: thConfigFilePath);

  final List<String> _outputLines;

  @override
  Future<void> start() async {
    statusNotifier.value = MPTherionRunStatus.error;
    outputLinesNotifier.value = _outputLines;
    issuesNotifier.value = const <MPTherionIssue>[];
    isRunningNotifier.value = false;
  }

  @override
  void stop() {}
}

class _RerunnableFakeTherionRunner extends MPTherionRunner {
  _RerunnableFakeTherionRunner(String thConfigFilePath)
    : super(thConfigFilePath: thConfigFilePath);

  final Completer<void> secondRunCompletion = Completer<void>();
  int startCount = 0;

  @override
  Future<void> start() async {
    startCount++;
    isRunningNotifier.value = true;

    if (startCount == 1) {
      statusNotifier.value = MPTherionRunStatus.error;
      outputLinesNotifier.value = <String>[
        'therion: error -- cave.th [line 3] -- first error',
      ];
      isRunningNotifier.value = false;

      return;
    }

    outputLinesNotifier.value = <String>[];
    statusNotifier.value = MPTherionRunStatus.running;
    await secondRunCompletion.future;
    statusNotifier.value = MPTherionRunStatus.ok;
    isRunningNotifier.value = false;
  }

  @override
  void stop() {
    if (!secondRunCompletion.isCompleted) {
      secondRunCompletion.complete();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.thProjectController.closeProject();
  });

  tearDown(() {
    mpLocator.thProjectController.closeProject();
  });

  group('MPRunTherionDialogWidget diagnostics bridge', () {
    testWidgets(
      "populates THProjectController.compilerErrors when the run's "
      'thConfigFilePath matches the loaded project',
      (WidgetTester tester) async {
        const String thConfigFilePath = '/tmp/mapiah_bridge_test/thconfig';
        final String canonicalRootConfigPath =
            THProjectPathResolver.canonicalize(p.absolute(thConfigFilePath));

        mpLocator.thProjectController.rootConfigPath = canonicalRootConfigPath;

        final _FakeTherionRunner fakeRunner = _FakeTherionRunner(
          thConfigFilePath,
          <String>['therion: error -- cave.th [line 3] -- bad syntax'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MPRunTherionDialogWidget(
                therionExecutablePath: 'therion',
                thConfigFilePath: thConfigFilePath,
                therionRunner: fakeRunner,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
        await tester.pump();

        expect(mpLocator.thProjectController.compilerErrors, hasLength(1));

        final THProjectParseError diagnostic =
            mpLocator.thProjectController.compilerErrors.single;

        expect(diagnostic.severity, THProjectParseErrorSeverity.error);
        expect(diagnostic.lineNumber, 3);
        expect(
          diagnostic.filePath,
          THProjectPathResolver.canonicalize(
            p.join(p.dirname(p.absolute(thConfigFilePath)), 'cave.th'),
          ),
        );
      },
    );

    testWidgets(
      'leaves compilerErrors empty when no project is loaded',
      (WidgetTester tester) async {
        const String thConfigFilePath = '/tmp/mapiah_bridge_test2/thconfig';

        expect(mpLocator.thProjectController.rootConfigPath, isEmpty);

        final _FakeTherionRunner fakeRunner = _FakeTherionRunner(
          thConfigFilePath,
          <String>['therion: error -- cave.th [line 3] -- bad syntax'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MPRunTherionDialogWidget(
                therionExecutablePath: 'therion',
                thConfigFilePath: thConfigFilePath,
                therionRunner: fakeRunner,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
        await tester.pump();

        expect(mpLocator.thProjectController.compilerErrors, isEmpty);
      },
    );

    testWidgets(
      'leaves compilerErrors empty when the run targets a different '
      'project than the loaded one',
      (WidgetTester tester) async {
        const String thConfigFilePath = '/tmp/mapiah_bridge_test3/thconfig';

        mpLocator.thProjectController.rootConfigPath =
            THProjectPathResolver.canonicalize(
              p.absolute('/tmp/some/other/thconfig'),
            );

        final _FakeTherionRunner fakeRunner = _FakeTherionRunner(
          thConfigFilePath,
          <String>['therion: error -- cave.th [line 3] -- bad syntax'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MPRunTherionDialogWidget(
                therionExecutablePath: 'therion',
                thConfigFilePath: thConfigFilePath,
                therionRunner: fakeRunner,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
        await tester.pump();

        expect(mpLocator.thProjectController.compilerErrors, isEmpty);
      },
    );

    testWidgets(
      'a second run with different diagnostics fully replaces the first '
      "run's set",
      (WidgetTester tester) async {
        const String thConfigFilePath = '/tmp/mapiah_bridge_test4/thconfig';
        final String canonicalRootConfigPath =
            THProjectPathResolver.canonicalize(p.absolute(thConfigFilePath));

        mpLocator.thProjectController.rootConfigPath = canonicalRootConfigPath;

        final _FakeTherionRunner firstRunner = _FakeTherionRunner(
          thConfigFilePath,
          <String>['therion: error -- cave.th [line 3] -- first error'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MPRunTherionDialogWidget(
                therionExecutablePath: 'therion',
                thConfigFilePath: thConfigFilePath,
                therionRunner: firstRunner,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
        await tester.pump();

        expect(mpLocator.thProjectController.compilerErrors, hasLength(1));
        expect(
          mpLocator.thProjectController.compilerErrors.single.message,
          'first error',
        );

        final _FakeTherionRunner secondRunner = _FakeTherionRunner(
          thConfigFilePath,
          <String>[
            'therion: warning -- cave.th [line 4] -- second warning',
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MPRunTherionDialogWidget(
                key: const Key('secondRun'),
                therionExecutablePath: 'therion',
                thConfigFilePath: thConfigFilePath,
                therionRunner: secondRunner,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
        await tester.pump();

        expect(mpLocator.thProjectController.compilerErrors, hasLength(1));
        expect(
          mpLocator.thProjectController.compilerErrors.single.message,
          'second warning',
        );
        expect(
          mpLocator.thProjectController.compilerErrors.single.severity,
          THProjectParseErrorSeverity.warning,
        );
      },
    );

    testWidgets(
      'an in-dialog rerun clears stale diagnostics before it finishes',
      (WidgetTester tester) async {
        const String thConfigFilePath = '/tmp/mapiah_bridge_test5/thconfig';
        final String canonicalRootConfigPath =
            THProjectPathResolver.canonicalize(p.absolute(thConfigFilePath));

        mpLocator.thProjectController.rootConfigPath = canonicalRootConfigPath;

        final _RerunnableFakeTherionRunner fakeRunner =
            _RerunnableFakeTherionRunner(thConfigFilePath);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MPRunTherionDialogWidget(
                therionExecutablePath: 'therion',
                thConfigFilePath: thConfigFilePath,
                therionRunner: fakeRunner,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await tester.pump();

        expect(mpLocator.thProjectController.compilerErrors, hasLength(1));
        expect(fakeRunner.startCount, 1);

        await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
        await tester.pump();

        expect(fakeRunner.startCount, 2);
        expect(fakeRunner.secondRunCompletion.isCompleted, isFalse);
        expect(mpLocator.thProjectController.compilerErrors, isEmpty);

        fakeRunner.secondRunCompletion.complete();
        await tester.pumpAndSettle();

        expect(mpLocator.thProjectController.compilerErrors, isEmpty);
      },
    );
  });
}
