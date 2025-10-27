import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
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

  group('UI: add line via mouse click + drag', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('creates a new line after two clicks and a drag', (
      tester,
    ) async {
      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
          .getTH2FileEditControllerForNewFile(
            scrapTHID: 'scrap-1',
            scrapOptions: const [],
            encoding: 'utf-8',
          );

      await tester.pumpWidget(
        MaterialApp(
          home: TH2FileEditPage(
            key: ValueKey('TH2FileEditPage|${th2Controller.thFile.filename}'),
            filename: th2Controller.thFile.filename,
            th2FileEditController: th2Controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter add-line state (equivalent to pressing the Add Line tool)
      th2Controller.stateController.setState(MPTH2FileEditStateType.addLine);
      await tester.pump();

      // Target the listener surface to send mouse events
      final listenerFinder = find.byKey(
        ValueKey('MPListenerWidget|${th2Controller.thFileMPID}'),
      );
      expect(listenerFinder, findsOneWidget);

      final Offset origin = tester.getTopLeft(listenerFinder);
      final Offset p1 = origin + const Offset(120, 120); // first click (start)
      final Offset p2 =
          origin + const Offset(240, 160); // second click (creates line)
      final Offset p3 =
          origin + const Offset(300, 200); // drag to curve the last segment

      // First click (pointer down/up) sets the start position
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.down(p1, buttons: kPrimaryButton));
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pump();

      // Second click + drag: create the line, then bend the last segment
      await tester.sendEventToBinding(mouse.down(p2, buttons: kPrimaryButton));
      await tester.pump();

      // Move enough to exceed thClickDragThreshold (2px) and update bezier
      await tester.sendEventToBinding(mouse.move(p3));
      await tester.pump(const Duration(milliseconds: 16));

      await tester.sendEventToBinding(mouse.up());
      await tester.pumpAndSettle();

      // Assert: one line exists in the THFile (under the active scrap)
      final lines = th2Controller.thFile.getLines().toList();
      expect(lines.length, 1);

      // Optional: the line should have at least one line segment
      final lineSegments = lines.first.getLineSegments(th2Controller.thFile);
      expect(lineSegments.isNotEmpty, isTrue);
    });
  });
}
