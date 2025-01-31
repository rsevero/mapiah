import 'package:flutter/gestures.dart';

abstract interface class MPActuatorInterface {
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
