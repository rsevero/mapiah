// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/widgets/mp_raster_image_widget.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th2_file_tabs_page_test_aux.dart';
import 'th_test_aux.dart';

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

  group(
    'UI: zoom actions guard empty selection and keep window zoom wiring',
    () {
      setUp(() {
        mpLocator.appLocalizations = AppLocalizationsEn();
        mpLocator.mpGeneralController.reset();
      });

      test('zoom to selection is a no-op when nothing is selected', () {
        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditControllerForNewFile(
              scrapTHID: 'scrap-1',
              scrapOptions: const [],
              encoding: 'utf-8',
            );

        controller.updateScreenSize(const Size(1200.0, 800.0));
        controller.setCanvasScale(2.0);

        final double initialScale = controller.canvasScale;
        final Offset initialTranslation = controller.canvasTranslation;

        controller.zoomToFit(zoomFitToType: MPZoomToFitType.selection);

        expect(controller.canvasScale, initialScale);
        expect(controller.canvasTranslation, initialTranslation);
      });

      testWidgets(
        'zoom selection window button enters selection-window zoom state',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1280, 720);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final String testFilename = THTestAux.testPath(
            '2025-10-07-002-point.th2',
          );
          final TH2FileEditController controller = mpLocator.mpGeneralController
              .getTH2FileEditController(filename: testFilename);

          await tester.runAsync(() async {
            await controller.load();
          });

          controller.performSetZoomButtonsHovered(true);

          await tester.pumpWidget(
            buildTH2FileTabsPageTestApp(th2FileEditController: controller),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byTooltip('Zoom selection window (5)'));
          await tester.pumpAndSettle();

          expect(
            controller.stateController.state.type,
            MPTH2FileEditStateType.selectionWindowZoom,
          );
        },
      );

      testWidgets('tiny selection-window drag does not zoom to the origin', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final String testFilename = THTestAux.testPath(
          '2025-10-07-002-point.th2',
        );
        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: testFilename);

        await tester.runAsync(() async {
          await controller.load();
        });

        controller.performSetZoomButtonsHovered(true);

        await tester.pumpWidget(
          buildTH2FileTabsPageTestApp(th2FileEditController: controller),
        );
        await tester.pumpAndSettle();

        controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);

        final double initialScale = controller.canvasScale;
        final Offset initialTranslation = controller.canvasTranslation;

        await tester.tap(find.byTooltip('Zoom selection window (5)'));
        await tester.pumpAndSettle();

        final Finder canvas = find.byKey(
          ValueKey('MPListenerWidget|${controller.th2FileMPID}'),
        );
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(canvas),
        );

        await gesture.moveBy(const Offset(3.0, 3.0));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(controller.canvasScale, initialScale);
        expect(controller.canvasTranslation, initialTranslation);
        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.selectEmptySelection,
        );
      });

      testWidgets(
        'plain click in selection-window mode exits without changing zoom',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1280, 720);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final String testFilename = THTestAux.testPath(
            '2025-10-07-002-point.th2',
          );
          final TH2FileEditController controller = mpLocator.mpGeneralController
              .getTH2FileEditController(filename: testFilename);

          await tester.runAsync(() async {
            await controller.load();
          });

          await tester.pumpWidget(
            buildTH2FileTabsPageTestApp(th2FileEditController: controller),
          );
          await tester.pumpAndSettle();

          controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);
          controller.stateController.setState(
            MPTH2FileEditStateType.selectionWindowZoom,
          );

          final double initialScale = controller.canvasScale;
          final Offset initialTranslation = controller.canvasTranslation;
          final Finder canvas = find.byKey(
            ValueKey('MPListenerWidget|${controller.th2FileMPID}'),
          );

          await tester.tapAt(tester.getCenter(canvas));
          await tester.pumpAndSettle();

          expect(controller.canvasScale, initialScale);
          expect(controller.canvasTranslation, initialTranslation);
          expect(
            controller.stateController.state.type,
            MPTH2FileEditStateType.selectEmptySelection,
          );
        },
      );

      testWidgets(
        'new file with inserted jpeg zooms out to fit the full image',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1280, 720);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final TH2FileEditController controller = mpLocator.mpGeneralController
              .getTH2FileEditControllerForNewFile(
                scrapTHID: 'scrap-1',
                scrapOptions: const [],
                encoding: 'utf-8',
              );
          final String imagePath = THTestAux.testPath('jpg/2025-10-07-001.jpg');
          final MPCommand addImageCommand =
              MPCommandFactory.addImageInsertConfig(
                imageFilename: imagePath,
                th2FileEditController: controller,
              );

          controller.updateScreenSize(const Size(1280.0, 720.0));
          controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);

          final double initialScale = controller.canvasScale;
          final Offset initialTranslation = controller.canvasTranslation;

          controller.execute(addImageCommand);

          await tester.runAsync(() async {
            final MPRuntimeImageInsertConfigMixin image = controller.th2File
                .getImages()
                .first;

            if (image is MPRuntimeRasterImageInsertConfigMixin) {
              await image.getRasterImageFrameInfo(controller);
            }
          });

          controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);

          expect(controller.canvasScale, lessThan(initialScale));
          expect(controller.canvasTranslation, isNot(initialTranslation));
        },
      );

      testWidgets(
        'inserted jpeg is shown without requiring an unrelated redraw',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1280, 720);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final TH2FileEditController controller = mpLocator.mpGeneralController
              .getTH2FileEditControllerForNewFile(
                scrapTHID: 'scrap-1',
                scrapOptions: const [],
                encoding: 'utf-8',
              );
          final String imagePath = THTestAux.testPath('jpg/2025-10-07-001.jpg');
          final MPCommand addImageCommand =
              MPCommandFactory.addImageInsertConfig(
                imageFilename: imagePath,
                th2FileEditController: controller,
              );

          controller.execute(addImageCommand);

          await tester.runAsync(() async {
            final MPRuntimeImageInsertConfigMixin image = controller.th2File
                .getImages()
                .first;

            if (image is MPRuntimeRasterImageInsertConfigMixin) {
              await image.getRasterImageFrameInfo(controller);
            }
          });

          await tester.pumpWidget(
            buildTH2FileTabsPageTestApp(th2FileEditController: controller),
          );
          await tester.pump();

          expect(find.byType(MPRasterImageWidget), findsOneWidget);
        },
      );
    },
  );
}
