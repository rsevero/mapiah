// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_file_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THFileStore on THFileStoreBase, Store {
  late final _$_screenSizeAtom =
      Atom(name: 'THFileStoreBase._screenSize', context: context);

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
      Atom(name: 'THFileStoreBase._canvasScale', context: context);

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
      Atom(name: 'THFileStoreBase._canvasTranslation', context: context);

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
      name: 'THFileStoreBase._canvasScaleTranslationUndefined',
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

  late final _$_triggerAtom =
      Atom(name: 'THFileStoreBase._trigger', context: context);

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
      Atom(name: 'THFileStoreBase._shouldRepaint', context: context);

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

  late final _$THFileStoreBaseActionController =
      ActionController(name: 'THFileStoreBase', context: context);

  @override
  void updateScreenSize(Size newSize) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.updateScreenSize');
    try {
      return super.updateScreenSize(newSize);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.onPanUpdate');
    try {
      return super.onPanUpdate(details);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setShouldRepaint(bool value) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.setShouldRepaint');
    try {
      return super.setShouldRepaint(value);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateCanvasScale(double newScale) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.updateCanvasScale');
    try {
      return super.updateCanvasScale(newScale);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateCanvasOffsetDrawing(Offset newOffset) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.updateCanvasOffsetDrawing');
    try {
      return super.updateCanvasOffsetDrawing(newOffset);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCanvasScaleTranslationUndefined(bool isUndefined) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.setCanvasScaleTranslationUndefined');
    try {
      return super.setCanvasScaleTranslationUndefined(isUndefined);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void zoomIn() {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.zoomIn');
    try {
      return super.zoomIn();
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void zoomOut() {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.zoomOut');
    try {
      return super.zoomOut();
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _calculateCanvasOffset() {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase._calculateCanvasOffset');
    try {
      return super._calculateCanvasOffset();
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDataWidth(double newWidth) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.updateDataWidth');
    try {
      return super.updateDataWidth(newWidth);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDataHeight(double newHeight) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.updateDataHeight');
    try {
      return super.updateDataHeight(newHeight);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDataBoundingBox(Rect newBoundingBox) {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.updateDataBoundingBox');
    try {
      return super.updateDataBoundingBox(newBoundingBox);
    } finally {
      _$THFileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void zoomShowAll() {
    final _$actionInfo = _$THFileStoreBaseActionController.startAction(
        name: 'THFileStoreBase.zoomShowAll');
    try {
      return super.zoomShowAll();
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
