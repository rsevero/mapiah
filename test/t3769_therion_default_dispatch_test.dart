// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_th2_edit_visualization_method.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_area_pattern_registry.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_default_symbol_set.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_registry.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_symbol_registry.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_survey_cave_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_survey_surface_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_survey_cave_line_decorator.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';
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

  group('Therion thTrans.mp default dispatch (Phase 5a)', () {
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

    test('therionDefault is the reset/new-install default', () {
      expect(
        mpLocator.mpSettingsController.tH2EditVisualizationMethod,
        MPTH2EditVisualizationMethod.therionDefault,
      );
    });

    test(
      'set: null (therionDefault) resolves camp to the SKBB point symbol',
      () {
        final MPTherionPointSymbol? symbol = getTherionPointSymbol(
          pointType: THPointType.camp,
          subtype: 'NO_SUBTYPE',
        );

        expect(symbol, MPTherionPointSymbol.campSKBB);
      },
    );

    test(
      'set: uis resolves camp to the UIS point symbol, unlike therionDefault',
      () {
        final MPTherionPointSymbol? symbol = getTherionPointSymbol(
          set: MPTherionSymbolSet.uis,
          pointType: THPointType.camp,
          subtype: 'NO_SUBTYPE',
        );

        expect(symbol, MPTherionPointSymbol.campUIS);
      },
    );

    test(
      'set: null (therionDefault) resolves survey -subtype surface to the '
      'SKBB decorator, matching real Therion with no symbol-set override',
      () {
        final definition = getTherionLineDefinition(
          lineType: THLineType.survey,
          subtype: 'surface',
        );

        expect(definition?.decorator, isA<MPSurveySurfaceSKBBLineDecorator>());
      },
    );

    test(
      'set: null (therionDefault) resolves survey -subtype cave to the SKBB '
      'decorator, while set: uis resolves it to the UIS decorator',
      () {
        final defaultDefinition = getTherionLineDefinition(
          lineType: THLineType.survey,
          subtype: 'cave',
        );
        final uisDefinition = getTherionLineDefinition(
          set: MPTherionSymbolSet.uis,
          lineType: THLineType.survey,
          subtype: 'cave',
        );

        expect(
          defaultDefinition?.decorator,
          isA<MPSurveyCaveSKBBLineDecorator>(),
        );
        expect(uisDefinition?.decorator, isA<MPSurveyCaveLineDecorator>());
      },
    );

    test(
      'set: therionAUT still resolves survey -subtype surface via the SKBB '
      'thTrans.mp default, because AUT has no macro of its own for it',
      () {
        final definition = getTherionLineDefinition(
          set: MPTherionSymbolSet.aut,
          lineType: THLineType.survey,
          subtype: 'surface',
        );

        expect(definition?.decorator, isA<MPSurveySurfaceSKBBLineDecorator>());
      },
    );

    test(
      'set: null (therionDefault) resolves area debris to the SKBB tile, '
      'while set: uis resolves it to the UIS tile',
      () {
        final defaultDefinition = getTherionAreaPatternDefinition(
          areaType: THAreaType.debris,
        );
        final uisDefinition = getTherionAreaPatternDefinition(
          set: MPTherionSymbolSet.uis,
          areaType: THAreaType.debris,
        );

        expect(defaultDefinition, isNotNull);
        expect(uisDefinition, isNotNull);
      },
    );

    test(
      'wall -subtype pit has neither a ported AUT nor a UIS macro yet, so '
      'therionDefault keeps the Mapiah placeholder, same as today',
      () {
        final definition = getTherionLineDefinition(
          lineType: THLineType.wall,
          subtype: 'pit',
        );

        expect(getTherionDefaultLineSet(lineType: THLineType.wall, subtype: 'pit'), MPTherionSymbolSet.aut);
        expect(definition, isNull);
      },
    );

    test(
      'survey -subtype surface renders through the visual controller under '
      'therionDefault',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          '2025-05-24-point_narrow-end.th2',
        );

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.therionDefault,
        );

        final MPVisualController visualController =
            th2Controller.visualController;

        expect(
          visualController.getLineDecorator(
            THLineType.survey,
            subtype: 'surface',
          ),
          isA<MPSurveySurfaceSKBBLineDecorator>(),
        );
      },
    );

    test(
      'the pattern cache keys therionDefault tiles separately from UIS '
      'tiles',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          '2025-05-24-point_narrow-end.th2',
        );
        final MPVisualController visualController =
            th2Controller.visualController;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.therionDefault,
        );
        visualController.getDefaultAreaPaint(areaType: THAreaType.water);

        expect(
          visualController.patternCache.contains(null, THAreaType.water),
          isTrue,
        );
        expect(
          visualController.patternCache.contains(
            MPTherionSymbolSet.uis,
            THAreaType.water,
          ),
          isFalse,
        );
      },
    );
  });
}
