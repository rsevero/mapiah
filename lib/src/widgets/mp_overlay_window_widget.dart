import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOverlayWindowWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final String title;
  final List<Widget> children;
  final MPOverlayWindowType overlayWindowType;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;
  final ValueChanged<KeyDownEvent>? onKeyDownEvent;
  final ValueChanged<KeyUpEvent>? onKeyUpEvent;

  const MPOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.title,
    required this.overlayWindowType,
    required this.children,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
    this.onKeyDownEvent,
    this.onKeyUpEvent,
  });

  @override
  State<MPOverlayWindowWidget> createState() => _MPOverlayWindowWidgetState();
}

class _MPOverlayWindowWidgetState extends State<MPOverlayWindowWidget> {
  late final TH2FileEditController th2FileEditController;
  late final TH2FileEditOverlayWindowController overlayWindowController;
  late Offset position;
  final GlobalKey _windowKey = GlobalKey();
  bool _initialPositionSet = false;
  LogicalKeyboardKey? logicalKeyPressed;

  bool _isRightDragging = false;
  Offset? _rightDragStartGlobal;
  Offset? _rightDragStartPosition;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    overlayWindowController = th2FileEditController.overlayWindowController;
    position = widget.outerAnchorPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCoordinates();
    });
  }

  void _updateCoordinates() {
    if (!_initialPositionSet) {
      final RenderBox? renderBox =
          _windowKey.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        final Size size = renderBox.size;

        setState(() {
          Offset newPosition = widget.outerAnchorPosition;

          switch (widget.innerAnchorType) {
            case MPWidgetPositionType.bottomCenter:
              newPosition =
                  widget.outerAnchorPosition -
                  Offset(size.width / 2, size.height);
            case MPWidgetPositionType.bottomLeft:
              newPosition = widget.outerAnchorPosition - Offset(0, size.height);
            case MPWidgetPositionType.bottomRight:
              newPosition =
                  widget.outerAnchorPosition - Offset(size.width, size.height);
            case MPWidgetPositionType.center:
              newPosition =
                  widget.outerAnchorPosition -
                  (Offset(size.width, size.height) / 2);
            case MPWidgetPositionType.centerLeft:
              newPosition =
                  widget.outerAnchorPosition - Offset(0, size.height / 2);
            case MPWidgetPositionType.centerRight:
              newPosition =
                  widget.outerAnchorPosition -
                  Offset(size.width, size.height / 2);
            case MPWidgetPositionType.topCenter:
              newPosition =
                  widget.outerAnchorPosition - Offset(size.width / 2, 0);
            case MPWidgetPositionType.topLeft:
              newPosition = widget.outerAnchorPosition;
            case MPWidgetPositionType.topRight:
              newPosition = widget.outerAnchorPosition - Offset(size.width, 0);
          }

          Rect? thFileBoundingBox = MPInteractionAux.getWidgetRectFromGlobalKey(
            widgetGlobalKey: th2FileEditController.getTHFileWidgetGlobalKey(),
          );

          thFileBoundingBox ??= th2FileEditController.screenBoundingBox;

          /// Up to here newPosition is the position inside the THFileWidget
          /// window. Adjusting it to global coordinates as overlay windows
          /// are positioned in global coordinates.
          newPosition += thFileBoundingBox.topLeft;

          if (thFileBoundingBox.bottom < (newPosition.dy + size.height)) {
            newPosition = Offset(
              newPosition.dx,
              thFileBoundingBox.bottom - size.height,
            );
          }

          if (newPosition.dy < thFileBoundingBox.top) {
            newPosition = Offset(newPosition.dx, thFileBoundingBox.top);
          }

          if (thFileBoundingBox.right < (newPosition.dx + size.width)) {
            newPosition = Offset(
              thFileBoundingBox.right - size.width,
              newPosition.dy,
            );
          }

          if (newPosition.dx < thFileBoundingBox.left) {
            newPosition = Offset(thFileBoundingBox.left, newPosition.dy);
          }

          position = newPosition;
          _initialPositionSet = true;
        });
      }
    }
  }

  Rect _getBoundingBoxForClamping() {
    Rect? thFileBoundingBox = MPInteractionAux.getWidgetRectFromGlobalKey(
      widgetGlobalKey: th2FileEditController.getTHFileWidgetGlobalKey(),
    );

    thFileBoundingBox ??= th2FileEditController.screenBoundingBox;
    return thFileBoundingBox;
  }

  Offset _clampPositionToBoundingBox({
    required Offset newPosition,
    required Size size,
  }) {
    final Rect boundingBox = _getBoundingBoxForClamping();

    if (boundingBox.bottom < (newPosition.dy + size.height)) {
      newPosition = Offset(newPosition.dx, boundingBox.bottom - size.height);
    }

    if (newPosition.dy < boundingBox.top) {
      newPosition = Offset(newPosition.dx, boundingBox.top);
    }

    if (boundingBox.right < (newPosition.dx + size.width)) {
      newPosition = Offset(boundingBox.right - size.width, newPosition.dy);
    }

    if (newPosition.dx < boundingBox.left) {
      newPosition = Offset(boundingBox.left, newPosition.dy);
    }

    return newPosition;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!_initialPositionSet) {
      return;
    }

    if ((event.kind != PointerDeviceKind.mouse) ||
        (event.buttons != kSecondaryMouseButton)) {
      return;
    }

    final RenderBox? renderBox =
        _windowKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return;
    }

    setState(() {
      _isRightDragging = true;
      _rightDragStartGlobal = event.position;
      _rightDragStartPosition = position;
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isRightDragging) {
      return;
    }

    final Offset? dragStartGlobal = _rightDragStartGlobal;
    final Offset? dragStartPosition = _rightDragStartPosition;

    if ((dragStartGlobal == null) || (dragStartPosition == null)) {
      return;
    }

    final RenderBox? renderBox =
        _windowKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return;
    }

    final Offset delta = event.position - dragStartGlobal;
    final Offset unclamped = dragStartPosition + delta;
    final Offset clamped = _clampPositionToBoundingBox(
      newPosition: unclamped,
      size: renderBox.size,
    );

    setState(() {
      position = clamped;
    });
  }

  void _stopRightDrag() {
    if (!_isRightDragging) {
      return;
    }

    setState(() {
      _isRightDragging = false;
      _rightDragStartGlobal = null;
      _rightDragStartPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Visibility.maintain(
        visible: _initialPositionSet,
        child: Material(
          key: _windowKey,
          color: Theme.of(context).colorScheme.primaryFixed,
          borderRadius: BorderRadius.circular(mpOverlayWindowCornerRadius),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: getMaxHeightForOverlayWindows(
                th2FileEditController.getTHFileWidgetGlobalKey(),
              ),
              minWidth: mpOverlayWindowMinWidth,
            ),
            child: IntrinsicWidth(
              child: Padding(
                padding: const EdgeInsets.all(mpOverlayWindowPadding),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        <Widget>[
                          MouseRegion(
                            cursor: SystemMouseCursors.move,
                            child: Listener(
                              behavior: HitTestBehavior.translucent,
                              onPointerDown: _onPointerDown,
                              onPointerMove: _onPointerMove,
                              onPointerUp: (_) => _stopRightDrag(),
                              onPointerCancel: (_) => _stopRightDrag(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  widget.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryFixed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ] +
                        widget.children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double getMaxHeightForOverlayWindows(GlobalKey targetKey) {
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      throw Exception(
        'No render box found for THFileWidget in MPOverlayWindowWidget.getMaxHeightForOverlayWindows()',
      );
    }

    return renderBox.size.height;
  }
}
