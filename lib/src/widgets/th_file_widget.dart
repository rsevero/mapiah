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
                  th2FileEditStore.currentPressedButton = kPrimaryButton;
                  th2FileEditStore.primaryButtonDragStartScreenCoordinates =
                      event.localPosition;
                  th2FileEditStore.isPrimaryButtonDragging = false;
                  th2FileEditStore.onPrimaryButtonDragStart(event);
                } else if (event.buttons == kSecondaryButton) {
                  th2FileEditStore.currentPressedButton = kSecondaryButton;
                  th2FileEditStore.secondaryButtonDragStartScreenCoordinates =
                      event.localPosition;
                  th2FileEditStore.isSecondaryButtonDragging = false;
                  th2FileEditStore.onSecondaryButtonDragStart(event);
                } else if (event.buttons == kTertiaryButton) {
                  th2FileEditStore.currentPressedButton = kTertiaryButton;
                  th2FileEditStore.tertiaryButtonDragStartScreenCoordinates =
                      event.localPosition;
                  th2FileEditStore.isTertiaryButtonDragging = false;
                  th2FileEditStore.onTertiaryButtonDragStart(event);
                }
              },
              onPointerMove: (PointerMoveEvent event) {
                if (event.buttons == kPrimaryButton) {
                  double distance = (event.localPosition -
                          th2FileEditStore
                              .primaryButtonDragStartScreenCoordinates)
                      .distanceSquared;

                  if (distance > thClickDragThresholdSquared &&
                      !th2FileEditStore.isPrimaryButtonDragging) {
                    th2FileEditStore.isPrimaryButtonDragging = true;
                  }
                  if (th2FileEditStore.isPrimaryButtonDragging) {
                    th2FileEditStore.onPrimaryButtonDragUpdate(event);
                  }
                } else if (event.buttons == kSecondaryButton) {
                  double distance = (event.localPosition -
                          th2FileEditStore
                              .secondaryButtonDragStartScreenCoordinates)
                      .distanceSquared;

                  if (distance > thClickDragThresholdSquared &&
                      !th2FileEditStore.isSecondaryButtonDragging) {
                    th2FileEditStore.isSecondaryButtonDragging = true;
                  }
                  if (th2FileEditStore.isSecondaryButtonDragging) {
                    th2FileEditStore.onSecondaryButtonDragUpdate(event);
                  }
                } else if (event.buttons == kTertiaryButton) {
                  double distance = (event.localPosition -
                          th2FileEditStore
                              .tertiaryButtonDragStartScreenCoordinates)
                      .distanceSquared;

                  if (distance > thClickDragThresholdSquared &&
                      !th2FileEditStore.isTertiaryButtonDragging) {
                    th2FileEditStore.isTertiaryButtonDragging = true;
                  }
                  if (th2FileEditStore.isTertiaryButtonDragging) {
                    th2FileEditStore.onTertiaryButtonDragUpdate(event);
                  }
                }
              },
              onPointerUp: (PointerUpEvent event) {
                if (th2FileEditStore.currentPressedButton == kPrimaryButton) {
                  th2FileEditStore.currentPressedButton = 0;
                  if (th2FileEditStore.isPrimaryButtonDragging) {
                    th2FileEditStore.onPrimaryButtonDragEnd(event);
                    th2FileEditStore.isPrimaryButtonDragging = false;
                  } else {
                    th2FileEditStore.onPrimaryButtonClick(event);
                  }
                } else if (th2FileEditStore.currentPressedButton ==
                    kSecondaryButton) {
                  th2FileEditStore.currentPressedButton = 0;
                  if (th2FileEditStore.isSecondaryButtonDragging) {
                    th2FileEditStore.onSecondaryButtonDragEnd(event);
                    th2FileEditStore.isSecondaryButtonDragging = false;
                  } else {
                    th2FileEditStore.onSecondaryButtonClick(event);
                  }
                } else if (th2FileEditStore.currentPressedButton ==
                    kTertiaryButton) {
                  th2FileEditStore.currentPressedButton = 0;
                  if (th2FileEditStore.isTertiaryButtonDragging) {
                    th2FileEditStore.onTertiaryButtonDragEnd(event);
                    th2FileEditStore.isTertiaryButtonDragging = false;
                  } else {
                    th2FileEditStore.onTertiaryButtonClick(event);
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
