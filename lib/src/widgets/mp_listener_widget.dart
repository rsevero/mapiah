import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/widgets/aux/mp_listener_widget_inner_state.dart';
import 'package:mapiah/src/widgets/interfaces/mp_actuator_interface.dart';

class MPListenerWidget extends StatelessWidget {
  final MPActuatorInterface actuator;
  final Widget child;
  final MPListenerWidgetInnerState state;

  MPListenerWidget({
    required Key key,
    required this.actuator,
    required this.child,
  })  : state = mpLocator.mpGeneralStore.getMPListenerInnerState(key),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (event.buttons == kPrimaryButton) {
          state.currentPressedMouseButton = kPrimaryButton;
          state.primaryButtonDragStartScreenCoordinates = event.localPosition;
          state.isPrimaryButtonDragging = false;
          actuator.onPrimaryButtonDragStart(event);
        } else if (event.buttons == kSecondaryButton) {
          state.currentPressedMouseButton = kSecondaryButton;
          state.secondaryButtonDragStartScreenCoordinates = event.localPosition;
          state.isSecondaryButtonDragging = false;
          actuator.onSecondaryButtonDragStart(event);
        } else if (event.buttons == kTertiaryButton) {
          state.currentPressedMouseButton = kTertiaryButton;
          state.tertiaryButtonDragStartScreenCoordinates = event.localPosition;
          state.isTertiaryButtonDragging = false;
          actuator.onTertiaryButtonDragStart(event);
        }
      },
      onPointerMove: (PointerMoveEvent event) {
        if (event.buttons == kPrimaryButton) {
          double distance = (event.localPosition -
                  state.primaryButtonDragStartScreenCoordinates)
              .distanceSquared;

          if (distance > thClickDragThresholdSquared &&
              !state.isPrimaryButtonDragging) {
            state.isPrimaryButtonDragging = true;
          }
          if (state.isPrimaryButtonDragging) {
            actuator.onPrimaryButtonDragUpdate(event);
          }
        } else if (event.buttons == kSecondaryButton) {
          double distance = (event.localPosition -
                  state.secondaryButtonDragStartScreenCoordinates)
              .distanceSquared;

          if (distance > thClickDragThresholdSquared &&
              !state.isSecondaryButtonDragging) {
            state.isSecondaryButtonDragging = true;
          }
          if (state.isSecondaryButtonDragging) {
            actuator.onSecondaryButtonDragUpdate(event);
          }
        } else if (event.buttons == kTertiaryButton) {
          double distance = (event.localPosition -
                  state.tertiaryButtonDragStartScreenCoordinates)
              .distanceSquared;

          if (distance > thClickDragThresholdSquared &&
              !state.isTertiaryButtonDragging) {
            state.isTertiaryButtonDragging = true;
          }
          if (state.isTertiaryButtonDragging) {
            actuator.onTertiaryButtonDragUpdate(event);
          }
        }
      },
      onPointerUp: (PointerUpEvent event) {
        if (state.currentPressedMouseButton == kPrimaryButton) {
          state.currentPressedMouseButton = 0;
          if (state.isPrimaryButtonDragging) {
            actuator.onPrimaryButtonDragEnd(event);
            state.isPrimaryButtonDragging = false;
          } else {
            actuator.onPrimaryButtonClick(event);
          }
        } else if (state.currentPressedMouseButton == kSecondaryButton) {
          state.currentPressedMouseButton = 0;
          if (state.isSecondaryButtonDragging) {
            actuator.onSecondaryButtonDragEnd(event);
            state.isSecondaryButtonDragging = false;
          } else {
            actuator.onSecondaryButtonClick(event);
          }
        } else if (state.currentPressedMouseButton == kTertiaryButton) {
          state.currentPressedMouseButton = 0;
          if (state.isTertiaryButtonDragging) {
            actuator.onTertiaryButtonDragEnd(event);
            state.isTertiaryButtonDragging = false;
          } else {
            actuator.onTertiaryButtonClick(event);
          }
        }
      },
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent) {
          actuator.onTertiaryButtonScroll(event);
        }
      },
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
              state.logicalKeyPressed = event.logicalKey;
            }
            actuator.onKeyDownEvent(event);
          } else if (event is KeyRepeatEvent) {
            actuator.onKeyRepeatEvent(event);
          } else if (event is KeyUpEvent) {
            actuator.onKeyUpEvent(event);
            state.logicalKeyPressed = null;
          }
        },
        child: child,
      ),
    );
  }
}
