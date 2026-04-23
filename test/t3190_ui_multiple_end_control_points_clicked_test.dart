// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th2_file_tabs_page_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  group('UI: multiple overlapping end/control points dialog', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'clicking the last endpoint overlapping control point 2 shows the chooser and can select the control point',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final TH2FileEditController controller = mpLocator
            .mpGeneralController
            .getTH2FileEditController(
              filename:
                  './test/auxiliary/2026-04-23-002-line_with_bezier_where_control_point_is_under_endpoint.th2',
            );

        await tester.runAsync(() async {
          await controller.load();
        });

        await tester.pumpWidget(
          buildTH2FileTabsPageTestApp(th2FileEditController: controller),
        );
        await tester.pumpAndSettle();

        controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);

        final TH2File th2File = controller.th2File;
        final TH2FileEditSelectionController selectionController =
            controller.selectionController;
        final THLine line = th2File.getLines().single;

        selectionController.setSelectedElements([line]);
        controller.stateController.setState(
          MPTH2FileEditStateType.editSingleLine,
        );

        final THBezierCurveLineSegment lastSegment =
            line.getLineSegments(th2File).last as THBezierCurveLineSegment;

        final MPSelectableEndControlPoint selectedEndPoint =
            MPSelectableEndControlPoint(
              lineSegment: lastSegment,
              th2fileEditController: controller,
              position: lastSegment.endPoint.coordinates,
              type: MPEndControlPointType.endPointBezierCurve,
            );

        selectionController.setSelectedEndControlPoint(selectedEndPoint);
        selectionController.updateSelectableEndAndControlPoints();
        controller.triggerEditLineRedraw();
        await tester.pumpAndSettle();

        final Finder listenerFinder = find.byKey(
          ValueKey('MPListenerWidget|${controller.th2FileMPID}'),
        );
        final Offset clickCanvasPosition =
            lastSegment.endPoint.coordinates +
            Offset(
              controller.selectionToleranceOnCanvas - 0.1,
              controller.selectionToleranceOnCanvas - 0.1,
            );
        final Offset screenOffset = controller.offsetCanvasToScreen(
          clickCanvasPosition,
        );
        final List<MPSelectableEndControlPoint> clickedEndControlPoints =
            await selectionController.selectableEndControlPointsClicked(
              screenCoordinates: screenOffset,
              includeControlPoints: true,
              canBeMultiple: false,
              presentMultipleEndControlPointsClickedWidget: false,
            );

        expect(clickedEndControlPoints.length, 2);

        await tester.tapAt(tester.getTopLeft(listenerFinder) + screenOffset);
        await tester.pump();

        expect(find.text('Multiple points clicked'), findsOneWidget);

        final Finder controlPointChoiceFinder = find.byKey(
          const ValueKey('MPMultipleElementsClickedWidget|RadioListTile|2'),
        );

        expect(controlPointChoiceFinder, findsOneWidget);

        await tester.tap(controlPointChoiceFinder);
        await tester.pumpAndSettle();

        expect(find.text('Multiple points clicked'), findsNothing);
        expect(
          selectionController.selectedEndControlPoints.values.single.type,
          MPEndControlPointType.controlPoint2,
        );
      },
    );
  });
}
