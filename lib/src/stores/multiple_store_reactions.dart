import 'package:mapiah/main.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/stores/mp_settings_store.dart';
import 'package:mobx/mobx.dart';

class MultipleStoreReactions {
  final updateLineThicknessOnCanvas = autorun((_) {
    final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();

    thFileDisplayStore.lineThicknessOnCanvas =
        getIt<MPSettingsStore>().lineThickness / thFileDisplayStore.canvasScale;
  });

  final updatePointRadiusOnCanvas = autorun((_) {
    final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();

    thFileDisplayStore.pointRadiusOnCanvas =
        getIt<MPSettingsStore>().pointRadius / thFileDisplayStore.canvasScale;
  });

  final updateSelectionToleranceSquaredOnCanvas = autorun((_) {
    final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();
    final double selectionTolerance =
        getIt<MPSettingsStore>().selectionTolerance;

    thFileDisplayStore.selectionToleranceSquaredOnCanvas =
        (selectionTolerance * selectionTolerance) /
            thFileDisplayStore.canvasScale;
  });
}
