// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th_test_aux.dart';

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

  group('special line borders', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    Future<TH2FileEditController> loadController(String filename) async {
      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: THTestAux.testPath(filename));

      await th2Controller.load();

      return th2Controller;
    }

    test('slope line without l-size gets special border', () async {
      final TH2FileEditController th2Controller = await loadController(
        '2026-02-17-001-slope_straight_line.th2',
      );
      final THLine line = th2Controller.th2File.getLines().single;

      expect(line.isSlopeWithoutLSize, isTrue);

      final THLinePaint linePaint = th2Controller.visualController
          .getUnselectedLinePaint(
            lineType: line.lineType,
            lineIsSlopeWithoutLSize: line.isSlopeWithoutLSize,
            isFromActiveScrap: true,
          );

      expect(linePaint.highlightBorders, hasLength(1));
      expect(linePaint.highlightBorders.single.color, THPaint.thPaint18.color);
    });

    test('slope line with l-size does not get special border', () async {
      final TH2FileEditController th2Controller = await loadController(
        'th_file_parser-03140-linepoint_with_lsize_option.th2',
      );
      final THLine line = th2Controller.th2File.getLines().single;

      expect(line.isSlopeWithoutLSize, isFalse);

      final THLinePaint linePaint = th2Controller.visualController
          .getUnselectedLinePaint(
            lineType: line.lineType,
            lineIsSlopeWithoutLSize: line.isSlopeWithoutLSize,
            isFromActiveScrap: true,
          );

      expect(linePaint.highlightBorders, isEmpty);
    });
  });
}
