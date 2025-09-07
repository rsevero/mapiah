import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';

class MPLocator {
  static final MPLocator _instance = MPLocator._internal();

  factory MPLocator() {
    return _instance;
  }

  MPLocator._internal();

  final MPGeneralController mpGeneralController = MPGeneralController();

  final MPSettingsController mpSettingsController = MPSettingsController();

  final MPLog mpLog = MPLog.instance;

  late AppLocalizations appLocalizations;

  final GlobalKey<NavigatorState> mpNavigatorKey = GlobalKey<NavigatorState>();

  void resetAppLocalizations(BuildContext context) {
    appLocalizations = AppLocalizations.of(context);
  }
}
