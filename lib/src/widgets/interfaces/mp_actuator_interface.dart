import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

abstract interface class MPActuatorInterface {
  /// These methods are used to allow the Actuator to actually actuate on the
  /// selected events. These are the methods where the actual desired actions
  /// should be performed when the events are triggered.
  Future<void> onPrimaryButtonPointerDown(PointerDownEvent event) {
    return Future.value();
  }

  void onSecondaryButtonPointerDown(PointerDownEvent event);

  void onTertiaryButtonPointerDown(PointerDownEvent event);

  void onPrimaryButtonDragUpdate(PointerMoveEvent event);

  void onSecondaryButtonDragUpdate(PointerMoveEvent event);

  void onTertiaryButtonDragUpdate(PointerMoveEvent event);

  void onPrimaryButtonDragEnd(PointerUpEvent event);

  void onSecondaryButtonDragEnd(PointerUpEvent event);

  void onTertiaryButtonDragEnd(PointerUpEvent event);

  Future<void> onPrimaryButtonClick(PointerUpEvent event);

  void onSecondaryButtonClick(PointerUpEvent event);

  void onTertiaryButtonClick(PointerUpEvent event);

  void onTertiaryButtonScroll(PointerScrollEvent event);

  void onKeyDownEvent(KeyDownEvent event);

  void onKeyRepeatEvent(KeyRepeatEvent event);

  void onKeyUpEvent(KeyUpEvent event);
}
