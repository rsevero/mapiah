// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_th2_edit_visualization_method.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

class _LinePaintingHelper with MPLinePaintingMixin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();
  final _LinePaintingHelper paintingHelper = _LinePaintingHelper();

  group('persistent line points', () {
    late TH2FileEditController th2Controller;
    late THLine line;

    setUp(() async {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      mpLocator.mpSettingsController.resetBool(
        MPSettingID.TH2Edit_ShowLinePoints,
      );
      mpLocator.mpSettingsController.resetEnum(
        MPSettingID.TH2Edit_VisualizationMethod,
      );

      th2Controller = mpLocator.mpGeneralController.getTH2FileEditController(
        filename: THTestAux.testPath(
          'th_file_parser-03020-line_with_clip_option.th2',
        ),
      );
      await th2Controller.load();
      line = th2Controller.th2File.getLines().single;
    });

    List<THLinePainter> createPainters() {
      return paintingHelper.getLinePainters(
        line: line,
        isLineSelected: false,
        showLineDirectionTicks: false,
        isFromActiveScrap: true,
        th2FileEditController: th2Controller,
      );
    }

    test('line points are shown by default', () {
      final List<THLinePainter> painters = createPainters();

      expect(painters, isNotEmpty);
      expect(
        painters.every((THLinePainter painter) => painter.showLinePoints),
        isTrue,
      );
    });

    test('line points can be hidden', () {
      mpLocator.mpSettingsController.setBool(
        MPSettingID.TH2Edit_ShowLinePoints,
        false,
      );

      final List<THLinePainter> painters = createPainters();

      expect(painters, isNotEmpty);
      expect(
        painters.every((THLinePainter painter) => !painter.showLinePoints),
        isTrue,
      );
    });

    test('Therion-faithful lines respect hidden line points', () {
      mpLocator.mpSettingsController.setEnum(
        MPSettingID.TH2Edit_VisualizationMethod,
        MPTH2EditVisualizationMethod.therionUIS,
      );
      mpLocator.mpSettingsController.setBool(
        MPSettingID.TH2Edit_ShowLinePoints,
        false,
      );

      final List<THLinePainter> painters = createPainters();

      expect(painters, isNotEmpty);
      expect(
        painters.every(
          (THLinePainter painter) => painter.lineDecorator != null,
        ),
        isTrue,
      );
      expect(
        painters.every((THLinePainter painter) => !painter.showLinePoints),
        isTrue,
      );
    });
  });
}
