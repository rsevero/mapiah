import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/pages/home.dart';
import 'package:mapiah/src/stores/th_file_display_page_store.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/th_definitions/color_schemes.orange_brown.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MapiahApp());
}

class MapiahApp extends StatelessWidget {
  const MapiahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => THFileDisplayPageStore(),
        ),
        Provider(
          create: (context) => THFileStore(),
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        title: 'Mapiah',
        home: Home(),
      ),
    );
  }
}
