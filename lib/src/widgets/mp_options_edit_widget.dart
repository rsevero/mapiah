import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOptionsEditWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final GlobalKey globalKey;
  final MPWidgetPositionType positionType;

  const MPOptionsEditWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
    required this.globalKey,
    required this.positionType,
  });

  @override
  State<MPOptionsEditWidget> createState() => _MPOptionsEditWidgetState();
}

class _MPOptionsEditWidgetState extends State<MPOptionsEditWidget> {
  late final TH2FileEditController th2FileEditController;
  late final int zOrder;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    zOrder = th2FileEditController.overlayWindowController.getNewZOrder();
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      globalKey: widget.globalKey,
      position: widget.position,
      positionType: widget.positionType,
      th2FileEditController: th2FileEditController,
      child: Material(
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
    );
  }
}
