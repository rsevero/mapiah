// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mp_general_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MPGeneralController on MPGeneralControllerBase, Store {
  late final _$_thConfigFilePathAtom = Atom(
    name: 'MPGeneralControllerBase._thConfigFilePath',
    context: context,
  );

  String get thConfigFilePath {
    _$_thConfigFilePathAtom.reportRead();
    return super._thConfigFilePath;
  }

  @override
  String get _thConfigFilePath => thConfigFilePath;

  @override
  set _thConfigFilePath(String value) {
    _$_thConfigFilePathAtom.reportWrite(value, super._thConfigFilePath, () {
      super._thConfigFilePath = value;
    });
  }

  late final _$MPGeneralControllerBaseActionController = ActionController(
    name: 'MPGeneralControllerBase',
    context: context,
  );

  @override
  void setTHConfigFilePath(String value) {
    final _$actionInfo = _$MPGeneralControllerBaseActionController.startAction(
      name: 'MPGeneralControllerBase.setTHConfigFilePath',
    );
    try {
      return super.setTHConfigFilePath(value);
    } finally {
      _$MPGeneralControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
