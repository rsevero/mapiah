import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/widgets/interfaces/mp_actuator_interface.dart';

class MPListenerWidget extends StatelessWidget {
  final MPActuatorInterface th2FileEditStore;
  final Widget child;

  const MPListenerWidget({
    super.key,
    required this.th2FileEditStore,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
                  th2FileEditStore.primaryButtonDragStartScreenCoordinates)
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
                  th2FileEditStore.secondaryButtonDragStartScreenCoordinates)
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
                  th2FileEditStore.tertiaryButtonDragStartScreenCoordinates)
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
        } else if (th2FileEditStore.currentPressedButton == kSecondaryButton) {
          th2FileEditStore.currentPressedButton = 0;
          if (th2FileEditStore.isSecondaryButtonDragging) {
            th2FileEditStore.onSecondaryButtonDragEnd(event);
            th2FileEditStore.isSecondaryButtonDragging = false;
          } else {
            th2FileEditStore.onSecondaryButtonClick(event);
          }
        } else if (th2FileEditStore.currentPressedButton == kTertiaryButton) {
          th2FileEditStore.currentPressedButton = 0;
          if (th2FileEditStore.isTertiaryButtonDragging) {
            th2FileEditStore.onTertiaryButtonDragEnd(event);
            th2FileEditStore.isTertiaryButtonDragging = false;
          } else {
            th2FileEditStore.onTertiaryButtonClick(event);
          }
        }
      },
      child: child,
    );
  }
}
