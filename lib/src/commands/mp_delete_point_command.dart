part of 'mp_command.dart';

class MPDeletePointCommand extends MPCommand {
  final THPoint originalPoint;

  MPDeletePointCommand.forCWJM({
    required this.originalPoint,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.deletePoint,
  }) : super.forCWJM();

  MPDeletePointCommand({
    required this.originalPoint,
    super.descriptionType = MPCommandDescriptionType.deletePoint,
  }) : super();

  @override
  void _actualExecute(TH2FileEditStore th2FileEditStore) {
    th2FileEditStore.deleteElement(originalPoint);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand() {
    final MPCreatePointCommand oppositeCommand = MPCreatePointCommand(
      newPoint: originalPoint,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        descriptionType: descriptionType,
        map: oppositeCommand.toMap());
  }

  @override
  MPCommand copyWith({
    THPoint? originalPoint,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPDeletePointCommand.forCWJM(
      originalPoint: originalPoint ?? this.originalPoint,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeletePointCommand.fromMap(Map<String, dynamic> map) {
    return MPDeletePointCommand.forCWJM(
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
      'originalPoint': originalPoint.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPDeletePointCommand &&
        other.originalPoint == originalPoint &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ originalPoint.hashCode;

  @override
  MPCommandType get type => MPCommandType.deletePoint;
}
