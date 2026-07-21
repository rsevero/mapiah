// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_th2_edit_visualization_method.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/painters/therion_uis/mp_gradient_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_survey_cave_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_uis_point_map.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';
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

  group('Therion UIS Phase 1 dispatch', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      mpLocator.mpSettingsController.resetEnum(
        MPSettingID.TH2Edit_VisualizationMethod,
      );
    });

    Future<TH2FileEditController> loadController(String filename) async {
      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: THTestAux.testPath(filename));

      await th2Controller.load();

      return th2Controller;
    }

    test('maps every Phase 1 point type to a UIS symbol', () {
      const List<THPointType> phase1Types = <THPointType>[
        THPointType.continuation,
        THPointType.crystal,
        THPointType.dig,
        THPointType.entrance,
        THPointType.flowstone,
        THPointType.flute,
        THPointType.ice,
        THPointType.karren,
        THPointType.lowEnd,
        THPointType.narrowEnd,
        THPointType.pillar,
        THPointType.sand,
        THPointType.sodaStraw,
        THPointType.stalactite,
        THPointType.stalagmite,
        THPointType.wallCalcite,
      ];

      for (final THPointType pointType in phase1Types) {
        expect(
          therionUISPointSymbols[pointType],
          isNotNull,
          reason: '$pointType should have a UIS symbol',
        );
      }
      expect(
        therionUISPointSymbols.length,
        greaterThanOrEqualTo(phase1Types.length),
      );
    });

    test(
      'point paint only gets a therionSymbol under the Therion UIS method',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          '2025-05-24-point_narrow-end.th2',
        );
        final THPoint point = th2Controller.th2File.getPoints().single;

        expect(point.pointType, THPointType.narrowEnd);

        final placeholderPaint = th2Controller.visualController
            .getUnselectedPointPaint(point: point, isFromActiveScrap: true);

        expect(placeholderPaint.therionSymbol, isNull);

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.therionUIS,
        );

        final therionPaint = th2Controller.visualController
            .getUnselectedPointPaint(point: point, isFromActiveScrap: true);

        expect(therionPaint.therionSymbol, MPTherionPointSymbol.narrowEndUIS);
      },
    );

    test(
      'area paint gets a pattern shader fill only under the Therion UIS method',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          '2025-05-24-point_narrow-end.th2',
        );

        final placeholderAreaPaint = th2Controller.visualController
            .getDefaultAreaPaint(areaType: THAreaType.water);

        expect(placeholderAreaPaint.fillPaint?.shader, isNull);
        expect(placeholderAreaPaint.cleanBeforeFill, isFalse);

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.therionUIS,
        );

        final therionAreaPaint = th2Controller.visualController
            .getDefaultAreaPaint(areaType: THAreaType.water);

        expect(therionAreaPaint.fillPaint?.shader, isNotNull);
        expect(therionAreaPaint.cleanBeforeFill, isTrue);

        final therionDebrisPaint = th2Controller.visualController
            .getDefaultAreaPaint(areaType: THAreaType.debris);

        expect(therionDebrisPaint.fillPaint?.shader, isNotNull);
        expect(therionDebrisPaint.cleanBeforeFill, isFalse);

        final unaffectedAreaPaint = th2Controller.visualController
            .getDefaultAreaPaint(areaType: THAreaType.bedrock);

        expect(unaffectedAreaPaint.fillPaint?.shader, isNull);
      },
    );

    test(
      'gradient lines get the arrowhead decorator only under the Therion UIS method',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          '2025-05-24-point_narrow-end.th2',
        );

        expect(
          th2Controller.visualController.getLineDecorator(THLineType.gradient),
          isNull,
        );
        expect(
          th2Controller.visualController.getLineDecorator(THLineType.wall),
          isNull,
        );

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.therionUIS,
        );

        expect(
          th2Controller.visualController.getLineDecorator(THLineType.gradient),
          isA<MPGradientLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(THLineType.wall),
          isNull,
        );
        expect(
          th2Controller.visualController.getLineDecorator(
            THLineType.survey,
            subtype: 'cave',
          ),
          isA<MPSurveyCaveLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(
            THLineType.survey,
            subtype: 'surface',
          ),
          isNull,
        );
      },
    );

    test('point orientation is carried into Therion point paint', () async {
      final TH2FileEditController th2Controller = await loadController(
        'th_file_parser-00126-point_with_orientation_option.th2',
      );
      final THPoint point = th2Controller.th2File.getPoints().single;
      final therionPaint = th2Controller.visualController.getDefaultPointPaint(
        point,
      );

      expect(therionPaint.rotation, closeTo(3.0234, 0.0001));
    });
  });
}
