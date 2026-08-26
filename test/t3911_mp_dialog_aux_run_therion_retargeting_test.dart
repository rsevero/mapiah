// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/widgets/mp_therion_run_dialog_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'th_test_aux.dart';

/// Minimal [PlatformFile] fake for tests that only need its [path]/[name]
/// -- exercising the real `FilePicker.pickFile` platform channel is neither
/// possible nor desirable in a unit/widget test.
base class _FakePlatformFile extends PlatformFile {
  _FakePlatformFile(String path)
    : name = path.split('/').last,
      uri = Uri.file(path);

  @override
  final String name;

  @override
  final Uri uri;

  @override
  XFile get xFile => XFile(uri.toFilePath(), name: name);

  @override
  Future<int> length() async => 0;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);

  @override
  Stream<Uint8List> readAsByteStream() => const Stream<Uint8List>.empty();
}

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

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
    mpLocator.thProjectController.closeProject();
  });

  tearDown(() {
    mpLocator.thProjectController.closeProject();
  });

  group('MPDialogAux.rerunTherionForOpenProject', () {
    testWidgets('no-ops when no project is loaded', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpAndGetContext(tester);

      expect(mpLocator.thProjectController.rootConfigPath, isEmpty);

      await MPDialogAux.rerunTherionForOpenProject(context);
      await tester.pump();

      expect(find.byType(MPRunTherionDialogWidget), findsNothing);
    });

    // NOTE: a "shows MPRunTherionDialogWidget with rootConfigPath when set"
    // scenario was attempted here (matching the plan's test-plan
    // description) but dropped: MPDialogAux.runTherion/rerunTherionForOpenProject
    // have no runner-injection seam (unlike MPRunTherionDialogWidget's own
    // `therionRunner` constructor parameter, used directly by
    // t3610_ui_therion_run_dialog_test.dart), so exercising this path means
    // spawning a real process from inside a `testWidgets` fake-async zone --
    // which left a periodic Timer (the dialog's own elapsed-time ticker)
    // reliably still pending at teardown across several mitigation attempts
    // (tester.runAsync bridging, real short-lived scripts, extra pumps).
    // The underlying logic (reading THProjectController.rootConfigPath and
    // gating on emptiness) is otherwise simple and reviewed directly; the
    // dialog's own behavior given a thConfigFilePath is already covered by
    // t3610, and MPTherionRunner itself by t3600.
  });

  group('MPDialogAux.pickProjectFileAndRunTherion', () {
    testWidgets('passes the picked path to launch', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpAndGetContext(tester);
      String? launchedContextPath;

      await MPDialogAux.pickProjectFileAndRunTherion(
        context,
        pickFile: () async => _FakePlatformFile('/tmp/picked/thconfig'),
        launch: (BuildContext launchContext, String thConfigFilePath) async {
          launchedContextPath = thConfigFilePath;
        },
      );

      expect(launchedContextPath, '/tmp/picked/thconfig');
    });

    testWidgets('does not call launch when the picker returns null', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpAndGetContext(tester);
      bool launchCalled = false;

      await MPDialogAux.pickProjectFileAndRunTherion(
        context,
        pickFile: () async => null,
        launch: (BuildContext launchContext, String thConfigFilePath) async {
          launchCalled = true;
        },
      );

      expect(launchCalled, isFalse);
    });
  });

  group('MPDialogAux.runTherionAndOpenProjectInBackground', () {
    testWidgets(
      'calls projectLoader without awaiting it and waits for '
      'runTherionStarter',
      (WidgetTester tester) async {
        final BuildContext context = await pumpAndGetContext(tester);
        final List<String> callOrder = <String>[];
        final Completer<void> loaderCompleter = Completer<void>();

        await MPDialogAux.runTherionAndOpenProjectInBackground(
          context,
          '/tmp/background/thconfig',
          projectLoader: (String configFilePath, {bool forceConfigShape = false}) {
            callOrder.add('loaderStarted');

            return loaderCompleter.future;
          },
          runTherionStarter:
              (BuildContext runContext, {required String thConfigFilePath}) async {
                callOrder.add('runStarted');
              },
        );

        expect(callOrder, <String>['loaderStarted', 'runStarted']);
        // The loader is intentionally left uncompleted here: completing it
        // would trigger runTherionAndOpenProjectInBackground's own
        // ensureProjectTabsPageOpen(context) follow-up, which pushes a real
        // TH2FileTabsPage route -- out of scope for this seam-focused test.
        expect(loaderCompleter.isCompleted, isFalse);
      },
    );
  });
}
