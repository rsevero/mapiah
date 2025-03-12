import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class MPOptionsEditContentWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final int zOrder;

  const MPOptionsEditContentWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
    required this.zOrder,
  });

  @override
  State<MPOptionsEditContentWidget> createState() =>
      _MPOptionsEditContentWidgetState();
}

class _MPOptionsEditContentWidgetState
    extends State<MPOptionsEditContentWidget> {
  final GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCoordinates();
    });
  }

  void _updateCoordinates() {
    widget.th2FileEditController.updateOverlayWindowInfo(
      MPOverlayWindowInfo(
        key: _widgetKey,
        zOrder: widget.zOrder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          mpLocator.mpLog.fine("MPOptionsEditContentWidget.onPointerDown()");
        },
        onPointerUp: (PointerUpEvent event) {
          mpLocator.mpLog.fine("MPOptionsEditContentWidget.onPointerUp()");
        },
        child: Center(
          child: Material(
            key: _widgetKey,
            elevation: 8.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Extra Information',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  // Add your interactive elements (dropdowns, buttons, etc.)
                  DropdownButton<String>(
                    dropdownColor: Colors.white.withAlpha(230),
                    items: <String>['Option 1', 'Option 2'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Material(
                          child: Text(value),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      // Handle dropdown changes
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    child: const Text('Do Something'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
