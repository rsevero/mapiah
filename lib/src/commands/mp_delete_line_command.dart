part of "mp_command.dart";

class MPDeleteLineCommand extends MPCommand {
  final int lineMapiahID;

  MPDeleteLineCommand.forCWJM({
    required this.lineMapiahID,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.deleteLine,
  }) : super.forCWJM();

  MPDeleteLineCommand({
    required this.lineMapiahID,
    super.descriptionType = MPCommandDescriptionType.deleteLine,
  }) : super();

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THLine line =
        th2FileEditController.thFile.elementByMapiahID(lineMapiahID) as THLine;
    final Set<int> lineChildren = line.childrenMapiahID.toSet();

    for (final int childMapiahID in lineChildren) {
      th2FileEditController.deleteElementByMapiahID(childMapiahID);
    }

    th2FileEditController.deleteElement(line);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
      TH2FileEditController th2FileEditController) {
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
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      descriptionType: descriptionType,
      map: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? lineMapiahID,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPDeleteLineCommand.forCWJM(
      lineMapiahID: lineMapiahID ?? this.lineMapiahID,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeleteLineCommand.fromMap(Map<String, dynamic> map) {
    return MPDeleteLineCommand.forCWJM(
      lineMapiahID: map['lineMapiahID'],
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
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPDeleteLineCommand &&
        other.lineMapiahID == lineMapiahID &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ lineMapiahID.hashCode;

  @override
  MPCommandType get type => MPCommandType.deleteLine;
}
