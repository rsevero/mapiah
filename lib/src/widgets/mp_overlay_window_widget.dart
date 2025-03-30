import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
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
  bool _initialPositionSet = false;
  LogicalKeyboardKey? logicalKeyPressed;

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
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        final Size size = renderBox.size;

        setState(
          () {
            Offset newPosition = widget.outerAnchorPosition;

            switch (widget.innerAnchorType) {
              case MPWidgetPositionType.bottomCenter:
                newPosition = widget.outerAnchorPosition -
                    Offset(size.width / 2, size.height);
              case MPWidgetPositionType.bottomLeft:
                newPosition =
                    widget.outerAnchorPosition - Offset(0, size.height);
              case MPWidgetPositionType.bottomRight:
                newPosition = widget.outerAnchorPosition -
                    Offset(size.width, size.height);
              case MPWidgetPositionType.center:
                newPosition = widget.outerAnchorPosition -
                    (Offset(size.width, size.height) / 2);
              case MPWidgetPositionType.leftCenter:
                newPosition =
                    widget.outerAnchorPosition - Offset(0, size.height / 2);
              case MPWidgetPositionType.rightCenter:
                newPosition = widget.outerAnchorPosition -
                    Offset(size.width, size.height / 2);
              case MPWidgetPositionType.topCenter:
                newPosition =
                    widget.outerAnchorPosition - Offset(size.width / 2, 0);
              case MPWidgetPositionType.topLeft:
                newPosition = widget.outerAnchorPosition;
              case MPWidgetPositionType.topRight:
                newPosition =
                    widget.outerAnchorPosition - Offset(size.width, 0);
            }

            Rect? thFileBoundingBox =
                MPInteractionAux.getWidgetRectFromGlobalKey(
              widgetGlobalKey: th2FileEditController.thFileWidgetKey,
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
        child: Material(
          color: Colors.yellowAccent,
          borderRadius: BorderRadius.circular(18.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: getMaxHeightForOverlayWindows(
                th2FileEditController.thFileWidgetKey,
              ),
            ),
            child: IntrinsicWidth(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                      Text(widget.title),
                    ] +
                    widget.children,
              )),
            )),
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
          'No render box found for THFileWidget in MPOverlayWindowWidget.getMaxHeightForOverlayWindows()');
    }

    return renderBox.size.height;
  }
}
