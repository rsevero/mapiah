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

  late final _$_thFileMapiahIDAtom =
      Atom(name: 'THFileStoreBase._thFileMapiahID', context: context);

  int get thFileMapiahID {
    _$_thFileMapiahIDAtom.reportRead();
    return super._thFileMapiahID;
  }

  @override
  int get _thFileMapiahID => thFileMapiahID;

  bool __thFileMapiahIDIsInitialized = false;

  @override
  set _thFileMapiahID(int value) {
    _$_thFileMapiahIDAtom.reportWrite(
        value, __thFileMapiahIDIsInitialized ? super._thFileMapiahID : null,
        () {
      super._thFileMapiahID = value;
      __thFileMapiahIDIsInitialized = true;
    });
  }

  late final _$_elementRedrawTriggerAtom =
      Atom(name: 'THFileStoreBase._elementRedrawTrigger', context: context);

  Map<int, Observable<bool>> get elementRedrawTrigger {
    _$_elementRedrawTriggerAtom.reportRead();
    return super._elementRedrawTrigger;
  }

  @override
  Map<int, Observable<bool>> get _elementRedrawTrigger => elementRedrawTrigger;

  @override
  set _elementRedrawTrigger(Map<int, Observable<bool>> value) {
    _$_elementRedrawTriggerAtom.reportWrite(value, super._elementRedrawTrigger,
        () {
      super._elementRedrawTrigger = value;
    });
  }

  late final _$_childrenListLengthChangeTriggerAtom = Atom(
      name: 'THFileStoreBase._childrenListLengthChangeTrigger',
      context: context);

  Map<int, Observable<bool>> get childrenListLengthChangeTrigger {
    _$_childrenListLengthChangeTriggerAtom.reportRead();
    return super._childrenListLengthChangeTrigger;
  }

  @override
  Map<int, Observable<bool>> get _childrenListLengthChangeTrigger =>
      childrenListLengthChangeTrigger;

  @override
  set _childrenListLengthChangeTrigger(Map<int, Observable<bool>> value) {
    _$_childrenListLengthChangeTriggerAtom
        .reportWrite(value, super._childrenListLengthChangeTrigger, () {
      super._childrenListLengthChangeTrigger = value;
    });
  }

  late final _$THFileStoreBaseActionController =
      ActionController(name: 'THFileStoreBase', context: context);

  @override
  void triggerTHFileLengthChildrenList() {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.triggerTHFileLengthChildrenList');
    try {
      return super.triggerTHFileLengthChildrenList();
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _substituteStoreElement(int mapiahID) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase._substituteStoreElement');
    try {
      return super._substituteStoreElement(mapiahID);
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
