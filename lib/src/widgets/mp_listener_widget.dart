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
  final FocusNode _focusNode = FocusNode();
  int currentPressedMouseButton = 0;
  Offset primaryButtonDragStartScreenCoordinates = Offset.zero;
  Offset secondaryButtonDragStartScreenCoordinates = Offset.zero;
  Offset tertiaryButtonDragStartScreenCoordinates = Offset.zero;
  bool isPrimaryButtonDragging = false;
  bool isSecondaryButtonDragging = false;
  bool isTertiaryButtonDragging = false;
  LogicalKeyboardKey? logicalKeyPressed;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        switch (event.buttons) {
          case kPrimaryButton:
            currentPressedMouseButton = kPrimaryButton;
            primaryButtonDragStartScreenCoordinates = event.localPosition;
            isPrimaryButtonDragging = false;
            widget.actuator.onPrimaryButtonDragStart(event);
            break;
          case kSecondaryButton:
            currentPressedMouseButton = kSecondaryButton;
            secondaryButtonDragStartScreenCoordinates = event.localPosition;
            isSecondaryButtonDragging = false;
            widget.actuator.onSecondaryButtonDragStart(event);
            break;
          case kTertiaryButton:
            currentPressedMouseButton = kTertiaryButton;
            tertiaryButtonDragStartScreenCoordinates = event.localPosition;
            isTertiaryButtonDragging = false;
            widget.actuator.onTertiaryButtonDragStart(event);
            break;
        }
      },
      onPointerMove: (PointerMoveEvent event) {
        switch (event.buttons) {
          case kPrimaryButton:
            double distanceSquared =
                (event.localPosition - primaryButtonDragStartScreenCoordinates)
                    .distanceSquared;

            if ((distanceSquared > thClickDragThresholdSquared) &&
                !isPrimaryButtonDragging) {
              isPrimaryButtonDragging = true;
            }
            if (isPrimaryButtonDragging) {
              widget.actuator.onPrimaryButtonDragUpdate(event);
            }
            break;
          case kSecondaryButton:
            double distanceSquared = (event.localPosition -
                    secondaryButtonDragStartScreenCoordinates)
                .distanceSquared;

            if ((distanceSquared > thClickDragThresholdSquared) &&
                !isSecondaryButtonDragging) {
              isSecondaryButtonDragging = true;
            }
            if (isSecondaryButtonDragging) {
              widget.actuator.onSecondaryButtonDragUpdate(event);
            }
            break;
          case kTertiaryButton:
            double distanceSquared =
                (event.localPosition - tertiaryButtonDragStartScreenCoordinates)
                    .distanceSquared;

            if ((distanceSquared > thClickDragThresholdSquared) &&
                !isTertiaryButtonDragging) {
              isTertiaryButtonDragging = true;
            }
            if (isTertiaryButtonDragging) {
              widget.actuator.onTertiaryButtonDragUpdate(event);
            }
            break;
        }
      },
      onPointerUp: (PointerUpEvent event) {
        switch (event.buttons) {
          case kPrimaryButton:
            currentPressedMouseButton = 0;
            if (isPrimaryButtonDragging) {
              widget.actuator.onPrimaryButtonDragEnd(event);
              isPrimaryButtonDragging = false;
            } else {
              widget.actuator.onPrimaryButtonClick(event);
            }
            break;
          case kSecondaryButton:
            currentPressedMouseButton = 0;
            if (isSecondaryButtonDragging) {
              widget.actuator.onSecondaryButtonDragEnd(event);
              isSecondaryButtonDragging = false;
            } else {
              widget.actuator.onSecondaryButtonClick(event);
            }
            break;
          case kTertiaryButton:
            currentPressedMouseButton = 0;
            if (isTertiaryButtonDragging) {
              widget.actuator.onTertiaryButtonDragEnd(event);
              isTertiaryButtonDragging = false;
            } else {
              widget.actuator.onTertiaryButtonClick(event);
            }
            break;
        }
      },
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent) {
          widget.actuator.onTertiaryButtonScroll(event);
        }
      },
      child: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            widget.actuator.onKeyDownEvent(event);
          } else if (event is KeyUpEvent) {
            widget.actuator.onKeyUpEvent(event);
            logicalKeyPressed = null;
          }
          return KeyEventResult.handled;
        },
        child: widget.child,
      ),
    );
  }
}
