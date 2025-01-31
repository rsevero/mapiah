import 'package:flutter/material.dart';

abstract interface class MPActuatorInterface {
  late int currentPressedButton;
  late bool isPrimaryButtonDragging;
  late bool isSecondaryButtonDragging;
  late bool isTertiaryButtonDragging;
  late Offset primaryButtonDragStartScreenCoordinates;
  late Offset secondaryButtonDragStartScreenCoordinates;
  late Offset tertiaryButtonDragStartScreenCoordinates;

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
}
