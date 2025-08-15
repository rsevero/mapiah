// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_option_edit_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditOptionEditController
    on TH2FileEditOptionEditControllerBase, Store {
  late final _$_thFileAtom = Atom(
    name: 'TH2FileEditOptionEditControllerBase._thFile',
    context: context,
  );

  THFile get thFile {
    _$_thFileAtom.reportRead();
    return super._thFile;
  }

  @override
  THFile get _thFile => thFile;

  @override
  set _thFile(THFile value) {
    _$_thFileAtom.reportWrite(value, super._thFile, () {
      super._thFile = value;
    });
  }

  late final _$_th2FileEditControllerAtom = Atom(
    name: 'TH2FileEditOptionEditControllerBase._th2FileEditController',
    context: context,
  );

  TH2FileEditController get th2FileEditController {
    _$_th2FileEditControllerAtom.reportRead();
    return super._th2FileEditController;
  }

  @override
  TH2FileEditController get _th2FileEditController => th2FileEditController;

  @override
  set _th2FileEditController(TH2FileEditController value) {
    _$_th2FileEditControllerAtom.reportWrite(
      value,
      super._th2FileEditController,
      () {
        super._th2FileEditController = value;
      },
    );
  }

  late final _$_optionStateMapAtom = Atom(
    name: 'TH2FileEditOptionEditControllerBase._optionStateMap',
    context: context,
  );

  Map<THCommandOptionType, MPOptionInfo> get optionStateMap {
    _$_optionStateMapAtom.reportRead();
    return super._optionStateMap;
  }

  @override
  Map<THCommandOptionType, MPOptionInfo> get _optionStateMap => optionStateMap;

  @override
  set _optionStateMap(Map<THCommandOptionType, MPOptionInfo> value) {
    _$_optionStateMapAtom.reportWrite(value, super._optionStateMap, () {
      super._optionStateMap = value;
    });
  }

  late final _$_optionAttrStateMapAtom = Atom(
    name: 'TH2FileEditOptionEditControllerBase._optionAttrStateMap',
    context: context,
  );

  Map<String, MPOptionInfo> get optionAttrStateMap {
    _$_optionAttrStateMapAtom.reportRead();
    return super._optionAttrStateMap;
  }

  @override
  Map<String, MPOptionInfo> get _optionAttrStateMap => optionAttrStateMap;

  @override
  set _optionAttrStateMap(Map<String, MPOptionInfo> value) {
    _$_optionAttrStateMapAtom.reportWrite(value, super._optionAttrStateMap, () {
      super._optionAttrStateMap = value;
    });
  }

  late final _$_currentOptionTypeAtom = Atom(
    name: 'TH2FileEditOptionEditControllerBase._currentOptionType',
    context: context,
  );

  THCommandOptionType? get currentOptionType {
    _$_currentOptionTypeAtom.reportRead();
    return super._currentOptionType;
  }

  @override
  THCommandOptionType? get _currentOptionType => currentOptionType;

  @override
  set _currentOptionType(THCommandOptionType? value) {
    _$_currentOptionTypeAtom.reportWrite(value, super._currentOptionType, () {
      super._currentOptionType = value;
    });
  }

  late final _$_optionsScrapMPIDAtom = Atom(
    name: 'TH2FileEditOptionEditControllerBase._optionsScrapMPID',
    context: context,
  );

  int get optionsScrapMPID {
    _$_optionsScrapMPIDAtom.reportRead();
    return super._optionsScrapMPID;
  }

  @override
  int get _optionsScrapMPID => optionsScrapMPID;

  @override
  set _optionsScrapMPID(int value) {
    _$_optionsScrapMPIDAtom.reportWrite(value, super._optionsScrapMPID, () {
      super._optionsScrapMPID = value;
    });
  }

  late final _$TH2FileEditOptionEditControllerBaseActionController =
      ActionController(
        name: 'TH2FileEditOptionEditControllerBase',
        context: context,
      );

  @override
  void updateOptionStateMap() {
    final _$actionInfo = _$TH2FileEditOptionEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditOptionEditControllerBase.updateOptionStateMap',
        );
    try {
      return super.updateOptionStateMap();
    } finally {
      _$TH2FileEditOptionEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void setOptionsScrapMPID(int mpID) {
    final _$actionInfo = _$TH2FileEditOptionEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditOptionEditControllerBase.setOptionsScrapMPID',
        );
    try {
      return super.setOptionsScrapMPID(mpID);
    } finally {
      _$TH2FileEditOptionEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void performToggleOptionShownStatus({
    required THCommandOptionType optionType,
    required Offset outerAnchorPosition,
  }) {
    final _$actionInfo = _$TH2FileEditOptionEditControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditOptionEditControllerBase.performToggleOptionShownStatus',
        );
    try {
      return super.performToggleOptionShownStatus(
        optionType: optionType,
        outerAnchorPosition: outerAnchorPosition,
      );
    } finally {
      _$TH2FileEditOptionEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void clearCurrentOptionType() {
    final _$actionInfo = _$TH2FileEditOptionEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditOptionEditControllerBase.clearCurrentOptionType',
        );
    try {
      return super.clearCurrentOptionType();
    } finally {
      _$TH2FileEditOptionEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void showOptionsOverlayWindow() {
    final _$actionInfo = _$TH2FileEditOptionEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditOptionEditControllerBase.showOptionsOverlayWindow',
        );
    try {
      return super.showOptionsOverlayWindow();
    } finally {
      _$TH2FileEditOptionEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
