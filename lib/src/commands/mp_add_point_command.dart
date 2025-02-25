part of 'mp_command.dart';

class MPAddPointCommand extends MPCommand {
  final THPoint newPoint;

  MPAddPointCommand.forCWJM({
    required this.newPoint,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.addPoint,
  }) : super.forCWJM();

  MPAddPointCommand({
    required this.newPoint,
    super.descriptionType = MPCommandDescriptionType.addPoint,
  }) : super();

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.addElement(newElement: newPoint);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPDeletePointCommand oppositeCommand = MPDeletePointCommand(
      pointMapiahID: newPoint.mapiahID,
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
    THPoint? newPoint,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPAddPointCommand.forCWJM(
      newPoint: newPoint ?? this.newPoint,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddPointCommand.fromMap(Map<String, dynamic> map) {
    return MPAddPointCommand.forCWJM(
      newPoint: THPoint.fromMap(map['newPoint']),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPAddPointCommand.fromJson(String source) {
    return MPAddPointCommand.fromMap(jsonDecode(source));
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

    return other is MPAddPointCommand &&
        other.newPoint == newPoint &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ newPoint.hashCode;

  @override
  MPCommandType get type => MPCommandType.addPoint;
}
