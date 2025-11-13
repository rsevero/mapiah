// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_element_edit_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditElementEditController
    on TH2FileEditElementEditControllerBase, Store {
  late final _$_thFileAtom = Atom(
    name: 'TH2FileEditElementEditControllerBase._thFile',
    context: context,
  );

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

  late final _$_lineStartScreenPositionAtom = Atom(
    name: 'TH2FileEditElementEditControllerBase._lineStartScreenPosition',
    context: context,
  );

  Offset? get lineStartScreenPosition {
    _$_lineStartScreenPositionAtom.reportRead();
    return super._lineStartScreenPosition;
  }

  @override
  Offset? get _lineStartScreenPosition => lineStartScreenPosition;

  @override
  set _lineStartScreenPosition(Offset? value) {
    _$_lineStartScreenPositionAtom.reportWrite(
      value,
      super._lineStartScreenPosition,
      () {
        super._lineStartScreenPosition = value;
      },
    );
  }

  late final _$_newLineAtom = Atom(
    name: 'TH2FileEditElementEditControllerBase._newLine',
    context: context,
  );

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
    name: 'TH2FileEditElementEditControllerBase._newArea',
    context: context,
  );

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

  late final _$_newScrapAtom = Atom(
    name: 'TH2FileEditElementEditControllerBase._newScrap',
    context: context,
  );

  THScrap? get newScrap {
    _$_newScrapAtom.reportRead();
    return super._newScrap;
  }

  @override
  THScrap? get _newScrap => newScrap;

  @override
  set _newScrap(THScrap? value) {
    _$_newScrapAtom.reportWrite(value, super._newScrap, () {
      super._newScrap = value;
    });
  }

  late final _$_lineSimplifyEpsilonOnCanvasAtom = Atom(
    name: 'TH2FileEditElementEditControllerBase._lineSimplifyEpsilonOnCanvas',
    context: context,
  );

  double get lineSimplifyEpsilonOnCanvas {
    _$_lineSimplifyEpsilonOnCanvasAtom.reportRead();
    return super._lineSimplifyEpsilonOnCanvas;
  }

  @override
  double get _lineSimplifyEpsilonOnCanvas => lineSimplifyEpsilonOnCanvas;

  @override
  set _lineSimplifyEpsilonOnCanvas(double value) {
    _$_lineSimplifyEpsilonOnCanvasAtom.reportWrite(
      value,
      super._lineSimplifyEpsilonOnCanvas,
      () {
        super._lineSimplifyEpsilonOnCanvas = value;
      },
    );
  }

  late final _$_lineSimplificationMethodAtom = Atom(
    name: 'TH2FileEditElementEditControllerBase._lineSimplificationMethod',
    context: context,
  );

  MPLineSimplificationMethod get lineSimplificationMethod {
    _$_lineSimplificationMethodAtom.reportRead();
    return super._lineSimplificationMethod;
  }

  @override
  MPLineSimplificationMethod get _lineSimplificationMethod =>
      lineSimplificationMethod;

  @override
  set _lineSimplificationMethod(MPLineSimplificationMethod value) {
    _$_lineSimplificationMethodAtom.reportWrite(
      value,
      super._lineSimplificationMethod,
      () {
        super._lineSimplificationMethod = value;
      },
    );
  }

  late final _$TH2FileEditElementEditControllerBaseActionController =
      ActionController(
        name: 'TH2FileEditElementEditControllerBase',
        context: context,
      );

  @override
  void applyReplaceLineLineSegments(
    int lineMPID,
    List<({THLineSegment lineSegment, int lineSegmentPosition})>
    newLineSegments,
  ) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditElementEditControllerBase.applyReplaceLineLineSegments',
        );
    try {
      return super.applyReplaceLineLineSegments(lineMPID, newLineSegments);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyAddLineSegment({
    required THLineSegment newLineSegment,
    required int lineSegmentPositionInParent,
  }) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.applyAddLineSegment',
        );
    try {
      return super.applyAddLineSegment(
        newLineSegment: newLineSegment,
        lineSegmentPositionInParent: lineSegmentPositionInParent,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void afterAddLineSegment(THLineSegment newLineSegment) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.afterAddLineSegment',
        );
    try {
      return super.afterAddLineSegment(newLineSegment);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyAddElement({
    required THElement newElement,
    THIsParentMixin? parent,
    int childPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.applyAddElement',
        );
    try {
      return super.applyAddElement(
        newElement: newElement,
        parent: parent,
        childPositionInParent: childPositionInParent,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void afterAddPoint(THPoint newPoint) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.afterAddPoint',
        );
    try {
      return super.afterAddPoint(newPoint);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void removeElement(THElement element, {bool setState = false}) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.removeElement',
        );
    try {
      return super.removeElement(element, setState: setState);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyRemoveElements(List<int> mpIDs) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.applyRemoveElements',
        );
    try {
      return super.applyRemoveElements(mpIDs);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void registerElementWithTHID(THElement element, String thID) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.registerElementWithTHID',
        );
    try {
      return super.registerElementWithTHID(element, thID);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  THLine getNewLine() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.getNewLine');
    try {
      return super.getNewLine();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  THArea getNewArea() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.getNewArea');
    try {
      return super.getNewArea();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void createScrap({
    required String thID,
    List<THElement>? scrapChildren,
    List<THCommandOption>? scrapOptions,
  }) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.createScrap');
    try {
      return super.createScrap(
        thID: thID,
        scrapChildren: scrapChildren,
        scrapOptions: scrapOptions,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void setNewLineStartScreenPosition(Offset lineStartScreenPosition) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditElementEditControllerBase.setNewLineStartScreenPosition',
        );
    try {
      return super.setNewLineStartScreenPosition(lineStartScreenPosition);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void clearNewLine() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.clearNewLine');
    try {
      return super.clearNewLine();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void clearNewArea() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.clearNewArea');
    try {
      return super.clearNewArea();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void setNewLine(THLine newLine) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.setNewLine');
    try {
      return super.setNewLine(newLine);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void updateBezierLineSegment(
    Offset quadraticControlPointPositionScreenCoordinates,
  ) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.updateBezierLineSegment',
        );
    try {
      return super.updateBezierLineSegment(
        quadraticControlPointPositionScreenCoordinates,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void addNewLineLineSegment(Offset endPointScreenCoordinates) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.addNewLineLineSegment',
        );
    try {
      return super.addNewLineLineSegment(endPointScreenCoordinates);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyAddScrap({
    required THScrap newScrap,
    required List<Object> scrapChildren,
    int scrapPositionAtParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.applyAddScrap',
        );
    try {
      return super.applyAddScrap(
        newScrap: newScrap,
        scrapChildren: scrapChildren,
        scrapPositionAtParent: scrapPositionAtParent,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyAddLine({
    required THLine newLine,
    required List<THElement> lineChildren,
    int linePositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    Offset? lineStartScreenPosition,
  }) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.applyAddLine');
    try {
      return super.applyAddLine(
        newLine: newLine,
        lineChildren: lineChildren,
        linePositionInParent: linePositionInParent,
        lineStartScreenPosition: lineStartScreenPosition,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyAddArea({
    required THArea newArea,
    required List<THElement> areaChildren,
    int areaPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.applyAddArea');
    try {
      return super.applyAddArea(
        newArea: newArea,
        areaChildren: areaChildren,
        areaPositionInParent: areaPositionInParent,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void afterAddArea(THArea newArea) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.afterAddArea');
    try {
      return super.afterAddArea(newArea);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyRemoveArea(int areaMPID) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.applyRemoveArea',
        );
    try {
      return super.applyRemoveArea(areaMPID);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyRemoveLine(int lineMPID) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.applyRemoveLine',
        );
    try {
      return super.applyRemoveLine(lineMPID);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void finalizeNewLineCreation() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.finalizeNewLineCreation',
        );
    try {
      return super.finalizeNewLineCreation();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void finalizeNewAreaCreation() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.finalizeNewAreaCreation',
        );
    try {
      return super.finalizeNewAreaCreation();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applySetOptionToElement({
    required THCommandOption option,
    String plaOriginalLineInTH2File = '',
  }) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.applySetOptionToElement',
        );
    try {
      return super.applySetOptionToElement(
        option: option,
        plaOriginalLineInTH2File: plaOriginalLineInTH2File,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyRemoveOptionFromElement({
    required THCommandOptionType optionType,
    required int parentMPID,
    required String newOriginalLineInTH2File,
  }) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditElementEditControllerBase.applyRemoveOptionFromElement',
        );
    try {
      return super.applyRemoveOptionFromElement(
        optionType: optionType,
        parentMPID: parentMPID,
        newOriginalLineInTH2File: newOriginalLineInTH2File,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applySetAttrOptionToElement({
    required THAttrCommandOption attrOption,
    required String plaOriginalLineInTH2File,
  }) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditElementEditControllerBase.applySetAttrOptionToElement',
        );
    try {
      return super.applySetAttrOptionToElement(
        attrOption: attrOption,
        plaOriginalLineInTH2File: plaOriginalLineInTH2File,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyRemoveAttrOptionFromElement({
    required String attrName,
    required int parentMPID,
    required String plaOriginalLineInTH2File,
  }) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditElementEditControllerBase.applyRemoveAttrOptionFromElement',
        );
    try {
      return super.applyRemoveAttrOptionFromElement(
        attrName: attrName,
        parentMPID: parentMPID,
        plaOriginalLineInTH2File: plaOriginalLineInTH2File,
      );
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyRemoveSelectedLineSegments() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditElementEditControllerBase.applyRemoveSelectedLineSegments',
        );
    try {
      return super.applyRemoveSelectedLineSegments();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void applyAddLineSegmentsBetweenSelectedLineSegments() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditElementEditControllerBase.applyAddLineSegmentsBetweenSelectedLineSegments',
        );
    try {
      return super.applyAddLineSegmentsBetweenSelectedLineSegments();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void removeScrap(int scrapMPID) {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(name: 'TH2FileEditElementEditControllerBase.removeScrap');
    try {
      return super.removeScrap(scrapMPID);
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void toggleSelectedLinesReverseOption() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditElementEditControllerBase.toggleSelectedLinesReverseOption',
        );
    try {
      return super.toggleSelectedLinesReverseOption();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void simplifySelectedLines() {
    final _$actionInfo = _$TH2FileEditElementEditControllerBaseActionController
        .startAction(
          name: 'TH2FileEditElementEditControllerBase.simplifySelectedLines',
        );
    try {
      return super.simplifySelectedLines();
    } finally {
      _$TH2FileEditElementEditControllerBaseActionController.endAction(
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
