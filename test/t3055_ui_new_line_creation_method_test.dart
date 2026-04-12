// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_new_line_creation_method.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
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

  group('UI: new line creation methods', () {
    setUp(() async {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      await mpLocator.mpSettingsController.initialized;
      mpLocator.mpSettingsController.reset();
    });

    testWidgets('xTherion mode creates a degenerate bezier next segment', (
      WidgetTester tester,
    ) async {
      await _configureTestSurface(tester);
      mpLocator.mpSettingsController.setEnum(
        MPSettingID.TH2Edit_NewLineCreationMethod,
        MPNewLineCreationMethod.xTherionCubicSmooth,
      );

      final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
          await _pumpEditor(tester, mpLocator);
      final Finder listenerFinder = find.byKey(
        ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
      );
      final Offset origin = tester.getTopLeft(listenerFinder);
      final Offset p1 = origin + const Offset(120, 120);
      final Offset p2 = origin + const Offset(240, 160);
      final Offset p3 = origin + const Offset(300, 200);
      final Offset p4 = origin + const Offset(400, 250);
      final Offset dragPoint = origin + const Offset(350, 220);
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

      await _enterAddLineMode(tester, editor.th2Controller);
      await _clickMouse(tester, mouse, p1);
      await _clickMouse(tester, mouse, p2);

      await tester.sendEventToBinding(mouse.down(p3, buttons: kPrimaryButton));
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(dragPoint, buttons: kPrimaryButton),
      );
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pumpAndSettle();

      await _clickMouse(tester, mouse, p4);
      await _finalizeLineCreation(tester);

      final List<THLine> lines = editor.th2File.getLines().toList();
      final List<THLineSegment> lineSegments = lines.first.getLineSegments(
        editor.th2File,
      );
      final THBezierCurveLineSegment smoothedCurrentSegment =
          lineSegments[2] as THBezierCurveLineSegment;
      final THBezierCurveLineSegment seededNextSegment =
          lineSegments[3] as THBezierCurveLineSegment;
      final Offset expectedControlPoint1 =
          (smoothedCurrentSegment.endPoint.coordinates * 2) -
          smoothedCurrentSegment.controlPoint2.coordinates;

      expect(lines.length, 1);
      expect(lineSegments.length, 4);
      expect(lineSegments[2], isA<THBezierCurveLineSegment>());
      expect(lineSegments[3], isA<THBezierCurveLineSegment>());
      expect(
        seededNextSegment.controlPoint2.coordinates,
        seededNextSegment.endPoint.coordinates,
      );
      expect(
        seededNextSegment.controlPoint1.coordinates.dx,
        closeTo(expectedControlPoint1.dx, 1e-9),
      );
      expect(
        seededNextSegment.controlPoint1.coordinates.dy,
        closeTo(expectedControlPoint1.dy, 1e-9),
      );
    });

    testWidgets(
      'Mapiah quadratic drag converts the current segment to Bézier',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.mapiahQuadratic,
        );

        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await _pumpEditor(tester, mpLocator);
        final Finder listenerFinder = find.byKey(
          ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
        );
        final Offset origin = tester.getTopLeft(listenerFinder);
        final Offset p1 = origin + const Offset(120, 120);
        final Offset p2 = origin + const Offset(240, 160);
        final Offset p3 = origin + const Offset(320, 210);
        final Offset dragPoint = origin + const Offset(360, 260);
        final Offset localDragPoint = dragPoint - origin;
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);

        await tester.sendEventToBinding(
          mouse.down(p3, buttons: kPrimaryButton),
        );
        await tester.pump();
        await tester.sendEventToBinding(
          mouse.move(dragPoint, buttons: kPrimaryButton),
        );
        await tester.pump();

        final THLine line = editor.th2File.getLines().first;
        final List<THLineSegment> lineSegments = line.getLineSegments(
          editor.th2File,
        );
        final THBezierCurveLineSegment convertedSegment =
            lineSegments.last as THBezierCurveLineSegment;
        final Offset startPointCoordinates =
            lineSegments[lineSegments.length - 2].endPoint.coordinates;
        final Offset endPointCoordinates =
            convertedSegment.endPoint.coordinates;
        final Offset quadraticControlPointCanvasCoordinates = editor
            .th2Controller
            .offsetScreenToCanvas(localDragPoint);
        final Offset twoThirdsControlPoint =
            quadraticControlPointCanvasCoordinates * (2 / 3);
        final Offset expectedControlPoint1 =
            (startPointCoordinates / 3) + twoThirdsControlPoint;
        final Offset expectedControlPoint2 =
            (endPointCoordinates / 3) + twoThirdsControlPoint;

        expect(lineSegments.length, 3);
        expect(lineSegments.last, isA<THBezierCurveLineSegment>());
        expect(
          editor
              .th2Controller
              .areaLineCreationController
              .newLinePendingControlPoint1CanvasCoordinates,
          isNull,
        );
        expect(
          convertedSegment.controlPoint1.coordinates.dx,
          closeTo(expectedControlPoint1.dx, 1e-9),
        );
        expect(
          convertedSegment.controlPoint1.coordinates.dy,
          closeTo(expectedControlPoint1.dy, 1e-9),
        );
        expect(
          convertedSegment.controlPoint2.coordinates.dx,
          closeTo(expectedControlPoint2.dx, 1e-9),
        );
        expect(
          convertedSegment.controlPoint2.coordinates.dy,
          closeTo(expectedControlPoint2.dy, 1e-9),
        );

        await tester.sendEventToBinding(mouse.up());
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Mapiah quadratic drag keeps the converted Bézier segment after release and finalize',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.mapiahQuadratic,
        );

        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await _pumpEditor(tester, mpLocator);
        final Finder listenerFinder = find.byKey(
          ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
        );
        final Offset origin = tester.getTopLeft(listenerFinder);
        final Offset p1 = origin + const Offset(120, 120);
        final Offset p2 = origin + const Offset(240, 160);
        final Offset p3 = origin + const Offset(320, 210);
        final Offset dragPoint = origin + const Offset(360, 260);
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);
        await _dragMouse(tester, mouse, p3, <Offset>[dragPoint]);
        await _finalizeLineCreation(tester);

        final THLine line = editor.th2File.getLines().first;
        final List<THLineSegment> lineSegments = line.getLineSegments(
          editor.th2File,
        );

        expect(lineSegments.length, 3);
        expect(lineSegments.last, isA<THBezierCurveLineSegment>());
      },
    );

    testWidgets('Ctrl-drag keeps previous control point distance fixed', (
      WidgetTester tester,
    ) async {
      await _configureTestSurface(tester);
      mpLocator.mpSettingsController.setEnum(
        MPSettingID.TH2Edit_NewLineCreationMethod,
        MPNewLineCreationMethod.xTherionCubicSmooth,
      );

      final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
          await _pumpEditor(tester, mpLocator);
      final Finder listenerFinder = find.byKey(
        ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
      );
      final Offset origin = tester.getTopLeft(listenerFinder);
      final Offset p1 = origin + const Offset(120, 120);
      final Offset p2 = origin + const Offset(240, 160);
      final Offset p3 = origin + const Offset(300, 200);
      final Offset firstDragPoint = origin + const Offset(335, 210);
      final Offset secondDragPoint = origin + const Offset(390, 255);
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

      await _enterAddLineMode(tester, editor.th2Controller);
      await _clickMouse(tester, mouse, p1);
      await _clickMouse(tester, mouse, p2);

      await tester.sendEventToBinding(mouse.down(p3, buttons: kPrimaryButton));
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(firstDragPoint, buttons: kPrimaryButton),
      );
      await tester.pump();

      final THBezierCurveLineSegment firstBezierSegment = _getLastBezierSegment(
        editor.th2File,
      );
      final Offset sharedEndPoint = firstBezierSegment.endPoint.coordinates;
      final double firstControlPointDistance =
          (firstBezierSegment.controlPoint2.coordinates - sharedEndPoint)
              .distance;

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(secondDragPoint, buttons: kPrimaryButton),
      );
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pumpAndSettle();

      final THBezierCurveLineSegment secondBezierSegment =
          _getLastBezierSegment(editor.th2File);
      final double secondControlPointDistance =
          (secondBezierSegment.controlPoint2.coordinates - sharedEndPoint)
              .distance;
      final Offset unconstrainedTarget =
          (sharedEndPoint * 2) -
          editor.th2Controller.offsetScreenToCanvas(secondDragPoint);
      final double unconstrainedDistance =
          (unconstrainedTarget - sharedEndPoint).distance;

      expect(
        secondControlPointDistance,
        closeTo(firstControlPointDistance, 1e-9),
      );
      expect(
        (secondControlPointDistance - unconstrainedDistance).abs(),
        greaterThan(1e-6),
      );
    });

    testWidgets('Ctrl-drag still seeds the next segment control point', (
      WidgetTester tester,
    ) async {
      await _configureTestSurface(tester);
      mpLocator.mpSettingsController.setEnum(
        MPSettingID.TH2Edit_NewLineCreationMethod,
        MPNewLineCreationMethod.xTherionCubicSmooth,
      );

      final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
          await _pumpEditor(tester, mpLocator);
      final Finder listenerFinder = find.byKey(
        ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
      );
      final Offset origin = tester.getTopLeft(listenerFinder);
      final Offset p1 = origin + const Offset(120, 120);
      final Offset p2 = origin + const Offset(240, 160);
      final Offset p3 = origin + const Offset(300, 200);
      final Offset p4 = origin + const Offset(400, 250);
      final Offset firstDragPoint = origin + const Offset(335, 210);
      final Offset ctrlDragPoint = origin + const Offset(390, 255);
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

      await _enterAddLineMode(tester, editor.th2Controller);
      await _clickMouse(tester, mouse, p1);
      await _clickMouse(tester, mouse, p2);

      await tester.sendEventToBinding(mouse.down(p3, buttons: kPrimaryButton));
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(firstDragPoint, buttons: kPrimaryButton),
      );
      await tester.pump();

      final THBezierCurveLineSegment initialBezierSegment =
          _getLastBezierSegment(editor.th2File);
      final Offset sharedEndPoint = initialBezierSegment.endPoint.coordinates;
      final double initialControlPointDistance =
          (initialBezierSegment.controlPoint2.coordinates - sharedEndPoint)
              .distance;

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(ctrlDragPoint, buttons: kPrimaryButton),
      );
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pumpAndSettle();

      await _clickMouse(tester, mouse, p4);
      await _finalizeLineCreation(tester);

      final THLine line = editor.th2File.getLines().first;
      final List<THLineSegment> lineSegments = line.getLineSegments(
        editor.th2File,
      );
      final THBezierCurveLineSegment smoothedCurrentSegment =
          lineSegments[2] as THBezierCurveLineSegment;
      final THBezierCurveLineSegment seededNextSegment =
          lineSegments[3] as THBezierCurveLineSegment;
      final double lockedControlPointDistance =
          (smoothedCurrentSegment.controlPoint2.coordinates - sharedEndPoint)
              .distance;
      final Offset nextControlPointVector =
          seededNextSegment.controlPoint1.coordinates - sharedEndPoint;
      final Offset lockedControlPointVector =
          smoothedCurrentSegment.controlPoint2.coordinates - sharedEndPoint;
      final double nextControlPointDistance = nextControlPointVector.distance;
      final double directionDotProduct =
          (nextControlPointVector.dx * lockedControlPointVector.dx) +
          (nextControlPointVector.dy * lockedControlPointVector.dy);

      expect(
        lockedControlPointDistance,
        closeTo(initialControlPointDistance, 1e-9),
      );
      expect(
        nextControlPointDistance,
        greaterThan(lockedControlPointDistance + 1e-6),
      );
      expect(directionDotProduct, lessThan(0));
    });

    testWidgets(
      'Shift-drag constrains the xTherion control point to the snap angle',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        final double originalSnapAngle = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_SnapAngle);
        const double snapAngle = 45.0;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_SnapAngle,
          snapAngle,
        );

        try {
          final ({TH2File th2File, TH2FileEditController th2Controller})
          editor = await _pumpEditor(tester, mpLocator);
          final Finder listenerFinder = find.byKey(
            ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
          );
          final Offset origin = tester.getTopLeft(listenerFinder);
          final Offset p1 = origin + const Offset(120, 120);
          final Offset p2 = origin + const Offset(240, 160);
          final Offset p3 = origin + const Offset(300, 200);
          final Offset unconstrainedDragPoint = origin + const Offset(360, 230);
          final Offset unconstrainedLocalDragPoint =
              unconstrainedDragPoint - origin;
          final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

          await _enterAddLineMode(tester, editor.th2Controller);
          await _clickMouse(tester, mouse, p1);
          await _clickMouse(tester, mouse, p2);

          await tester.sendEventToBinding(
            mouse.down(p3, buttons: kPrimaryButton),
          );
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();
          await tester.sendEventToBinding(
            mouse.move(unconstrainedDragPoint, buttons: kPrimaryButton),
          );
          await tester.pump();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();
          await tester.sendEventToBinding(mouse.up());
          await tester.pumpAndSettle();

          final THBezierCurveLineSegment currentSegment = _getLastBezierSegment(
            editor.th2File,
          );
          final Offset sharedEndPoint = currentSegment.endPoint.coordinates;
          final Offset constrainedNextControlPoint = editor
              .th2Controller
              .areaLineCreationController
              .newLinePendingControlPoint1CanvasCoordinates!;
          final Offset constrainedDirection =
              constrainedNextControlPoint - sharedEndPoint;
          final Offset unconstrainedNextControlPoint = editor.th2Controller
              .offsetScreenToCanvas(unconstrainedLocalDragPoint);
          final Offset unconstrainedDirection =
              unconstrainedNextControlPoint - sharedEndPoint;
          final double constrainedAngleDegrees =
              math.atan2(constrainedDirection.dy, constrainedDirection.dx) *
              180 /
              math.pi;

          expect(
            constrainedDirection.distance,
            closeTo(unconstrainedDirection.distance, 1e-6),
          );
          expect(constrainedAngleDegrees.abs(), closeTo(45.0, 1e-6));
          expect(
            (constrainedNextControlPoint.dx - unconstrainedNextControlPoint.dx)
                .abs(),
            greaterThan(1e-6),
          );
          expect(
            currentSegment.controlPoint2.coordinates.dx,
            closeTo(
              (sharedEndPoint.dx * 2) - constrainedNextControlPoint.dx,
              1e-9,
            ),
          );
          expect(
            currentSegment.controlPoint2.coordinates.dy,
            closeTo(
              (sharedEndPoint.dy * 2) - constrainedNextControlPoint.dy,
              1e-9,
            ),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_SnapAngle,
            originalSnapAngle,
          );
        }
      },
    );

    testWidgets('Alt-drag keeps the current xTherion control point fixed', (
      WidgetTester tester,
    ) async {
      await _configureTestSurface(tester);
      mpLocator.mpSettingsController.setEnum(
        MPSettingID.TH2Edit_NewLineCreationMethod,
        MPNewLineCreationMethod.xTherionCubicSmooth,
      );

      final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
          await _pumpEditor(tester, mpLocator);
      final Finder listenerFinder = find.byKey(
        ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
      );
      final Offset origin = tester.getTopLeft(listenerFinder);
      final Offset p1 = origin + const Offset(120, 120);
      final Offset p2 = origin + const Offset(240, 160);
      final Offset p3 = origin + const Offset(300, 200);
      final Offset firstDragPoint = origin + const Offset(335, 210);
      final Offset altDragPoint = origin + const Offset(390, 255);
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

      await _enterAddLineMode(tester, editor.th2Controller);
      await _clickMouse(tester, mouse, p1);
      await _clickMouse(tester, mouse, p2);

      await tester.sendEventToBinding(mouse.down(p3, buttons: kPrimaryButton));
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(firstDragPoint, buttons: kPrimaryButton),
      );
      await tester.pump();

      final THBezierCurveLineSegment initialBezierSegment =
          _getLastBezierSegment(editor.th2File);
      final Offset initialControlPoint2 =
          initialBezierSegment.controlPoint2.coordinates;

      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(altDragPoint, buttons: kPrimaryButton),
      );
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pumpAndSettle();

      final THBezierCurveLineSegment altBezierSegment = _getLastBezierSegment(
        editor.th2File,
      );

      expect(
        altBezierSegment.controlPoint2.coordinates.dx,
        closeTo(initialControlPoint2.dx, 1e-9),
      );
      expect(
        altBezierSegment.controlPoint2.coordinates.dy,
        closeTo(initialControlPoint2.dy, 1e-9),
      );
    });

    testWidgets('Alt-drag seeds the next xTherion control point separately', (
      WidgetTester tester,
    ) async {
      await _configureTestSurface(tester);
      mpLocator.mpSettingsController.setEnum(
        MPSettingID.TH2Edit_NewLineCreationMethod,
        MPNewLineCreationMethod.xTherionCubicSmooth,
      );

      final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
          await _pumpEditor(tester, mpLocator);
      final Finder listenerFinder = find.byKey(
        ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
      );
      final Offset origin = tester.getTopLeft(listenerFinder);
      final Offset p1 = origin + const Offset(120, 120);
      final Offset p2 = origin + const Offset(240, 160);
      final Offset p3 = origin + const Offset(300, 200);
      final Offset p4 = origin + const Offset(400, 250);
      final Offset firstDragPoint = origin + const Offset(335, 210);
      final Offset altDragPoint = origin + const Offset(390, 255);
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

      await _enterAddLineMode(tester, editor.th2Controller);
      await _clickMouse(tester, mouse, p1);
      await _clickMouse(tester, mouse, p2);

      await tester.sendEventToBinding(mouse.down(p3, buttons: kPrimaryButton));
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(firstDragPoint, buttons: kPrimaryButton),
      );
      await tester.pump();

      final THBezierCurveLineSegment initialBezierSegment =
          _getLastBezierSegment(editor.th2File);
      final Offset initialControlPoint2 =
          initialBezierSegment.controlPoint2.coordinates;
      final Offset expectedSeparateControlPoint1 = editor.th2Controller
          .offsetScreenToCanvas(altDragPoint - origin);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(altDragPoint, buttons: kPrimaryButton),
      );
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pumpAndSettle();

      await _clickMouse(tester, mouse, p4);
      await _finalizeLineCreation(tester);

      final THLine line = editor.th2File.getLines().first;
      final List<THLineSegment> lineSegments = line.getLineSegments(
        editor.th2File,
      );
      final THBezierCurveLineSegment currentSegment =
          lineSegments[2] as THBezierCurveLineSegment;
      final THBezierCurveLineSegment nextSegment =
          lineSegments[3] as THBezierCurveLineSegment;
      final Offset mirroredAltControlPoint2 =
          (currentSegment.endPoint.coordinates * 2) -
          expectedSeparateControlPoint1;

      expect(
        currentSegment.controlPoint2.coordinates.dx,
        closeTo(initialControlPoint2.dx, 1e-9),
      );
      expect(
        currentSegment.controlPoint2.coordinates.dy,
        closeTo(initialControlPoint2.dy, 1e-9),
      );
      expect(
        nextSegment.controlPoint1.coordinates.dx,
        closeTo(expectedSeparateControlPoint1.dx, 1e-9),
      );
      expect(
        nextSegment.controlPoint1.coordinates.dy,
        closeTo(expectedSeparateControlPoint1.dy, 1e-9),
      );
      expect(
        (currentSegment.controlPoint2.coordinates.dx -
                mirroredAltControlPoint2.dx)
            .abs(),
        greaterThan(1e-6),
      );
      expect(
        (currentSegment.controlPoint2.coordinates.dy -
                mirroredAltControlPoint2.dy)
            .abs(),
        greaterThan(1e-6),
      );
    });

    testWidgets(
      'Shift constrains the first Mapiah quadratic segment to the snap angle',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        final double originalSnapAngle = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_SnapAngle);
        const double snapAngle = 45.0;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.mapiahQuadratic,
        );
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_SnapAngle,
          snapAngle,
        );

        try {
          final ({TH2File th2File, TH2FileEditController th2Controller})
          editor = await _pumpEditor(tester, mpLocator);
          final Finder listenerFinder = find.byKey(
            ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
          );
          final Offset origin = tester.getTopLeft(listenerFinder);
          final Offset p1Local = const Offset(120, 120);
          final Offset unconstrainedP2Local = const Offset(250, 240);
          final Offset p1 = origin + p1Local;
          final Offset unconstrainedP2 = origin + unconstrainedP2Local;
          final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

          await _enterAddLineMode(tester, editor.th2Controller);
          await _clickMouse(tester, mouse, p1);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();
          await _clickMouse(tester, mouse, unconstrainedP2);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();

          final THLineSegment lastLineSegment = _getLastLineSegment(
            editor.th2File,
          );
          final Offset constrainedP2 = editor.th2Controller
              .offsetCanvasToScreen(lastLineSegment.endPoint.coordinates);
          final Offset constrainedDirection = constrainedP2 - p1Local;
          final double constrainedAngleDegrees =
              math.atan2(constrainedDirection.dy, constrainedDirection.dx) *
              180 /
              math.pi;

          expect(
            constrainedDirection.distance,
            closeTo((unconstrainedP2Local - p1Local).distance, 1e-6),
          );
          expect(constrainedAngleDegrees, closeTo(45.0, 1e-6));
          expect(
            (constrainedP2.dx - unconstrainedP2Local.dx).abs(),
            greaterThan(1e-6),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_SnapAngle,
            originalSnapAngle,
          );
        }
      },
    );

    testWidgets(
      'Shift constrains later Mapiah quadratic nodes relative to the previous node',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        final double originalSnapAngle = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_SnapAngle);
        const double snapAngle = 45.0;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.mapiahQuadratic,
        );
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_SnapAngle,
          snapAngle,
        );

        try {
          final ({TH2File th2File, TH2FileEditController th2Controller})
          editor = await _pumpEditor(tester, mpLocator);
          final Finder listenerFinder = find.byKey(
            ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
          );
          final Offset origin = tester.getTopLeft(listenerFinder);
          final Offset p1Local = const Offset(120, 120);
          final Offset unconstrainedP2Local = const Offset(250, 240);
          final Offset unconstrainedP3Local = const Offset(280, 380);
          final Offset p1 = origin + p1Local;
          final Offset unconstrainedP2 = origin + unconstrainedP2Local;
          final Offset unconstrainedP3 = origin + unconstrainedP3Local;
          final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

          await _enterAddLineMode(tester, editor.th2Controller);
          await _clickMouse(tester, mouse, p1);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();
          await _clickMouse(tester, mouse, unconstrainedP2);
          await _clickMouse(tester, mouse, unconstrainedP3);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();

          final THLine line = editor.th2File.getLines().first;
          final List<THLineSegment> lineSegments = line.getLineSegments(
            editor.th2File,
          );
          final THLineSegment secondSegment = lineSegments[1];
          final THLineSegment thirdSegment = lineSegments[2];
          final Offset constrainedP2 = editor.th2Controller
              .offsetCanvasToScreen(secondSegment.endPoint.coordinates);
          final Offset constrainedP3 = editor.th2Controller
              .offsetCanvasToScreen(thirdSegment.endPoint.coordinates);
          final Offset constrainedDirection = constrainedP3 - constrainedP2;
          final double constrainedAngleDegrees =
              math.atan2(constrainedDirection.dy, constrainedDirection.dx) *
              180 /
              math.pi;

          expect(
            constrainedDirection.distance,
            closeTo((unconstrainedP3Local - constrainedP2).distance, 1e-6),
          );
          expect(constrainedAngleDegrees, closeTo(90.0, 1e-6));
          expect(
            (constrainedP3.dx - unconstrainedP3Local.dx).abs(),
            greaterThan(1e-6),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_SnapAngle,
            originalSnapAngle,
          );
        }
      },
    );

    testWidgets(
      'Shift constrains the first xTherion segment to the snap angle',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        final double originalSnapAngle = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_SnapAngle);
        const double snapAngle = 45.0;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_SnapAngle,
          snapAngle,
        );

        try {
          final ({TH2File th2File, TH2FileEditController th2Controller})
          editor = await _pumpEditor(tester, mpLocator);
          final Finder listenerFinder = find.byKey(
            ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
          );
          final Offset origin = tester.getTopLeft(listenerFinder);
          final Offset p1Local = const Offset(120, 120);
          final Offset unconstrainedP2Local = const Offset(250, 240);
          final Offset p1 = origin + p1Local;
          final Offset unconstrainedP2 = origin + unconstrainedP2Local;
          final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

          await _enterAddLineMode(tester, editor.th2Controller);
          await _clickMouse(tester, mouse, p1);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();
          await _clickMouse(tester, mouse, unconstrainedP2);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();

          final THLineSegment lastLineSegment = _getLastLineSegment(
            editor.th2File,
          );
          final Offset constrainedP2 = editor.th2Controller
              .offsetCanvasToScreen(lastLineSegment.endPoint.coordinates);
          final Offset constrainedDirection = constrainedP2 - p1Local;
          final double constrainedAngleDegrees =
              math.atan2(constrainedDirection.dy, constrainedDirection.dx) *
              180 /
              math.pi;

          expect(
            constrainedDirection.distance,
            closeTo((unconstrainedP2Local - p1Local).distance, 1e-6),
          );
          expect(constrainedAngleDegrees, closeTo(45.0, 1e-6));
          expect(
            (constrainedP2.dx - unconstrainedP2Local.dx).abs(),
            greaterThan(1e-6),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_SnapAngle,
            originalSnapAngle,
          );
        }
      },
    );

    testWidgets(
      'Shift constrains later xTherion nodes relative to the previous node',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        final double originalSnapAngle = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_SnapAngle);
        const double snapAngle = 45.0;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_SnapAngle,
          snapAngle,
        );

        try {
          final ({TH2File th2File, TH2FileEditController th2Controller})
          editor = await _pumpEditor(tester, mpLocator);
          final Finder listenerFinder = find.byKey(
            ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
          );
          final Offset origin = tester.getTopLeft(listenerFinder);
          final Offset p1Local = const Offset(120, 120);
          final Offset unconstrainedP2Local = const Offset(250, 240);
          final Offset unconstrainedP3Local = const Offset(280, 380);
          final Offset p1 = origin + p1Local;
          final Offset unconstrainedP2 = origin + unconstrainedP2Local;
          final Offset unconstrainedP3 = origin + unconstrainedP3Local;
          final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

          await _enterAddLineMode(tester, editor.th2Controller);
          await _clickMouse(tester, mouse, p1);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();
          await _clickMouse(tester, mouse, unconstrainedP2);
          await _clickMouse(tester, mouse, unconstrainedP3);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();

          final THLine line = editor.th2File.getLines().first;
          final List<THLineSegment> lineSegments = line.getLineSegments(
            editor.th2File,
          );
          final THLineSegment secondSegment = lineSegments[1];
          final THLineSegment thirdSegment = lineSegments[2];
          final Offset constrainedP2 = editor.th2Controller
              .offsetCanvasToScreen(secondSegment.endPoint.coordinates);
          final Offset constrainedP3 = editor.th2Controller
              .offsetCanvasToScreen(thirdSegment.endPoint.coordinates);
          final Offset constrainedDirection = constrainedP3 - constrainedP2;
          final double constrainedAngleDegrees =
              math.atan2(constrainedDirection.dy, constrainedDirection.dx) *
              180 /
              math.pi;

          expect(
            constrainedDirection.distance,
            closeTo((unconstrainedP3Local - constrainedP2).distance, 1e-6),
          );
          expect(constrainedAngleDegrees, closeTo(90.0, 1e-6));
          expect(
            (constrainedP3.dx - unconstrainedP3Local.dx).abs(),
            greaterThan(1e-6),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_SnapAngle,
            originalSnapAngle,
          );
        }
      },
    );

    testWidgets(
      'Arrow moves the last created xTherion node by the nudge factor',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        final double originalNudgeFactor = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor);
        const double nudgeFactor = 3.0;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_NudgeFactor,
          nudgeFactor,
        );

        try {
          final ({TH2File th2File, TH2FileEditController th2Controller})
          editor = await _pumpEditor(tester, mpLocator);
          final Finder listenerFinder = find.byKey(
            ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
          );
          final Offset origin = tester.getTopLeft(listenerFinder);
          final Offset p1 = origin + const Offset(120, 120);
          final Offset p2 = origin + const Offset(240, 160);
          final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

          await _enterAddLineMode(tester, editor.th2Controller);
          await _clickMouse(tester, mouse, p1);
          await _clickMouse(tester, mouse, p2);

          final THLineSegment originalLastSegment = _getLastLineSegment(
            editor.th2File,
          );

          await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();

          final THLineSegment movedLastSegment = _getLastLineSegment(
            editor.th2File,
          );

          expect(
            movedLastSegment.endPoint.coordinates.dx,
            closeTo(
              originalLastSegment.endPoint.coordinates.dx + nudgeFactor,
              1e-9,
            ),
          );
          expect(
            movedLastSegment.endPoint.coordinates.dy,
            closeTo(originalLastSegment.endPoint.coordinates.dy, 1e-9),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_NudgeFactor,
            originalNudgeFactor,
          );
        }
      },
    );

    testWidgets(
      'Shift+Arrow moves the last created xTherion node by ten times the nudge factor',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        final double originalNudgeFactor = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor);
        const double nudgeFactor = 2.0;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_NudgeFactor,
          nudgeFactor,
        );

        try {
          final ({TH2File th2File, TH2FileEditController th2Controller})
          editor = await _pumpEditor(tester, mpLocator);
          final Finder listenerFinder = find.byKey(
            ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
          );
          final Offset origin = tester.getTopLeft(listenerFinder);
          final Offset p1 = origin + const Offset(120, 120);
          final Offset p2 = origin + const Offset(240, 160);
          final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

          await _enterAddLineMode(tester, editor.th2Controller);
          await _clickMouse(tester, mouse, p1);
          await _clickMouse(tester, mouse, p2);

          final THLineSegment originalLastSegment = _getLastLineSegment(
            editor.th2File,
          );

          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();

          final THLineSegment movedLastSegment = _getLastLineSegment(
            editor.th2File,
          );

          expect(
            movedLastSegment.endPoint.coordinates.dx,
            closeTo(originalLastSegment.endPoint.coordinates.dx, 1e-9),
          );
          expect(
            movedLastSegment.endPoint.coordinates.dy,
            closeTo(
              originalLastSegment.endPoint.coordinates.dy +
                  (nudgeFactor * 10.0),
              1e-9,
            ),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_NudgeFactor,
            originalNudgeFactor,
          );
        }
      },
    );

    testWidgets(
      'Arrow moves the last created Mapiah quadratic node by the nudge factor',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        final double originalNudgeFactor = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor);
        const double nudgeFactor = 3.0;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.mapiahQuadratic,
        );
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_NudgeFactor,
          nudgeFactor,
        );

        try {
          final ({TH2File th2File, TH2FileEditController th2Controller})
          editor = await _pumpEditor(tester, mpLocator);
          final Finder listenerFinder = find.byKey(
            ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
          );
          final Offset origin = tester.getTopLeft(listenerFinder);
          final Offset p1 = origin + const Offset(120, 120);
          final Offset p2 = origin + const Offset(240, 160);
          final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

          await _enterAddLineMode(tester, editor.th2Controller);
          await _clickMouse(tester, mouse, p1);
          await _clickMouse(tester, mouse, p2);

          final THLineSegment originalLastSegment = _getLastLineSegment(
            editor.th2File,
          );

          await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();

          final THLineSegment movedLastSegment = _getLastLineSegment(
            editor.th2File,
          );

          expect(
            movedLastSegment.endPoint.coordinates.dx,
            closeTo(
              originalLastSegment.endPoint.coordinates.dx + nudgeFactor,
              1e-9,
            ),
          );
          expect(
            movedLastSegment.endPoint.coordinates.dy,
            closeTo(originalLastSegment.endPoint.coordinates.dy, 1e-9),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_NudgeFactor,
            originalNudgeFactor,
          );
        }
      },
    );

    testWidgets(
      'Shift+Arrow moves the last created Mapiah quadratic node by ten times the nudge factor',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        final double originalNudgeFactor = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor);
        const double nudgeFactor = 2.0;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.mapiahQuadratic,
        );
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_NudgeFactor,
          nudgeFactor,
        );

        try {
          final ({TH2File th2File, TH2FileEditController th2Controller})
          editor = await _pumpEditor(tester, mpLocator);
          final Finder listenerFinder = find.byKey(
            ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
          );
          final Offset origin = tester.getTopLeft(listenerFinder);
          final Offset p1 = origin + const Offset(120, 120);
          final Offset p2 = origin + const Offset(240, 160);
          final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

          await _enterAddLineMode(tester, editor.th2Controller);
          await _clickMouse(tester, mouse, p1);
          await _clickMouse(tester, mouse, p2);

          final THLineSegment originalLastSegment = _getLastLineSegment(
            editor.th2File,
          );

          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowUp);
          await tester.pump();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();

          final THLineSegment movedLastSegment = _getLastLineSegment(
            editor.th2File,
          );

          expect(
            movedLastSegment.endPoint.coordinates.dx,
            closeTo(originalLastSegment.endPoint.coordinates.dx, 1e-9),
          );
          expect(
            movedLastSegment.endPoint.coordinates.dy,
            closeTo(
              originalLastSegment.endPoint.coordinates.dy +
                  (nudgeFactor * 10.0),
              1e-9,
            ),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_NudgeFactor,
            originalNudgeFactor,
          );
        }
      },
    );

    testWidgets(
      'Alt+Arrow moves the last created xTherion node by one screen pixel',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );

        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await _pumpEditor(tester, mpLocator);
        final Finder listenerFinder = find.byKey(
          ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
        );
        final Offset origin = tester.getTopLeft(listenerFinder);
        final Offset p1 = origin + const Offset(120, 120);
        final Offset p2 = origin + const Offset(240, 160);
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
        final double expectedCanvasStep = editor.th2Controller
            .scaleScreenToCanvas(1.0);

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);

        final THLineSegment originalLastSegment = _getLastLineSegment(
          editor.th2File,
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.pump();

        final THLineSegment movedLastSegment = _getLastLineSegment(
          editor.th2File,
        );

        expect(
          movedLastSegment.endPoint.coordinates.dx,
          closeTo(
            originalLastSegment.endPoint.coordinates.dx - expectedCanvasStep,
            1e-9,
          ),
        );
        expect(
          movedLastSegment.endPoint.coordinates.dy,
          closeTo(originalLastSegment.endPoint.coordinates.dy, 1e-9),
        );
      },
    );

    testWidgets(
      'Alt+Arrow moves the last created Mapiah quadratic node by one screen pixel',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.mapiahQuadratic,
        );

        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await _pumpEditor(tester, mpLocator);
        final Finder listenerFinder = find.byKey(
          ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
        );
        final Offset origin = tester.getTopLeft(listenerFinder);
        final Offset p1 = origin + const Offset(120, 120);
        final Offset p2 = origin + const Offset(240, 160);
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
        final double expectedCanvasStep = editor.th2Controller
            .scaleScreenToCanvas(1.0);

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);

        final THLineSegment originalLastSegment = _getLastLineSegment(
          editor.th2File,
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.pump();

        final THLineSegment movedLastSegment = _getLastLineSegment(
          editor.th2File,
        );

        expect(
          movedLastSegment.endPoint.coordinates.dx,
          closeTo(
            originalLastSegment.endPoint.coordinates.dx - expectedCanvasStep,
            1e-9,
          ),
        );
        expect(
          movedLastSegment.endPoint.coordinates.dy,
          closeTo(originalLastSegment.endPoint.coordinates.dy, 1e-9),
        );
      },
    );

    testWidgets(
      'Arrow moves the last xTherion node together with its smooth handles',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        final double originalNudgeFactor = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor);
        const double nudgeFactor = 2.5;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_NudgeFactor,
          nudgeFactor,
        );

        try {
          final ({TH2File th2File, TH2FileEditController th2Controller})
          editor = await _pumpEditor(tester, mpLocator);
          final Finder listenerFinder = find.byKey(
            ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
          );
          final Offset origin = tester.getTopLeft(listenerFinder);
          final Offset p1 = origin + const Offset(120, 120);
          final Offset p2 = origin + const Offset(240, 160);
          final Offset p3 = origin + const Offset(300, 200);
          final Offset dragPoint = origin + const Offset(350, 220);
          final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

          await _enterAddLineMode(tester, editor.th2Controller);
          await _clickMouse(tester, mouse, p1);
          await _clickMouse(tester, mouse, p2);

          await tester.sendEventToBinding(
            mouse.down(p3, buttons: kPrimaryButton),
          );
          await tester.pump();
          await tester.sendEventToBinding(
            mouse.move(dragPoint, buttons: kPrimaryButton),
          );
          await tester.pump();
          await tester.sendEventToBinding(mouse.up());
          await tester.pumpAndSettle();

          final THBezierCurveLineSegment originalLastSegment =
              _getLastBezierSegment(editor.th2File);
          final Offset originalPendingControlPoint1 = editor
              .th2Controller
              .areaLineCreationController
              .newLinePendingControlPoint1CanvasCoordinates!;

          await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();

          final THBezierCurveLineSegment movedLastSegment =
              _getLastBezierSegment(editor.th2File);
          final Offset movedPendingControlPoint1 = editor
              .th2Controller
              .areaLineCreationController
              .newLinePendingControlPoint1CanvasCoordinates!;

          expect(
            movedLastSegment.endPoint.coordinates.dx,
            closeTo(
              originalLastSegment.endPoint.coordinates.dx + nudgeFactor,
              1e-9,
            ),
          );
          expect(
            movedLastSegment.controlPoint2.coordinates.dx,
            closeTo(
              originalLastSegment.controlPoint2.coordinates.dx + nudgeFactor,
              1e-9,
            ),
          );
          expect(
            movedPendingControlPoint1.dx,
            closeTo(originalPendingControlPoint1.dx + nudgeFactor, 1e-9),
          );
          expect(
            movedLastSegment.endPoint.coordinates.dy,
            closeTo(originalLastSegment.endPoint.coordinates.dy, 1e-9),
          );
          expect(
            movedLastSegment.controlPoint2.coordinates.dy,
            closeTo(originalLastSegment.controlPoint2.coordinates.dy, 1e-9),
          );
          expect(
            movedPendingControlPoint1.dy,
            closeTo(originalPendingControlPoint1.dy, 1e-9),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_NudgeFactor,
            originalNudgeFactor,
          );
        }
      },
    );

    testWidgets(
      'xTherion mode allows dragging two consecutive segments after many updates',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );

        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await _pumpEditor(tester, mpLocator);
        final Finder listenerFinder = find.byKey(
          ValueKey('MPListenerWidget|${editor.th2File.mpID}'),
        );
        final Offset origin = tester.getTopLeft(listenerFinder);
        final Offset p1 = origin + const Offset(120, 120);
        final Offset p2 = origin + const Offset(240, 160);
        final Offset p3 = origin + const Offset(300, 200);
        final Offset p4 = origin + const Offset(380, 235);
        final List<Offset> dragPoints1 = <Offset>[
          origin + const Offset(332, 208),
          origin + const Offset(346, 216),
          origin + const Offset(360, 224),
          origin + const Offset(372, 231),
        ];
        final List<Offset> dragPoints2 = <Offset>[
          origin + const Offset(410, 255),
          origin + const Offset(430, 275),
        ];
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);
        await _dragMouse(tester, mouse, p3, dragPoints1);
        expect(tester.takeException(), isNull);

        await _dragMouse(tester, mouse, p4, dragPoints2);
        expect(tester.takeException(), isNull);

        await _finalizeLineCreation(tester);
        expect(tester.takeException(), isNull);

        final List<THLine> lines = editor.th2File.getLines().toList();
        final List<THLineSegment> lineSegments = lines.first.getLineSegments(
          editor.th2File,
        );

        expect(lines.length, 1);
        expect(lineSegments.length, 4);
        expect(lineSegments[2], isA<THBezierCurveLineSegment>());
        expect(lineSegments[3], isA<THBezierCurveLineSegment>());
      },
    );
  });
}

Future<void> _configureTestSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 720);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<({TH2File th2File, TH2FileEditController th2Controller})> _pumpEditor(
  WidgetTester tester,
  MPLocator mpLocator,
) async {
  final TH2FileEditController th2Controller = mpLocator.mpGeneralController
      .getTH2FileEditControllerForNewFile(
        scrapTHID: 'scrap-1',
        scrapOptions: const [],
        encoding: 'utf-8',
      );
  final TH2File th2File = th2Controller.th2File;

  await tester.pumpWidget(
    buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
  );
  await tester.pumpAndSettle();
  th2Controller.zoomOneToOne();

  return (th2File: th2File, th2Controller: th2Controller);
}

Future<void> _enterAddLineMode(
  WidgetTester tester,
  TH2FileEditController th2Controller,
) async {
  th2Controller.stateController.setState(MPTH2FileEditStateType.addLine);
  await tester.pump();
}

Future<void> _clickMouse(
  WidgetTester tester,
  TestPointer mouse,
  Offset position,
) async {
  await tester.sendEventToBinding(
    mouse.down(position, buttons: kPrimaryButton),
  );
  await tester.pump();
  await tester.sendEventToBinding(mouse.up());
  await tester.pumpAndSettle();
}

Future<void> _dragMouse(
  WidgetTester tester,
  TestPointer mouse,
  Offset downPosition,
  List<Offset> movePositions,
) async {
  await tester.sendEventToBinding(
    mouse.down(downPosition, buttons: kPrimaryButton),
  );
  await tester.pump();

  for (final Offset movePosition in movePositions) {
    await tester.sendEventToBinding(
      mouse.move(movePosition, buttons: kPrimaryButton),
    );
    await tester.pump();
  }

  await tester.sendEventToBinding(mouse.up());
  await tester.pumpAndSettle();
}

Future<void> _finalizeLineCreation(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
  await tester.pump();
  await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

THBezierCurveLineSegment _getLastBezierSegment(TH2File th2File) {
  final THLine line = th2File.getLines().first;
  final List<THLineSegment> lineSegments = line.getLineSegments(th2File);

  return lineSegments.last as THBezierCurveLineSegment;
}

THLineSegment _getLastLineSegment(TH2File th2File) {
  final THLine line = th2File.getLines().first;
  final List<THLineSegment> lineSegments = line.getLineSegments(th2File);

  return lineSegments.last;
}
