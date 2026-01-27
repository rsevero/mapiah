part of 'mp_command.dart';

class MPEditPointTypeCommand extends MPCommand {
  final int pointMPID;
  final THPointType newPointType;
  final String unknownPLAType;
  final String originalLineInTH2File;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.editPointType;

  MPEditPointTypeCommand.forCWJM({
    required this.pointMPID,
    required this.newPointType,
    required this.unknownPLAType,
    required this.originalLineInTH2File,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  MPEditPointTypeCommand({
    required this.pointMPID,
    required this.newPointType,
    required this.unknownPLAType,
    this.originalLineInTH2File = '',
    super.descriptionType = defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.editPointType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THPoint originalPoint = th2FileEditController.thFile.pointByMPID(
      pointMPID,
    );

    _undoRedoInfo = {
      'originalPointType': originalPoint.pointType,
      'originalUnknownPLAType': originalPoint.unknownPLAType,
      'originalLineInTH2File': originalPoint.originalLineInTH2File,
    };
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THPoint newPoint = th2FileEditController.thFile
        .pointByMPID(pointMPID)
        .copyWith(
          pointType: newPointType,
          unknownPLAType: unknownPLAType,
          originalLineInTH2File: originalLineInTH2File,
        );

    th2FileEditController.elementEditController.substituteElement(newPoint);
    th2FileEditController.optionEditController.updateOptionStateMap();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPEditPointTypeCommand.forCWJM(
      pointMPID: pointMPID,
      newPointType: _undoRedoInfo!['originalPointType'] as THPointType,
      unknownPLAType: _undoRedoInfo!['originalUnknownPLAType'] as String,
      originalLineInTH2File: _undoRedoInfo!['originalLineInTH2File'] as String,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPEditPointTypeCommand copyWith({
    int? pointMPID,
    THPointType? newPointType,
    String? unknownPLAType,
    String? originalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPEditPointTypeCommand.forCWJM(
      pointMPID: pointMPID ?? this.pointMPID,
      newPointType: newPointType ?? this.newPointType,
      unknownPLAType: unknownPLAType ?? this.unknownPLAType,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditPointTypeCommand.fromMap(Map<String, dynamic> map) {
    return MPEditPointTypeCommand.forCWJM(
      pointMPID: map['pointMPID'] as int,
      newPointType: THPointType.values.byName(map['newPointType']),
      unknownPLAType: map['unknownPLAType'] as String,
      originalLineInTH2File: map['originalLineInTH2File'] as String,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
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
      'unknownPLAType': unknownPLAType,
      'originalLineInTH2File': originalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPEditPointTypeCommand &&
        other.pointMPID == pointMPID &&
        other.newPointType == newPointType &&
        other.unknownPLAType == unknownPLAType &&
        other.originalLineInTH2File == originalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    pointMPID,
    newPointType,
    unknownPLAType,
    originalLineInTH2File,
  );
}
