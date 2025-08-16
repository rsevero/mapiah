part of 'mp_command.dart';

class MPMultipleElementsCommand extends MPCommand {
  late final List<MPCommand> commandsList;
  final MPMultipleElementsCommandCompletionType completionType;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.multipleElements;

  MPMultipleElementsCommand.forCWJM({
    required this.commandsList,
    required this.completionType,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMultipleElementsCommand.removeOption({
    required THCommandOptionType optionType,
    required List<int> parentMPIDs,
    required THFile thFile,
    super.descriptionType = MPCommandDescriptionType.removeOptionFromElements,
  }) : completionType = MPMultipleElementsCommandCompletionType.optionsEdited,
       super() {
    commandsList = [];

    for (final int parentMPID in parentMPIDs) {
      final MPRemoveOptionFromElementCommand removeOptionFromElementCommand =
          MPRemoveOptionFromElementCommand(
            optionType: optionType,
            parentMPID: parentMPID,
            currentOriginalLineInTH2File: thFile
                .elementByMPID(parentMPID)
                .originalLineInTH2File,
            descriptionType: descriptionType,
          );

      commandsList.add(removeOptionFromElementCommand);
    }
  }

  MPMultipleElementsCommand.setAttrOption({
    required THAttrCommandOption option,
    required List<THElement> elements,
    required THFile thFile,
    super.descriptionType = MPCommandDescriptionType.setOptionToElements,
  }) : completionType = MPMultipleElementsCommandCompletionType.optionsEdited,
       super() {
    commandsList = [];

    for (final THElement element in elements) {
      if (element is! THHasOptionsMixin) {
        throw ArgumentError(
          'Element with MPID ${element.parentMPID} does not support options',
        );
      }

      final MPSetAttrOptionToElementCommand setOptionToElementCommand =
          MPSetAttrOptionToElementCommand(
            option: option.copyWith(parentMPID: element.mpID),
            descriptionType: descriptionType,
            currentOriginalLineInTH2File: thFile
                .elementByMPID(element.mpID)
                .originalLineInTH2File,
          );

      commandsList.add(setOptionToElementCommand);
    }
  }

  MPMultipleElementsCommand.removeAttrOption({
    required String attrName,
    required List<int> parentMPIDs,
    required THFile thFile,
    super.descriptionType = MPCommandDescriptionType.removeOptionFromElements,
  }) : completionType = MPMultipleElementsCommandCompletionType.optionsEdited,
       super() {
    commandsList = [];

    for (final int parentMPID in parentMPIDs) {
      final MPRemoveAttrOptionFromElementCommand
      removeAttrOptionFromElementCommand = MPRemoveAttrOptionFromElementCommand(
        attrName: attrName,
        parentMPID: parentMPID,
        currentOriginalLineInTH2File: thFile
            .elementByMPID(parentMPID)
            .originalLineInTH2File,
        descriptionType: descriptionType,
      );

      commandsList.add(removeAttrOptionFromElementCommand);
    }
  }

  MPMultipleElementsCommand.removeElements({
    required List<int> mpIDs,
    required THFile thFile,
    super.descriptionType = MPCommandDescriptionType.removeElements,
  }) : completionType =
           MPMultipleElementsCommandCompletionType.elementsListChanged,
       super() {
    commandsList = [];

    for (final int mpID in mpIDs) {
      final MPCommand removeCommand;

      switch (thFile.getElementTypeByMPID(mpID)) {
        case THElementType.point:
          removeCommand = MPRemovePointCommand(pointMPID: mpID);
        case THElementType.line:
          removeCommand = MPRemoveLineCommand(
            lineMPID: mpID,
            isInteractiveLineCreation: false,
          );
        default:
          throw ArgumentError(
            'Unsupported element type in MPMultipleElementsCommand.removeElements',
          );
      }

      commandsList.add(removeCommand);
    }
  }

  MPMultipleElementsCommand.removeLineSegmentWithSubstitution({
    required int lineSegmentMPID,
    required THLineSegment lineSegmentSubstitution,
    required THFile thFile,
    super.descriptionType = MPCommandDescriptionType.removeLineSegment,
  }) : completionType =
           MPMultipleElementsCommandCompletionType.lineSegmentsRemoved,
       super() {
    commandsList = [];

    final MPCommand removeLineSegmentCommand = MPRemoveLineSegmentCommand(
      lineSegment: thFile.lineSegmentByMPID(lineSegmentMPID),
    );
    final MPCommand editLineSegmentCommand = MPEditLineSegmentCommand(
      originalLineSegment: thFile.lineSegmentByMPID(
        lineSegmentSubstitution.mpID,
      ),
      newLineSegment: lineSegmentSubstitution,
    );

    commandsList.add(removeLineSegmentCommand);
    commandsList.add(editLineSegmentCommand);
  }

  MPMultipleElementsCommand.removeLineSegments({
    required Iterable<int> lineSegmentMPIDs,
    required TH2FileEditController th2FileEditController,
    super.descriptionType = MPCommandDescriptionType.removeLineSegments,
  }) : completionType =
           MPMultipleElementsCommandCompletionType.lineSegmentsRemoved,
       super() {
    commandsList = [];
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final MPCommand removeLineSegmentCommand = elementEditController
          .getRemoveLineSegmentCommand(lineSegmentMPID);

      commandsList.add(removeLineSegmentCommand);
    }
  }

  MPMultipleElementsCommand.moveElementsFromDeltaOnCanvas({
    required Offset deltaOnCanvas,
    required int decimalPositions,
    required Iterable<MPSelectedElement> mpSelectedElements,
    super.descriptionType = MPCommandDescriptionType.moveElements,
  }) : completionType = MPMultipleElementsCommandCompletionType.elementsEdited,
       super() {
    commandsList = [];

    for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
      final THElement element = mpSelectedElement.originalElementClone;
      final MPCommand moveCommand;

      switch (element) {
        case THPoint _:
          moveCommand = MPMovePointCommand.fromDeltaOnCanvas(
            pointMPID: element.mpID,
            originalPosition: element.position,
            deltaOnCanvas: deltaOnCanvas,
            decimalPositions: decimalPositions,
          );
        case THLine _:
          moveCommand = MPMoveLineCommand.fromDeltaOnCanvas(
            lineMPID: element.mpID,
            originalLineSegmentsMap: (mpSelectedElement as MPSelectedLine)
                .originalLineSegmentsMapClone,
            deltaOnCanvas: deltaOnCanvas,
            decimalPositions: decimalPositions,
          );
        default:
          throw ArgumentError(
            'Unsupported MPSelectedElement type in MPMultipleElementsCommand.moveElementsFromDelta',
          );
      }

      commandsList.add(moveCommand);
    }
  }

  MPMultipleElementsCommand.moveLineSegments({
    required LinkedHashMap<int, THLineSegment> originalElementsMap,
    required LinkedHashMap<int, THLineSegment> modifiedElementsMap,
    super.descriptionType = MPCommandDescriptionType.moveLineSegments,
  }) : completionType = MPMultipleElementsCommandCompletionType.elementsEdited,
       super() {
    commandsList = [];

    for (final entry in originalElementsMap.entries) {
      final int originalElementMPID = entry.key;
      final THLineSegment originalElement = entry.value;
      final THLineSegment modifiedElement =
          modifiedElementsMap[originalElementMPID]!;
      final MPCommand moveLineSegmentCommand;

      switch (originalElement) {
        case THStraightLineSegment _:
          moveLineSegmentCommand = MPMoveStraightLineSegmentCommand(
            lineSegmentMPID: originalElementMPID,
            originalEndPointPosition: originalElement.endPoint,
            modifiedEndPointPosition: modifiedElement.endPoint,
          );
        case THBezierCurveLineSegment _:
          moveLineSegmentCommand = MPMoveBezierLineSegmentCommand(
            lineSegmentMPID: originalElementMPID,
            originalEndPointPosition: originalElement.endPoint,
            modifiedEndPointPosition: modifiedElement.endPoint,
            originalControlPoint1Position: originalElement.controlPoint1,
            modifiedControlPoint1Position:
                (modifiedElement as THBezierCurveLineSegment).controlPoint1,
            originalControlPoint2Position: originalElement.controlPoint2,
            modifiedControlPoint2Position: modifiedElement.controlPoint2,
          );
        default:
          throw ArgumentError(
            'Unsupported THLineSegment type in MPMultipleElementsCommand.moveLineSegments',
          );
      }

      commandsList.add(moveLineSegmentCommand);
    }
  }

  MPMultipleElementsCommand.moveLineSegmentsFromDeltaOnCanvas({
    required LinkedHashMap<int, THLineSegment> originalElementsMap,
    required Offset deltaOnCanvas,
    required int decimalPositions,
    super.descriptionType = MPCommandDescriptionType.moveLineSegments,
  }) : completionType = MPMultipleElementsCommandCompletionType.elementsEdited,
       super() {
    commandsList = [];

    for (final entry in originalElementsMap.entries) {
      final int originalElementMPID = entry.key;
      final THLineSegment originalElement = entry.value;
      final MPCommand moveLineSegmentCommand;

      switch (originalElement) {
        case THStraightLineSegment _:
          moveLineSegmentCommand = MPMoveStraightLineSegmentCommand.fromDelta(
            lineSegmentMPID: originalElementMPID,
            originalEndPointPosition: originalElement.endPoint,
            deltaOnCanvas: deltaOnCanvas,
            decimalPositions: decimalPositions,
          );
        case THBezierCurveLineSegment _:
          moveLineSegmentCommand = MPMoveBezierLineSegmentCommand.fromDelta(
            lineSegmentMPID: originalElementMPID,
            originalEndPointPosition: originalElement.endPoint,
            originalControlPoint1Position: originalElement.controlPoint1,
            originalControlPoint2Position: originalElement.controlPoint2,
            deltaOnCanvas: deltaOnCanvas,
            decimalPositions: decimalPositions,
          );
        default:
          throw ArgumentError(
            'Unsupported THLineSegment type in MPMultipleElementsCommand.moveLineSegments',
          );
      }

      commandsList.add(moveLineSegmentCommand);
    }
  }

  MPMultipleElementsCommand.editLinesSegmentType({
    required List<THLineSegment> newLineSegments,
    required THFile thFile,
    super.descriptionType = MPCommandDescriptionType.editLineSegmentsType,
  }) : completionType = MPMultipleElementsCommandCompletionType.elementsEdited,
       super() {
    commandsList = [];

    for (final THLineSegment newLineSegment in newLineSegments) {
      final MPCommand setLineSegmentTypeCommand = MPEditLineSegmentCommand(
        originalLineSegment: thFile.lineSegmentByMPID(newLineSegment.mpID),
        newLineSegment: newLineSegment,
        descriptionType: descriptionType,
      );

      commandsList.add(setLineSegmentTypeCommand);
    }
  }

  MPMultipleElementsCommand.moveLinesFromDeltaOnCanvas({
    required Iterable<MPSelectedLine> lines,
    required Offset deltaOnCanvas,
    required int decimalPositions,
    super.descriptionType = MPCommandDescriptionType.moveLines,
  }) : completionType = MPMultipleElementsCommandCompletionType.elementsEdited,
       super() {
    commandsList = [];

    for (final MPSelectedLine line in lines) {
      final MPCommand moveLineCommand = MPMoveLineCommand.fromDeltaOnCanvas(
        lineMPID: line.mpID,
        originalLineSegmentsMap: line.originalLineSegmentsMapClone,
        deltaOnCanvas: deltaOnCanvas,
        decimalPositions: decimalPositions,
        descriptionType: descriptionType,
      );

      commandsList.add(moveLineCommand);
    }
  }

  MPMultipleElementsCommand.editAreasType({
    required List<int> areaMPIDs,
    required THAreaType newAreaType,
    super.descriptionType = MPCommandDescriptionType.editAreasType,
  }) : completionType = MPMultipleElementsCommandCompletionType.elementsEdited,
       super() {
    commandsList = [];

    for (final int areaMPID in areaMPIDs) {
      final MPCommand editAreaTypeCommand = MPEditAreaTypeCommand(
        areaMPID: areaMPID,
        newAreaType: newAreaType,
        descriptionType: descriptionType,
      );

      commandsList.add(editAreaTypeCommand);
    }
  }

  MPMultipleElementsCommand.editLinesType({
    required List<int> lineMPIDs,
    required THLineType newLineType,
    super.descriptionType = MPCommandDescriptionType.editLinesType,
  }) : completionType = MPMultipleElementsCommandCompletionType.elementsEdited,
       super() {
    commandsList = [];

    for (final int lineMPID in lineMPIDs) {
      final MPCommand editLineTypeCommand = MPEditLineTypeCommand(
        lineMPID: lineMPID,
        newLineType: newLineType,
        descriptionType: descriptionType,
      );

      commandsList.add(editLineTypeCommand);
    }
  }

  MPMultipleElementsCommand.editPointsType({
    required List<int> pointMPIDs,
    required THPointType newPointType,
    super.descriptionType = MPCommandDescriptionType.editPointsType,
  }) : completionType = MPMultipleElementsCommandCompletionType.elementsEdited,
       super() {
    commandsList = [];

    for (final int pointMPID in pointMPIDs) {
      final MPCommand editPointTypeCommand = MPEditPointTypeCommand(
        pointMPID: pointMPID,
        newPointType: newPointType,
        descriptionType: descriptionType,
      );

      commandsList.add(editPointTypeCommand);
    }
  }

  @override
  MPCommandType get type => MPCommandType.multipleElements;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.applyMPCommandList(commandsList, completionType);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final List<MPCommand> undoCommandList = [];

    for (final MPCommand command in commandsList) {
      final MPUndoRedoCommand undoRedoCommand = command.getUndoRedoCommand(
        th2FileEditController,
      );

      undoCommandList.add(undoRedoCommand.undoCommand);
    }

    final MPCommand multipleUndoCommand = MPMultipleElementsCommand.forCWJM(
      commandsList: undoCommandList.reversed.toList(),
      completionType: completionType,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: multipleUndoCommand.toMap(),
    );
  }

  @override
  MPMultipleElementsCommand copyWith({
    List<MPCommand>? commandsList,
    MPMultipleElementsCommandCompletionType? completionType,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList ?? this.commandsList,
      completionType: completionType ?? this.completionType,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPMultipleElementsCommand.fromMap(Map<String, dynamic> map) {
    return MPMultipleElementsCommand.forCWJM(
      commandsList: (map['commandsList'] as List)
          .map((commandMap) => MPCommand.fromMap(commandMap))
          .toList(),
      completionType: MPMultipleElementsCommandCompletionType.values.byName(
        map['completionType'],
      ),
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPMultipleElementsCommand.fromJson(String jsonString) {
    return MPMultipleElementsCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'commandsList': commandsList.map((option) => option.toMap()).toList(),
      'completionType': completionType.name,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMultipleElementsCommand &&
        other.completionType == completionType &&
        const ListEquality<MPCommand>().equals(
          other.commandsList,
          commandsList,
        ) &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^ Object.hashAll(commandsList) ^ completionType.hashCode;
}

enum MPMultipleElementsCommandCompletionType {
  elementsEdited,
  elementsListChanged,
  lineSegmentsAdded,
  lineSegmentsRemoved,
  optionsEdited,
}
