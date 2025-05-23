part of 'mp_command.dart';

class MPEditLineSegmentCommand extends MPCommand {
  final THLineSegment originalLineSegment;
  final THLineSegment newLineSegment;
  final String originalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.editLineSegment;

  MPEditLineSegmentCommand.forCWJM({
    required this.originalLineSegment,
    required this.newLineSegment,
    required this.originalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPEditLineSegmentCommand({
    required this.originalLineSegment,
    required this.newLineSegment,
    super.descriptionType = _defaultDescriptionType,
  })  : originalLineInTH2File = '',
        super();

  @override
  MPCommandType get type => MPCommandType.editLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController
        .substituteElement(newLineSegment);
    th2FileEditController.triggerNewLineRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPEditLineSegmentCommand.forCWJM(
      originalLineSegment: newLineSegment,
      newLineSegment: originalLineSegment,
      originalLineInTH2File: originalLineSegment.originalLineInTH2File,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    THLineSegment? originalLineSegment,
    THLineSegment? newLineSegment,
    String? originalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPEditLineSegmentCommand.forCWJM(
      originalLineSegment: originalLineSegment ?? this.originalLineSegment,
      newLineSegment: newLineSegment ?? this.newLineSegment,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPEditLineSegmentCommand.forCWJM(
      originalLineSegment: THLineSegment.fromMap(map['originalLineSegment']),
      newLineSegment: THLineSegment.fromMap(map['newLineSegment']),
      originalLineInTH2File: map['originalLineInTH2File'],
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPEditLineSegmentCommand.fromJson(String source) {
    return MPEditLineSegmentCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'originalLineSegment': originalLineSegment.toMap(),
      'newLineSegment': newLineSegment.toMap(),
      'originalLineInTH2File': originalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPEditLineSegmentCommand &&
        other.originalLineSegment == originalLineSegment &&
        other.newLineSegment == newLineSegment &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        originalLineSegment,
        newLineSegment,
        originalLineInTH2File,
      );
}
