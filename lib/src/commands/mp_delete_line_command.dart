part of "mp_command.dart";

class MPDeleteLineCommand extends MPCommand {
  final int lineMapiahID;
  final bool isInteractiveLineCreation;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.deleteLine;

  MPDeleteLineCommand.forCWJM({
    required this.lineMapiahID,
    required this.isInteractiveLineCreation,
    required super.oppositeCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPDeleteLineCommand({
    required this.lineMapiahID,
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
    th2FileEditController.elementEditController.deleteLine(lineMapiahID);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THFile thFile = th2FileEditController.thFile;
    final THLine originalLine =
        thFile.elementByMapiahID(lineMapiahID) as THLine;
    final List<THElement> lineChildren = [];
    final Set<int> lineChildrenMapiahIDs = originalLine.childrenMapiahID;

    for (final int childMapiahID in lineChildrenMapiahIDs) {
      final THElement childElement = thFile.elementByMapiahID(childMapiahID);

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
      map: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? lineMapiahID,
    MPUndoRedoCommand? oppositeCommand,
    bool makeOppositeCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPDeleteLineCommand.forCWJM(
      lineMapiahID: lineMapiahID ?? this.lineMapiahID,
      isInteractiveLineCreation: isInteractiveLineCreation,
      oppositeCommand: makeOppositeCommandNull
          ? null
          : (oppositeCommand ?? this.oppositeCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeleteLineCommand.fromMap(Map<String, dynamic> map) {
    return MPDeleteLineCommand.forCWJM(
      lineMapiahID: map['lineMapiahID'],
      isInteractiveLineCreation: map['isInteractiveLineCreation'],
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
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
      'lineMapiahID': lineMapiahID,
      'isInteractiveLineCreation': isInteractiveLineCreation,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPDeleteLineCommand &&
        other.lineMapiahID == lineMapiahID &&
        other.isInteractiveLineCreation == isInteractiveLineCreation &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineMapiahID,
        isInteractiveLineCreation,
      );
}
