// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_user_interaction_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditUserInteractionController
    on TH2FileEditUserInteractionControllerBase, Store {
  late final _$_th2FileAtom = Atom(
    name: 'TH2FileEditUserInteractionControllerBase._th2File',
    context: context,
  );

  TH2File get th2File {
    _$_th2FileAtom.reportRead();
    return super._th2File;
  }

  @override
  TH2File get _th2File => th2File;

  @override
  set _th2File(TH2File value) {
    _$_th2FileAtom.reportWrite(value, super._th2File, () {
      super._th2File = value;
    });
  }

  late final _$_th2FileEditControllerAtom = Atom(
    name: 'TH2FileEditUserInteractionControllerBase._th2FileEditController',
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

  late final _$TH2FileEditUserInteractionControllerBaseActionController =
      ActionController(
        name: 'TH2FileEditUserInteractionControllerBase',
        context: context,
      );

  @override
  void prepareSetOption({
    required THCommandOption? option,
    required THCommandOptionType optionType,
  }) {
    final _$actionInfo =
        _$TH2FileEditUserInteractionControllerBaseActionController.startAction(
          name: 'TH2FileEditUserInteractionControllerBase.prepareSetOption',
        );
    try {
      return super.prepareSetOption(option: option, optionType: optionType);
    } finally {
      _$TH2FileEditUserInteractionControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void prepareSetMultipleOptionChoice({
    required THCommandOptionType optionType,
    required String choice,
  }) {
    final _$actionInfo =
        _$TH2FileEditUserInteractionControllerBaseActionController.startAction(
          name:
              'TH2FileEditUserInteractionControllerBase.prepareSetMultipleOptionChoice',
        );
    try {
      return super.prepareSetMultipleOptionChoice(
        optionType: optionType,
        choice: choice,
      );
    } finally {
      _$TH2FileEditUserInteractionControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void prepareSetLineSegmentType({
    required MPSelectedLineSegmentType selectedLineSegmentType,
  }) {
    final _$actionInfo =
        _$TH2FileEditUserInteractionControllerBaseActionController.startAction(
          name:
              'TH2FileEditUserInteractionControllerBase.prepareSetLineSegmentType',
        );
    try {
      return super.prepareSetLineSegmentType(
        selectedLineSegmentType: selectedLineSegmentType,
      );
    } finally {
      _$TH2FileEditUserInteractionControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void prepareSetPLAType({
    required THElementType elementType,
    required String newPLAType,
  }) {
    final _$actionInfo =
        _$TH2FileEditUserInteractionControllerBaseActionController.startAction(
          name: 'TH2FileEditUserInteractionControllerBase.prepareSetPLAType',
        );
    try {
      return super.prepareSetPLAType(
        elementType: elementType,
        newPLAType: newPLAType,
      );
    } finally {
      _$TH2FileEditUserInteractionControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void prepareRemoveAreaBorderTHID(int areaBorderTHIDMPID) {
    final _$actionInfo =
        _$TH2FileEditUserInteractionControllerBaseActionController.startAction(
          name:
              'TH2FileEditUserInteractionControllerBase.prepareRemoveAreaBorderTHID',
        );
    try {
      return super.prepareRemoveAreaBorderTHID(areaBorderTHIDMPID);
    } finally {
      _$TH2FileEditUserInteractionControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void prepareAddAreaBorderTHID() {
    final _$actionInfo =
        _$TH2FileEditUserInteractionControllerBaseActionController.startAction(
          name:
              'TH2FileEditUserInteractionControllerBase.prepareAddAreaBorderTHID',
        );
    try {
      return super.prepareAddAreaBorderTHID();
    } finally {
      _$TH2FileEditUserInteractionControllerBaseActionController.endAction(
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
