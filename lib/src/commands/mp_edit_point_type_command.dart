part of 'mp_command.dart';

class MPEditPointTypeCommand extends MPCommand {
  final int pointMPID;
  final THPointType newPointType;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.editPointType;

  MPEditPointTypeCommand.forCWJM({
    required this.pointMPID,
    required this.newPointType,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPEditPointTypeCommand({
    required this.pointMPID,
    required this.newPointType,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.editPointType;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THPoint newPoint =
        th2FileEditController.thFile.pointByMPID(pointMPID).copyWith(
              pointType: newPointType,
            );

    th2FileEditController.elementEditController.substituteElement(newPoint);
    th2FileEditController.optionEditController.updateOptionStateMap();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPEditPointTypeCommand oppositeCommand = MPEditPointTypeCommand(
      pointMPID: pointMPID,
      newPointType:
          th2FileEditController.thFile.pointByMPID(pointMPID).pointType,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? pointMPID,
    THPointType? newPointType,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPEditPointTypeCommand.forCWJM(
      pointMPID: pointMPID ?? this.pointMPID,
      newPointType: newPointType ?? this.newPointType,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditPointTypeCommand.fromMap(Map<String, dynamic> map) {
    return MPEditPointTypeCommand.forCWJM(
      pointMPID: map['pointMPID'] as int,
      newPointType: THPointType.values.byName(map['newPointType']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPEditPointTypeCommand.fromJson(String source) {
    return MPEditPointTypeCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'pointMPID': pointMPID,
      'newPointType': newPointType.name,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPEditPointTypeCommand &&
        other.pointMPID == pointMPID &&
        other.newPointType == newPointType &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(pointMPID, newPointType);
}
