part of 'mp_command.dart';

class MPDeletePointCommand extends MPCommand {
  final int pointMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.deletePoint;

  MPDeletePointCommand.forCWJM({
    required this.pointMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPDeletePointCommand({
    required this.pointMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.deletePoint;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.deleteElementByMPID(pointMPID);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THPoint originalPoint =
        th2FileEditController.thFile.elementByMPID(pointMPID) as THPoint;

    final MPAddPointCommand oppositeCommand = MPAddPointCommand(
      newPoint: originalPoint,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      mapUndo: oppositeCommand.toMap(),
      mapRedo: toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? pointMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPDeletePointCommand.forCWJM(
      pointMPID: pointMPID ?? this.pointMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeletePointCommand.fromMap(Map<String, dynamic> map) {
    return MPDeletePointCommand.forCWJM(
      pointMPID: map['pointMPID'],
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPDeletePointCommand.fromJson(String source) {
    return MPDeletePointCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'pointMPID': pointMPID,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPDeletePointCommand &&
        other.pointMPID == pointMPID &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ pointMPID.hashCode;
}
