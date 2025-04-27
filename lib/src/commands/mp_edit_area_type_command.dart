part of 'mp_command.dart';

class MPEditAreaTypeCommand extends MPCommand {
  final int areaMPID;
  final THAreaType newAreaType;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.editAreaType;

  MPEditAreaTypeCommand.forCWJM({
    required this.areaMPID,
    required this.newAreaType,
    super.keepOriginalLine = false,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPEditAreaTypeCommand({
    required this.areaMPID,
    required this.newAreaType,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.editAreaType;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THArea newArea =
        th2FileEditController.thFile.areaByMPID(areaMPID).copyWith(
              areaType: newAreaType,
              originalLineInTH2File: keepOriginalLine ? null : '',
            );

    th2FileEditController.elementEditController.substituteElement(newArea);
    th2FileEditController.optionEditController.updateOptionStateMap();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPEditAreaTypeCommand oppositeCommand = MPEditAreaTypeCommand(
      areaMPID: areaMPID,
      newAreaType: th2FileEditController.thFile.areaByMPID(areaMPID).areaType,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? areaMPID,
    THAreaType? newAreaType,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPEditAreaTypeCommand.forCWJM(
      areaMPID: areaMPID ?? this.areaMPID,
      newAreaType: newAreaType ?? this.newAreaType,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditAreaTypeCommand.fromMap(Map<String, dynamic> map) {
    return MPEditAreaTypeCommand.forCWJM(
      areaMPID: map['areaMPID'] as int,
      newAreaType: THAreaType.values.byName(map['newAreaType']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPEditAreaTypeCommand.fromJson(String source) {
    return MPEditAreaTypeCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'areaMPID': areaMPID,
      'newAreaType': newAreaType.name,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPEditAreaTypeCommand &&
        other.areaMPID == areaMPID &&
        other.newAreaType == newAreaType &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(areaMPID, newAreaType);
}
