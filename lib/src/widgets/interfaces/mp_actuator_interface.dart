import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

abstract interface class MPActuatorInterface {
  /// These methods are used to allow the Actuator to actually actuate on the
  /// selected events. These are the methods whee the actual desired actions
  /// should be performed when the events are triggered.
  void onPrimaryButtonDragStart(PointerDownEvent event);

  void onSecondaryButtonDragStart(PointerDownEvent event);

  void onTertiaryButtonDragStart(PointerDownEvent event);

  void onPrimaryButtonDragUpdate(PointerMoveEvent event);

  void onSecondaryButtonDragUpdate(PointerMoveEvent event);

  void onTertiaryButtonDragUpdate(PointerMoveEvent event);

  void onPrimaryButtonDragEnd(PointerUpEvent event);

  void onSecondaryButtonDragEnd(PointerUpEvent event);

  void onTertiaryButtonDragEnd(PointerUpEvent event);

  void onPrimaryButtonClick(PointerUpEvent event);

  void onSecondaryButtonClick(PointerUpEvent event);

  void onTertiaryButtonClick(PointerUpEvent event);

  void onTertiaryButtonScroll(PointerScrollEvent event);

  void onKeyDownEvent(KeyDownEvent event);

  void onKeyRepeatEvent(KeyRepeatEvent event);

  void onKeyUpEvent(KeyUpEvent event);
}
