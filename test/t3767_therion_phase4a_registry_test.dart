// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_th2_edit_visualization_method.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_area_pattern_registry.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_registry.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_symbol_registry.dart';
import 'package:mapiah/src/painters/therion_uis/mp_gradient_line_decorator.dart';
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

  group('Therion Phase 4A registry infrastructure', () {
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

    test(
      'MPTH2EditVisualizationMethod exposes UIS plus the seven Phase 4 sets',
      () {
        expect(MPTH2EditVisualizationMethod.values, <
          MPTH2EditVisualizationMethod
        >[
          MPTH2EditVisualizationMethod.mapiahPlaceholder,
          MPTH2EditVisualizationMethod.therionDefault,
          MPTH2EditVisualizationMethod.therionUIS,
          MPTH2EditVisualizationMethod.therionAUT,
          MPTH2EditVisualizationMethod.therionSBE,
          MPTH2EditVisualizationMethod.therionSKBB,
          MPTH2EditVisualizationMethod.therionBCRA,
          MPTH2EditVisualizationMethod.therionNSS,
          MPTH2EditVisualizationMethod.therionNZSS,
          MPTH2EditVisualizationMethod.therionASF,
        ]);
      },
    );

    test(
      'localizedLabelBuilder resolves a distinct label for every non-'
      'placeholder MPTH2EditVisualizationMethod value',
      () {
        final enumDefinition = MPSettingID.TH2Edit_VisualizationMethod
            .enumDefinition();
        final Set<String> seen = <String>{};

        for (final method in MPTH2EditVisualizationMethod.values) {
          final String label = enumDefinition.localizedLabel(
            mpLocator.appLocalizations,
            method,
          );

          expect(label, isNotEmpty);
          expect(
            seen.add(label),
            isTrue,
            reason: 'duplicate label for $method: $label',
          );
        }
      },
    );

    test(
      'every non-placeholder visualization method falls back to a known '
      'UIS point symbol before any set-specific implementation exists',
      () {
        for (final MPTherionSymbolSet set in MPTherionSymbolSet.values) {
          final MPTherionPointSymbol? symbol = getTherionPointSymbol(
            set: set,
            pointType: THPointType.narrowEnd,
            subtype: 'undefined',
          );

          expect(
            symbol,
            MPTherionPointSymbol.narrowEndUIS,
            reason: '$set should fall back to the UIS narrow-end symbol',
          );
          expect(getTherionPointDrawMethod(symbol!), isNotNull);
        }
      },
    );

    test(
      'every non-placeholder visualization method falls back to the UIS '
      'gradient line decorator before any set-specific implementation '
      'exists',
      () {
        for (final MPTherionSymbolSet set in MPTherionSymbolSet.values) {
          final definition = getTherionLineDefinition(
            set: set,
            lineType: THLineType.gradient,
          );

          expect(
            definition?.decorator,
            isA<MPGradientLineDecorator>(),
            reason: '$set should fall back to the UIS gradient decorator',
          );
        }
      },
    );

    test(
      'every non-placeholder visualization method falls back to the UIS '
      'water area pattern before any set-specific implementation exists',
      () {
        for (final MPTherionSymbolSet set in MPTherionSymbolSet.values) {
          final definition = getTherionAreaPatternDefinition(
            set: set,
            areaType: THAreaType.water,
          );

          expect(
            definition,
            isNotNull,
            reason: '$set should fall back to the UIS water pattern',
          );
        }
      },
    );

    test(
      'selecting each Phase 4 set renders the UIS point symbol/area pattern '
      'through the visual controller',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          '2025-05-24-point_narrow-end.th2',
        );
        final THPoint point = th2Controller.th2File.getPoints().single;

        for (final MPTH2EditVisualizationMethod method
            in MPTH2EditVisualizationMethod.values) {
          if (method == MPTH2EditVisualizationMethod.mapiahPlaceholder) {
            continue;
          }

          mpLocator.mpSettingsController.setEnum(
            MPSettingID.TH2Edit_VisualizationMethod,
            method,
          );

          final pointPaint = th2Controller.visualController
              .getUnselectedPointPaint(point: point, isFromActiveScrap: true);

          expect(
            pointPaint.therionSymbol,
            MPTherionPointSymbol.narrowEndUIS,
            reason: '$method should render the UIS narrow-end symbol',
          );

          final areaPaint = th2Controller.visualController.getDefaultAreaPaint(
            areaType: THAreaType.water,
          );

          expect(
            areaPaint.fillPaint?.shader,
            isNotNull,
            reason: '$method should render the UIS water pattern shader',
          );
        }
      },
    );

    test(
      'the pattern cache keys tiles by symbol set as well as area type',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          '2025-05-24-point_narrow-end.th2',
        );
        final MPVisualController visualController =
            th2Controller.visualController;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.therionUIS,
        );
        visualController.getDefaultAreaPaint(areaType: THAreaType.water);

        expect(
          visualController.patternCache.contains(
            MPTherionSymbolSet.uis,
            THAreaType.water,
          ),
          isTrue,
        );
        expect(
          visualController.patternCache.contains(
            MPTherionSymbolSet.aut,
            THAreaType.water,
          ),
          isFalse,
        );
      },
    );
  });
}
