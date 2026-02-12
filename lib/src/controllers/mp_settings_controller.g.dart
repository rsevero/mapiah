// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mp_settings_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MPSettingsController on MPSettingsControllerBase, Store {
  late final _$_pointRadiusAtom = Atom(
    name: 'MPSettingsControllerBase._pointRadius',
    context: context,
  );

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

  late final _$_lineThicknessAtom = Atom(
    name: 'MPSettingsControllerBase._lineThickness',
    context: context,
  );

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

  late final _$MPSettingsControllerBaseActionController = ActionController(
    name: 'MPSettingsControllerBase',
    context: context,
  );

  @override
  void setPointRadius(double pointRadius) {
    final _$actionInfo = _$MPSettingsControllerBaseActionController.startAction(
      name: 'MPSettingsControllerBase.setPointRadius',
    );
    try {
      return super.setPointRadius(pointRadius);
    } finally {
      _$MPSettingsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLineThickness(double lineThickness) {
    final _$actionInfo = _$MPSettingsControllerBaseActionController.startAction(
      name: 'MPSettingsControllerBase.setLineThickness',
    );
    try {
      return super.setLineThickness(lineThickness);
    } finally {
      _$MPSettingsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void trigger(MPSettingsType type) {
    final _$actionInfo = _$MPSettingsControllerBaseActionController.startAction(
      name: 'MPSettingsControllerBase.trigger',
    );
    try {
      return super.trigger(type);
    } finally {
      _$MPSettingsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
