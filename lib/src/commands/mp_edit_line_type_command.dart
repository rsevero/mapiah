part of 'mp_command.dart';

class MPEditLineTypeCommand extends MPCommand {
  final int lineMPID;
  final THLineType newLineType;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.editLineType;

  MPEditLineTypeCommand.forCWJM({
    required this.lineMPID,
    required this.newLineType,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPEditLineTypeCommand({
    required this.lineMPID,
    required this.newLineType,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.editLineType;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THLine newLine =
        th2FileEditController.thFile.lineByMPID(lineMPID).copyWith(
              lineType: newLineType,
            );

    th2FileEditController.elementEditController.substituteElement(newLine);
    th2FileEditController.triggerOptionsListRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPEditLineTypeCommand oppositeCommand = MPEditLineTypeCommand(
      lineMPID: lineMPID,
      newLineType: th2FileEditController.thFile.lineByMPID(lineMPID).lineType,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? lineMPID,
    THLineType? newLineType,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPEditLineTypeCommand.forCWJM(
      lineMPID: lineMPID ?? this.lineMPID,
      newLineType: newLineType ?? this.newLineType,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditLineTypeCommand.fromMap(Map<String, dynamic> map) {
    return MPEditLineTypeCommand.forCWJM(
      lineMPID: map['lineMPID'] as int,
      newLineType: THLineType.values.byName(map['newLineType']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPEditLineTypeCommand.fromJson(String source) {
    return MPEditLineTypeCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'lineMPID': lineMPID,
      'newLineType': newLineType.name,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPEditLineTypeCommand &&
        other.lineMPID == lineMPID &&
        other.newLineType == newLineType &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(lineMPID, newLineType);
}
