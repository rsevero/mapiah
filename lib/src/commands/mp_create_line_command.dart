part of 'mp_command.dart';

class MPCreateLineCommand extends MPCommand {
  final THLine newLine;
  final List<THElement> lineChildren;

  MPCreateLineCommand.forCWJM({
    required this.newLine,
    required this.lineChildren,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.deleteLine,
  }) : super.forCWJM();

  MPCreateLineCommand({
    required this.newLine,
    required this.lineChildren,
    super.descriptionType = MPCommandDescriptionType.deleteLine,
  }) : super();

  @override
  void _actualExecute(TH2FileEditStore th2FileEditStore) {
    th2FileEditStore.addElementWithParentMapiahIDWithoutSelectableElement(
      newElement: newLine,
      parentMapiahID: th2FileEditStore.activeScrapID,
    );

    final int newLineMapiahID = newLine.mapiahID;

    for (final THElement child in lineChildren) {
      th2FileEditStore.addElement(
        newElement: child,
        parentMapiahID: newLineMapiahID,
      );
    }
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(TH2FileEditStore th2FileEditStore) {
    final MPDeleteLineCommand oppositeCommand = MPDeleteLineCommand(
      lineMapiahID: newLine.mapiahID,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        descriptionType: descriptionType,
        map: oppositeCommand.toMap());
  }

  @override
  MPCommand copyWith({
    THLine? newLine,
    List<THElement>? lineChildren,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPCreateLineCommand.forCWJM(
      newLine: newLine ?? this.newLine,
      lineChildren: lineChildren ?? this.lineChildren,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPCreateLineCommand.fromMap(Map<String, dynamic> map) {
    return MPCreateLineCommand.forCWJM(
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

  factory MPCreateLineCommand.fromJson(String source) {
    return MPCreateLineCommand.fromMap(jsonDecode(source));
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

    return other is MPCreateLineCommand &&
        other.newLine == newLine &&
        other.lineChildren == lineChildren &&
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
  MPCommandType get type => MPCommandType.createLine;
}
