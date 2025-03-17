part of "mp_command.dart";

class MPDeleteLineCommand extends MPCommand {
  final int lineMPID;
  final bool isInteractiveLineCreation;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.deleteLine;

  MPDeleteLineCommand.forCWJM({
    required this.lineMPID,
    required this.isInteractiveLineCreation,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPDeleteLineCommand({
    required this.lineMPID,
    required this.isInteractiveLineCreation,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.deleteLine;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.deleteLine(lineMPID);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THFile thFile = th2FileEditController.thFile;
    final THLine originalLine = thFile.elementByMPID(lineMPID) as THLine;
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
      commandType: oppositeCommand.type,
      mapUndo: oppositeCommand.toMap(),
      mapRedo: toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? lineMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPDeleteLineCommand.forCWJM(
      lineMPID: lineMPID ?? this.lineMPID,
      isInteractiveLineCreation: isInteractiveLineCreation,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeleteLineCommand.fromMap(Map<String, dynamic> map) {
    return MPDeleteLineCommand.forCWJM(
      lineMPID: map['lineMPID'],
      isInteractiveLineCreation: map['isInteractiveLineCreation'],
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPDeleteLineCommand.fromJson(String source) {
    return MPDeleteLineCommand.fromMap(jsonDecode(source));
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

    return other is MPDeleteLineCommand &&
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
