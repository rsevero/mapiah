// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/widgets/mp_therion_run_dialog_widget.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UI: therion run dialog', () {
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
  });
}
