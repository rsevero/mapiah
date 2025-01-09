import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'th_settings_store.g.dart';

class THSettingsStore = THSettingsStoreBase with _$THSettingsStore;

abstract class THSettingsStoreBase with Store {
  @readonly
  String _localeID = 'en';

  @computed
  Locale get locale => Locale(_localeID);

  THSettingsStoreBase() {
    _initialize();
  }

  void _initialize() {
    final Locale systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale;
    setLocaleID(systemLocale.languageCode);
  }

  @action
  void setLocaleID(String aLocaleID) {
    _localeID = aLocaleID;
  }
}
