part of 'mp_command.dart';

class MPDeletePointCommand extends MPCommand {
  final int pointMapiahID;

  MPDeletePointCommand.forCWJM({
    required this.pointMapiahID,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.deletePoint,
  }) : super.forCWJM();

  MPDeletePointCommand({
    required this.pointMapiahID,
    super.descriptionType = MPCommandDescriptionType.deletePoint,
  }) : super();

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.deleteElementByMapiahID(pointMapiahID);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
      TH2FileEditController th2FileEditController) {
    final THPoint originalPoint = th2FileEditController.thFile
        .elementByMapiahID(pointMapiahID) as THPoint;

    final MPAddPointCommand oppositeCommand = MPAddPointCommand(
      newPoint: originalPoint,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      descriptionType: descriptionType,
      map: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? pointMapiahID,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPDeletePointCommand.forCWJM(
      pointMapiahID: pointMapiahID ?? this.pointMapiahID,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeletePointCommand.fromMap(Map<String, dynamic> map) {
    return MPDeletePointCommand.forCWJM(
      pointMapiahID: map['pointMapiahID'],
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
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
      'pointMapiahID': pointMapiahID,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPDeletePointCommand &&
        other.pointMapiahID == pointMapiahID &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ pointMapiahID.hashCode;

  @override
  MPCommandType get type => MPCommandType.deletePoint;
}
