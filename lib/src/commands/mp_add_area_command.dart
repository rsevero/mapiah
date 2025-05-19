part of 'mp_command.dart';

class MPAddAreaCommand extends MPCommand {
  final THArea newArea;
  late final MPCommand addAreaTHIDsCommand;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addArea;

  MPAddAreaCommand.forCWJM({
    required this.newArea,
    required this.addAreaTHIDsCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddAreaCommand({
    required this.newArea,
    required TH2FileEditController th2FileEditController,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    final List<MPCommand> addAreaTHIDCommands = [];
    final THFile thFile = th2FileEditController.thFile;
    final Set<int> lineMPIDs = newArea.getLineMPIDs(thFile);

    for (final int lineMPID in lineMPIDs) {
      addAreaTHIDCommands.add(
        MPAddLineCommand.fromLineMPID(
          lineMPID: lineMPID,
          th2FileEditController: th2FileEditController,
        ),
      );
    }

    addAreaTHIDsCommand = MPMultipleElementsCommand.forCWJM(
      commandsList: addAreaTHIDCommands,
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
    addAreaTHIDsCommand.execute(th2FileEditController);
    th2FileEditController.elementEditController.applyAddElement(
      newElement: newArea,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveAreaCommand(
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
    MPCommand? addAreaTHIDsCommand,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddAreaCommand.forCWJM(
      newArea: newArea ?? this.newArea,
      addAreaTHIDsCommand: addAreaTHIDsCommand ?? this.addAreaTHIDsCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddAreaCommand.fromMap(Map<String, dynamic> map) {
    return MPAddAreaCommand.forCWJM(
      newArea: THArea.fromMap(map['newArea']),
      addAreaTHIDsCommand: MPCommand.fromMap(map['addAreaTHIDsCommand']),
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
      'addAreaTHIDsCommand': addAreaTHIDsCommand.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddAreaCommand &&
        other.newArea == newArea &&
        other.addAreaTHIDsCommand == addAreaTHIDsCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        newArea,
        addAreaTHIDsCommand,
      );
}
