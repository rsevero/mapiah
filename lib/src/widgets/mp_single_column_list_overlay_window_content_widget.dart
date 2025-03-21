import 'package:flutter/material.dart';

class MPSingleColumnListOverlayWindowContentWidget extends StatelessWidget {
  final List<Widget> children;

  const MPSingleColumnListOverlayWindowContentWidget({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
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
    );
  }
}
