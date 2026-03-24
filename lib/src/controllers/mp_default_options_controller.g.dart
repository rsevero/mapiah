// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mp_default_options_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MPDefaultOptionsController on MPDefaultOptionsControllerBase, Store {
  Computed<bool>? _$hasAnyDefaultsComputed;

  @override
  bool get hasAnyDefaults => (_$hasAnyDefaultsComputed ??= Computed<bool>(
    () => super.hasAnyDefaults,
    name: 'MPDefaultOptionsControllerBase.hasAnyDefaults',
  )).value;

  late final _$_defaultOptionsVersionAtom = Atom(
    name: 'MPDefaultOptionsControllerBase._defaultOptionsVersion',
    context: context,
  );

  @override
  int get _defaultOptionsVersion {
    _$_defaultOptionsVersionAtom.reportRead();
    return super._defaultOptionsVersion;
  }

  @override
  set _defaultOptionsVersion(int value) {
    _$_defaultOptionsVersionAtom.reportWrite(
      value,
      super._defaultOptionsVersion,
      () {
        super._defaultOptionsVersion = value;
      },
    );
  }

  late final _$MPDefaultOptionsControllerBaseActionController =
      ActionController(
        name: 'MPDefaultOptionsControllerBase',
        context: context,
      );

  @override
  void setDefault(THElementType elementType, THCommandOption option) {
    final _$actionInfo = _$MPDefaultOptionsControllerBaseActionController
        .startAction(name: 'MPDefaultOptionsControllerBase.setDefault');
    try {
      return super.setDefault(elementType, option);
    } finally {
      _$MPDefaultOptionsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeDefault(
    THElementType elementType,
    THCommandOptionType optionType,
  ) {
    final _$actionInfo = _$MPDefaultOptionsControllerBaseActionController
        .startAction(name: 'MPDefaultOptionsControllerBase.removeDefault');
    try {
      return super.removeDefault(elementType, optionType);
    } finally {
      _$MPDefaultOptionsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAll() {
    final _$actionInfo = _$MPDefaultOptionsControllerBaseActionController
        .startAction(name: 'MPDefaultOptionsControllerBase.clearAll');
    try {
      return super.clearAll();
    } finally {
      _$MPDefaultOptionsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearForElementType(THElementType elementType) {
    final _$actionInfo = _$MPDefaultOptionsControllerBaseActionController
        .startAction(
          name: 'MPDefaultOptionsControllerBase.clearForElementType',
        );
    try {
      return super.clearForElementType(elementType);
    } finally {
      _$MPDefaultOptionsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
hasAnyDefaults: ${hasAnyDefaults}
    ''';
  }
}
