// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  THTextEditorController? activeController;

  THTextEditorController buildController(String content) {
    final THTextEditorController controller = THTextEditorController(
      projectController: THProjectController(),
    );

    activeController = controller;
    controller.setContent(content);

    return controller;
  }

  Widget buildTestApp(THTextEditorController controller) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: THTextEditorWidget(controller: controller)),
    );
  }

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  tearDown(() {
    activeController?.dispose();
    activeController = null;
  });

  group('THTextEditorController findMatches', () {
    test('is empty for an empty query', () {
      final THTextEditorController controller = buildController(
        'survey one\nendsurvey',
      );

      controller.setFindQuery('');

      expect(controller.findMatches, isEmpty);
    });

    test('is empty when there are no matches', () {
      final THTextEditorController controller = buildController(
        'survey one\nendsurvey',
      );

      controller.setFindQuery('nonexistent');

      expect(controller.findMatches, isEmpty);
    });

    test('is empty when the query is longer than the content', () {
      final THTextEditorController controller = buildController('short');

      controller.setFindQuery('this is a much longer query than the content');

      expect(controller.findMatches, isEmpty);
    });

    test('finds non-overlapping, left-to-right matches', () {
      final THTextEditorController controller = buildController(
        'aaaa',
      );

      controller.setFindQuery('aa');

      expect(controller.findMatches, <TextRange>[
        const TextRange(start: 0, end: 2),
        const TextRange(start: 2, end: 4),
      ]);
    });

    test('is case-insensitive by default', () {
      final THTextEditorController controller = buildController(
        'Survey One\nEndsurvey',
      );

      controller.setFindQuery('survey');

      expect(controller.findMatches, hasLength(2));
    });

    test('is case-sensitive when findCaseSensitive is true', () {
      final THTextEditorController controller = buildController(
        'Survey One\nendsurvey',
      );

      controller.setFindQuery('survey');
      controller.setFindCaseSensitive(true);

      expect(controller.findMatches, hasLength(1));
      expect(controller.findMatches.single, const TextRange(start: 14, end: 20));
    });
  });

  group('THTextEditorController findNext/findPrevious', () {
    test('findNext selects the first match, then wraps around', () {
      final THTextEditorController controller = buildController('a.a.a');

      // Setting a query with matches auto-selects the first one.
      controller.setFindQuery('a');
      expect(controller.activeMatchIndex, 0);

      controller.findNext();
      expect(controller.activeMatchIndex, 1);

      controller.findNext();
      expect(controller.activeMatchIndex, 2);

      controller.findNext();
      expect(controller.activeMatchIndex, 0);
    });

    test('findPrevious wraps around to the last match', () {
      final THTextEditorController controller = buildController('a.a.a');

      controller.setFindQuery('a');

      controller.findPrevious();
      expect(controller.activeMatchIndex, 2);

      controller.findPrevious();
      expect(controller.activeMatchIndex, 1);
    });

    test('findNext/findPrevious are no-ops with no matches', () {
      final THTextEditorController controller = buildController('abc');

      controller.setFindQuery('zzz');
      controller.findNext();

      expect(controller.activeMatchIndex, isNull);

      controller.findPrevious();

      expect(controller.activeMatchIndex, isNull);
    });
  });

  group('THTextEditorController replaceActiveMatch', () {
    test('replaces only the active match', () {
      final THTextEditorController controller = buildController('a.a.a');

      // setFindQuery auto-selects match 0; one findNext moves to match 1.
      controller.setFindQuery('a');
      controller.setReplaceQuery('X');
      controller.findNext();
      expect(controller.activeMatchIndex, 1);

      controller.replaceActiveMatch();

      expect(controller.content, 'a.X.a');
    });

    test('re-syncs findMatches against the new content', () {
      final THTextEditorController controller = buildController('a.a.a');

      // setFindQuery auto-selects match 0, so no findNext() call is needed.
      controller.setFindQuery('a');
      controller.setReplaceQuery('bb');
      controller.replaceActiveMatch();

      expect(controller.content, 'bb.a.a');
      expect(controller.findMatches, hasLength(2));
    });

    test('does nothing when there is no active match (no matches at all)', () {
      final THTextEditorController controller = buildController('a.a.a');

      controller.setFindQuery('zzz');
      controller.setReplaceQuery('X');
      expect(controller.activeMatchIndex, isNull);

      controller.replaceActiveMatch();

      expect(controller.content, 'a.a.a');
    });
  });

  group('THTextEditorController replaceAllMatches', () {
    test('replaces every match in one call', () {
      final THTextEditorController controller = buildController('a.a.a');

      controller.setFindQuery('a');
      controller.setReplaceQuery('X');

      controller.replaceAllMatches();

      expect(controller.content, 'X.X.X');
      expect(controller.activeMatchIndex, isNull);
    });

    test('does nothing when there are no matches', () {
      final THTextEditorController controller = buildController('abc');

      controller.setFindQuery('zzz');
      controller.setReplaceQuery('X');

      controller.replaceAllMatches();

      expect(controller.content, 'abc');
    });
  });

  group('THTextEditorController find bar visibility', () {
    test('openFindBar shows the bar and selects the first match', () {
      final THTextEditorController controller = buildController('a.a.a');

      controller.setFindQuery('a');
      controller.openFindBar();

      expect(controller.isFindBarVisible, isTrue);
      expect(controller.activeMatchIndex, 0);
    });

    test('closeFindBar hides the bar and clears find/replace state', () {
      final THTextEditorController controller = buildController('a.a.a');

      controller.setFindQuery('a');
      controller.setReplaceQuery('X');
      controller.openFindBar();

      controller.closeFindBar();

      expect(controller.isFindBarVisible, isFalse);
      expect(controller.findQuery, isEmpty);
      expect(controller.replaceQuery, isEmpty);
      expect(controller.activeMatchIndex, isNull);
    });
  });

  group('THTextEditorWidget find bar', () {
    THTextEditorController buildWidgetTestController(String content) {
      final THTextEditorController controller = buildController(content);

      // setContent starts a debounced reparseFile Timer that these tests
      // don't need; cancel it immediately so testWidgets doesn't fail its
      // end-of-test "no pending Timer" invariant.
      controller.dispose();

      return controller;
    }

    testWidgets('the find button opens the find bar', (
      WidgetTester tester,
    ) async {
      final THTextEditorController controller = buildWidgetTestController(
        'survey one\nendsurvey',
      );

      await tester.pumpWidget(buildTestApp(controller));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('THTextEditorWidget|FindField')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('THTextEditorWidget|FindButton')),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('THTextEditorWidget|FindField')),
        findsOneWidget,
      );
      expect(controller.isFindBarVisible, isTrue);
    });

    testWidgets('typing in the find field filters matches', (
      WidgetTester tester,
    ) async {
      final THTextEditorController controller = buildWidgetTestController(
        'survey one\nendsurvey',
      );

      controller.openFindBar();
      await tester.pumpWidget(buildTestApp(controller));
      await tester.pump();

      await tester.enterText(
        find.byKey(const ValueKey('THTextEditorWidget|FindField')),
        'survey',
      );
      await tester.pump();

      expect(controller.findQuery, 'survey');
      expect(controller.findMatches, hasLength(2));
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('closing the find bar clears it', (
      WidgetTester tester,
    ) async {
      final THTextEditorController controller = buildWidgetTestController(
        'survey one\nendsurvey',
      );

      controller.setFindQuery('survey');
      controller.openFindBar();
      await tester.pumpWidget(buildTestApp(controller));
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey('THTextEditorWidget|FindCloseButton')),
      );
      await tester.pump();

      expect(controller.isFindBarVisible, isFalse);
      expect(
        find.byKey(const ValueKey('THTextEditorWidget|FindField')),
        findsNothing,
      );
    });
  });
}
