import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';

class MPOverlayWindowWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final Widget child;
  final GlobalKey globalKey;

  const MPOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
    required this.child,
    required this.globalKey,
  });

  @override
  State<MPOverlayWindowWidget> createState() => _MPOverlayWindowWidgetState();
}

class _MPOverlayWindowWidgetState extends State<MPOverlayWindowWidget> {
  late final TH2FileEditController th2FileEditController;
  late final TH2FileEditOverlayWindowController overlayWindowController;
  late final int zOrder;
  late final Offset position;

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
    overlayWindowController.updateOverlayWindowInfo(
      MPOverlayWindowType.commandOptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      key: widget.globalKey,
      left: position.dx,
      top: position.dy,
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          // mpLocator.mpLog.fine("MPOverlayWindowWidget.onPointerDown()");
        },
        onPointerUp: (PointerUpEvent event) {
          // mpLocator.mpLog.fine("MPOverlayWindowWidget.onPointerUp()");
        },
        child: widget.child,
      ),
    );
  }
}
