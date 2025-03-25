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
      switch (thFile.getElementTypeByMPID(mpID)) {
        case THElementType.point:
          final MPRemovePointCommand removePointCommand =
              MPRemovePointCommand(pointMPID: mpID);

          commandsList.add(removePointCommand);
        case THElementType.line:
          final MPRemoveLineCommand removeLineCommand = MPRemoveLineCommand(
            lineMPID: mpID,
            isInteractiveLineCreation: false,
          );

          commandsList.add(removeLineCommand);
        default:
          throw ArgumentError(
            'Unsupported element type in MPMultipleElementsCommand.removeElements',
          );
      }
    }
  }

  MPMultipleElementsCommand.moveElementsFromDelta({
    required Offset deltaOnCanvas,
    required Iterable<MPSelectedElement> mpSelectedElements,
    super.descriptionType = MPCommandDescriptionType.moveElements,
  }) : super() {
    commandsList = [];

    for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
      final THElement element = mpSelectedElement.originalElementClone;

      switch (element) {
        case THPoint _:
          final MPMovePointCommand movePointCommand =
              MPMovePointCommand.fromDelta(
            pointMPID: element.mpID,
            originalCoordinates: element.position.coordinates,
            deltaOnCanvas: deltaOnCanvas,
          );

          commandsList.add(movePointCommand);
        case THLine _:
          final MPMoveLineCommand moveLineCommand = MPMoveLineCommand.fromDelta(
            lineMPID: element.mpID,
            originalLineSegmentsMap: (mpSelectedElement as MPSelectedLine)
                .originalLineSegmentsMapClone,
            deltaOnCanvas: deltaOnCanvas,
          );

          commandsList.add(moveLineCommand);
        default:
          throw ArgumentError(
            'Unsupported MPSelectedElement type in MPMultipleElementsCommand.moveElementsFromDelta',
          );
      }
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
