import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOverlayWindowWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final Widget child;
  final MPWindowType windowType;
  final MPWidgetPositionType positionType;
  final ValueChanged<KeyDownEvent>? onKeyDownEvent;
  final ValueChanged<KeyUpEvent>? onKeyUpEvent;

  const MPOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
    required this.child,
    required this.positionType,
    required this.windowType,
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
  bool _initialPositionSet = false;
  LogicalKeyboardKey? logicalKeyPressed;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    overlayWindowController = th2FileEditController.overlayWindowController;
    position = widget.position;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCoordinates();
    });
  }

  void _updateCoordinates() {
    if (!_initialPositionSet) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        final Size size = renderBox.size;

        setState(
          () {
            switch (widget.positionType) {
              case MPWidgetPositionType.bottomCenter:
                position =
                    widget.position - Offset(size.width / 2, size.height);
              case MPWidgetPositionType.bottomLeft:
                position = widget.position - Offset(0, size.height);
              case MPWidgetPositionType.bottomRight:
                position = widget.position - Offset(size.width, size.height);
              case MPWidgetPositionType.center:
                position =
                    widget.position - (Offset(size.width, size.height) / 2);
              case MPWidgetPositionType.leftCenter:
                position = widget.position - Offset(0, size.height / 2);
              case MPWidgetPositionType.rightCenter:
                position =
                    widget.position - Offset(size.width, size.height / 2);
              case MPWidgetPositionType.topCenter:
                position = widget.position - Offset(size.width / 2, 0);
              case MPWidgetPositionType.topLeft:
                position = widget.position;
              case MPWidgetPositionType.topRight:
                position = widget.position - Offset(size.width, 0);
            }

            final Rect screenBoundingBox =
                th2FileEditController.screenBoundingBox;

            if (position.dy + size.height > screenBoundingBox.bottom) {
              position = Offset(
                position.dx,
                screenBoundingBox.bottom - size.height,
              );
            }

            if (position.dy < screenBoundingBox.top) {
              position = Offset(position.dx, screenBoundingBox.top);
            }

            if (position.dx + size.width > screenBoundingBox.right) {
              position = Offset(
                screenBoundingBox.right - size.width,
                position.dy,
              );
            }

            if (position.dx < screenBoundingBox.left) {
              position = Offset(screenBoundingBox.left, position.dy);
            }

            _initialPositionSet = true;
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Visibility.maintain(
        visible: _initialPositionSet,
        child: widget.child,
      ),
    );
  }
}
