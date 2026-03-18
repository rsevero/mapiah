// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
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
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: TH2FileEditPage(
        key: ValueKey('TH2FileEditPage|${th2File.filename}'),
        filename: th2File.filename,
        th2FileEditController: th2Controller,
      ),
    ),
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
