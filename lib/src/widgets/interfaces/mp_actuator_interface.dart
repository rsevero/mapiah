import 'package:flutter/gestures.dart';

abstract interface class MPActuatorInterface {
  /// Threse methods are used for the internal control of the Listener widget.
  /// They should not be used elsewhere.
  void setCurrentPressedButton(int button);

  int getCurrentPressedButton();

  void setIsPrimaryButtonDragging(bool isDragging);

  bool getIsPrimaryButtonDragging();

  void setIsSecondaryButtonDragging(bool isDragging);

  bool getIsSecondaryButtonDragging();

  void setIsTertiaryButtonDragging(bool isDragging);

  bool getIsTertiaryButtonDragging();

  void setPrimaryButtonDragStartScreenCoordinates(Offset coordinates);

  Offset getPrimaryButtonDragStartScreenCoordinates();

  void setSecondaryButtonDragStartScreenCoordinates(Offset coordinates);

  Offset getSecondaryButtonDragStartScreenCoordinates();

  void setTertiaryButtonDragStartScreenCoordinates(Offset coordinates);

  Offset getTertiaryButtonDragStartScreenCoordinates();

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

  void onMiddleButtonScroll(PointerScrollEvent event);
}
