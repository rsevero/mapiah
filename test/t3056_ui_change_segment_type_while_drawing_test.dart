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

  group('UI: change segment type while drawing (Shift+L / Shift+U)', () {
    setUp(() async {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      await mpLocator.mpSettingsController.initialized;
      mpLocator.mpSettingsController.reset();
    });

    testWidgets('Shift+L converts last bezier segment to straight (xTherion)', (
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
      final Offset dragPoint = origin + const Offset(350, 220);
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

      await _enterAddLineMode(tester, editor.th2Controller);
      await _clickMouse(tester, mouse, p1);
      await _clickMouse(tester, mouse, p2);
      await _dragMouse(tester, mouse, p3, [dragPoint]);

      expect(
        _getLastLineSegment(editor.th2File),
        isA<THBezierCurveLineSegment>(),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyL);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyL);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(_getLastLineSegment(editor.th2File), isA<THStraightLineSegment>());
      expect(
        editor
            .th2Controller
            .areaLineCreationController
            .newLinePendingControlPoint1CanvasCoordinates,
        isNull,
      );
    });

    testWidgets(
      'Shift+L converts last bezier segment to straight (Mapiah quadratic)',
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
        final Offset p3 = origin + const Offset(300, 200);
        final Offset dragPoint = origin + const Offset(350, 260);
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);
        await _dragMouse(tester, mouse, p3, [dragPoint]);

        expect(
          _getLastLineSegment(editor.th2File),
          isA<THBezierCurveLineSegment>(),
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyL);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyL);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        expect(
          _getLastLineSegment(editor.th2File),
          isA<THStraightLineSegment>(),
        );
      },
    );

    testWidgets(
      'Shift+L preserves the segment endpoint when converting to straight',
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
        final Offset dragPoint = origin + const Offset(350, 220);
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);
        await _dragMouse(tester, mouse, p3, [dragPoint]);

        final Offset endPointBefore = _getLastLineSegment(
          editor.th2File,
        ).endPoint.coordinates;

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyL);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyL);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        final Offset endPointAfter = _getLastLineSegment(
          editor.th2File,
        ).endPoint.coordinates;

        expect(endPointAfter.dx, closeTo(endPointBefore.dx, 1e-9));
        expect(endPointAfter.dy, closeTo(endPointBefore.dy, 1e-9));
      },
    );

    testWidgets('Shift+U converts last straight segment to bezier (xTherion)', (
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
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

      await _enterAddLineMode(tester, editor.th2Controller);
      await _clickMouse(tester, mouse, p1);
      await _clickMouse(tester, mouse, p2);

      expect(_getLastLineSegment(editor.th2File), isA<THStraightLineSegment>());

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyU);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyU);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(
        _getLastLineSegment(editor.th2File),
        isA<THBezierCurveLineSegment>(),
      );
    });

    testWidgets(
      'Shift+U converts last straight segment to bezier (Mapiah quadratic)',
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

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);

        expect(
          _getLastLineSegment(editor.th2File),
          isA<THStraightLineSegment>(),
        );

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyU);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyU);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        expect(
          _getLastLineSegment(editor.th2File),
          isA<THBezierCurveLineSegment>(),
        );
      },
    );

    testWidgets(
      'Shift+U places bezier control points at 1/3 and 2/3 of the chord',
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

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);

        final THLine line = editor.th2File.getLines().first;
        final List<THLineSegment> segmentsBefore = line.getLineSegments(
          editor.th2File,
        );
        final Offset startPoint =
            segmentsBefore[segmentsBefore.length - 2].endPoint.coordinates;
        final Offset endPoint = segmentsBefore.last.endPoint.coordinates;
        final Offset chord = endPoint - startPoint;
        final Offset expectedControlPoint1 = startPoint + chord / 3;
        final Offset expectedControlPoint2 = startPoint + chord * 2 / 3;

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyU);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyU);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        final THBezierCurveLineSegment bezier =
            _getLastLineSegment(editor.th2File) as THBezierCurveLineSegment;

        expect(
          bezier.controlPoint1.coordinates.dx,
          closeTo(expectedControlPoint1.dx, 1e-9),
        );
        expect(
          bezier.controlPoint1.coordinates.dy,
          closeTo(expectedControlPoint1.dy, 1e-9),
        );
        expect(
          bezier.controlPoint2.coordinates.dx,
          closeTo(expectedControlPoint2.dx, 1e-9),
        );
        expect(
          bezier.controlPoint2.coordinates.dy,
          closeTo(expectedControlPoint2.dy, 1e-9),
        );
      },
    );

    testWidgets(
      'Shift+U preserves the segment endpoint when converting to bezier',
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

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);

        final Offset endPointBefore = _getLastLineSegment(
          editor.th2File,
        ).endPoint.coordinates;

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyU);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyU);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        final Offset endPointAfter = _getLastLineSegment(
          editor.th2File,
        ).endPoint.coordinates;

        expect(endPointAfter.dx, closeTo(endPointBefore.dx, 1e-9));
        expect(endPointAfter.dy, closeTo(endPointBefore.dy, 1e-9));
      },
    );

    testWidgets(
      'Shift+L then Shift+U round-trips back to bezier with 1/3-2/3 control points',
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
        final Offset dragPoint = origin + const Offset(350, 220);
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);
        await _dragMouse(tester, mouse, p3, [dragPoint]);

        expect(
          _getLastLineSegment(editor.th2File),
          isA<THBezierCurveLineSegment>(),
        );

        // Shift+L: bezier → straight
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyL);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyL);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        expect(
          _getLastLineSegment(editor.th2File),
          isA<THStraightLineSegment>(),
        );

        // Shift+U: straight → bezier
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyU);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyU);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        expect(
          _getLastLineSegment(editor.th2File),
          isA<THBezierCurveLineSegment>(),
        );
      },
    );

    testWidgets(
      'Shift+L has no effect when the last segment is already straight',
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

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);

        expect(
          editor.th2Controller.areaLineCreationController
              .canChangeLastSegmentToStraight(),
          isFalse,
        );

        final Offset endPointBefore = _getLastLineSegment(
          editor.th2File,
        ).endPoint.coordinates;

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyL);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyL);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        expect(
          _getLastLineSegment(editor.th2File),
          isA<THStraightLineSegment>(),
        );
        expect(
          _getLastLineSegment(editor.th2File).endPoint.coordinates,
          endPointBefore,
        );
      },
    );

    testWidgets(
      'Shift+U has no effect when the last segment is already a bezier',
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
        final Offset dragPoint = origin + const Offset(350, 220);
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await _enterAddLineMode(tester, editor.th2Controller);
        await _clickMouse(tester, mouse, p1);
        await _clickMouse(tester, mouse, p2);
        await _dragMouse(tester, mouse, p3, [dragPoint]);

        expect(
          editor.th2Controller.areaLineCreationController
              .canChangeLastSegmentToCurve(),
          isFalse,
        );

        final Offset endPointBefore = _getLastLineSegment(
          editor.th2File,
        ).endPoint.coordinates;

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyU);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyU);
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        expect(
          _getLastLineSegment(editor.th2File),
          isA<THBezierCurveLineSegment>(),
        );
        expect(
          _getLastLineSegment(editor.th2File).endPoint.coordinates,
          endPointBefore,
        );
      },
    );

    testWidgets(
      'canChangeLastSegmentToStraight is false before any node is placed',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );

        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await _pumpEditor(tester, mpLocator);

        await _enterAddLineMode(tester, editor.th2Controller);

        expect(
          editor.th2Controller.areaLineCreationController
              .canChangeLastSegmentToStraight(),
          isFalse,
        );
      },
    );

    testWidgets(
      'canChangeLastSegmentToCurve is false before any node is placed',
      (WidgetTester tester) async {
        await _configureTestSurface(tester);
        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );

        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await _pumpEditor(tester, mpLocator);

        await _enterAddLineMode(tester, editor.th2Controller);

        expect(
          editor.th2Controller.areaLineCreationController
              .canChangeLastSegmentToCurve(),
          isFalse,
        );
      },
    );
  });
}

Future<void> _configureTestSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 600));
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1.0;
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

THLineSegment _getLastLineSegment(TH2File th2File) {
  final THLine line = th2File.getLines().first;
  final List<THLineSegment> lineSegments = line.getLineSegments(th2File);

  return lineSegments.last;
}
