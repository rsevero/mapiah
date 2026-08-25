// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/mp_telemetry_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class MPLocator {
  static final MPLocator _instance = MPLocator._internal();

  factory MPLocator() {
    return _instance;
  }

  MPLocator._internal();

  final MPGeneralController mpGeneralController = MPGeneralController();
  final MPTelemetryController mpTelemetryController = MPTelemetryController();
  final THProjectController thProjectController = THProjectController();

  MPSettingsController? _mpSettingsController;
  THProjectTreeUIController? _thProjectTreeUIController;

  MPSettingsController get mpSettingsController =>
      _mpSettingsController ??= MPSettingsController();

  THProjectTreeUIController get thProjectTreeUIController =>
      _thProjectTreeUIController ??= THProjectTreeUIController();

  final MPLog mpLog = MPLog.instance;

  late AppLocalizations appLocalizations;

  final GlobalKey<NavigatorState> mpNavigatorKey = GlobalKey<NavigatorState>();

  void resetAppLocalizations(BuildContext context) {
    appLocalizations = AppLocalizations.of(context);
  }
}
