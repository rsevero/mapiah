part of 'mp_command.dart';

class MPEditLineTypeCommand extends MPCommand {
  final int lineMPID;
  final THLineType newLineType;
  final String originalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.editLineType;

  MPEditLineTypeCommand.forCWJM({
    required this.lineMPID,
    required this.newLineType,
    required this.originalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPEditLineTypeCommand({
    required this.lineMPID,
    required this.newLineType,
    super.descriptionType = _defaultDescriptionType,
  })  : originalLineInTH2File = '',
        super();

  @override
  MPCommandType get type => MPCommandType.editLineType;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    final THLine newLine =
        th2FileEditController.thFile.lineByMPID(lineMPID).copyWith(
              lineType: newLineType,
              originalLineInTH2File: keepOriginalLineTH2File ? null : '',
            );

    th2FileEditController.elementEditController.substituteElement(newLine);
    th2FileEditController.optionEditController.updateOptionStateMap();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THLine originalLine =
        th2FileEditController.thFile.lineByMPID(lineMPID);

    final MPCommand oppositeCommand = MPEditLineTypeCommand.forCWJM(
      lineMPID: lineMPID,
      newLineType: originalLine.lineType,
      originalLineInTH2File: originalLine.originalLineInTH2File,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPEditLineTypeCommand copyWith({
    int? lineMPID,
    THLineType? newLineType,
    String? originalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPEditLineTypeCommand.forCWJM(
      lineMPID: lineMPID ?? this.lineMPID,
      newLineType: newLineType ?? this.newLineType,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditLineTypeCommand.fromMap(Map<String, dynamic> map) {
    return MPEditLineTypeCommand.forCWJM(
      lineMPID: map['lineMPID'] as int,
      newLineType: THLineType.values.byName(map['newLineType']),
      originalLineInTH2File: map['originalLineInTH2File'],
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPEditLineTypeCommand.fromJson(String source) {
    return MPEditLineTypeCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'lineMPID': lineMPID,
      'newLineType': newLineType.name,
      'originalLineInTH2File': originalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPEditLineTypeCommand &&
        other.lineMPID == lineMPID &&
        other.newLineType == newLineType &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineMPID,
        newLineType,
        originalLineInTH2File,
      );
}
