import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:mapiah/src/th_elements/th_element.dart';

class TH2FileDisplayPage extends StatelessWidget {
  final THFile file;

  TH2FileDisplayPage({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Display'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: CustomPaint(
          painter: TH2FilePainter(file),
        ),
      ),
    );
  }
}

class TH2FilePainter extends CustomPainter {
  final THFile file;

  TH2FilePainter(this.file);

  @override
  void paint(Canvas canvas, Size size) {
    // Add your drawing logic here based on the file's content
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
