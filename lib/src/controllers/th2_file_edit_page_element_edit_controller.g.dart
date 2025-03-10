// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_page_element_edit_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditElementEditController
    on TH2FileEditElementEditControllerBase, Store {
  late final _$_thFileAtom = Atom(
      name: 'TH2FileEditElementEditControllerBase._thFile', context: context);

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
      name: 'TH2FileEditElementEditControllerBase._th2FileEditController',
      context: context);

  TH2FileEditController get th2FileEditController {
    _$_th2FileEditControllerAtom.reportRead();
    return super._th2FileEditController;
  }

  @override
  TH2FileEditController get _th2FileEditController => th2FileEditController;

  @override
  set _th2FileEditController(TH2FileEditController value) {
    _$_th2FileEditControllerAtom
        .reportWrite(value, super._th2FileEditController, () {
      super._th2FileEditController = value;
    });
  }

  late final _$TH2FileEditElementEditControllerBaseActionController =
      ActionController(
          name: 'TH2FileEditElementEditControllerBase', context: context);

  @override
  void addElement({required THElement newElement}) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.addElement');
    try {
      return super.addElement(newElement: newElement);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void addElementWithParentWithoutSelectableElement(
      {required THElement newElement, required THIsParentMixin parent}) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.addElementWithParentWithoutSelectableElement');
    try {
      return super.addElementWithParentWithoutSelectableElement(
          newElement: newElement, parent: parent);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void deleteElement(THElement element) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.deleteElement');
    try {
      return super.deleteElement(element);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void deleteElementByTHID(String thID) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.deleteElementByTHID');
    try {
      return super.deleteElementByTHID(thID);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void deleteElements(List<int> mapiahIDs) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.deleteElements');
    try {
      return super.deleteElements(mapiahIDs);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void registerElementWithTHID(THElement element, String thID) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.registerElementWithTHID');
    try {
      return super.registerElementWithTHID(element, thID);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
