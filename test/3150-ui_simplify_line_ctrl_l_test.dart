import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
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

  group('UI: simplify line through Ctrl+L', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('open a file, select a line and simplify pressing Ctrl+L', (
      tester,
    ) async {
      // Increase test surface to avoid BottomAppBar Row overflow in small test window
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final String testFilename =
          './test/auxiliary/2025-10-27-001-straight_line.th2';
      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
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

      th2Controller.zoomOneToOne();

      final THLine linePre = thFile.getLines().first;

      expect(linePre.getLineSegmentMPIDs(thFile).length == 17, isTrue);

      selectionController.setSelectedElements([linePre]);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyL);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyL);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      final THLine linePost = thFile.getLines().first;

      expect(linePost.getLineSegmentMPIDs(thFile).length == 9, isTrue);
    });
  });
}
