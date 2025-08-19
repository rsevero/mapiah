import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/widgets/mp_add_line_widget.dart';
import 'package:mapiah/src/widgets/mp_line_edit_widget.dart';
import 'package:mapiah/src/widgets/mp_images_widget.dart';
import 'package:mapiah/src/widgets/mp_listener_widget.dart';
import 'package:mapiah/src/widgets/mp_multiple_elements_clicked_highlight_widget.dart';
import 'package:mapiah/src/widgets/mp_multiple_end_control_points_clicked_highlight_widget.dart';
import 'package:mapiah/src/widgets/mp_non_selected_elements_widget.dart';
import 'package:mapiah/src/widgets/mp_scrap_scale_widget.dart';
import 'package:mapiah/src/widgets/mp_selected_elements_widget.dart';
import 'package:mapiah/src/widgets/mp_selection_handles_widget.dart';
import 'package:mapiah/src/widgets/mp_selection_window_widget.dart';

class THFileWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  late final THFile thFile = th2FileEditController.thFile;
  late final int thFileMPID = th2FileEditController.thFileMPID;
  late final TH2FileEditOverlayWindowController overlayWindowController =
      th2FileEditController.overlayWindowController;

  THFileWidget({required super.key, required this.th2FileEditController});

  @override
  Widget build(BuildContext context) {
    mpLocator.mpLog.finer("THFileWidget.build()");
    th2FileEditController.devicePixelRatio = MediaQuery.of(
      context,
    ).devicePixelRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        th2FileEditController.updateScreenSize(
          Size(constraints.maxWidth, constraints.maxHeight),
        );

        if (th2FileEditController.canvasScaleTranslationUndefined) {
          th2FileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.file);
        }

        return MPListenerWidget(
          key: ValueKey("MPListenerWidget|$thFileMPID"),
          actuator: th2FileEditController.stateController,
          th2FileEditController: th2FileEditController,
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            child: Stack(
              key: ValueKey("THFileWidgetStack|$thFileMPID"),
              children: [
                Observer(
                  builder: (_) {
                    if (th2FileEditController.showImages) {
                      return MPImagesWidget(
                        key: ValueKey("MPImagesWidget|$thFileMPID"),
                        th2FileEditController: th2FileEditController,
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
                MPNonSelectedElementsWidget(
                  key: ValueKey("MPNonSelectedElementsWidget|$thFileMPID"),
                  th2FileEditController: th2FileEditController,
                ),
                Observer(
                  builder: (_) {
                    if (th2FileEditController.showScrapScale) {
                      return MPScrapScaleWidget(
                        key: ValueKey("MPScrapScaleWidget|$thFileMPID"),
                        th2FileEditController: th2FileEditController,
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
                Observer(
                  builder: (_) {
                    if (th2FileEditController.showSelectedElements) {
                      return MPSelectedElementsWidget(
                        key: ValueKey("MPSelectedElementsWidget|$thFileMPID"),
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
                        key: ValueKey("MPAddLineWidget|$thFileMPID"),
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
                      return MPLineEditWidget(
                        key: ValueKey("MPEditLineWidget|$thFileMPID"),
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
                        key: ValueKey("MPSelectionHandlesWidget|$thFileMPID"),
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
                        key: ValueKey("MPSelectionWindowWidget|$thFileMPID"),
                        th2FileEditController: th2FileEditController,
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
                Observer(
                  builder: (_) {
                    if (th2FileEditController
                        .showMultipleElementsClickedHighlight) {
                      return MPMultipleElementsClickedHighlightWidget(
                        key: ValueKey(
                          "MPMultipleElementsClickedHighlightWidget|$thFileMPID",
                        ),
                        th2FileEditController: th2FileEditController,
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
                Observer(
                  builder: (_) {
                    if (th2FileEditController
                        .showMultipleEndControlPointsClickedHighlight) {
                      return MPMultipleEndControlPointsClickedHighlightWidget(
                        key: ValueKey(
                          "MPMultipleEndControlPointsClickedHighlightWidget|$thFileMPID",
                        ),
                        th2FileEditController: th2FileEditController,
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
                if (mpDebugMousePosition)
                  Positioned(
                    bottom: 32,
                    left: 16,
                    child: Observer(
                      builder: (_) {
                        final Offset screenPosition =
                            th2FileEditController.mousePosition;
                        final Offset canvasPosition = th2FileEditController
                            .offsetScreenToCanvas(screenPosition);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mouse Screen Position: (x: ${screenPosition.dx.toStringAsFixed(1)}, y: ${screenPosition.dy.toStringAsFixed(1)})',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Mouse Canvas Position: (x: ${canvasPosition.dx.toStringAsFixed(2)}, y: ${canvasPosition.dy.toStringAsFixed(2)})',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
