part of 'mp_command.dart';

class MPMultipleElementsCommand extends MPCommand {
  late final List<MPCommand> commandsList;
  final MPMultipleElementsCommandCompletionType completionType;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.multipleElements;

  MPMultipleElementsCommand.forCWJM({
    required this.commandsList,
    required this.completionType,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    if (commandsList.length < 2) {
      throw ArgumentError(
        'commandsList must contain at least two commands at MPMultipleElementsCommand.forCWJM().',
      );
    }
  }

  @override
  MPCommandType get type => MPCommandType.multipleElements;

  @override
  void _prePrepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    for (final MPCommand command in commandsList) {
      command._prePrepareUndoRedoInfo(th2FileEditController);
    }
  }

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    for (final MPCommand command in commandsList) {
      command._prepareUndoRedoInfo(th2FileEditController);
    }

    _undoRedoInfo = {};
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.executeMPCommandList(commandsList, completionType);
  }

  @override
  void _posCreateUndoRedoCommand(TH2FileEditController th2FileEditController) {
    for (final MPCommand command in commandsList) {
      command._posCreateUndoRedoCommand(th2FileEditController);
    }
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

  /// If the subcommands have already been executed, it is necessary to call
  /// manually the multiple command prepareUndoRedoInfo method to prepare
  /// its own the undo/redo information. The subcommands prepareUndoRedoInfo
  /// method has already been called.
  void prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    _undoRedoInfo = {};
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
    if (!super.equalsBase(other)) return false;

    return other is MPMultipleElementsCommand &&
        other.completionType == completionType &&
        const ListEquality<MPCommand>().equals(
          other.commandsList,
          commandsList,
        );
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    DeepCollectionEquality().hash(commandsList),
    completionType,
  );
}

enum MPMultipleElementsCommandCompletionType {
  elementsEdited,
  elementsListChanged,
  lineSegmentsEdited,
  optionsEdited,
}
