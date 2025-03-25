import 'package:flutter/material.dart';

class MPSingleColumnListOverlayWindowContentWidget extends StatelessWidget {
  final List<Widget> children;
  final double maxHeight;

  const MPSingleColumnListOverlayWindowContentWidget({
    super.key,
    required this.children,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        child: IntrinsicWidth(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
