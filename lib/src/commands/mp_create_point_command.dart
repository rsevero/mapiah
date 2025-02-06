part of 'mp_command.dart';

class MPCreatePointCommand extends MPCommand {
  final THPoint newPoint;

  MPCreatePointCommand.forCWJM({
    required this.newPoint,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.createPoint,
  }) : super.forCWJM();

  MPCreatePointCommand({
    required this.newPoint,
    super.descriptionType = MPCommandDescriptionType.createPoint,
  }) : super();

  @override
  void _actualExecute(TH2FileEditStore th2FileEditStore) {
    th2FileEditStore.addElement(newPoint);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand() {
    final MPDeletePointCommand oppositeCommand = MPDeletePointCommand(
      originalPoint: newPoint,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        descriptionType: descriptionType,
        map: oppositeCommand.toMap());
  }

  @override
  MPCommand copyWith({
    THPoint? newPoint,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPCreatePointCommand.forCWJM(
      newPoint: newPoint ?? this.newPoint,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPCreatePointCommand.fromMap(Map<String, dynamic> map) {
    return MPCreatePointCommand.forCWJM(
      newPoint: THPoint.fromMap(map['newPoint']),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPCreatePointCommand.fromJson(String source) {
    return MPCreatePointCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newPoint': newPoint.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPCreatePointCommand &&
        other.newPoint == newPoint &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ newPoint.hashCode;

  @override
  MPCommandType get type => MPCommandType.createPoint;
}
