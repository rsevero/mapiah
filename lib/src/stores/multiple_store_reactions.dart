import 'package:mapiah/main.dart';
import 'package:mapiah/src/stores/mp_settings_store.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mobx/mobx.dart';

class MultipleStoreReactions {
  final updateLineThicknessOnCanvas = autorun((_) {
    final TH2FileEditStore th2FileEditStore = getIt<TH2FileEditStore>();

    th2FileEditStore.lineThicknessOnCanvas =
        getIt<MPSettingsStore>().lineThickness / th2FileEditStore.canvasScale;
  });

  final updatePointRadiusOnCanvas = autorun((_) {
    final TH2FileEditStore th2FileEditStore = getIt<TH2FileEditStore>();

    th2FileEditStore.pointRadiusOnCanvas =
        getIt<MPSettingsStore>().pointRadius / th2FileEditStore.canvasScale;
  });

  final updateSelectionToleranceSquaredOnCanvas = autorun((_) {
    final TH2FileEditStore th2FileEditStore = getIt<TH2FileEditStore>();
    final double selectionTolerance =
        getIt<MPSettingsStore>().selectionTolerance;

    th2FileEditStore.selectionToleranceSquaredOnCanvas =
        (selectionTolerance * selectionTolerance) /
            th2FileEditStore.canvasScale;
  });
}
