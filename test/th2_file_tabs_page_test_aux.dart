// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';

Widget buildTH2FileTabsPageTestApp({
  required TH2FileEditController th2FileEditController,
  Locale locale = const Locale('en'),
}) {
  final String filename = th2FileEditController.th2File.filename;

  mpLocator.mpGeneralController.addFileTab(filename);

  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: const TH2FileTabsPage(),
  );
}
