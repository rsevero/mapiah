// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:material_ui/material_ui.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';

Widget buildTH2FileTabsPageTestApp({
  required TH2FileEditController th2FileEditController,
  Locale locale = const Locale('en'),
}) {
  final String filename = th2FileEditController.th2File.filename;

  // These tests exercise the editor workspace, not the first-launch flow.
  // Record an explicit consent choice so the startup dialog cannot absorb
  // their pointer and keyboard events.
  mpLocator.mpSettingsController.setBool(
    MPSettingID.Main_TelemetryConsent,
    false,
  );
  mpLocator.mpGeneralController.addFileTab(filename);

  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: const TH2FileTabsPage(),
  );
}
