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

  group('UI: change line type', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      MPTextToUser.initialize();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'open a file, select a line, change its type, and verify the options presented are updated',
      (tester) async {
        /// Increase test surface to avoid BottomAppBar Row overflow in small test window
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

        selectionController.setSelectedElements([linePre]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.keyO);
        await tester.pumpAndSettle();

        final Finder editWidgetFinderWall = find.byWidgetPredicate((widget) {
          final Key? k = widget.key;

          if (k is ValueKey) {
            final dynamic v = k.value;

            return (v is String) && v.startsWith('MPOptionsEditWidget|');
          }

          return false;
        }, description: 'ValueKey starts with MPOptionsEditWidget|');

        expect(editWidgetFinderWall, findsOneWidget);

        /// ID option should be present for all line types.
        Finder mpTileWidgetWithIdFinder = find.descendant(
          of: editWidgetFinderWall,
          matching: find.ancestor(
            of: find.text('ID'),
            matching: find.byType(MPTileWidget),
          ),
        );

        expect(mpTileWidgetWithIdFinder, findsOneWidget);

        /// Border option should only be present for slope lines.
        Finder mpTileWidgetWithBorderFinder = find.descendant(
          of: editWidgetFinderWall,
          matching: find.ancestor(
            of: find.text('Border'),
            matching: find.byType(MPTileWidget),
          ),
        );

        expect(mpTileWidgetWithBorderFinder, findsNothing);

        /// PLA type should be present for all line types.
        final Finder mpTileWidgetWithWallPLATypeFinder = find.descendant(
          of: editWidgetFinderWall,
          matching: find.ancestor(
            of: find.text('Wall'),
            matching: find.byType(MPTileWidget),
          ),
        );

        expect(mpTileWidgetWithWallPLATypeFinder, findsOneWidget);

        /// Tap the MPTileWidget and verify MPPLATypeOptionsOverlayWindowWidget
        /// opens.
        await tester.tap(mpTileWidgetWithWallPLATypeFinder);
        await tester.pumpAndSettle();

        final Finder mpWallPLATypeOptionOpenedFinder = find.byType(
          MPPLATypeOptionsOverlayWindowWidget,
        );

        expect(mpWallPLATypeOptionOpenedFinder, findsOneWidget);

        /// Slope line type should be present.
        Finder mpRadioListTileSlopePLATypeFinder = find.descendant(
          of: mpWallPLATypeOptionOpenedFinder,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is RadioListTile<String> && widget.value == 'slope',
            description: 'RadioListTile<String> with value "slope"',
          ),
        );

        expect(mpRadioListTileSlopePLATypeFinder, findsOneWidget);

        /// Tap the RadioListTile and verify MPPLATypeOptionsOverlayWindowWidget
        /// closes.
        await tester.ensureVisible(mpRadioListTileSlopePLATypeFinder);
        await tester.tap(mpRadioListTileSlopePLATypeFinder);
        await tester.pumpAndSettle();

        final Finder mpSlopePLATypeOptionClosedFinder = find.byType(
          MPPLATypeOptionsOverlayWindowWidget,
        );

        expect(mpSlopePLATypeOptionClosedFinder, findsNothing);

        final Finder editWidgetFinderSlope = find.byWidgetPredicate((widget) {
          final Key? k = widget.key;

          if (k is ValueKey) {
            final dynamic v = k.value;

            return (v is String) && v.startsWith('MPOptionsEditWidget|');
          }

          return false;
        }, description: 'ValueKey starts with MPOptionsEditWidget|');

        expect(editWidgetFinderSlope, findsOneWidget);

        /// ID option should be present for all line types.
        mpTileWidgetWithIdFinder = find.descendant(
          of: editWidgetFinderSlope,
          matching: find.ancestor(
            of: find.text('ID'),
            matching: find.byType(MPTileWidget),
          ),
        );

        expect(mpTileWidgetWithIdFinder, findsOneWidget);

        /// Border option should only be present for slope lines.
        mpTileWidgetWithBorderFinder = find.descendant(
          of: editWidgetFinderSlope,
          matching: find.ancestor(
            of: find.text('Border'),
            matching: find.byType(MPTileWidget),
          ),
        );

        expect(mpTileWidgetWithBorderFinder, findsOne);

        /// PLA type should be present for all line types.
        mpRadioListTileSlopePLATypeFinder = find.descendant(
          of: editWidgetFinderSlope,
          matching: find.ancestor(
            of: find.text('Slope'),
            matching: find.byType(MPTileWidget),
          ),
        );

        expect(mpRadioListTileSlopePLATypeFinder, findsOneWidget);
      },
    );
  });
}
