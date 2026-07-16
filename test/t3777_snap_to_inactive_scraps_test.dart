// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_snap_controller.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';

import 'th_test_aux.dart';
import 'th2_file_tabs_page_test_aux.dart';

void main() {
  THTestAux.ensureTestEnvironment();
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
  });

  Future<TH2FileEditController> loadController() async {
    final TH2FileParser parser = TH2FileParser();
    final String path = THTestAux.testPath(
      '2026-03-18-002-two_scraps_with_point_line_area.th2',
    );
    final (_, bool isSuccessful, List<String> errors) = await parser.parse(
      path,
      forceNewController: true,
    );

    expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

    final TH2FileEditController controller = mpLocator.mpGeneralController
        .getTH2FileEditController(filename: path);
    final List<THScrap> scraps = controller.th2File.getScraps().toList();

    controller.setActiveScrap(scraps.last.mpID);
    controller.setCanvasScale(1);

    return controller;
  }

  test('inactive scrap point targets are independently configurable', () async {
    final TH2FileEditController controller = await loadController();
    const Offset inactivePointPosition = Offset(200, 200);

    controller.snapController.setSnapTargets(
      pointTarget: MPSnapPointTarget.point,
    );

    expect(
      controller.snapController.getCanvasSnapedPositionFromCanvasOffset(
        inactivePointPosition,
      ),
      isNull,
    );

    controller.snapController.setSnapPointToInactiveScraps(true);

    final THPositionPart? target = controller.snapController
        .getCanvasSnapedPositionFromCanvasOffset(inactivePointPosition);

    expect(target?.coordinates, inactivePointPosition);
    expect(controller.snapController.snapLinePointToInactiveScraps, isFalse);
  });

  test('inactive scrap line targets ignore hidden scraps', () async {
    final TH2FileEditController controller = await loadController();
    final THScrap inactiveScrap = controller.th2File.getScraps().first;
    const Offset inactiveLinePointPosition = Offset(300, 300);

    controller.snapController.setSnapTargets(
      linePointTarget: MPSnapLinePointTarget.linePoint,
    );
    controller.snapController.setSnapLinePointToInactiveScraps(true);

    final THPositionPart? visibleTarget = controller.snapController
        .getCanvasSnapedPositionFromCanvasOffset(inactiveLinePointPosition);

    expect(visibleTarget?.coordinates, inactiveLinePointPosition);

    controller.hideElementController.toggleScrapVisibility(inactiveScrap.mpID);

    expect(
      controller.snapController.getCanvasSnapedPositionFromCanvasOffset(
        inactiveLinePointPosition,
      ),
      isNull,
    );
  });

  testWidgets('point and line blocks show the inactive scraps option', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    late TH2FileEditController controller;

    await tester.runAsync(() async {
      final String path = THTestAux.testPath(
        '2026-03-18-002-two_scraps_with_point_line_area.th2',
      );

      controller = mpLocator.mpGeneralController.getTH2FileEditController(
        filename: path,
      );
      await controller.load();
    });

    await tester.pumpWidget(
      buildTH2FileTabsPageTestApp(th2FileEditController: controller),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Snap'));
    await tester.pumpAndSettle();

    expect(find.text('Snap to inactive scraps'), findsNWidgets(2));
  });
}
