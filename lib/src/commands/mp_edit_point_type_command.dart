part of 'mp_command.dart';

class MPEditPointTypeCommand extends MPCommand {
  final int pointMPID;
  final THPointType newPointType;
  final String originalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.editPointType;

  MPEditPointTypeCommand.forCWJM({
    required this.pointMPID,
    required this.newPointType,
    required this.originalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPEditPointTypeCommand({
    required this.pointMPID,
    required this.newPointType,
    super.descriptionType = _defaultDescriptionType,
  })  : originalLineInTH2File = '',
        super();

  @override
  MPCommandType get type => MPCommandType.editPointType;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    final THPoint newPoint =
        th2FileEditController.thFile.pointByMPID(pointMPID).copyWith(
              pointType: newPointType,
              originalLineInTH2File:
                  keepOriginalLineTH2File ? originalLineInTH2File : '',
            );

    th2FileEditController.elementEditController.substituteElement(newPoint);
    th2FileEditController.optionEditController.updateOptionStateMap();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THPoint originalPoint =
        th2FileEditController.thFile.pointByMPID(pointMPID);

    final MPCommand oppositeCommand = MPEditPointTypeCommand.forCWJM(
      pointMPID: pointMPID,
      newPointType: originalPoint.pointType,
      originalLineInTH2File: originalPoint.originalLineInTH2File,
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
    String? originalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPEditPointTypeCommand.forCWJM(
      pointMPID: pointMPID ?? this.pointMPID,
      newPointType: newPointType ?? this.newPointType,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditPointTypeCommand.fromMap(Map<String, dynamic> map) {
    return MPEditPointTypeCommand.forCWJM(
      pointMPID: map['pointMPID'] as int,
      newPointType: THPointType.values.byName(map['newPointType']),
      originalLineInTH2File: map['originalLineInTH2File'] as String,
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
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
      'originalLineInTH2File': originalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPEditPointTypeCommand &&
        other.pointMPID == pointMPID &&
        other.newPointType == newPointType &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        pointMPID,
        newPointType,
        originalLineInTH2File,
      );
}
