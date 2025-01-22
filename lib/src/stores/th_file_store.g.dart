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

  late final _$THFileStoreBaseActionController =
      ActionController(name: 'THFileStoreBase', context: context);

  @override
  void substituteElement(THElement newElement) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.substituteElement');
    try {
      return super.substituteElement(newElement);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void execute(Command command) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.execute');
    try {
      return super.execute(command);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void undo() {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.undo');
    try {
      return super.undo();
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void redo() {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.redo');
    try {
      return super.redo();
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updatePointPosition(
      {required THPoint originalPoint, required THPoint modifiedPoint}) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.updatePointPosition');
    try {
      return super.updatePointPosition(
          originalPoint: originalPoint, modifiedPoint: modifiedPoint);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateLinePosition(
      {required THLine originalLine,
      required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
      required THLine newLine,
      required LinkedHashMap<int, THLineSegment> newLineSegmentsMap}) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.updateLinePosition');
    try {
      return super.updateLinePosition(
          originalLine: originalLine,
          originalLineSegmentsMap: originalLineSegmentsMap,
          newLine: newLine,
          newLineSegmentsMap: newLineSegmentsMap);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateLinePositionPerOffset(
      {required THLine originalLine,
      required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
      required Offset deltaOnCanvas}) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.updateLinePositionPerOffset');
    try {
      return super.updateLinePositionPerOffset(
          originalLine: originalLine,
          originalLineSegmentsMap: originalLineSegmentsMap,
          deltaOnCanvas: deltaOnCanvas);
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
