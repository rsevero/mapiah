// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_file_display_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THFileDisplayStore on THFileDisplayStoreBase, Store {
  late final _$_screenSizeAtom =
      Atom(name: 'THFileDisplayStoreBase._screenSize', context: context);

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
      Atom(name: 'THFileDisplayStoreBase._canvasScale', context: context);

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
      Atom(name: 'THFileDisplayStoreBase._canvasTranslation', context: context);

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
      name: 'THFileDisplayStoreBase._canvasScaleTranslationUndefined',
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

  late final _$_th2fileEditModeAtom =
      Atom(name: 'THFileDisplayStoreBase._th2fileEditMode', context: context);

  TH2FileEditMode get th2fileEditMode {
    _$_th2fileEditModeAtom.reportRead();
    return super._th2fileEditMode;
  }

  @override
  TH2FileEditMode get _th2fileEditMode => th2fileEditMode;

  @override
  set _th2fileEditMode(TH2FileEditMode value) {
    _$_th2fileEditModeAtom.reportWrite(value, super._th2fileEditMode, () {
      super._th2fileEditMode = value;
    });
  }

  late final _$_triggerAtom =
      Atom(name: 'THFileDisplayStoreBase._trigger', context: context);

  bool get trigger {
    _$_triggerAtom.reportRead();
    return super._trigger;
  }

  @override
  bool get _trigger => trigger;

  @override
  set _trigger(bool value) {
    _$_triggerAtom.reportWrite(value, super._trigger, () {
      super._trigger = value;
    });
  }

  late final _$_shouldRepaintAtom =
      Atom(name: 'THFileDisplayStoreBase._shouldRepaint', context: context);

  bool get shouldRepaint {
    _$_shouldRepaintAtom.reportRead();
    return super._shouldRepaint;
  }

  @override
  bool get _shouldRepaint => shouldRepaint;

  @override
  set _shouldRepaint(bool value) {
    _$_shouldRepaintAtom.reportWrite(value, super._shouldRepaint, () {
      super._shouldRepaint = value;
    });
  }

  late final _$THFileDisplayStoreBaseActionController =
      ActionController(name: 'THFileDisplayStoreBase', context: context);

  @override
  void updateScreenSize(Size newSize) {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.updateScreenSize');
    try {
      return super.updateScreenSize(newSize);
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTH2FileEditMode(TH2FileEditMode newMode) {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.setTH2FileEditMode');
    try {
      return super.setTH2FileEditMode(newMode);
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.onPanUpdate');
    try {
      return super.onPanUpdate(details);
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setShouldRepaint(bool value) {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.setShouldRepaint');
    try {
      return super.setShouldRepaint(value);
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateCanvasScale(double newScale) {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.updateCanvasScale');
    try {
      return super.updateCanvasScale(newScale);
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateCanvasOffsetDrawing(Offset newOffset) {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.updateCanvasOffsetDrawing');
    try {
      return super.updateCanvasOffsetDrawing(newOffset);
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCanvasScaleTranslationUndefined(bool isUndefined) {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.setCanvasScaleTranslationUndefined');
    try {
      return super.setCanvasScaleTranslationUndefined(isUndefined);
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void zoomIn() {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.zoomIn');
    try {
      return super.zoomIn();
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void zoomOut() {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.zoomOut');
    try {
      return super.zoomOut();
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _calculateCanvasOffset() {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase._calculateCanvasOffset');
    try {
      return super._calculateCanvasOffset();
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDataWidth(double newWidth) {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.updateDataWidth');
    try {
      return super.updateDataWidth(newWidth);
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDataHeight(double newHeight) {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.updateDataHeight');
    try {
      return super.updateDataHeight(newHeight);
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDataBoundingBox(Rect newBoundingBox) {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.updateDataBoundingBox');
    try {
      return super.updateDataBoundingBox(newBoundingBox);
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void zoomShowAll() {
    final _$actionInfo = _$THFileDisplayStoreBaseActionController.startAction(
        name: 'THFileDisplayStoreBase.zoomShowAll');
    try {
      return super.zoomShowAll();
    } finally {
      _$THFileDisplayStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
