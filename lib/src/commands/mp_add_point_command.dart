part of 'mp_command.dart';

class MPAddPointCommand extends MPCommand {
  final THPoint newPoint;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addPoint;

  MPAddPointCommand.forCWJM({
    required this.newPoint,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddPointCommand({
    required this.newPoint,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.addPoint;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController
        .applyAddElement(newElement: newPoint);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPRemovePointCommand oppositeCommand = MPRemovePointCommand(
      pointMPID: newPoint.mpID,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    THPoint? newPoint,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddPointCommand.forCWJM(
      newPoint: newPoint ?? this.newPoint,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddPointCommand.fromMap(Map<String, dynamic> map) {
    return MPAddPointCommand.forCWJM(
      newPoint: THPoint.fromMap(map['newPoint']),
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
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ newPoint.hashCode;
}
