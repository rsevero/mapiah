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
