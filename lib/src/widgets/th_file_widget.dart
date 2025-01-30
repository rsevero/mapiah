import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mapiah/src/widgets/mp_non_selected_elements_widget.dart';
import 'package:mapiah/src/widgets/mp_selected_elements_widget.dart';
import 'package:mapiah/src/widgets/mp_selection_handles_widget.dart';
import 'package:mapiah/src/widgets/mp_selection_window_widget.dart';
import 'package:flutter/services.dart';

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

            return Listener(
              onPointerDown: (PointerDownEvent event) {
                if (event.buttons == kPrimaryButton) {
                  th2FileEditStore.setPrimaryButtonDragStartScreenCoordinates(
                      event.localPosition);
                  th2FileEditStore.setIsPrimaryButtonDragging(false);
                  th2FileEditStore.onPrimaryButtonDragStart(event);
                } else if (event.buttons == kSecondaryButton) {
                  th2FileEditStore.setSecondaryButtonDragStartScreenCoordinates(
                      event.localPosition);
                  th2FileEditStore.setIsSecondaryButtonDragging(false);
                } else if (event.buttons == kTertiaryButton) {
                  th2FileEditStore.setTertiaryButtonDragStartScreenCoordinates(
                      event.localPosition);
                  th2FileEditStore.setIsTertiaryButtonDragging(false);
                }
              },
              onPointerMove: (PointerMoveEvent event) {
                if (event.buttons == kPrimaryButton) {
                  th2FileEditStore.setPrimaryButtonDragCurrentScreenCoordinates(
                      event.localPosition);
                  double distance = (event.localPosition -
                          th2FileEditStore
                              .primaryButtonDragStartScreenCoordinates)
                      .distanceSquared;

                  if (distance > thClickDragThresholdSquared &&
                      !th2FileEditStore.isPrimaryButtonDragging) {
                    th2FileEditStore.setIsPrimaryButtonDragging(true);
                  }
                  if (th2FileEditStore.isPrimaryButtonDragging) {
                    th2FileEditStore.onPrimaryButtonDragUpdate(event);
                  }
                } else if (event.buttons == kSecondaryButton) {
                  th2FileEditStore
                      .setSecondaryButtonDragCurrentScreenCoordinates(
                          event.localPosition);
                  double distance = (event.localPosition -
                          th2FileEditStore
                              .secondaryButtonDragStartScreenCoordinates)
                      .distanceSquared;

                  if (distance > thClickDragThresholdSquared &&
                      !th2FileEditStore.isSecondaryButtonDragging) {
                    th2FileEditStore.setIsSecondaryButtonDragging(true);
                  }
                } else if (event.buttons == kTertiaryButton) {
                  th2FileEditStore
                      .setTertiaryButtonDragCurrentScreenCoordinates(
                          event.localPosition);
                  double distance = (event.localPosition -
                          th2FileEditStore
                              .tertiaryButtonDragStartScreenCoordinates)
                      .distanceSquared;

                  if (distance > thClickDragThresholdSquared &&
                      !th2FileEditStore.isTertiaryButtonDragging) {
                    th2FileEditStore.setIsTertiaryButtonDragging(true);
                  }
                  if (th2FileEditStore.isTertiaryButtonDragging) {
                    th2FileEditStore.onTertiaryButtonDragUpdate(event);
                  }
                }
              },
              onPointerUp: (PointerUpEvent event) {
                if (event.buttons == kPrimaryButton) {
                  if (th2FileEditStore.isPrimaryButtonDragging) {
                    th2FileEditStore.onPrimaryButtonDragEnd(event);
                    th2FileEditStore.setIsPrimaryButtonDragging(false);
                  } else {
                    th2FileEditStore.onPrimaryButtonClick(event);
                  }
                }
              },
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
