import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mapiah/src/widgets/mp_listener_widget.dart';
import 'package:mapiah/src/widgets/mp_non_selected_elements_widget.dart';
import 'package:mapiah/src/widgets/mp_selected_elements_widget.dart';
import 'package:mapiah/src/widgets/mp_selection_handles_widget.dart';
import 'package:mapiah/src/widgets/mp_selection_window_widget.dart';

class THFileWidget extends StatelessWidget {
  final TH2FileEditStore th2FileEditStore;

  late final THFile thFile = th2FileEditStore.thFile;
  late final int thFileMapiahID = th2FileEditStore.thFileMapiahID;

  THFileWidget({required super.key, required this.th2FileEditStore});

  @override
  Widget build(BuildContext context) {
    mpLocator.mpLog.finer("THFileWidget.build()");
    return LayoutBuilder(
      builder: (context, constraints) {
        th2FileEditStore.updateScreenSize(
            Size(constraints.maxWidth, constraints.maxHeight));

        if (th2FileEditStore.canvasScaleTranslationUndefined) {
          th2FileEditStore.zoomOutAll(wholeFile: true);
        }

        return Observer(
          builder: (context) {
            mpLocator.mpLog.finer("THFileWidget Observer()");

            return MPListenerWidget(
              key: ValueKey("MPListenerWidget|$thFileMapiahID"),
              actuator: th2FileEditStore,
              child: Stack(
                children: [
                  MPNonSelectedElementsWidget(
                    key:
                        ValueKey("MPNonSelectedElementsWidget|$thFileMapiahID"),
                    th2FileEditStore: th2FileEditStore,
                  ),
                  if (th2FileEditStore.showSelectedElements)
                    MPSelectedElementsWidget(
                      key: ValueKey("MPSelectedElementsWidget|$thFileMapiahID"),
                      th2FileEditStore: th2FileEditStore,
                    ),
                  if (th2FileEditStore.showSelectionHandles)
                    MPSelectionHandlesWidget(
                      key: ValueKey("MPSelectionHandlesWidget|$thFileMapiahID"),
                      th2FileEditStore: th2FileEditStore,
                    ),
                  if (th2FileEditStore.showSelectionWindow)
                    MPSelectionWindowWidget(
                      key: ValueKey("MPSelectionWindowWidget|$thFileMapiahID"),
                      th2FileEditStore: th2FileEditStore,
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
