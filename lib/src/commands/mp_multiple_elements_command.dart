part of 'mp_command.dart';

class MPMultipleElementsCommand extends MPCommand {
  late final List<MPCommand> commandsList;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.multipleElements;

  MPMultipleElementsCommand.forCWJM({
    required this.commandsList,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMultipleElementsCommand.setOption({
    required THCommandOption option,
    required List<THElement> elements,
    super.descriptionType = MPCommandDescriptionType.setOptionToElements,
  }) : super() {
    commandsList = [];

    for (final THElement element in elements) {
      if (element is! THHasOptionsMixin) {
        throw ArgumentError(
          'Element with MPID ${element.parentMPID} does not support options',
        );
      }

      final MPSetOptionToElementCommand setOptionToElementCommand =
          MPSetOptionToElementCommand(
        option: option.copyWith(parentMPID: element.mpID),
        descriptionType: descriptionType,
      );

      commandsList.add(setOptionToElementCommand);
    }
  }

  MPMultipleElementsCommand.removeOption({
    required THCommandOptionType optionType,
    required List<int> parentMPIDs,
    super.descriptionType = MPCommandDescriptionType.removeOptionFromElements,
  }) : super() {
    commandsList = [];

    for (final int parentMPID in parentMPIDs) {
      final MPRemoveOptionFromElementCommand removeOptionFromElementCommand =
          MPRemoveOptionFromElementCommand(
        optionType: optionType,
        parentMPID: parentMPID,
        descriptionType: descriptionType,
      );

      commandsList.add(removeOptionFromElementCommand);
    }
  }

  MPMultipleElementsCommand.removeElements({
    required List<int> mpIDs,
    required THFile thFile,
    super.descriptionType = MPCommandDescriptionType.removeElements,
  }) : super() {
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

  MPMultipleElementsCommand.moveElementsFromDeltaOnCanvas({
    required Offset deltaOnCanvas,
    required int decimalPositions,
    required Iterable<MPSelectedElement> mpSelectedElements,
    super.descriptionType = MPCommandDescriptionType.moveElements,
  }) : super() {
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
  }) : super() {
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
  }) : super() {
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

  MPMultipleElementsCommand.editAreasType({
    required List<int> areaMPIDs,
    required THAreaType newAreaType,
    super.descriptionType = MPCommandDescriptionType.editAreasType,
  }) : super() {
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
  }) : super() {
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
  }) : super() {
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
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.applyMPCommandList(
      commandsList,
      th2FileEditController.elementEditController.updateOptionEdited,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final List<MPUndoRedoCommand> undoRedoCommandList = commandsList
        .map((command) => command.getUndoRedoCommand(th2FileEditController))
        .toList();
    final List<MPCommand> undoCommandList = undoRedoCommandList
        .map((undoRedoCommand) => undoRedoCommand.undoCommand)
        .toList();
    final MPCommand multipleUndoCommand = MPMultipleElementsCommand.forCWJM(
      commandsList: undoCommandList,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: multipleUndoCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    List<MPCommand>? commandsList,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList ?? this.commandsList,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPMultipleElementsCommand.fromMap(Map<String, dynamic> map) {
    return MPMultipleElementsCommand.forCWJM(
      commandsList: (map['commandsList'] as List)
          .map((commandMap) => MPCommand.fromMap(commandMap))
          .toList(),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
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
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMultipleElementsCommand &&
        const ListEquality<MPCommand>()
            .equals(other.commandsList, commandsList) &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hashAll(commandsList);
}
