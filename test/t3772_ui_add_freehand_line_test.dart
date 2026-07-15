// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
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

  Future<TH2FileEditController> buildFreehandEditor(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final TH2FileEditController th2Controller = mpLocator.mpGeneralController
        .getTH2FileEditControllerForNewFile(
          scrapTHID: 'scrap-1',
          scrapOptions: const [],
          encoding: 'utf-8',
        );

    await tester.pumpWidget(
      buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
    );
    await tester.pumpAndSettle();

    th2Controller.zoomOneToOne();
    th2Controller.stateController.setState(
      MPTH2FileEditStateType.addFreehandLine,
    );
    await tester.pump();

    return th2Controller;
  }

  Finder listenerFinder(TH2FileEditController th2Controller) {
    return find.byKey(
      ValueKey('MPListenerWidget|${th2Controller.th2FileMPID}'),
    );
  }

  Future<void> drag({
    required WidgetTester tester,
    required TestPointer pointer,
    required List<Offset> points,
  }) async {
    await tester.sendEventToBinding(
      pointer.down(points.first, buttons: kPrimaryButton),
    );
    await tester.pump();

    for (final Offset point in points.skip(1)) {
      await tester.sendEventToBinding(pointer.move(point));
      await tester.pump(const Duration(milliseconds: 16));
    }

    await tester.sendEventToBinding(pointer.up());
    await tester.pumpAndSettle();
  }

  List<Offset> strokePoints(Offset origin) => [
    origin + const Offset(0, 0),
    origin + const Offset(20, 0),
    origin + const Offset(40, 10),
    origin + const Offset(60, 30),
    origin + const Offset(80, 30),
  ];

  group('UI: add freehand line', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'dragging renders a preview without adding elements or undo entries '
      'before release',
      (tester) async {
        final TH2FileEditController th2Controller = await buildFreehandEditor(
          tester,
        );
        final Offset origin = tester.getTopLeft(listenerFinder(th2Controller));
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
        final List<Offset> points = strokePoints(origin + const Offset(50, 50));

        await tester.sendEventToBinding(
          mouse.down(points[0], buttons: kPrimaryButton),
        );
        await tester.pump();

        for (final Offset point in points.skip(1)) {
          await tester.sendEventToBinding(mouse.move(point));
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(
          th2Controller.freehandLineCreationController.isCapturing,
          isTrue,
        );
        expect(
          th2Controller.freehandLineCreationController.sampledCanvasPoints
              .length,
          greaterThan(1),
        );
        expect(th2Controller.th2File.getLines(), isEmpty);
        expect(th2Controller.undoRedoController.undoCount, 0);

        await tester.sendEventToBinding(mouse.up());
        await tester.pumpAndSettle();
      },
    );

    testWidgets('release adds exactly one THLine and one undo entry', (
      tester,
    ) async {
      final TH2FileEditController th2Controller = await buildFreehandEditor(
        tester,
      );
      final Offset origin = tester.getTopLeft(listenerFinder(th2Controller));
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

      await drag(
        tester: tester,
        pointer: mouse,
        points: strokePoints(origin + const Offset(50, 50)),
      );

      final List<THLine> lines = th2Controller.th2File.getLines().toList();

      expect(lines, hasLength(1));
      expect(th2Controller.undoRedoController.undoCount, 1);
      expect(
        th2Controller.freehandLineCreationController.isCapturing,
        isFalse,
      );

      final List<THLineSegment> lineSegments = lines.first.getLineSegments(
        th2Controller.th2File,
      );

      expect(lineSegments, isNotEmpty);
      expect(
        lineSegments.every((THLineSegment s) => s is THStraightLineSegment),
        isTrue,
      );
    });

    testWidgets(
      'undo removes the complete line; redo restores the exact segment '
      'geometry',
      (tester) async {
        final TH2FileEditController th2Controller = await buildFreehandEditor(
          tester,
        );
        final Offset origin = tester.getTopLeft(listenerFinder(th2Controller));
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await drag(
          tester: tester,
          pointer: mouse,
          points: strokePoints(origin + const Offset(50, 50)),
        );

        final THLine committedLine = th2Controller.th2File.getLines().first;
        final List<Offset> committedCoordinates = committedLine
            .getLineSegments(th2Controller.th2File)
            .map((THLineSegment s) => (s as THStraightLineSegment)
                .endPoint
                .coordinates)
            .toList();

        th2Controller.undo();
        expect(th2Controller.th2File.getLines(), isEmpty);

        th2Controller.redo();

        final List<THLine> linesAfterRedo = th2Controller.th2File.getLines()
            .toList();

        expect(linesAfterRedo, hasLength(1));

        final List<Offset> redoCoordinates = linesAfterRedo.first
            .getLineSegments(th2Controller.th2File)
            .map((THLineSegment s) => (s as THStraightLineSegment)
                .endPoint
                .coordinates)
            .toList();

        expect(redoCoordinates, committedCoordinates);
      },
    );

    testWidgets(
      'a second drag creates a second independent line without leaving the '
      'mode',
      (tester) async {
        final TH2FileEditController th2Controller = await buildFreehandEditor(
          tester,
        );
        final Offset origin = tester.getTopLeft(listenerFinder(th2Controller));
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await drag(
          tester: tester,
          pointer: mouse,
          points: strokePoints(origin + const Offset(50, 50)),
        );
        expect(
          th2Controller.stateController.state.type,
          MPTH2FileEditStateType.addFreehandLine,
        );

        await drag(
          tester: tester,
          pointer: mouse,
          points: strokePoints(origin + const Offset(300, 300)),
        );

        expect(th2Controller.th2File.getLines(), hasLength(2));
        expect(
          th2Controller.stateController.state.type,
          MPTH2FileEditStateType.addFreehandLine,
        );
      },
    );

    testWidgets(
      'Escape abandons an active stroke without modifying the file',
      (tester) async {
        final TH2FileEditController th2Controller = await buildFreehandEditor(
          tester,
        );
        final Offset origin = tester.getTopLeft(listenerFinder(th2Controller));
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
        final List<Offset> points = strokePoints(origin + const Offset(50, 50));

        await tester.sendEventToBinding(
          mouse.down(points[0], buttons: kPrimaryButton),
        );
        await tester.pump();
        await tester.sendEventToBinding(mouse.move(points[1]));
        await tester.pump(const Duration(milliseconds: 16));

        expect(
          th2Controller.freehandLineCreationController.isCapturing,
          isTrue,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(
          th2Controller.freehandLineCreationController.isCapturing,
          isFalse,
        );
        expect(th2Controller.th2File.getLines(), isEmpty);
        expect(
          th2Controller.stateController.state.type,
          MPTH2FileEditStateType.addFreehandLine,
        );

        await tester.sendEventToBinding(mouse.cancel());
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'pointer cancel abandons an active stroke without modifying the file',
      (tester) async {
        final TH2FileEditController th2Controller = await buildFreehandEditor(
          tester,
        );
        final Offset origin = tester.getTopLeft(listenerFinder(th2Controller));
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
        final List<Offset> points = strokePoints(origin + const Offset(50, 50));

        await tester.sendEventToBinding(
          mouse.down(points[0], buttons: kPrimaryButton),
        );
        await tester.pump();
        await tester.sendEventToBinding(mouse.move(points[1]));
        await tester.pump(const Duration(milliseconds: 16));

        await tester.sendEventToBinding(mouse.cancel());
        await tester.pumpAndSettle();

        expect(
          th2Controller.freehandLineCreationController.isCapturing,
          isFalse,
        );
        expect(th2Controller.th2File.getLines(), isEmpty);
      },
    );

    testWidgets(
      'a state change abandons an active preview without modifying the file',
      (tester) async {
        final TH2FileEditController th2Controller = await buildFreehandEditor(
          tester,
        );
        final Offset origin = tester.getTopLeft(listenerFinder(th2Controller));
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
        final List<Offset> points = strokePoints(origin + const Offset(50, 50));

        await tester.sendEventToBinding(
          mouse.down(points[0], buttons: kPrimaryButton),
        );
        await tester.pump();
        await tester.sendEventToBinding(mouse.move(points[1]));
        await tester.pump(const Duration(milliseconds: 16));

        expect(
          th2Controller.freehandLineCreationController.isCapturing,
          isTrue,
        );

        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
        await tester.pumpAndSettle();

        expect(
          th2Controller.freehandLineCreationController.isCapturing,
          isFalse,
        );
        expect(th2Controller.th2File.getLines(), isEmpty);

        await tester.sendEventToBinding(mouse.cancel());
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'a non-drag click clears its temporary start point and creates '
      'nothing',
      (tester) async {
        final TH2FileEditController th2Controller = await buildFreehandEditor(
          tester,
        );
        final Offset origin = tester.getTopLeft(listenerFinder(th2Controller));
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
        final Offset p1 = origin + const Offset(50, 50);

        await tester.sendEventToBinding(
          mouse.down(p1, buttons: kPrimaryButton),
        );
        await tester.pump();
        await tester.sendEventToBinding(mouse.up());
        await tester.pumpAndSettle();

        expect(
          th2Controller.freehandLineCreationController.isCapturing,
          isFalse,
        );
        expect(th2Controller.th2File.getLines(), isEmpty);
        expect(th2Controller.undoRedoController.undoCount, 0);
      },
    );

    testWidgets(
      'mouse, touch, and stylus pointer kinds use the same geometry pipeline',
      (tester) async {
        final TH2FileEditController th2Controller = await buildFreehandEditor(
          tester,
        );
        final Offset origin = tester.getTopLeft(listenerFinder(th2Controller));

        final Map<PointerDeviceKind, Offset> strokeOrigins = {
          PointerDeviceKind.mouse: origin + const Offset(50, 50),
          PointerDeviceKind.touch: origin + const Offset(300, 50),
          PointerDeviceKind.stylus: origin + const Offset(550, 50),
        };

        int pointerID = 1;

        for (final MapEntry<PointerDeviceKind, Offset> entry
            in strokeOrigins.entries) {
          final TestPointer pointer = TestPointer(pointerID++, entry.key);

          await drag(
            tester: tester,
            pointer: pointer,
            points: strokePoints(entry.value),
          );
        }

        final List<THLine> lines = th2Controller.th2File.getLines().toList();

        expect(lines, hasLength(3));

        final List<List<Offset>> relativeGeometries = lines.map((THLine line) {
          final List<Offset> coordinates = line
              .getLineSegments(th2Controller.th2File)
              .map(
                (THLineSegment s) =>
                    (s as THStraightLineSegment).endPoint.coordinates,
              )
              .toList();
          final Offset first = coordinates.first;

          return coordinates
              .map((Offset point) => point - first)
              .toList();
        }).toList();

        expect(relativeGeometries[1], relativeGeometries[0]);
        expect(relativeGeometries[2], relativeGeometries[0]);
      },
    );
  });
}
