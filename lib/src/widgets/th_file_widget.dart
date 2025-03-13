import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/widgets/mp_add_line_widget.dart';
import 'package:mapiah/src/widgets/mp_edit_line_widget.dart';
import 'package:mapiah/src/widgets/mp_listener_widget.dart';
import 'package:mapiah/src/widgets/mp_non_selected_elements_widget.dart';
import 'package:mapiah/src/widgets/mp_options_edit_content_widget.dart';
import 'package:mapiah/src/widgets/mp_scrap_scale_widget.dart';
import 'package:mapiah/src/widgets/mp_selected_elements_widget.dart';
import 'package:mapiah/src/widgets/mp_selection_handles_widget.dart';
import 'package:mapiah/src/widgets/mp_selection_window_widget.dart';

class THFileWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  late final THFile thFile = th2FileEditController.thFile;
  late final int thFileMapiahID = th2FileEditController.thFileMapiahID;

  THFileWidget({required super.key, required this.th2FileEditController});

  @override
  Widget build(BuildContext context) {
    mpLocator.mpLog.finer("THFileWidget.build()");
    return LayoutBuilder(
      builder: (context, constraints) {
        th2FileEditController.updateScreenSize(
            Size(constraints.maxWidth, constraints.maxHeight));

        if (th2FileEditController.canvasScaleTranslationUndefined) {
          th2FileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.file);
        }

        return MPListenerWidget(
          key: ValueKey("MPListenerWidget|$thFileMapiahID"),
          actuator: th2FileEditController.stateController,
          th2FileEditController: th2FileEditController,
          child: Stack(
            children: [
              MPNonSelectedElementsWidget(
                key: ValueKey("MPNonSelectedElementsWidget|$thFileMapiahID"),
                th2FileEditController: th2FileEditController,
              ),
              Observer(
                builder: (_) {
                  if (th2FileEditController.showSelectedElements) {
                    return MPSelectedElementsWidget(
                      key: ValueKey("MPSelectedElementsWidget|$thFileMapiahID"),
                      th2FileEditController: th2FileEditController,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Observer(
                builder: (_) {
                  if (th2FileEditController.showAddLine) {
                    return MPAddLineWidget(
                      key: ValueKey("MPAddLineWidget|$thFileMapiahID"),
                      th2FileEditController: th2FileEditController,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Observer(
                builder: (_) {
                  if (th2FileEditController.showEditLineSegment) {
                    return MPEditLineWidget(
                      key: ValueKey("MPEditLineWidget|$thFileMapiahID"),
                      th2FileEditController: th2FileEditController,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Observer(
                builder: (_) {
                  if (th2FileEditController.showSelectionHandles) {
                    return MPSelectionHandlesWidget(
                      key: ValueKey("MPSelectionHandlesWidget|$thFileMapiahID"),
                      th2FileEditController: th2FileEditController,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Observer(
                builder: (_) {
                  if (th2FileEditController.showSelectionWindow) {
                    return MPSelectionWindowWidget(
                      key: ValueKey("MPSelectionWindowWidget|$thFileMapiahID"),
                      th2FileEditController: th2FileEditController,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Observer(
                builder: (_) {
                  if (th2FileEditController.showScrapScale) {
                    return MPScrapScaleWidget(
                      key: ValueKey("MPScrapScaleWidget|$thFileMapiahID"),
                      th2FileEditController: th2FileEditController,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Observer(
                builder: (_) {
                  if (th2FileEditController.showOptionsEdit) {
                    return MPOptionsEditContentWidget(
                      key: ValueKey("MPOptionsEditWidget|$thFileMapiahID"),
                      th2FileEditController: th2FileEditController,
                      position: Offset(57, 48),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
