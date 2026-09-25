// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/widgets/options/mp_sketch_option_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'th_test_aux.dart';

/// A 4x3 pixels PNG image.
const String _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAQAAAADCAYAAAC09K7GAAAAEklEQVR4nGP4z8DwHxkzEBQAAGHtF+mRbBMEAAAAAElFTkSuQmCC';

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();
  late Directory tempDir;

  setUp(() {
    locator.appLocalizations = AppLocalizationsEn();
    locator.mpGeneralController.reset();
    tempDir = Directory.systemTemp.createTempSync('mapiah_t3955_');
    File(
      p.join(tempDir.path, 'sketch.png'),
    ).writeAsBytesSync(base64Decode(_pngBase64));
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  Future<TH2FileEditController> loadController(String xScale) async {
    final String th2Path = p.join(tempDir.path, 'sketch.th2');

    File(th2Path).writeAsStringSync(
      'encoding UTF-8\n'
      '##MAPIAH## image_insert_v1 {format=raster;filename=.%2Fsketch.png;'
      'xx=10;yy=20;xScale=$xScale;yScale=1;rotationCenterDx=0;'
      'rotationCenterDy=0;rotationDeg=0;pivotSet=false}\n'
      'scrap s1\n'
      'endscrap\n',
    );

    final (_, bool isSuccessful, List<String> errors) = await TH2FileParser()
        .parse(th2Path, forceNewController: true);

    expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

    final TH2FileEditController controller = locator.mpGeneralController
        .getTH2FileEditController(filename: th2Path);

    /// Raster decoding needs real async, so it is done here, inside
    /// tester.runAsync(), instead of while the widget is being tested.
    await controller.th2File.getImages().first.asRasterImage!
        .getRasterImageFrameInfo(controller);

    return controller;
  }

  Future<void> pumpSketchWidget(
    WidgetTester tester,
    TH2FileEditController controller,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Widget app({required bool showSketchWidget}) {
      return MaterialApp(
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              SizedBox.expand(key: controller.getTH2FileWidgetGlobalKey()),
              if (showSketchWidget)
                MPSketchOptionWidget(
                  th2FileEditController: controller,
                  optionInfo: MPOptionInfo(
                    type: THCommandOptionType.sketch,
                    state: MPOptionStateType.unset,
                  ),
                  outerAnchorPosition: const Offset(800, 500),
                  innerAnchorType: MPWidgetPositionType.center,
                ),
            ],
          ),
        ),
      );
    }

    /// The overlay window needs the TH2 file widget laid out before it builds.
    await tester.pumpWidget(app(showSketchWidget: false));
    await tester.pumpWidget(app(showSketchWidget: true));
    await tester.pump();
  }

  Future<void> pickLoadedImage(WidgetTester tester) async {
    await tester.tap(
      find.byKey(
        const ValueKey(
          "MPSketchOptionWidget|RadioListTile|$mpNonMultipleChoiceSetID",
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownMenu<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('./sketch.png').last);
    await tester.pumpAndSettle();
  }

  String textFieldValue(WidgetTester tester, String label) {
    final TextField field = tester.widget<TextField>(
      find.ancestor(of: find.text(label), matching: find.byType(TextField)),
    );

    return field.controller!.text;
  }

  testWidgets('picking a loaded image fills filename and lower left corner', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = (await tester.runAsync(
      () => loadController('1'),
    ))!;

    await pumpSketchWidget(tester, controller);
    await pickLoadedImage(tester);

    expect(textFieldValue(tester, 'Filename'), './sketch.png');
    expect(textFieldValue(tester, 'X'), '10');
    expect(textFieldValue(tester, 'Y'), '17');
    expect(
      find.text(AppLocalizationsEn().mpSketchTransformedImageWarning),
      findsNothing,
    );

    final ElevatedButton okButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'OK'),
    );

    expect(okButton.onPressed, isNotNull);
  });

  testWidgets('picking a scaled loaded image shows a warning', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = (await tester.runAsync(
      () => loadController('2'),
    ))!;

    await pumpSketchWidget(tester, controller);
    await pickLoadedImage(tester);

    expect(
      find.text(AppLocalizationsEn().mpSketchTransformedImageWarning),
      findsOneWidget,
    );
  });

  testWidgets('an unset sketch option starts with OK disabled', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = (await tester.runAsync(
      () => loadController('1'),
    ))!;

    await pumpSketchWidget(tester, controller);

    final ElevatedButton okButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'OK'),
    );

    expect(okButton.onPressed, isNull);
  });
}
