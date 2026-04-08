// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/widgets/interfaces/mp_actuator_interface.dart';

class MPListenerWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPActuatorInterface actuator;
  final Widget child;

  MPListenerWidget({
    super.key,
    required this.th2FileEditController,
    required this.actuator,
    required this.child,
  });

  @override
  State<MPListenerWidget> createState() => MPListenerWidgetState();
}

class MPListenerWidgetState extends State<MPListenerWidget> {
  late final TH2FileEditController th2FileEditController;
  late final TH2FileEditOverlayWindowController overlayWindowController;
  late final FocusNode _focusNode;
  int currentPressedMouseButton = 0;
  Offset primaryButtonDragStartScreenCoordinates = Offset.zero;
  Offset secondaryButtonDragStartScreenCoordinates = Offset.zero;
  Offset tertiaryButtonDragStartScreenCoordinates = Offset.zero;
  bool isPrimaryButtonDragging = false;
  bool isSecondaryButtonDragging = false;
  bool isTertiaryButtonDragging = false;
  LogicalKeyboardKey? logicalKeyPressed;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    overlayWindowController = th2FileEditController.overlayWindowController;
    _focusNode = th2FileEditController.th2FileFocusNode;
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
            widget.actuator.onPrimaryButtonPointerDown(event);
          case kSecondaryButton:
            currentPressedMouseButton = kSecondaryButton;
            secondaryButtonDragStartScreenCoordinates = event.localPosition;
            isSecondaryButtonDragging = false;
            widget.actuator.onSecondaryButtonPointerDown(event);
          case kTertiaryButton:
            currentPressedMouseButton = kTertiaryButton;
            tertiaryButtonDragStartScreenCoordinates = event.localPosition;
            isTertiaryButtonDragging = false;
            widget.actuator.onTertiaryButtonPointerDown(event);
        }
      },
      onPointerMove: (PointerMoveEvent event) {
        switch (event.buttons) {
          case kPrimaryButton:
            if (isPrimaryButtonDragging) {
              widget.actuator.onPrimaryButtonDragUpdate(event);
            } else {
              final double distanceSquared =
                  (event.localPosition -
                          primaryButtonDragStartScreenCoordinates)
                      .distanceSquared;

              if (distanceSquared > mpClickDragThresholdSquared) {
                isPrimaryButtonDragging = true;
                widget.actuator.onPrimaryButtonDragUpdate(event);
              }
            }
          case kSecondaryButton:
            if (isSecondaryButtonDragging) {
              widget.actuator.onSecondaryButtonDragUpdate(event);
            } else {
              final double distanceSquared =
                  (event.localPosition -
                          secondaryButtonDragStartScreenCoordinates)
                      .distanceSquared;

              if (distanceSquared > mpClickDragThresholdSquared) {
                isSecondaryButtonDragging = true;
                widget.actuator.onSecondaryButtonDragUpdate(event);
              }
            }
          case kTertiaryButton:
            if (isTertiaryButtonDragging) {
              widget.actuator.onTertiaryButtonDragUpdate(event);
            } else {
              final double distanceSquared =
                  (event.localPosition -
                          tertiaryButtonDragStartScreenCoordinates)
                      .distanceSquared;

              if (distanceSquared > mpClickDragThresholdSquared) {
                isTertiaryButtonDragging = true;
                widget.actuator.onTertiaryButtonDragUpdate(event);
              }
            }
        }
      },
      onPointerUp: (PointerUpEvent event) {
        final bool wasDragging =
            isPrimaryButtonDragging ||
            isSecondaryButtonDragging ||
            isTertiaryButtonDragging;
        final bool shouldKeepOverlayOpen = th2FileEditController
            .stateController
            .state
            .shouldKeepOverlayOpenOnCanvasPointerUp(
              event,
              wasDragging: wasDragging,
            );

        if (overlayWindowController.isAutoDismissWindowOpen &&
            !shouldKeepOverlayOpen) {
          if (overlayWindowController.getIsOverlayWindowShown(
                MPWindowType.changeImage,
              ) &&
              th2FileEditController
                  .stateController
                  .state
                  .keepOverlayOpenOnCanvasClick) {
            th2FileEditController.stateController.clearImageOperationState();
          }

          overlayWindowController.closeAutoDismissOverlayWindows();
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
        if (event is PointerScrollEvent) {
          widget.actuator.onTertiaryButtonScroll(event);
        }
      },
      child: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          final bool isArrowKey = _isArrowKey(event.logicalKey);

          if (event is KeyDownEvent) {
            logicalKeyPressed = event.logicalKey;
            widget.actuator.onKeyDownEvent(event);
          } else if (event is KeyRepeatEvent) {
            logicalKeyPressed = event.logicalKey;
            widget.actuator.onKeyRepeatEvent(event);
          } else if (event is KeyUpEvent) {
            logicalKeyPressed = null;
            widget.actuator.onKeyUpEvent(event);
          }

          return isArrowKey ? KeyEventResult.handled : KeyEventResult.ignored;
        },
        child: widget.child,
      ),
    );
  }

  bool _isArrowKey(LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.arrowDown:
        return true;
      default:
        return false;
    }
  }
}
