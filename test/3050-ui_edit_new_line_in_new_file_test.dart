import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
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

  group('UI: edit new line in new file', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('creates a new line after two clicks and a drag', (
      tester,
    ) async {
      // Increase test surface to avoid BottomAppBar Row overflow in small test window
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
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: TH2FileEditPage(
            key: ValueKey('TH2FileEditPage|${th2Controller.thFile.filename}'),
            filename: th2Controller.thFile.filename,
            th2FileEditController: th2Controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the Add Element FAB is present by hero tag before changing state
      // Note: The heroTag uses the enum name, so 'addLine' becomes 'add_element_addLine'.
      // Initially, the active button is 'addElement'.
      final Finder addElementHero = find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'add_element_addElement',
        description: 'Hero(tag: add_element_addElement)',
      );
      expect(addElementHero, findsOneWidget);

      th2Controller.zoomOneToOne();

      // Enter add-line state (equivalent to pressing the Add Line tool)
      th2Controller.stateController.setState(MPTH2FileEditStateType.addLine);
      await tester.pump();

      // After switching to addLine state, the active FAB hero tag changes accordingly.
      final Finder addLineHero = find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'add_element_addLine',
        description: 'Hero(tag: add_element_addLine)',
      );
      expect(addLineHero, findsOneWidget);

      // Target the listener surface to send mouse events
      final Finder listenerFinder = find.byKey(
        ValueKey('MPListenerWidget|${th2Controller.thFileMPID}'),
      );
      expect(listenerFinder, findsOneWidget);

      final Offset origin = tester.getTopLeft(listenerFinder);
      final Offset p1 = origin + const Offset(120, 120); // first click (start)
      final Offset p2 =
          origin + const Offset(240, 160); // second click (creates line)
      final Offset p3 =
          origin + const Offset(300, 200); // third click (third line point)

      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(mouse.down(p1, buttons: kPrimaryButton));
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pump();

      await tester.sendEventToBinding(mouse.down(p2, buttons: kPrimaryButton));
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pump();

      await tester.sendEventToBinding(mouse.down(p3, buttons: kPrimaryButton));
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pumpAndSettle();

      // After three clicks, press Enter to finalize the line creation.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Assert: one line exists in the THFile
      final List<THLine> lines = th2Controller.thFile.getLines().toList();
      expect(lines.length, 1);

      final List<THLineSegment> lineSegments = lines.first.getLineSegments(
        th2Controller.thFile,
      );
      expect(lineSegments.length == 3, isTrue);

      // The node edit FAB should be present
      final Finder nodeEditFinder = find.byWidgetPredicate(
        (w) => w is FloatingActionButton && w.heroTag == 'node_edit_tool',
        description: "FloatingActionButton(heroTag: node_edit_tool)",
      );
      expect(nodeEditFinder, findsOneWidget);

      // Click the node-edit FAB (heroTag: 'node_edit_tool').
      await tester.tap(nodeEditFinder);
      await tester.pumpAndSettle();

      // Selecting the line to enable node edit FAB.
      await tester.sendEventToBinding(mouse.down(p1, buttons: kPrimaryButton));
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pump();

      expect(
        th2Controller.selectionController.mpSelectedElementsLogical.length == 1,
        isTrue,
      );

      // Check controller flag that governs the FAB appearance/availability
      expect(th2Controller.enableNodeEditButton, isTrue);
    });
  });
}
