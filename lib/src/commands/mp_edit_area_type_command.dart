part of 'mp_command.dart';

class MPEditAreaTypeCommand extends MPCommand {
  final int areaMPID;
  final THAreaType newAreaType;
  final String unknownPLAType;
  late final String originalLineInTH2File;

  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.editAreaType;

        static MPCommandDescriptionType get defaultDescriptionTypeStatic =>
      _defaultDescriptionType;

  MPEditAreaTypeCommand.forCWJM({
    required this.areaMPID,
    required this.newAreaType,
    required this.unknownPLAType,
    required this.originalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPEditAreaTypeCommand({
    required this.areaMPID,
    required this.newAreaType,
    required this.unknownPLAType,
    this.originalLineInTH2File = '',
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.editAreaType;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THArea originalArea = th2FileEditController.thFile.areaByMPID(
      areaMPID,
    );

    _undoRedoInfo = {
      'originalAreaType': originalArea.areaType,
      'originalUnknownPLAType': originalArea.unknownPLAType,
      'originalLineInTH2File': originalArea.originalLineInTH2File,
    };
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THArea newArea = th2FileEditController.thFile
        .areaByMPID(areaMPID)
        .copyWith(
          areaType: newAreaType,
          unknownPLAType: unknownPLAType,
          originalLineInTH2File: originalLineInTH2File,
        );

    th2FileEditController.elementEditController.substituteElement(newArea);
    th2FileEditController.optionEditController.updateOptionStateMap();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPEditAreaTypeCommand.forCWJM(
      areaMPID: areaMPID,
      newAreaType: _undoRedoInfo!['originalAreaType'] as THAreaType,
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
  MPEditAreaTypeCommand copyWith({
    int? areaMPID,
    THAreaType? newAreaType,
    String? unknownPLAType,
    String? fromOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPEditAreaTypeCommand.forCWJM(
      areaMPID: areaMPID ?? this.areaMPID,
      newAreaType: newAreaType ?? this.newAreaType,
      unknownPLAType: unknownPLAType ?? this.unknownPLAType,
      originalLineInTH2File:
          fromOriginalLineInTH2File ?? this.originalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditAreaTypeCommand.fromMap(Map<String, dynamic> map) {
    return MPEditAreaTypeCommand.forCWJM(
      areaMPID: map['areaMPID'] as int,
      newAreaType: THAreaType.values.byName(map['newAreaType']),
      unknownPLAType: map['unknownPLAType'] as String,
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
      'unknownPLAType': unknownPLAType,
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
        other.unknownPLAType == unknownPLAType &&
        other.originalLineInTH2File == originalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    areaMPID,
    newAreaType,
    unknownPLAType,
    originalLineInTH2File,
  );
}
