import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/widgets/mp_pla_type_options_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_tile_widget.dart';
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

  group('UI: change point type to hyphenated type', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      MPTextToUser.initialize();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'open a file, select a line point, open options window, edit a non multiple option, see the edit option window close after edit',
      (tester) async {
        // Increase test surface to avoid BottomAppBar Row overflow in small test window
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final String testFilename =
            './test/auxiliary/2025-12-17-001-single_point.th2';
        final TH2FileEditController th2Controller = mpLocator
            .mpGeneralController
            .getTH2FileEditController(filename: testFilename);

        await tester.runAsync(() async {
          await th2Controller.load();
        });

        final TH2FileEditSelectionController selectionController =
            th2Controller.selectionController;
        final THFile thFile = th2Controller.thFile;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: TH2FileEditPage(
              filename: testFilename,
              th2FileEditController: th2Controller,
            ),
          ),
        );
        await tester.pump();

        th2Controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);

        final THPoint pointPre = thFile.getPoints().first;

        selectionController.setSelectedElements([pointPre]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.keyO);
        await tester.pumpAndSettle();

        final Finder editPLATypeWidgetFinder = find.byWidgetPredicate((widget) {
          final Key? k = widget.key;

          if (k is ValueKey) {
            final dynamic v = k.value;

            return (v is String) && v.startsWith('MPPLATypeWidget|');
          }

          return false;
        }, description: 'ValueKey starts with MPPLATypeWidget|');

        expect(editPLATypeWidgetFinder, findsOneWidget);

        final MPTileWidget mpTileWidgetPre = tester.widget<MPTileWidget>(
          editPLATypeWidgetFinder,
        );
        expect(mpTileWidgetPre, isA<MPTileWidget>());
        expect(mpTileWidgetPre.title, 'Anchor');

        // tap the MPTileWidget and verify MPPLATypeOptionsOverlayWindowWidget opens
        await tester.tap(editPLATypeWidgetFinder);
        await tester.pumpAndSettle();

        final Finder mpPLATypeOptionFinder = find.byType(
          MPPLATypeOptionsOverlayWindowWidget,
        );

        expect(mpPLATypeOptionFinder, findsOneWidget);

        // Click the RadioListTile to select the SET option
        final Finder setRadioFinder = find.byKey(
          const ValueKey(
            'MPPLATypeOptionWidget|RadioListTile|choices|passageHeight',
          ),
        );

        expect(setRadioFinder, findsOneWidget);
        await tester.ensureVisible(setRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(setRadioFinder);
        await tester.pumpAndSettle();

        final MPTileWidget mpTileWidgetPos = tester.widget<MPTileWidget>(
          editPLATypeWidgetFinder,
        );
        expect(mpTileWidgetPos.title, 'Passage Height');

        /// Final check
      },
    );
  });
}
