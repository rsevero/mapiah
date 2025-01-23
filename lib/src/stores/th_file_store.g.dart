// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_file_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THFileStore on THFileStoreBase, Store {
  late final _$_isLoadingAtom =
      Atom(name: 'THFileStoreBase._isLoading', context: context);

  bool get isLoading {
    _$_isLoadingAtom.reportRead();
    return super._isLoading;
  }

  @override
  bool get _isLoading => isLoading;

  @override
  set _isLoading(bool value) {
    _$_isLoadingAtom.reportWrite(value, super._isLoading, () {
      super._isLoading = value;
    });
  }

  late final _$_thFileAtom =
      Atom(name: 'THFileStoreBase._thFile', context: context);

  THFile get thFile {
    _$_thFileAtom.reportRead();
    return super._thFile;
  }

  @override
  THFile get _thFile => thFile;

  bool __thFileIsInitialized = false;

  @override
  set _thFile(THFile value) {
    _$_thFileAtom
        .reportWrite(value, __thFileIsInitialized ? super._thFile : null, () {
      super._thFile = value;
      __thFileIsInitialized = true;
    });
  }

  late final _$_elementsAtom =
      Atom(name: 'THFileStoreBase._elements', context: context);

  ObservableMap<int, THElement> get elements {
    _$_elementsAtom.reportRead();
    return super._elements;
  }

  @override
  ObservableMap<int, THElement> get _elements => elements;

  @override
  set _elements(ObservableMap<int, THElement> value) {
    _$_elementsAtom.reportWrite(value, super._elements, () {
      super._elements = value;
    });
  }

  late final _$_redrawTriggerAtom =
      Atom(name: 'THFileStoreBase._redrawTrigger', context: context);

  ObservableMap<int, MPRedrawTrigger> get redrawTrigger {
    _$_redrawTriggerAtom.reportRead();
    return super._redrawTrigger;
  }

  @override
  ObservableMap<int, MPRedrawTrigger> get _redrawTrigger => redrawTrigger;

  @override
  set _redrawTrigger(ObservableMap<int, MPRedrawTrigger> value) {
    _$_redrawTriggerAtom.reportWrite(value, super._redrawTrigger, () {
      super._redrawTrigger = value;
    });
  }

  late final _$THFileStoreBaseActionController =
      ActionController(name: 'THFileStoreBase', context: context);

  @override
  void triggerFileRedraw() {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.triggerFileRedraw');
    try {
      return super.triggerFileRedraw();
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void triggerScrapRedraw(int mapiahID) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.triggerScrapRedraw');
    try {
      return super.triggerScrapRedraw(mapiahID);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _substituteStoreElement(THElement newElement) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase._substituteStoreElement');
    try {
      return super._substituteStoreElement(newElement);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addElement(THElement element) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.addElement');
    try {
      return super.addElement(element);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addElementWithParent(THElement element, THParent parent) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.addElementWithParent');
    try {
      return super.addElementWithParent(element, parent);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteElement(THElement element) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.deleteElement');
    try {
      return super.deleteElement(element);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteElementByMapiahID(int mapiahID) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.deleteElementByMapiahID');
    try {
      return super.deleteElementByMapiahID(mapiahID);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteElementByTHID(String thID) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.deleteElementByTHID');
    try {
      return super.deleteElementByTHID(thID);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void registerElementWithTHID(THElement element, String thID) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.registerElementWithTHID');
    try {
      return super.registerElementWithTHID(element, thID);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
