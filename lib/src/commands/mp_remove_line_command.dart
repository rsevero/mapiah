part of "mp_command.dart";

class MPRemoveLineCommand extends MPCommand {
  final int lineMPID;
  final bool isInteractiveLineCreation;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeLine;

  MPRemoveLineCommand.forCWJM({
    required this.lineMPID,
    required this.isInteractiveLineCreation,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveLineCommand({
    required this.lineMPID,
    required this.isInteractiveLineCreation,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeLine;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.applyRemoveLine(lineMPID);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THFile thFile = th2FileEditController.thFile;
    final THLine originalLine = thFile.lineByMPID(lineMPID);
    final List<THElement> lineChildren = [];
    final Set<int> lineChildrenMPIDs = originalLine.childrenMPID;

    for (final int childMPID in lineChildrenMPIDs) {
      final THElement childElement = thFile.elementByMPID(childMPID);

      lineChildren.add(childElement);
    }

    final MPAddLineCommand oppositeCommand = MPAddLineCommand(
      newLine: originalLine,
      lineChildren: lineChildren,
      lineStartScreenPosition:
          th2FileEditController.elementEditController.lineStartScreenPosition,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? lineMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveLineCommand.forCWJM(
      lineMPID: lineMPID ?? this.lineMPID,
      isInteractiveLineCreation: isInteractiveLineCreation,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveLineCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveLineCommand.forCWJM(
      lineMPID: map['lineMPID'],
      isInteractiveLineCreation: map['isInteractiveLineCreation'],
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPRemoveLineCommand.fromJson(String source) {
    return MPRemoveLineCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'lineMPID': lineMPID,
      'isInteractiveLineCreation': isInteractiveLineCreation,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPRemoveLineCommand &&
        other.lineMPID == lineMPID &&
        other.isInteractiveLineCreation == isInteractiveLineCreation &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineMPID,
        isInteractiveLineCreation,
      );
}
