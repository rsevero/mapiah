part of 'mp_command.dart';

class MPEditAreaTypeCommand extends MPCommand {
  final int areaMPID;
  final THAreaType newAreaType;
  late final String originalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.editAreaType;

  MPEditAreaTypeCommand.forCWJM({
    required this.areaMPID,
    required this.newAreaType,
    required this.originalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPEditAreaTypeCommand({
    required this.areaMPID,
    required this.newAreaType,
    super.descriptionType = _defaultDescriptionType,
  }) : originalLineInTH2File = '',
       super();

  @override
  MPCommandType get type => MPCommandType.editAreaType;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    final THArea newArea = th2FileEditController.thFile
        .areaByMPID(areaMPID)
        .copyWith(
          areaType: newAreaType,
          originalLineInTH2File: keepOriginalLineTH2File ? null : '',
        );

    th2FileEditController.elementEditController.substituteElement(newArea);
    th2FileEditController.optionEditController.updateOptionStateMap();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THArea originalArea = th2FileEditController.thFile.areaByMPID(
      areaMPID,
    );

    final MPCommand oppositeCommand = MPEditAreaTypeCommand.forCWJM(
      areaMPID: areaMPID,
      newAreaType: originalArea.areaType,
      originalLineInTH2File: originalArea.originalLineInTH2File,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPEditAreaTypeCommand copyWith({
    int? areaBorderTHIDMPID,
    THAreaType? newAreaType,
    String? originalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPEditAreaTypeCommand.forCWJM(
      areaMPID: areaBorderTHIDMPID ?? this.areaMPID,
      newAreaType: newAreaType ?? this.newAreaType,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditAreaTypeCommand.fromMap(Map<String, dynamic> map) {
    return MPEditAreaTypeCommand.forCWJM(
      areaMPID: map['areaMPID'] as int,
      newAreaType: THAreaType.values.byName(map['newAreaType']),
      originalLineInTH2File: map['originalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
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
      'originalLineInTH2File': originalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPEditAreaTypeCommand &&
        other.areaMPID == areaMPID &&
        other.newAreaType == newAreaType &&
        other.originalLineInTH2File == originalLineInTH2File;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, areaMPID, newAreaType, originalLineInTH2File);
}
