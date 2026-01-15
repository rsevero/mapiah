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
import 'package:mapiah/src/widgets/mp_tile_widget.dart';
import 'package:mapiah/src/widgets/options/mp_multiple_choices_widget.dart';
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

  group('UI: multiple option window open and close, set and unset option', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      MPTextToUser.initialize();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'open a file, select a line open options window, edit a multiple option, see the edit option window close after edit',
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

        final Finder mpTileWidgetWithVisibilityFinder = find.descendant(
          of: editWidgetFinder,
          matching: find.ancestor(
            of: find.text('Visibility'),
            matching: find.byType(MPTileWidget),
          ),
        );

        expect(mpTileWidgetWithVisibilityFinder, findsOneWidget);

        // check MPTileWidget background color equals
        // theme.colorScheme.surfaceContainer, i.e., is unset.
        final MPTileWidget mpTileWidgetVisibilityPre = tester
            .widget<MPTileWidget>(mpTileWidgetWithVisibilityFinder);

        final Color unsetExpectedColor = Theme.of(
          tester.element(editWidgetFinder),
        ).colorScheme.surfaceContainer;

        expect(mpTileWidgetVisibilityPre.backgroundColor, unsetExpectedColor);

        // tap the MPTileWidget and verify MPMultipleOptionWidget opens
        await tester.tap(mpTileWidgetWithVisibilityFinder);
        await tester.pumpAndSettle();

        final Finder mpVisibilityOptionFinder = find.byType(
          MPMultipleChoicesWidget,
        );

        expect(mpVisibilityOptionFinder, findsOneWidget);

        // Click the RadioListTile to select the OFF option
        final Finder offRadioFinder = find.byKey(
          const ValueKey(
            'MPMultipleChoicesWidget|visibility|RadioListTile|off',
          ),
        );

        expect(offRadioFinder, findsOneWidget);
        await tester.ensureVisible(offRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(offRadioFinder);
        await tester.pumpAndSettle();

        // // check MPTileWidget background color equals
        // // theme.colorScheme.tertiaryFixed, i.e., is set.
        final MPTileWidget mpTileWidgetVisibilityPos = tester
            .widget<MPTileWidget>(mpTileWidgetWithVisibilityFinder);

        final Color setExpectedColor = Theme.of(
          tester.element(editWidgetFinder),
        ).colorScheme.tertiaryFixed;

        expect(mpTileWidgetVisibilityPos.backgroundColor, setExpectedColor);

        // Verify the MPMultipleChoicesWidget is gone after selecting an option
        expect(find.byType(MPMultipleChoicesWidget), findsNothing);

        // tap the MPTileWidget and verify MPMultipleOptionWidget opens
        await tester.tap(mpTileWidgetWithVisibilityFinder);
        await tester.pumpAndSettle();

        expect(mpVisibilityOptionFinder, findsOneWidget);

        // Click the RadioListTile to select the UNSET option
        final Finder unsetRadioFinder = find.byKey(
          const ValueKey(
            'MPMultipleChoicesWidget|visibility|RadioListTile|UNSET',
          ),
        );

        expect(unsetRadioFinder, findsOneWidget);
        await tester.ensureVisible(unsetRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(unsetRadioFinder);
        await tester.pumpAndSettle();

        // check MPTileWidget background color equals
        // theme.colorScheme.surfaceContainer, i.e., is unset.
        final MPTileWidget mpTileWidgetVisibilityPosUnset = tester
            .widget<MPTileWidget>(mpTileWidgetWithVisibilityFinder);

        expect(
          mpTileWidgetVisibilityPosUnset.backgroundColor,
          unsetExpectedColor,
        );

        // Verify the MPMultipleChoicesWidget is gone after selecting an option
        expect(find.byType(MPMultipleChoicesWidget), findsNothing);
      },
    );
  });
}
