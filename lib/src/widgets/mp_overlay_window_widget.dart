import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class MPOverlayWindowWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final int zOrder;
  final Widget child;

  const MPOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
    required this.zOrder,
    required this.child,
  });

  @override
  State<MPOverlayWindowWidget> createState() => _MPOverlayWindowWidgetState();
}

class _MPOverlayWindowWidgetState extends State<MPOverlayWindowWidget> {
  final GlobalKey widgetKey = GlobalKey();
  late final TH2FileEditController th2FileEditController;
  late final int zOrder;
  late final Offset position;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    zOrder = widget.zOrder;
    position = widget.position;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCoordinates();
    });
  }

  @override
  void dispose() {
    th2FileEditController.removeOverlayWindowInfo(widgetKey);
    super.dispose();
  }

  void _updateCoordinates() {
    th2FileEditController.updateOverlayWindowInfo(widgetKey, zOrder);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Listener(
        key: widgetKey,
        onPointerDown: (PointerDownEvent event) {
          mpLocator.mpLog.fine("MPOverlayWindowWidget.onPointerDown()");
        },
        onPointerUp: (PointerUpEvent event) {
          mpLocator.mpLog.fine("MPOverlayWindowWidget.onPointerUp()");
        },
        child: widget.child,
      ),
    );
  }
}
