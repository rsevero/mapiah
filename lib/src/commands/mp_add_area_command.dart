part of 'mp_command.dart';

class MPAddAreaCommand extends MPCommand {
  final THArea newArea;
  late final MPCommand addLinesCommand;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addArea;

  MPAddAreaCommand.forCWJM({
    required this.newArea,
    required this.addLinesCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddAreaCommand({
    required this.newArea,
    required TH2FileEditController th2FileEditController,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    final List<MPCommand> addLineCommands = [];
    final THFile thFile = th2FileEditController.thFile;
    final Set<int> lineMPIDs = newArea.getLineMPIDs(thFile);

    for (final int lineMPID in lineMPIDs) {
      addLineCommands.add(
        MPAddLineCommand.fromLineMPID(
          lineMPID: lineMPID,
          th2FileEditController: th2FileEditController,
        ),
      );
    }

    addLinesCommand = MPMultipleElementsCommand.forCWJM(
      commandsList: addLineCommands,
      completionType:
          MPMultipleElementsCommandCompletionType.elementsListChanged,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.addArea;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    addLinesCommand.execute(th2FileEditController);
    th2FileEditController.elementEditController.applyAddElement(
      newElement: newArea,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPRemoveAreaCommand oppositeCommand = MPRemoveAreaCommand(
      areaMPID: newArea.mpID,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    THArea? newArea,
    MPCommand? addLinesCommand,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddAreaCommand.forCWJM(
      newArea: newArea ?? this.newArea,
      addLinesCommand: addLinesCommand ?? this.addLinesCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddAreaCommand.fromMap(Map<String, dynamic> map) {
    return MPAddAreaCommand.forCWJM(
      newArea: THArea.fromMap(map['newArea']),
      addLinesCommand: MPCommand.fromMap(map['addLinesCommand']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPAddAreaCommand.fromJson(String source) {
    return MPAddAreaCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newArea': newArea.toMap(),
      'addLinesCommand': addLinesCommand.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddAreaCommand &&
        other.newArea == newArea &&
        other.addLinesCommand == addLinesCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        newArea,
        addLinesCommand,
      );
}
