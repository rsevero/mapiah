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

  late final _$_lastAddedPointTypeAtom = Atom(
      name: 'TH2FileEditElementEditControllerBase._lastAddedPointType',
      context: context);

  THPointType get lastAddedPointType {
    _$_lastAddedPointTypeAtom.reportRead();
    return super._lastAddedPointType;
  }

  @override
  THPointType get _lastAddedPointType => lastAddedPointType;

  @override
  set _lastAddedPointType(THPointType value) {
    _$_lastAddedPointTypeAtom.reportWrite(value, super._lastAddedPointType, () {
      super._lastAddedPointType = value;
    });
  }

  late final _$_lastAddedLineTypeAtom = Atom(
      name: 'TH2FileEditElementEditControllerBase._lastAddedLineType',
      context: context);

  THLineType get lastAddedLineType {
    _$_lastAddedLineTypeAtom.reportRead();
    return super._lastAddedLineType;
  }

  @override
  THLineType get _lastAddedLineType => lastAddedLineType;

  @override
  set _lastAddedLineType(THLineType value) {
    _$_lastAddedLineTypeAtom.reportWrite(value, super._lastAddedLineType, () {
      super._lastAddedLineType = value;
    });
  }

  late final _$_lastAddedAreaTypeAtom = Atom(
      name: 'TH2FileEditElementEditControllerBase._lastAddedAreaType',
      context: context);

  THAreaType get lastAddedAreaType {
    _$_lastAddedAreaTypeAtom.reportRead();
    return super._lastAddedAreaType;
  }

  @override
  THAreaType get _lastAddedAreaType => lastAddedAreaType;

  @override
  set _lastAddedAreaType(THAreaType value) {
    _$_lastAddedAreaTypeAtom.reportWrite(value, super._lastAddedAreaType, () {
      super._lastAddedAreaType = value;
    });
  }

  late final _$_lineStartScreenPositionAtom = Atom(
      name: 'TH2FileEditElementEditControllerBase._lineStartScreenPosition',
      context: context);

  Offset? get lineStartScreenPosition {
    _$_lineStartScreenPositionAtom.reportRead();
    return super._lineStartScreenPosition;
  }

  @override
  Offset? get _lineStartScreenPosition => lineStartScreenPosition;

  @override
  set _lineStartScreenPosition(Offset? value) {
    _$_lineStartScreenPositionAtom
        .reportWrite(value, super._lineStartScreenPosition, () {
      super._lineStartScreenPosition = value;
    });
  }

  late final _$_newLineAtom = Atom(
      name: 'TH2FileEditElementEditControllerBase._newLine', context: context);

  THLine? get newLine {
    _$_newLineAtom.reportRead();
    return super._newLine;
  }

  @override
  THLine? get _newLine => newLine;

  @override
  set _newLine(THLine? value) {
    _$_newLineAtom.reportWrite(value, super._newLine, () {
      super._newLine = value;
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
  THLine getNewLine() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.getNewLine');
    try {
      return super.getNewLine();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setNewLineStartScreenPosition(Offset lineStartScreenPosition) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.setNewLineStartScreenPosition');
    try {
      return super.setNewLineStartScreenPosition(lineStartScreenPosition);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void clearNewLine() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.clearNewLine');
    try {
      return super.clearNewLine();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setNewLine(THLine newLine) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.setNewLine');
    try {
      return super.setNewLine(newLine);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setLastAddedPointType(THPointType pointType) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.setLastAddedPointType');
    try {
      return super.setLastAddedPointType(pointType);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setLastAddedLineType(THLineType lineType) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.setLastAddedLineType');
    try {
      return super.setLastAddedLineType(lineType);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setLastAddedAreaType(THAreaType areaType) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.setLastAddedAreaType');
    try {
      return super.setLastAddedAreaType(areaType);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void updateBezierLineSegment(
      Offset quadraticControlPointPositionScreenCoordinates) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.updateBezierLineSegment');
    try {
      return super.updateBezierLineSegment(
          quadraticControlPointPositionScreenCoordinates);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void addNewLineLineSegment(Offset enPointScreenCoordinates) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.addNewLineLineSegment');
    try {
      return super.addNewLineLineSegment(enPointScreenCoordinates);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void addLine(
      {required THLine newLine,
      required List<THElement> lineChildren,
      Offset? lineStartScreenPosition}) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.addLine');
    try {
      return super.addLine(
          newLine: newLine,
          lineChildren: lineChildren,
          lineStartScreenPosition: lineStartScreenPosition);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void deleteLine(int lineMapiahID) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.deleteLine');
    try {
      return super.deleteLine(lineMapiahID);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void finalizeNewLineCreation() {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.finalizeNewLineCreation');
    try {
      return super.finalizeNewLineCreation();
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
