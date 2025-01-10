// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THSettingsStore on THSettingsStoreBase, Store {
  late final _$_localeIDAtom =
      Atom(name: 'THSettingsStoreBase._localeID', context: context);

  String get localeID {
    _$_localeIDAtom.reportRead();
    return super._localeID;
  }

  @override
  String get _localeID => localeID;

  @override
  set _localeID(String value) {
    _$_localeIDAtom.reportWrite(value, super._localeID, () {
      super._localeID = value;
    });
  }

  late final _$_localeAtom =
      Atom(name: 'THSettingsStoreBase._locale', context: context);

  Locale get locale {
    _$_localeAtom.reportRead();
    return super._locale;
  }

  @override
  Locale get _locale => locale;

  @override
  set _locale(Locale value) {
    _$_localeAtom.reportWrite(value, super._locale, () {
      super._locale = value;
    });
  }

  late final _$_selectionToleranceAtom =
      Atom(name: 'THSettingsStoreBase._selectionTolerance', context: context);

  double get selectionTolerance {
    _$_selectionToleranceAtom.reportRead();
    return super._selectionTolerance;
  }

  @override
  double get _selectionTolerance => selectionTolerance;

  @override
  set _selectionTolerance(double value) {
    _$_selectionToleranceAtom.reportWrite(value, super._selectionTolerance, () {
      super._selectionTolerance = value;
    });
  }

  late final _$_selectionToleranceSquaredAtom = Atom(
      name: 'THSettingsStoreBase._selectionToleranceSquared', context: context);

  double get selectionToleranceSquared {
    _$_selectionToleranceSquaredAtom.reportRead();
    return super._selectionToleranceSquared;
  }

  @override
  double get _selectionToleranceSquared => selectionToleranceSquared;

  @override
  set _selectionToleranceSquared(double value) {
    _$_selectionToleranceSquaredAtom
        .reportWrite(value, super._selectionToleranceSquared, () {
      super._selectionToleranceSquared = value;
    });
  }

  late final _$THSettingsStoreBaseActionController =
      ActionController(name: 'THSettingsStoreBase', context: context);

  @override
  void setLocaleID(String aLocaleID) {
    final _$actionInfo = _$THSettingsStoreBaseActionController.startAction(
        name: 'THSettingsStoreBase.setLocaleID');
    try {
      return super.setLocaleID(aLocaleID);
    } finally {
      _$THSettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
