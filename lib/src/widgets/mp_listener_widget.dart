import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/widgets/interfaces/mp_actuator_interface.dart';

class MPListenerWidget extends StatelessWidget {
  final MPActuatorInterface actuator;
  final Widget child;

  const MPListenerWidget({
    super.key,
    required this.actuator,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (event.buttons == kPrimaryButton) {
          actuator.setCurrentPressedButton(kPrimaryButton);
          actuator
              .setPrimaryButtonDragStartScreenCoordinates(event.localPosition);
          actuator.setIsPrimaryButtonDragging(false);
          actuator.onPrimaryButtonDragStart(event);
        } else if (event.buttons == kSecondaryButton) {
          actuator.setCurrentPressedButton(kSecondaryButton);
          actuator.setSecondaryButtonDragStartScreenCoordinates(
              event.localPosition);
          actuator.setIsSecondaryButtonDragging(false);
          actuator.onSecondaryButtonDragStart(event);
        } else if (event.buttons == kTertiaryButton) {
          actuator.setCurrentPressedButton(kTertiaryButton);
          actuator
              .setTertiaryButtonDragStartScreenCoordinates(event.localPosition);
          actuator.setIsTertiaryButtonDragging(false);
          actuator.onTertiaryButtonDragStart(event);
        }
      },
      onPointerMove: (PointerMoveEvent event) {
        if (event.buttons == kPrimaryButton) {
          double distance = (event.localPosition -
                  actuator.getPrimaryButtonDragStartScreenCoordinates())
              .distanceSquared;

          if (distance > thClickDragThresholdSquared &&
              !actuator.getIsPrimaryButtonDragging()) {
            actuator.setIsPrimaryButtonDragging(true);
          }
          if (actuator.getIsPrimaryButtonDragging()) {
            actuator.onPrimaryButtonDragUpdate(event);
          }
        } else if (event.buttons == kSecondaryButton) {
          double distance = (event.localPosition -
                  actuator.getSecondaryButtonDragStartScreenCoordinates())
              .distanceSquared;

          if (distance > thClickDragThresholdSquared &&
              !actuator.getIsSecondaryButtonDragging()) {
            actuator.setIsSecondaryButtonDragging(true);
          }
          if (actuator.getIsSecondaryButtonDragging()) {
            actuator.onSecondaryButtonDragUpdate(event);
          }
        } else if (event.buttons == kTertiaryButton) {
          double distance = (event.localPosition -
                  actuator.getTertiaryButtonDragStartScreenCoordinates())
              .distanceSquared;

          if (distance > thClickDragThresholdSquared &&
              !actuator.getIsTertiaryButtonDragging()) {
            actuator.setIsTertiaryButtonDragging(true);
          }
          if (actuator.getIsTertiaryButtonDragging()) {
            actuator.onTertiaryButtonDragUpdate(event);
          }
        }
      },
      onPointerUp: (PointerUpEvent event) {
        if (actuator.getCurrentPressedButton() == kPrimaryButton) {
          actuator.setCurrentPressedButton(0);
          if (actuator.getIsPrimaryButtonDragging()) {
            actuator.onPrimaryButtonDragEnd(event);
            actuator.setIsPrimaryButtonDragging(false);
          } else {
            actuator.onPrimaryButtonClick(event);
          }
        } else if (actuator.getCurrentPressedButton() == kSecondaryButton) {
          actuator.setCurrentPressedButton(0);
          if (actuator.getIsSecondaryButtonDragging()) {
            actuator.onSecondaryButtonDragEnd(event);
            actuator.setIsSecondaryButtonDragging(false);
          } else {
            actuator.onSecondaryButtonClick(event);
          }
        } else if (actuator.getCurrentPressedButton() == kTertiaryButton) {
          actuator.setCurrentPressedButton(0);
          if (actuator.getIsTertiaryButtonDragging()) {
            actuator.onTertiaryButtonDragEnd(event);
            actuator.setIsTertiaryButtonDragging(false);
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
      child: child,
    );
  }
}
