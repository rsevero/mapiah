part of 'mp_command.dart';

class MPDeletePointCommand extends MPCommand {
  final int pointMapiahID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.deletePoint;

  MPDeletePointCommand.forCWJM({
    required this.pointMapiahID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPDeletePointCommand({
    required this.pointMapiahID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.deletePoint;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController
        .deleteElementByMapiahID(pointMapiahID);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THPoint originalPoint = th2FileEditController.thFile
        .elementByMapiahID(pointMapiahID) as THPoint;

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
    int? pointMapiahID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPDeletePointCommand.forCWJM(
      pointMapiahID: pointMapiahID ?? this.pointMapiahID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeletePointCommand.fromMap(Map<String, dynamic> map) {
    return MPDeletePointCommand.forCWJM(
      pointMapiahID: map['pointMapiahID'],
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
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ pointMapiahID.hashCode;
}
