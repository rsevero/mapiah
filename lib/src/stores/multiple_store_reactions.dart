import 'package:mapiah/main.dart';
import 'package:mapiah/src/stores/mp_settings_store.dart';
import 'package:mapiah/src/stores/th_file_edit_store.dart';
import 'package:mobx/mobx.dart';

class MultipleStoreReactions {
  final updateLineThicknessOnCanvas = autorun((_) {
    final THFileEditStore thFileEditStore = getIt<THFileEditStore>();

    thFileEditStore.lineThicknessOnCanvas =
        getIt<MPSettingsStore>().lineThickness / thFileEditStore.canvasScale;
  });

  final updatePointRadiusOnCanvas = autorun((_) {
    final THFileEditStore thFileEditStore = getIt<THFileEditStore>();

    thFileEditStore.pointRadiusOnCanvas =
        getIt<MPSettingsStore>().pointRadius / thFileEditStore.canvasScale;
  });

  final updateSelectionToleranceSquaredOnCanvas = autorun((_) {
    final THFileEditStore thFileEditStore = getIt<THFileEditStore>();
    final double selectionTolerance =
        getIt<MPSettingsStore>().selectionTolerance;

    thFileEditStore.selectionToleranceSquaredOnCanvas =
        (selectionTolerance * selectionTolerance) / thFileEditStore.canvasScale;
  });
}
