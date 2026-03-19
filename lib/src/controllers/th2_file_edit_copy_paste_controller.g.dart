// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_copy_paste_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditCopyPasteController
    on TH2FileEditCopyPasteControllerBase, Store {
  late final _$_th2FileAtom = Atom(
    name: 'TH2FileEditCopyPasteControllerBase._th2File',
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
    name: 'TH2FileEditCopyPasteControllerBase._th2FileEditController',
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

  late final _$TH2FileEditCopyPasteControllerBaseActionController =
      ActionController(
        name: 'TH2FileEditCopyPasteControllerBase',
        context: context,
      );

  @override
  void copySelectedElements() {
    final _$actionInfo = _$TH2FileEditCopyPasteControllerBaseActionController
        .startAction(
          name: 'TH2FileEditCopyPasteControllerBase.copySelectedElements',
        );
    try {
      return super.copySelectedElements();
    } finally {
      _$TH2FileEditCopyPasteControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  List<int> pasteElements() {
    final _$actionInfo = _$TH2FileEditCopyPasteControllerBaseActionController
        .startAction(name: 'TH2FileEditCopyPasteControllerBase.pasteElements');
    try {
      return super.pasteElements();
    } finally {
      _$TH2FileEditCopyPasteControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  List<int> duplicateSelectedElements() {
    final _$actionInfo = _$TH2FileEditCopyPasteControllerBaseActionController
        .startAction(
          name: 'TH2FileEditCopyPasteControllerBase.duplicateSelectedElements',
        );
    try {
      return super.duplicateSelectedElements();
    } finally {
      _$TH2FileEditCopyPasteControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void cutSelectedElements() {
    final _$actionInfo = _$TH2FileEditCopyPasteControllerBaseActionController
        .startAction(
          name: 'TH2FileEditCopyPasteControllerBase.cutSelectedElements',
        );
    try {
      return super.cutSelectedElements();
    } finally {
      _$TH2FileEditCopyPasteControllerBaseActionController.endAction(
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
