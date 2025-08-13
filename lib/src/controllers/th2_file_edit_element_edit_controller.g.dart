// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_element_edit_controller.dart';

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

  late final _$_newAreaAtom = Atom(
      name: 'TH2FileEditElementEditControllerBase._newArea', context: context);

  THArea? get newArea {
    _$_newAreaAtom.reportRead();
    return super._newArea;
  }

  @override
  THArea? get _newArea => newArea;

  @override
  set _newArea(THArea? value) {
    _$_newAreaAtom.reportWrite(value, super._newArea, () {
      super._newArea = value;
    });
  }

  late final _$TH2FileEditElementEditControllerBaseActionController =
      ActionController(
          name: 'TH2FileEditElementEditControllerBase', context: context);

  @override
  void applyInsertLineSegment(
      {required THLineSegment newLineSegment,
      required int beforeLineSegmentMPID}) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.applyInsertLineSegment');
    try {
      return super.applyInsertLineSegment(
          newLineSegment: newLineSegment,
          beforeLineSegmentMPID: beforeLineSegmentMPID);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void applyAddElement({required THElement newElement}) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.applyAddElement');
    try {
      return super.applyAddElement(newElement: newElement);
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
  void removeElement(THElement element, {bool setState = false}) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.removeElement');
    try {
      return super.removeElement(element, setState: setState);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void removeElementByTHID(String thID) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.removeElementByTHID');
    try {
      return super.removeElementByTHID(thID);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void applyRemoveElements(List<int> mpIDs) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.applyRemoveElements');
    try {
      return super.applyRemoveElements(mpIDs);
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
  THArea getNewArea() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.getNewArea');
    try {
      return super.getNewArea();
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
  void clearNewArea() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.clearNewArea');
    try {
      return super.clearNewArea();
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
  void applyAddLine(
      {required THLine newLine,
      required List<THElement> lineChildren,
      Offset? lineStartScreenPosition}) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.applyAddLine');
    try {
      return super.applyAddLine(
          newLine: newLine,
          lineChildren: lineChildren,
          lineStartScreenPosition: lineStartScreenPosition);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void applyRemoveArea(int areaMPID) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.applyRemoveArea');
    try {
      return super.applyRemoveArea(areaMPID);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void applyRemoveLine(int lineMPID) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name: 'TH2FileEditElementEditControllerBase.applyRemoveLine');
    try {
      return super.applyRemoveLine(lineMPID);
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
  void finalizeNewAreaCreation() {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.finalizeNewAreaCreation');
    try {
      return super.finalizeNewAreaCreation();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void applySetOptionToElement(THCommandOption option) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.applySetOptionToElement');
    try {
      return super.applySetOptionToElement(option);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void applyRemoveAttrOptionFromElement(
      {required String attrName,
      required int parentMPID,
      required String newOriginalLineInTH2File}) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.applyRemoveAttrOptionFromElement');
    try {
      return super.applyRemoveAttrOptionFromElement(
          attrName: attrName,
          parentMPID: parentMPID,
          newOriginalLineInTH2File: newOriginalLineInTH2File);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void applyRemoveOptionFromElement(
      {required THCommandOptionType optionType,
      required int parentMPID,
      required String newOriginalLineInTH2File}) {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.applyRemoveOptionFromElement');
    try {
      return super.applyRemoveOptionFromElement(
          optionType: optionType,
          parentMPID: parentMPID,
          newOriginalLineInTH2File: newOriginalLineInTH2File);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void applyRemoveSelectedLineSegments() {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.applyRemoveSelectedLineSegments');
    try {
      return super.applyRemoveSelectedLineSegments();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void applyAddLineSegmentsBetweenSelectedLineSegments() {
    final _$actionInfo =
        _$TH2FileEditElementEditControllerBaseActionController.startAction(
            name:
                'TH2FileEditElementEditControllerBase.applyAddLineSegmentsBetweenSelectedLineSegments');
    try {
      return super.applyAddLineSegmentsBetweenSelectedLineSegments();
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
