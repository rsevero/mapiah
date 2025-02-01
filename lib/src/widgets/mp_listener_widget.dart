import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/widgets/interfaces/mp_actuator_interface.dart';

class MPListenerWidget extends StatefulWidget {
  final MPActuatorInterface actuator;
  final Widget child;

  MPListenerWidget({
    super.key,
    required this.actuator,
    required this.child,
  });

  @override
  State<MPListenerWidget> createState() => MPListenerWidgetState();
}

class MPListenerWidgetState extends State<MPListenerWidget> {
  int currentPressedMouseButton = 0;
  Offset primaryButtonDragStartScreenCoordinates = Offset.zero;
  Offset secondaryButtonDragStartScreenCoordinates = Offset.zero;
  Offset tertiaryButtonDragStartScreenCoordinates = Offset.zero;
  bool isPrimaryButtonDragging = false;
  bool isSecondaryButtonDragging = false;
  bool isTertiaryButtonDragging = false;
  LogicalKeyboardKey? logicalKeyPressed;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (event.buttons == kPrimaryButton) {
          currentPressedMouseButton = kPrimaryButton;
          primaryButtonDragStartScreenCoordinates = event.localPosition;
          isPrimaryButtonDragging = false;
          widget.actuator.onPrimaryButtonDragStart(event);
        } else if (event.buttons == kSecondaryButton) {
          currentPressedMouseButton = kSecondaryButton;
          secondaryButtonDragStartScreenCoordinates = event.localPosition;
          isSecondaryButtonDragging = false;
          widget.actuator.onSecondaryButtonDragStart(event);
        } else if (event.buttons == kTertiaryButton) {
          currentPressedMouseButton = kTertiaryButton;
          tertiaryButtonDragStartScreenCoordinates = event.localPosition;
          isTertiaryButtonDragging = false;
          widget.actuator.onTertiaryButtonDragStart(event);
        }
      },
      onPointerMove: (PointerMoveEvent event) {
        if (event.buttons == kPrimaryButton) {
          double distance =
              (event.localPosition - primaryButtonDragStartScreenCoordinates)
                  .distanceSquared;

          if (distance > thClickDragThresholdSquared &&
              !isPrimaryButtonDragging) {
            isPrimaryButtonDragging = true;
          }
          if (isPrimaryButtonDragging) {
            widget.actuator.onPrimaryButtonDragUpdate(event);
          }
        } else if (event.buttons == kSecondaryButton) {
          double distance =
              (event.localPosition - secondaryButtonDragStartScreenCoordinates)
                  .distanceSquared;

          if (distance > thClickDragThresholdSquared &&
              !isSecondaryButtonDragging) {
            isSecondaryButtonDragging = true;
          }
          if (isSecondaryButtonDragging) {
            widget.actuator.onSecondaryButtonDragUpdate(event);
          }
        } else if (event.buttons == kTertiaryButton) {
          double distance =
              (event.localPosition - tertiaryButtonDragStartScreenCoordinates)
                  .distanceSquared;

          if (distance > thClickDragThresholdSquared &&
              !isTertiaryButtonDragging) {
            isTertiaryButtonDragging = true;
          }
          if (isTertiaryButtonDragging) {
            widget.actuator.onTertiaryButtonDragUpdate(event);
          }
        }
      },
      onPointerUp: (PointerUpEvent event) {
        if (currentPressedMouseButton == kPrimaryButton) {
          currentPressedMouseButton = 0;
          if (isPrimaryButtonDragging) {
            widget.actuator.onPrimaryButtonDragEnd(event);
            isPrimaryButtonDragging = false;
          } else {
            widget.actuator.onPrimaryButtonClick(event);
          }
        } else if (currentPressedMouseButton == kSecondaryButton) {
          currentPressedMouseButton = 0;
          if (isSecondaryButtonDragging) {
            widget.actuator.onSecondaryButtonDragEnd(event);
            isSecondaryButtonDragging = false;
          } else {
            widget.actuator.onSecondaryButtonClick(event);
          }
        } else if (currentPressedMouseButton == kTertiaryButton) {
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
        if (event is PointerScrollEvent) {
          widget.actuator.onTertiaryButtonScroll(event);
        }
      },
      child: Focus(
        autofocus: true,
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey != LogicalKeyboardKey.shiftLeft &&
                  event.logicalKey != LogicalKeyboardKey.shiftRight &&
                  event.logicalKey != LogicalKeyboardKey.controlLeft &&
                  event.logicalKey != LogicalKeyboardKey.controlRight &&
                  event.logicalKey != LogicalKeyboardKey.altLeft &&
                  event.logicalKey != LogicalKeyboardKey.altRight &&
                  event.logicalKey != LogicalKeyboardKey.metaLeft &&
                  event.logicalKey != LogicalKeyboardKey.metaRight) {
                logicalKeyPressed = event.logicalKey;
              }
              widget.actuator.onKeyDownEvent(event);
            } else if (event is KeyRepeatEvent) {
              widget.actuator.onKeyRepeatEvent(event);
            } else if (event is KeyUpEvent) {
              widget.actuator.onKeyUpEvent(event);
              logicalKeyPressed = null;
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}
