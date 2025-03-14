import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOverlayWindowWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final Widget child;
  final GlobalKey globalKey;
  final MPWidgetPositionType positionType;

  const MPOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
    required this.child,
    required this.globalKey,
    required this.positionType,
  });

  @override
  State<MPOverlayWindowWidget> createState() => _MPOverlayWindowWidgetState();
}

class _MPOverlayWindowWidgetState extends State<MPOverlayWindowWidget> {
  late final TH2FileEditController th2FileEditController;
  late final TH2FileEditOverlayWindowController overlayWindowController;
  late final int zOrder;
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

  @override
  void dispose() {
    overlayWindowController.hideOverlayWindow(
      MPOverlayWindowType.commandOptions,
    );
    super.dispose();
  }

  void _updateCoordinates() {
    bool overlayWindowUpdated = false;

    if (!_initialPositionSet) {
      final RenderBox? renderBox =
          widget.globalKey.currentContext?.findRenderObject() as RenderBox?;

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
        overlayWindowController.updateOverlayWindowWithBoundingBox(
          widget.globalKey,
          MPNumericAux.orderedRectFromLTWH(
            left: position.dx,
            top: position.dy,
            width: size.width,
            height: size.height,
          ),
        );
        overlayWindowUpdated = true;
      }
    }

    if (!overlayWindowUpdated) {
      overlayWindowController.updateOverlayWindowInfo(
        MPOverlayWindowType.commandOptions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      key: widget.globalKey,
      left: position.dx,
      top: position.dy,
      child: Visibility.maintain(
        visible: _initialPositionSet,
        child: Listener(
          onPointerDown: (PointerDownEvent event) {
            // mpLocator.mpLog.fine("MPOverlayWindowWidget.onPointerDown()");
          },
          onPointerUp: (PointerUpEvent event) {
            // mpLocator.mpLog.fine("MPOverlayWindowWidget.onPointerUp()");
          },
          child: widget.child,
        ),
      ),
    );
  }
}
