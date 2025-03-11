import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/widgets/interfaces/mp_actuator_interface.dart';

class MPListenerWidget extends StatefulWidget {
  final MPActuatorInterface actuator;
  final Map<Key, Rect> ignoreRects;
  final Widget child;

  MPListenerWidget({
    super.key,
    required this.actuator,
    required this.ignoreRects,
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
        final ignoreRects = widget.ignoreRects.values;

        for (final Rect ignoreRect in ignoreRects) {
          if (ignoreRect.contains(event.localPosition)) {
            return;
          }
        }
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
        final ignoreRects = widget.ignoreRects.values;

        for (final Rect ignoreRect in ignoreRects) {
          if (ignoreRect.contains(event.localPosition)) {
            return;
          }
        }
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
        final ignoreRects = widget.ignoreRects.values;

        for (final Rect ignoreRect in ignoreRects) {
          if (ignoreRect.contains(event.localPosition)) {
            return;
          }
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
        final ignoreRects = widget.ignoreRects.values;

        for (final Rect ignoreRect in ignoreRects) {
          if (ignoreRect.contains(event.localPosition)) {
            return;
          }
        }
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
