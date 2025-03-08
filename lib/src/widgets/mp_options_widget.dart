import 'package:flutter/material.dart';

class MPOptionsWidget extends StatelessWidget {
  final VoidCallback onDismiss; // Callback to dismiss the widget

  const MPOptionsWidget({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Handles taps outside the widget
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque, // Ensures taps outside are detected
      child: Center(
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
                  items: <String>['Option 1', 'Option 2'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
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
    );
  }
}
