import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/pages/home.dart';
import 'package:mapiah/src/th_definitions/color_schemes.orange_brown.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      title: 'Mapiah',
      home: Home(),
    );
  }
}
