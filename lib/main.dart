import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mapiah/src/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mapiah',
      home: HomePage(),
    );
  }
}
