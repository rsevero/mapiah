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

  late final _$_openFileOrderAtom = Atom(
    name: 'MPGeneralControllerBase._openFileOrder',
    context: context,
  );

  ObservableList<String> get openFileOrder {
    _$_openFileOrderAtom.reportRead();
    return super._openFileOrder;
  }

  @override
  ObservableList<String> get _openFileOrder => openFileOrder;

  @override
  set _openFileOrder(ObservableList<String> value) {
    _$_openFileOrderAtom.reportWrite(value, super._openFileOrder, () {
      super._openFileOrder = value;
    });
  }

  late final _$_activeTabIndexAtom = Atom(
    name: 'MPGeneralControllerBase._activeTabIndex',
    context: context,
  );

  int get activeTabIndex {
    _$_activeTabIndexAtom.reportRead();
    return super._activeTabIndex;
  }

  @override
  int get _activeTabIndex => activeTabIndex;

  @override
  set _activeTabIndex(int value) {
    _$_activeTabIndexAtom.reportWrite(value, super._activeTabIndex, () {
      super._activeTabIndex = value;
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
  void addFileTab(String filename) {
    final _$actionInfo = _$MPGeneralControllerBaseActionController.startAction(
      name: 'MPGeneralControllerBase.addFileTab',
    );
    try {
      return super.addFileTab(filename);
    } finally {
      _$MPGeneralControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeFileTab({required String filename}) {
    final _$actionInfo = _$MPGeneralControllerBaseActionController.startAction(
      name: 'MPGeneralControllerBase.removeFileTab',
    );
    try {
      return super.removeFileTab(filename: filename);
    } finally {
      _$MPGeneralControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setActiveTab(int index) {
    final _$actionInfo = _$MPGeneralControllerBaseActionController.startAction(
      name: 'MPGeneralControllerBase.setActiveTab',
    );
    try {
      return super.setActiveTab(index);
    } finally {
      _$MPGeneralControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reorderFileTabs(List<String> newOrder) {
    final _$actionInfo = _$MPGeneralControllerBaseActionController.startAction(
      name: 'MPGeneralControllerBase.reorderFileTabs',
    );
    try {
      return super.reorderFileTabs(newOrder);
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
