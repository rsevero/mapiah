part of 'mp_command.dart';

class MPDeletePointCommand extends MPCommand {
  final int pointMapiahID;
  final THPoint originalPoint;

  MPDeletePointCommand.forCWJM({
    required this.pointMapiahID,
    required this.originalPoint,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.deletePoint,
  }) : super.forCWJM();

  MPDeletePointCommand({
    required this.originalPoint,
    super.descriptionType = MPCommandDescriptionType.deletePoint,
  })  : pointMapiahID = originalPoint.mapiahID,
        super();

  @override
  void _actualExecute(TH2FileEditStore th2FileEditStore) {
    th2FileEditStore.deleteElementByMapiahID(pointMapiahID);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand() {
    final MPCreatePointCommand oppositeCommand = MPCreatePointCommand(
      originalPoint: originalPoint,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        descriptionType: descriptionType,
        map: oppositeCommand.toMap());
  }

  @override
  MPCommand copyWith({
    int? pointMapiahID,
    THPoint? originalPoint,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPDeletePointCommand.forCWJM(
      pointMapiahID: pointMapiahID ?? this.pointMapiahID,
      originalPoint: originalPoint ?? this.originalPoint,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeletePointCommand.fromMap(Map<String, dynamic> map) {
    return MPDeletePointCommand.forCWJM(
      pointMapiahID: map['pointMapiahID'],
      originalPoint: THPoint.fromMap(map['originalPoint']),
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
      'originalPoint': originalPoint.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPDeletePointCommand &&
        other.pointMapiahID == pointMapiahID &&
        other.originalPoint == originalPoint &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        pointMapiahID,
        originalPoint,
      );

  @override
  MPCommandType get type => MPCommandType.deletePoint;
}
