import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/widgets/interfaces/mp_actuator_interface.dart';

class MPListenerWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPActuatorInterface actuator;
  final Widget child;

  MPListenerWidget({
    super.key,
    required this.th2FileEditController,
    required this.actuator,
    required this.child,
  });

  @override
  State<MPListenerWidget> createState() => MPListenerWidgetState();
}

class MPListenerWidgetState extends State<MPListenerWidget> {
  late final TH2FileEditController th2FileEditController;
  late final TH2FileEditOverlayWindowController overlayWindowController;
  late final FocusNode _focusNode;
  int currentPressedMouseButton = 0;
  Offset primaryButtonDragStartScreenCoordinates = Offset.zero;
  Offset secondaryButtonDragStartScreenCoordinates = Offset.zero;
  Offset tertiaryButtonDragStartScreenCoordinates = Offset.zero;
  bool isPrimaryButtonDragging = false;
  bool isSecondaryButtonDragging = false;
  bool isTertiaryButtonDragging = false;
  LogicalKeyboardKey? logicalKeyPressed;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    overlayWindowController = th2FileEditController.overlayWindowController;
    _focusNode = th2FileEditController.thFileFocusNode;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        // mpLocator.mpLog.fine("MPListenerWidget.onPointerDown() entered");

        if (overlayWindowController.processingPointerDownEvent) {
          overlayWindowController.processingPointerDownEvent = false;
          return;
        }

        // mpLocator.mpLog.fine("MPListenerWidget.onPointerDown() executed");

        switch (event.buttons) {
          case kPrimaryButton:
            currentPressedMouseButton = kPrimaryButton;
            primaryButtonDragStartScreenCoordinates = event.localPosition;
            isPrimaryButtonDragging = false;
            widget.actuator.onPrimaryButtonDragStart(event);
          case kSecondaryButton:
            currentPressedMouseButton = kSecondaryButton;
            secondaryButtonDragStartScreenCoordinates = event.localPosition;
            isSecondaryButtonDragging = false;
            widget.actuator.onSecondaryButtonDragStart(event);
          case kTertiaryButton:
            currentPressedMouseButton = kTertiaryButton;
            tertiaryButtonDragStartScreenCoordinates = event.localPosition;
            isTertiaryButtonDragging = false;
            widget.actuator.onTertiaryButtonDragStart(event);
        }
      },
      onPointerMove: (PointerMoveEvent event) {
        // mpLocator.mpLog.fine("MPListenerWidget.onPointerMove() entered");

        if (overlayWindowController.processingPointerMoveEvent) {
          overlayWindowController.processingPointerMoveEvent = false;
          return;
        }

        // mpLocator.mpLog.fine("MPListenerWidget.onPointerMove() executed");

        switch (event.buttons) {
          case kPrimaryButton:
            if (isPrimaryButtonDragging) {
              widget.actuator.onPrimaryButtonDragUpdate(event);
            } else {
              final double distanceSquared = (event.localPosition -
                      primaryButtonDragStartScreenCoordinates)
                  .distanceSquared;

              if (distanceSquared > thClickDragThresholdSquared) {
                isPrimaryButtonDragging = true;
                widget.actuator.onPrimaryButtonDragUpdate(event);
              }
            }
          case kSecondaryButton:
            if (isSecondaryButtonDragging) {
              widget.actuator.onSecondaryButtonDragUpdate(event);
            } else {
              final double distanceSquared = (event.localPosition -
                      secondaryButtonDragStartScreenCoordinates)
                  .distanceSquared;

              if (distanceSquared > thClickDragThresholdSquared) {
                isSecondaryButtonDragging = true;
                widget.actuator.onSecondaryButtonDragUpdate(event);
              }
            }
          case kTertiaryButton:
            if (isTertiaryButtonDragging) {
              widget.actuator.onTertiaryButtonDragUpdate(event);
            } else {
              final double distanceSquared = (event.localPosition -
                      tertiaryButtonDragStartScreenCoordinates)
                  .distanceSquared;

              if (distanceSquared > thClickDragThresholdSquared) {
                isTertiaryButtonDragging = true;
                widget.actuator.onTertiaryButtonDragUpdate(event);
              }
            }
        }
      },
      onPointerUp: (PointerUpEvent event) {
        // mpLocator.mpLog.fine("MPListenerWidget.onPointerUp() entered");

        if (overlayWindowController.processingPointerUpEvent) {
          overlayWindowController.processingPointerUpEvent = false;
          return;
        }

        // mpLocator.mpLog.fine("MPListenerWidget.onPointerUp() executed");

        if (overlayWindowController.isAutoDismissWindowOpen) {
          overlayWindowController.closeAutoDismissOverlayWindows();
        }

        switch (currentPressedMouseButton) {
          case kPrimaryButton:
            currentPressedMouseButton = 0;
            if (isPrimaryButtonDragging) {
              widget.actuator.onPrimaryButtonDragEnd(event);
              isPrimaryButtonDragging = false;
            } else {
              widget.actuator.onPrimaryButtonClick(event);
            }
          case kSecondaryButton:
            currentPressedMouseButton = 0;
            if (isSecondaryButtonDragging) {
              widget.actuator.onSecondaryButtonDragEnd(event);
              isSecondaryButtonDragging = false;
            } else {
              widget.actuator.onSecondaryButtonClick(event);
            }
          case kTertiaryButton:
            currentPressedMouseButton = 0;
            if (isTertiaryButtonDragging) {
              widget.actuator.onTertiaryButtonDragEnd(event);
              isTertiaryButtonDragging = false;
            } else {
              widget.actuator.onTertiaryButtonClick(event);
            }
        }
      },
      onPointerSignal: (PointerSignalEvent event) {
        // mpLocator.mpLog.fine("MPListenerWidget.onPointerSignal() entered");

        if (overlayWindowController.processingPointerSignalEvent) {
          overlayWindowController.processingPointerSignalEvent = false;
          return;
        }

        // mpLocator.mpLog.fine("MPListenerWidget.onPointerSignal() executed");

        if (event is PointerScrollEvent) {
          widget.actuator.onTertiaryButtonScroll(event);
        }
      },
      child: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          print("MPListenerWidget.onKeyEvent() entered");
          if (event is KeyDownEvent) {
            logicalKeyPressed = event.logicalKey;
            widget.actuator.onKeyDownEvent(event);
          } else if (event is KeyUpEvent) {
            logicalKeyPressed = null;
            widget.actuator.onKeyUpEvent(event);
          }
          return KeyEventResult.handled;
        },
        child: widget.child,
      ),
    );
  }
}
