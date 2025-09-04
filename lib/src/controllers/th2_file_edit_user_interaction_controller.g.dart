// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_user_interaction_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditUserInteractionController
    on TH2FileEditUserInteractionControllerBase, Store {
  late final _$_thFileAtom = Atom(
    name: 'TH2FileEditUserInteractionControllerBase._thFile',
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
  String toString() {
    return '''

    ''';
  }
}
