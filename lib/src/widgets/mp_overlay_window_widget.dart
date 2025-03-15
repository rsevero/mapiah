import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOverlayWindowWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final Widget child;
  final MPOverlayWindowType overlayWindowType;
  final MPWidgetPositionType positionType;

  const MPOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
    required this.child,
    required this.positionType,
    required this.overlayWindowType,
  });

  @override
  State<MPOverlayWindowWidget> createState() => _MPOverlayWindowWidgetState();
}

class _MPOverlayWindowWidgetState extends State<MPOverlayWindowWidget> {
  late final TH2FileEditController th2FileEditController;
  late final TH2FileEditOverlayWindowController overlayWindowController;
  late Offset position;
  bool _initialPositionSet = false;

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
        child: Listener(
          onPointerDown: (PointerDownEvent event) {
            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerDown() entered");

            if (overlayWindowController.processingPointerDownEvent) {
              return;
            }
            overlayWindowController.processingPointerDownEvent = true;
            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerDown() to be executed");

            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerDown() executed");
          },
          onPointerUp: (PointerUpEvent event) {
            mpLocator.mpLog.fine("MPOverlayWindowWidget.onPointerUp() entered");

            if (overlayWindowController.processingPointerUpEvent) {
              return;
            }
            overlayWindowController.processingPointerUpEvent = true;
            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerUp() to be executed");

            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerUp() executed");
          },
          onPointerMove: (PointerMoveEvent event) {
            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerMove() entered");

            if (overlayWindowController.processingPointerMoveEvent) {
              return;
            }
            overlayWindowController.processingPointerMoveEvent = true;
            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerMove() to be executed");

            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerMove() executed");
          },
          onPointerSignal: (PointerSignalEvent event) {
            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerSignal() entered");

            if (overlayWindowController.processingPointerSignalEvent) {
              return;
            }
            overlayWindowController.processingPointerSignalEvent = true;
            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerSignal() to be executed");

            mpLocator.mpLog
                .fine("MPOverlayWindowWidget.onPointerSignal() executed");
          },
          child: widget.child,
        ),
      ),
    );
  }
}
