// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mp_settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MPSettingsStore on MPSettingsStoreBase, Store {
  late final _$_localeIDAtom =
      Atom(name: 'MPSettingsStoreBase._localeID', context: context);

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
      Atom(name: 'MPSettingsStoreBase._locale', context: context);

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
      Atom(name: 'MPSettingsStoreBase._selectionTolerance', context: context);

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

  late final _$_pointRadiusAtom =
      Atom(name: 'MPSettingsStoreBase._pointRadius', context: context);

  double get pointRadius {
    _$_pointRadiusAtom.reportRead();
    return super._pointRadius;
  }

  @override
  double get _pointRadius => pointRadius;

  @override
  set _pointRadius(double value) {
    _$_pointRadiusAtom.reportWrite(value, super._pointRadius, () {
      super._pointRadius = value;
    });
  }

  late final _$_lineThicknessAtom =
      Atom(name: 'MPSettingsStoreBase._lineThickness', context: context);

  double get lineThickness {
    _$_lineThicknessAtom.reportRead();
    return super._lineThickness;
  }

  @override
  double get _lineThickness => lineThickness;

  @override
  set _lineThickness(double value) {
    _$_lineThicknessAtom.reportWrite(value, super._lineThickness, () {
      super._lineThickness = value;
    });
  }

  late final _$MPSettingsStoreBaseActionController =
      ActionController(name: 'MPSettingsStoreBase', context: context);

  @override
  void setLocaleID(String localeID) {
    final _$actionInfo = _$MPSettingsStoreBaseActionController.startAction(
        name: 'MPSettingsStoreBase.setLocaleID');
    try {
      return super.setLocaleID(localeID);
    } finally {
      _$MPSettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectionTolerance(double selectionTolerance) {
    final _$actionInfo = _$MPSettingsStoreBaseActionController.startAction(
        name: 'MPSettingsStoreBase.setSelectionTolerance');
    try {
      return super.setSelectionTolerance(selectionTolerance);
    } finally {
      _$MPSettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPointRadius(double pointRadius) {
    final _$actionInfo = _$MPSettingsStoreBaseActionController.startAction(
        name: 'MPSettingsStoreBase.setPointRadius');
    try {
      return super.setPointRadius(pointRadius);
    } finally {
      _$MPSettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLineThickness(double lineThickness) {
    final _$actionInfo = _$MPSettingsStoreBaseActionController.startAction(
        name: 'MPSettingsStoreBase.setLineThickness');
    try {
      return super.setLineThickness(lineThickness);
    } finally {
      _$MPSettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
