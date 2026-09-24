// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_file_problem_text_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_pt.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
import 'package:mapiah/src/widgets/th2_broken_file_body_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'th2_file_tabs_page_test_aux.dart';
import 'th_test_aux.dart';

const String _brokenContents =
    'encoding utf-8\n'
    'point 10 20 station -name 1\n'
    'scrap s1\n'
    '  point 30 40 station -name 2\n'
    '    poin 150 250 station -name 3   \n'
    'endscrap\n';

const Map<TH2FileProblemKind, String> _expectedEn =
    <TH2FileProblemKind, String>{
      TH2FileProblemKind.plaOutsideScrap: 'Point, line or area outside a scrap',
      TH2FileProblemKind.scrapInsideScrap: 'Scrap inside another scrap',
      TH2FileProblemKind.strayEndscrap: 'endscrap without an open scrap',
      TH2FileProblemKind.missingEndline: 'Line missing endline',
      TH2FileProblemKind.missingEndarea: 'Area missing endarea',
      TH2FileProblemKind.missingEndscrap: 'Scrap missing endscrap',
      TH2FileProblemKind.invalidBorderReference:
          'Area border does not refer to a valid line',
      TH2FileProblemKind.parseError: 'Unrecognized or invalid TH2 content',
    };

const Map<TH2FileProblemKind, String> _expectedPt =
    <TH2FileProblemKind, String>{
      TH2FileProblemKind.plaOutsideScrap:
          'Ponto, linha ou área fora de um croqui',
      TH2FileProblemKind.scrapInsideScrap: 'Croqui dentro de outro croqui',
      TH2FileProblemKind.strayEndscrap: 'endscrap sem um croqui aberto',
      TH2FileProblemKind.missingEndline: 'Linha sem endline',
      TH2FileProblemKind.missingEndarea: 'Área sem endarea',
      TH2FileProblemKind.missingEndscrap: 'Croqui sem endscrap',
      TH2FileProblemKind.invalidBorderReference:
          'Borda de área não aponta para uma linha válida',
      TH2FileProblemKind.parseError: 'Conteúdo TH2 não reconhecido ou inválido',
    };

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  group('TH2FileProblemTextAux.userMessage', () {
    void expectAllKinds(
      AppLocalizations appLocalizations,
      Map<TH2FileProblemKind, String> expected,
    ) {
      for (final TH2FileProblemKind kind in TH2FileProblemKind.values) {
        expect(
          TH2FileProblemTextAux.userMessage(kind, appLocalizations),
          expected[kind],
          reason: kind.name,
        );
      }
    }

    test('covers every kind in English', () {
      expect(_expectedEn.keys, unorderedEquals(TH2FileProblemKind.values));
      expectAllKinds(AppLocalizationsEn(), _expectedEn);
    });

    test('covers every kind in Portuguese', () {
      expect(_expectedPt.keys, unorderedEquals(TH2FileProblemKind.values));
      expectAllKinds(AppLocalizationsPt(), _expectedPt);
    });
  });

  group('TH2BrokenFileBodyWidget', () {
    late Directory tempDir;
    late String filename;

    setUp(() async {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      await mpLocator.mpSettingsController.initialized;
      tempDir = Directory.systemTemp.createTempSync('mapiah_t3954_');
      filename = p.join(tempDir.path, 'broken.th2');
      File(filename).writeAsStringSync(_brokenContents);
    });

    tearDown(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      tempDir.deleteSync(recursive: true);
    });

    /// Loads the broken file and mounts it in a tab of the tabs page.
    Future<TH2FileEditController> pumpBrokenTab(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
    }) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: filename);

      await tester.runAsync(() => controller.load());
      /// Built like buildTH2FileTabsPageTestApp, plus the Material
      /// localizations the Portuguese locale needs.
      buildTH2FileTabsPageTestApp(th2FileEditController: controller);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: const TH2FileTabsPage(),
        ),
      );
      await tester.pump();
      await tester.pump();

      return controller;
    }

    testWidgets('shows localized categories, source lines and hidden details', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController controller = await pumpBrokenTab(tester);
      final TH2FileProblem parseProblem = controller.problems.last;

      expect(find.byType(TH2BrokenFileBodyWidget), findsOneWidget);
      expect(
        find.text(mpLocator.appLocalizations.th2BrokenFileExplanation),
        findsOneWidget,
      );
      expect(
        find.text('Line 2: Point, line or area outside a scrap'),
        findsOneWidget,
      );
      expect(
        find.text('Line 5: Unrecognized or invalid TH2 content'),
        findsOneWidget,
      );
      expect(find.text('point 10 20 station -name 1'), findsOneWidget);

      /// Leading indentation is kept; trailing whitespace is trimmed.
      expect(find.text('    poin 150 250 station -name 3'), findsOneWidget);
      expect(find.text('Details'), findsNWidgets(2));
      expect(find.text(parseProblem.detail), findsNothing);

      await tester.tap(find.text('Details').last);
      await tester.pumpAndSettle();

      expect(find.text(parseProblem.detail), findsOneWidget);
      expect(find.text('Reload'), findsOneWidget);
    });

    testWidgets('is localized in Portuguese', (WidgetTester tester) async {
      await pumpBrokenTab(tester, locale: const Locale('pt'));

      expect(
        find.text(AppLocalizationsPt().th2BrokenFileExplanation),
        findsOneWidget,
      );
      expect(
        find.text('Linha 2: Ponto, linha ou área fora de um croqui'),
        findsOneWidget,
      );
      expect(
        find.text('Linha 5: Conteúdo TH2 não reconhecido ou inválido'),
        findsOneWidget,
      );
      expect(find.text('Detalhes'), findsNWidgets(2));
      expect(find.text('Copiar caminho'), findsOneWidget);
      expect(find.text('Recarregar'), findsOneWidget);
    });

    testWidgets('shows the path and Copy path copies it exactly', (
      WidgetTester tester,
    ) async {
      String? copiedText;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }

          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pumpBrokenTab(tester);

      expect(find.text(filename), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('TH2BrokenFileBodyCopyPathButton')),
      );
      await tester.pump();

      expect(copiedText, filename);
    });
  });
}
