part of 'mp_command.dart';

class MPRemovePointCommand extends MPCommand {
  final int pointMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removePoint;

  MPRemovePointCommand.forCWJM({
    required this.pointMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemovePointCommand({
    required this.pointMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removePoint;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      pointMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THPoint originalPoint = th2FileEditController.thFile.pointByMPID(
      pointMPID,
    );
    final MPCommand oppositeCommand = MPAddPointCommand(
      newPoint: originalPoint,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemovePointCommand copyWith({
    int? pointMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemovePointCommand.forCWJM(
      pointMPID: pointMPID ?? this.pointMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemovePointCommand.fromMap(Map<String, dynamic> map) {
    return MPRemovePointCommand.forCWJM(
      pointMPID: map['pointMPID'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemovePointCommand.fromJson(String source) {
    return MPRemovePointCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'pointMPID': pointMPID});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemovePointCommand && other.pointMPID == pointMPID;
  }

  @override
  int get hashCode => super.hashCode ^ pointMPID.hashCode;
}
