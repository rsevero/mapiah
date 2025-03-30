import 'package:flutter/material.dart';

class MPOverlayWindowBlockWidget extends StatelessWidget {
  final List<Widget> children;

  const MPOverlayWindowBlockWidget({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.green,
      borderRadius: BorderRadius.circular(18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
