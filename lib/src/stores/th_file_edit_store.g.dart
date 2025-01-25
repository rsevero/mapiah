// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_file_edit_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THFileEditStore on THFileEditStoreBase, Store {
  Computed<bool>? _$isSelectModeComputed;

  @override
  bool get isSelectMode =>
      (_$isSelectModeComputed ??= Computed<bool>(() => super.isSelectMode,
              name: 'THFileEditStoreBase.isSelectMode'))
          .value;
  Computed<bool>? _$isPanModeComputed;

  @override
  bool get isPanMode =>
      (_$isPanModeComputed ??= Computed<bool>(() => super.isPanMode,
              name: 'THFileEditStoreBase.isPanMode'))
          .value;

  late final _$_screenSizeAtom =
      Atom(name: 'THFileEditStoreBase._screenSize', context: context);

  Size get screenSize {
    _$_screenSizeAtom.reportRead();
    return super._screenSize;
  }

  @override
  Size get _screenSize => screenSize;

  @override
  set _screenSize(Size value) {
    _$_screenSizeAtom.reportWrite(value, super._screenSize, () {
      super._screenSize = value;
    });
  }

  late final _$_canvasScaleAtom =
      Atom(name: 'THFileEditStoreBase._canvasScale', context: context);

  double get canvasScale {
    _$_canvasScaleAtom.reportRead();
    return super._canvasScale;
  }

  @override
  double get _canvasScale => canvasScale;

  @override
  set _canvasScale(double value) {
    _$_canvasScaleAtom.reportWrite(value, super._canvasScale, () {
      super._canvasScale = value;
    });
  }

  late final _$_canvasTranslationAtom =
      Atom(name: 'THFileEditStoreBase._canvasTranslation', context: context);

  Offset get canvasTranslation {
    _$_canvasTranslationAtom.reportRead();
    return super._canvasTranslation;
  }

  @override
  Offset get _canvasTranslation => canvasTranslation;

  @override
  set _canvasTranslation(Offset value) {
    _$_canvasTranslationAtom.reportWrite(value, super._canvasTranslation, () {
      super._canvasTranslation = value;
    });
  }

  late final _$_canvasScaleTranslationUndefinedAtom = Atom(
      name: 'THFileEditStoreBase._canvasScaleTranslationUndefined',
      context: context);

  bool get canvasScaleTranslationUndefined {
    _$_canvasScaleTranslationUndefinedAtom.reportRead();
    return super._canvasScaleTranslationUndefined;
  }

  @override
  bool get _canvasScaleTranslationUndefined => canvasScaleTranslationUndefined;

  @override
  set _canvasScaleTranslationUndefined(bool value) {
    _$_canvasScaleTranslationUndefinedAtom
        .reportWrite(value, super._canvasScaleTranslationUndefined, () {
      super._canvasScaleTranslationUndefined = value;
    });
  }

  late final _$_modeAtom =
      Atom(name: 'THFileEditStoreBase._mode', context: context);

  TH2FileEditMode get mode {
    _$_modeAtom.reportRead();
    return super._mode;
  }

  @override
  TH2FileEditMode get _mode => mode;

  @override
  set _mode(TH2FileEditMode value) {
    _$_modeAtom.reportWrite(value, super._mode, () {
      super._mode = value;
    });
  }

  late final _$_isLoadingAtom =
      Atom(name: 'THFileEditStoreBase._isLoading', context: context);

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
      Atom(name: 'THFileEditStoreBase._thFile', context: context);

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
      Atom(name: 'THFileEditStoreBase._thFileMapiahID', context: context);

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
      Atom(name: 'THFileEditStoreBase._elementRedrawTrigger', context: context);

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
      name: 'THFileEditStoreBase._childrenListLengthChangeTrigger',
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

  late final _$_selectedElementAtom =
      Atom(name: 'THFileEditStoreBase._selectedElement', context: context);

  MPSelectedElement? get selectedElement {
    _$_selectedElementAtom.reportRead();
    return super._selectedElement;
  }

  @override
  MPSelectedElement? get _selectedElement => selectedElement;

  @override
  set _selectedElement(MPSelectedElement? value) {
    _$_selectedElementAtom.reportWrite(value, super._selectedElement, () {
      super._selectedElement = value;
    });
  }

  late final _$_hasUndoAtom =
      Atom(name: 'THFileEditStoreBase._hasUndo', context: context);

  bool get hasUndo {
    _$_hasUndoAtom.reportRead();
    return super._hasUndo;
  }

  @override
  bool get _hasUndo => hasUndo;

  @override
  set _hasUndo(bool value) {
    _$_hasUndoAtom.reportWrite(value, super._hasUndo, () {
      super._hasUndo = value;
    });
  }

  late final _$_hasRedoAtom =
      Atom(name: 'THFileEditStoreBase._hasRedo', context: context);

  bool get hasRedo {
    _$_hasRedoAtom.reportRead();
    return super._hasRedo;
  }

  @override
  bool get _hasRedo => hasRedo;

  @override
  set _hasRedo(bool value) {
    _$_hasRedoAtom.reportWrite(value, super._hasRedo, () {
      super._hasRedo = value;
    });
  }

  late final _$_undoDescriptionAtom =
      Atom(name: 'THFileEditStoreBase._undoDescription', context: context);

  String get undoDescription {
    _$_undoDescriptionAtom.reportRead();
    return super._undoDescription;
  }

  @override
  String get _undoDescription => undoDescription;

  @override
  set _undoDescription(String value) {
    _$_undoDescriptionAtom.reportWrite(value, super._undoDescription, () {
      super._undoDescription = value;
    });
  }

  late final _$_redoDescriptionAtom =
      Atom(name: 'THFileEditStoreBase._redoDescription', context: context);

  String get redoDescription {
    _$_redoDescriptionAtom.reportRead();
    return super._redoDescription;
  }

  @override
  String get _redoDescription => redoDescription;

  @override
  set _redoDescription(String value) {
    _$_redoDescriptionAtom.reportWrite(value, super._redoDescription, () {
      super._redoDescription = value;
    });
  }

  late final _$THFileEditStoreBaseActionController =
      ActionController(name: 'THFileEditStoreBase', context: context);

  @override
  void _setSelectedElement(MPSelectedElement selectedElement) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase._setSelectedElement');
    try {
      return super._setSelectedElement(selectedElement);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedElement() {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.clearSelectedElement');
    try {
      return super.clearSelectedElement();
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateScreenSize(Size newSize) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase._updateScreenSize');
    try {
      return super._updateScreenSize(newSize);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTH2FileEditMode(TH2FileEditMode newMode) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.setTH2FileEditMode');
    try {
      return super.setTH2FileEditMode(newMode);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onPanUpdatePanMode(DragUpdateDetails details) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase._onPanUpdatePanMode');
    try {
      return super._onPanUpdatePanMode(details);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateCanvasScale(double newScale) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase._updateCanvasScale');
    try {
      return super._updateCanvasScale(newScale);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateCanvasOffsetDrawing(Offset newOffset) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.updateCanvasOffsetDrawing');
    try {
      return super.updateCanvasOffsetDrawing(newOffset);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCanvasScaleTranslationUndefined(bool isUndefined) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.setCanvasScaleTranslationUndefined');
    try {
      return super.setCanvasScaleTranslationUndefined(isUndefined);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDataBoundingBox(Rect newBoundingBox) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.updateDataBoundingBox');
    try {
      return super.updateDataBoundingBox(newBoundingBox);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void triggerTHFileLengthChildrenList() {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.triggerTHFileLengthChildrenList');
    try {
      return super.triggerTHFileLengthChildrenList();
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void triggerElementWithChildrenRedraw(int mapiahID) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.triggerElementWithChildrenRedraw');
    try {
      return super.triggerElementWithChildrenRedraw(mapiahID);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void triggerElementActuallyDrawableRedraw(int mapiahID) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.triggerElementActuallyDrawableRedraw');
    try {
      return super.triggerElementActuallyDrawableRedraw(mapiahID);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateUndoRedoStatus() {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase._updateUndoRedoStatus');
    try {
      return super._updateUndoRedoStatus();
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addElement(THElement element) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.addElement');
    try {
      return super.addElement(element);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addElementWithParent(THElement element, THParent parent) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.addElementWithParent');
    try {
      return super.addElementWithParent(element, parent);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteElement(THElement element) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.deleteElement');
    try {
      return super.deleteElement(element);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteElementByMapiahID(int mapiahID) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.deleteElementByMapiahID');
    try {
      return super.deleteElementByMapiahID(mapiahID);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteElementByTHID(String thID) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.deleteElementByTHID');
    try {
      return super.deleteElementByTHID(thID);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void registerElementWithTHID(THElement element, String thID) {
    final _$actionInfo = _$THFileEditStoreBaseActionController.startAction(
        name: 'THFileEditStoreBase.registerElementWithTHID');
    try {
      return super.registerElementWithTHID(element, thID);
    } finally {
      _$THFileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isSelectMode: ${isSelectMode},
isPanMode: ${isPanMode}
    ''';
  }
}
