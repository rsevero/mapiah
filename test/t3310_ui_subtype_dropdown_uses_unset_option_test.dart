// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/widgets/mp_tile_widget.dart';
import 'package:mapiah/src/widgets/options/mp_subtype_option_widget.dart';
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

  group('UI: subtype dropdown editor uses unset entry', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      MPTextToUser.initialize();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'single selected point subtype editor uses dropdown unset instead of set and unset radios',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final String testFilename =
            './test/auxiliary/th_file_parser-00072-point_with_option_and_id.th2';
        final TH2FileEditController th2Controller = mpLocator
            .mpGeneralController
            .getTH2FileEditController(filename: testFilename);

        await tester.runAsync(() async {
          await th2Controller.load();
        });

        final TH2FileEditSelectionController selectionController =
            th2Controller.selectionController;
        final TH2File th2File = th2Controller.th2File;
        final THPoint point = th2File.getPoints().first;

        await tester.pumpWidget(
          buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
        );
        await tester.pump();

        th2Controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);

        selectionController.setSelectedElements([point]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.keyO);
        await tester.pumpAndSettle();

        final Finder editWidgetFinder = find.byWidgetPredicate((Widget widget) {
          final Key? key = widget.key;

          if (key is ValueKey<String>) {
            return key.value.startsWith('MPOptionsEditWidget|');
          }

          return false;
        });

        expect(editWidgetFinder, findsOneWidget);

        final Finder subtypeTileFinder = find.descendant(
          of: editWidgetFinder,
          matching: find.ancestor(
            of: find.text('Subtype'),
            matching: find.byType(MPTileWidget),
          ),
        );

        expect(subtypeTileFinder, findsOneWidget);

        await tester.tap(subtypeTileFinder);
        await tester.pumpAndSettle();

        final Finder subtypeWidgetFinder = find.byType(MPSubtypeOptionWidget);

        expect(subtypeWidgetFinder, findsOneWidget);
        expect(
          find.byKey(
            const ValueKey('MPSubtypeOptionWidget|RadioListTile|UNSET'),
          ),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('MPSubtypeOptionWidget|RadioListTile|SET')),
          findsNothing,
        );
        expect(find.byType(DropdownMenu<String>), findsOneWidget);

        await tester.tap(find.byType(DropdownMenu<String>));
        await tester.pumpAndSettle();

        expect(find.text('Unset').last, findsOneWidget);

        await tester.tap(find.text('Unset').last);
        await tester.pumpAndSettle();

        final Finder okButtonFinder = find.descendant(
          of: subtypeWidgetFinder,
          matching: find.widgetWithText(ElevatedButton, 'OK'),
        );

        expect(okButtonFinder, findsOneWidget);

        final ElevatedButton okButton = tester.widget<ElevatedButton>(
          okButtonFinder,
        );

        expect(okButton.onPressed, isNotNull);
      },
    );
  });
}
