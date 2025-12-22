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
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_tile_widget.dart';
import 'package:mapiah/src/widgets/options/mp_id_option_widget.dart';
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

  group('UI: non multiple option window open and close', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      MPTextToUser.initialize();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'open a file, select a line open options window, edit a non multiple option, see the edit option window close after edit',
      (tester) async {
        // Increase test surface to avoid BottomAppBar Row overflow in small test window
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final String testFilename =
            './test/auxiliary/2025-10-27-001-straight_line.th2';
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

        final THLine linePre = thFile.getLines().first;

        expect(linePre.getLineSegmentMPIDs(thFile).length == 17, isTrue);

        selectionController.setSelectedElements([linePre]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.keyO);
        await tester.pumpAndSettle();

        final Finder editWidgetFinder = find.byWidgetPredicate((widget) {
          final Key? k = widget.key;

          if (k is ValueKey) {
            final dynamic v = k.value;

            return (v is String) && v.startsWith('MPOptionsEditWidget|');
          }

          return false;
        }, description: 'ValueKey starts with MPOptionsEditWidget|');

        expect(editWidgetFinder, findsOneWidget);

        final Finder mpTileWidgetWithIdFinder = find.descendant(
          of: editWidgetFinder,
          matching: find.ancestor(
            of: find.text('ID'),
            matching: find.byType(MPTileWidget),
          ),
        );

        expect(mpTileWidgetWithIdFinder, findsOneWidget);

        // check MPTileWidget background color equals
        // theme.colorScheme.surfaceContainer, i.e., is unset.
        final MPTileWidget mpTileWidgetID = tester.widget<MPTileWidget>(
          mpTileWidgetWithIdFinder,
        );

        final Color unsetExpectedColor = Theme.of(
          tester.element(editWidgetFinder),
        ).colorScheme.surfaceContainer;

        expect(mpTileWidgetID.backgroundColor, unsetExpectedColor);

        // tap the MPTileWidget and verify MPIDOptionWidget opens
        await tester.tap(mpTileWidgetWithIdFinder);
        await tester.pumpAndSettle();

        final Finder mpIDOptionFinder = find.byType(MPIDOptionWidget);

        expect(mpIDOptionFinder, findsOneWidget);

        // Click the RadioListTile to select the SET option
        final Finder setRadioFinder = find.byKey(
          const ValueKey('MPIDOptionWidget|RadioListTile|SET'),
        );

        expect(setRadioFinder, findsOneWidget);
        await tester.ensureVisible(setRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(setRadioFinder);
        await tester.pumpAndSettle();

        // Find the MPTextFieldInputWidget whose labelText == 'ID'
        final Finder idTextInputFinder = find.byWidgetPredicate((widget) {
          return widget is MPTextFieldInputWidget && widget.labelText == 'ID';
        }, description: 'MPTextFieldInputWidget with labelText == ID');

        expect(idTextInputFinder, findsOneWidget);

        // Find the TextField inside that widget and enter 'test'
        final Finder idTextFieldFinder = find.descendant(
          of: idTextInputFinder,
          matching: find.byType(TextField),
        );

        expect(idTextFieldFinder, findsOneWidget);
        await tester.enterText(idTextFieldFinder, 'test');
        await tester.pumpAndSettle();

        // Tap the Ok button inside the MPIDOptionWidget
        final Finder okButtonFinder = find.descendant(
          of: mpIDOptionFinder,
          matching: find.text('OK'),
        );

        expect(okButtonFinder, findsOneWidget);
        await tester.ensureVisible(okButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
        th2Controller.triggerOptionsListRedraw();
        await tester.pumpAndSettle();

        // check MPTileWidget background color equals
        // theme.colorScheme.tertiaryFixed, i.e., is set.
        final Color setExpectedColor = Theme.of(
          tester.element(editWidgetFinder),
        ).colorScheme.tertiaryFixed;

        expect(mpTileWidgetID.backgroundColor, setExpectedColor);

        // Verify the MPIDOptionWidget is gone after pressing Ok
        expect(find.byType(MPIDOptionWidget), findsNothing);
      },
    );
  });
}
