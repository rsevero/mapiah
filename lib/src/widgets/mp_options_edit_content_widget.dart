import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class MPOptionsEditContentWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;

  const MPOptionsEditContentWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
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
    final RenderBox renderBox =
        _widgetKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    widget.th2FileEditController.updateIgnoreRect(
      widget.key!,
      MPNumericAux.orderedRectFromLTWH(
        left: position.dy,
        top: position.dx,
        width: position.dy + size.height,
        height: position.dx + size.width,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: Listener(
        behavior: HitTestBehavior.opaque, // Prevent event propagation
        child: GestureDetector(
          behavior: HitTestBehavior.opaque, // Prevent event propagation
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
                      dropdownColor: Colors.white.withOpacity(0.9),
                      items:
                          <String>['Option 1', 'Option 2'].map((String value) {
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
      ),
    );
  }
}
