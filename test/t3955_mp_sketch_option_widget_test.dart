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
import 'package:mapiah/src/elements/parts/th_position_part.dart';
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
    await controller.th2File
        .getImages()
        .first
        .asRasterImage!
        .getRasterImageFrameInfo(controller);

    return controller;
  }

  Future<void> pumpSketchWidget(
    WidgetTester tester,
    TH2FileEditController controller, {
    MPOptionInfo? optionInfo,
  }) async {
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
                  optionInfo:
                      optionInfo ??
                      MPOptionInfo(
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

  Future<void> chooseSet(WidgetTester tester) async {
    await tester.tap(
      find.byKey(
        const ValueKey(
          "MPSketchOptionWidget|RadioListTile|$mpNonMultipleChoiceSetID",
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> addLoadedImage(WidgetTester tester, String filename) async {
    await tester.tap(
      find.byKey(const ValueKey('MPSketchOptionWidget|AddLoadedImage')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, filename));
    await tester.pumpAndSettle();
  }

  Finder fieldFinder(String name, int index) => find.descendant(
    of: find.byKey(ValueKey('MPSketchOptionWidget|$name|$index')),
    matching: find.byType(TextField),
    matchRoot: true,
  );

  String fieldValue(WidgetTester tester, String name, int index) {
    return tester.widget<TextField>(fieldFinder(name, index)).controller!.text;
  }

  bool isOkEnabled(WidgetTester tester) {
    return tester
            .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'OK'))
            .onPressed !=
        null;
  }

  testWidgets('adding a loaded image fills filename and lower left corner', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = (await tester.runAsync(
      () => loadController('1'),
    ))!;

    await pumpSketchWidget(tester, controller);
    await chooseSet(tester);

    expect(isOkEnabled(tester), isFalse);

    await addLoadedImage(tester, './sketch.png');

    expect(fieldValue(tester, 'Filename', 0), './sketch.png');
    expect(fieldValue(tester, 'X', 0), '10');
    expect(fieldValue(tester, 'Y', 0), '17');
    expect(
      find.text(AppLocalizationsEn().mpSketchTransformedImageWarning),
      findsNothing,
    );
    expect(isOkEnabled(tester), isTrue);
  });

  testWidgets('adding a scaled loaded image shows a warning', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = (await tester.runAsync(
      () => loadController('2'),
    ))!;

    await pumpSketchWidget(tester, controller);
    await chooseSet(tester);
    await addLoadedImage(tester, './sketch.png');

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

    expect(isOkEnabled(tester), isFalse);
  });

  testWidgets('adding a loaded image keeps the existing sketches', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = (await tester.runAsync(
      () => loadController('1'),
    ))!;
    final THSketchCommandOption option =
        THSketchCommandOption.fromStringWithParentMPID(
          parentMPID: mpParentMPIDPlaceholder,
          filename: './first.png',
          pointList: ['1', '2'],
        );

    await pumpSketchWidget(
      tester,
      controller,
      optionInfo: MPOptionInfo(
        type: THCommandOptionType.sketch,
        state: MPOptionStateType.set,
        option: option,
      ),
    );

    expect(isOkEnabled(tester), isFalse);

    await addLoadedImage(tester, './sketch.png');

    expect(fieldValue(tester, 'Filename', 0), './first.png');
    expect(fieldValue(tester, 'X', 0), '1');
    expect(fieldValue(tester, 'Y', 0), '2');
    expect(fieldValue(tester, 'Filename', 1), './sketch.png');
    expect(fieldValue(tester, 'X', 1), '10');
    expect(fieldValue(tester, 'Y', 1), '17');
    expect(isOkEnabled(tester), isTrue);
  });

  testWidgets('multiple sketches are shown and edited independently', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = (await tester.runAsync(
      () => loadController('1'),
    ))!;
    final THSketchCommandOption option =
        THSketchCommandOption.fromStringWithParentMPID(
          parentMPID: mpParentMPIDPlaceholder,
          filename: './first.png',
          pointList: ['1', '2'],
        ).copyWith(
          sketches: [
            THSketchSpec(
              filename: './first.png',
              point: THPositionPart.fromStringList(list: ['1', '2']),
            ),
            THSketchSpec(
              filename: './second.png',
              point: THPositionPart.fromStringList(list: ['3', '4']),
            ),
          ],
        );

    await pumpSketchWidget(
      tester,
      controller,
      optionInfo: MPOptionInfo(
        type: THCommandOptionType.sketch,
        state: MPOptionStateType.set,
        option: option,
      ),
    );

    expect(fieldValue(tester, 'Filename', 0), './first.png');
    expect(fieldValue(tester, 'Filename', 1), './second.png');
    expect(fieldValue(tester, 'X', 1), '3');
    expect(fieldValue(tester, 'Y', 1), '4');

    await tester.enterText(fieldFinder('X', 1), '30');
    await tester.pumpAndSettle();

    expect(fieldValue(tester, 'X', 0), '1');
    expect(fieldValue(tester, 'X', 1), '30');
    expect(isOkEnabled(tester), isTrue);

    await tester.enterText(fieldFinder('Y', 0), '');
    await tester.pumpAndSettle();

    expect(isOkEnabled(tester), isFalse);
  });

  testWidgets('removing sketches keeps the others and unsets when empty', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController controller = (await tester.runAsync(
      () => loadController('1'),
    ))!;

    await pumpSketchWidget(tester, controller);
    await chooseSet(tester);
    await addLoadedImage(tester, './sketch.png');
    await addLoadedImage(tester, './sketch.png');
    await tester.enterText(fieldFinder('X', 1), '30');
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('MPSketchOptionWidget|Remove|0')),
    );
    await tester.pumpAndSettle();

    expect(fieldFinder('Filename', 1), findsNothing);
    expect(fieldValue(tester, 'X', 0), '30');
    expect(isOkEnabled(tester), isTrue);

    await tester.tap(
      find.byKey(const ValueKey('MPSketchOptionWidget|Remove|0')),
    );
    await tester.pumpAndSettle();

    expect(fieldFinder('Filename', 0), findsNothing);
    expect(
      find.byKey(const ValueKey('MPSketchOptionWidget|AddLoadedImage')),
      findsNothing,
    );
    expect(isOkEnabled(tester), isFalse);
  });
}
