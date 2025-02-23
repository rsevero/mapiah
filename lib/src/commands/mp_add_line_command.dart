part of 'mp_command.dart';

class MPAddLineCommand extends MPCommand {
  final THLine newLine;
  final List<THElement> lineChildren;

  MPAddLineCommand.forCWJM({
    required this.newLine,
    required this.lineChildren,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.addLine,
  }) : super.forCWJM();

  MPAddLineCommand({
    required this.newLine,
    required this.lineChildren,
    super.descriptionType = MPCommandDescriptionType.addLine,
  }) : super();

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.addElementWithParentMapiahIDWithoutSelectableElement(
      newElement: newLine,
      parentMapiahID: th2FileEditController.activeScrapID,
    );

    for (final THElement child in lineChildren) {
      th2FileEditController.addElement(newElement: child);
    }

    th2FileEditController.addSelectableElement(newLine);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
      TH2FileEditController th2FileEditController) {
    final MPDeleteLineCommand oppositeCommand = MPDeleteLineCommand(
      lineMapiahID: newLine.mapiahID,
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
    THLine? newLine,
    List<THElement>? lineChildren,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPAddLineCommand.forCWJM(
      newLine: newLine ?? this.newLine,
      lineChildren: lineChildren ?? this.lineChildren,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddLineCommand.fromMap(Map<String, dynamic> map) {
    return MPAddLineCommand.forCWJM(
      newLine: THLine.fromMap(map['newLine']),
      lineChildren: List<THElement>.from(
        map['lineChildren'].map(
          (x) => THElement.fromMap(x),
        ),
      ),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPAddLineCommand.fromJson(String source) {
    return MPAddLineCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newLine': newLine.toMap(),
      'lineChildren': lineChildren.map((x) => x.toMap()).toList(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddLineCommand &&
        other.newLine == newLine &&
        const DeepCollectionEquality()
            .equals(other.lineChildren, lineChildren) &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        newLine,
        Object.hashAll(lineChildren),
      );

  @override
  MPCommandType get type => MPCommandType.addLine;
}
