part of 'mp_command.dart';

class MPAddLineCommand extends MPCommand {
  final THLine newLine;
  final List<THElement> lineChildren;
  final Offset? lineStartScreenPosition;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addLine;

  MPAddLineCommand.forCWJM({
    required this.newLine,
    required this.lineChildren,
    this.lineStartScreenPosition,
    required super.oppositeCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddLineCommand({
    required this.newLine,
    required this.lineChildren,
    this.lineStartScreenPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.addLine;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.addElementController.addLine(
      newLine: newLine,
      lineChildren: lineChildren,
      lineStartScreenPosition: lineStartScreenPosition,
    );
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPDeleteLineCommand oppositeCommand = MPDeleteLineCommand(
      lineMapiahID: newLine.mapiahID,
      descriptionType: descriptionType,
      isInteractiveLineCreation: lineStartScreenPosition != null,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      map: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    THLine? newLine,
    List<THElement>? lineChildren,
    Offset? lineStartScreenPosition,
    bool makeLineStartScreenPositionNull = false,
    MPUndoRedoCommand? oppositeCommand,
    bool makeOppositeCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddLineCommand.forCWJM(
      newLine: newLine ?? this.newLine,
      lineChildren: lineChildren ?? this.lineChildren,
      lineStartScreenPosition: makeLineStartScreenPositionNull
          ? null
          : (lineStartScreenPosition ?? this.lineStartScreenPosition),
      oppositeCommand: makeOppositeCommandNull
          ? null
          : (oppositeCommand ?? this.oppositeCommand),
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
      lineStartScreenPosition: map.containsKey('lineStartScreenPosition')
          ? Offset(
              map['lineStartScreenPosition']['x'],
              map['lineStartScreenPosition']['y'],
            )
          : null,
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

    if (lineStartScreenPosition != null) {
      map.addAll({
        'lineStartScreenPosition': {
          'x': lineStartScreenPosition!.dx,
          'y': lineStartScreenPosition!.dy,
        },
      });
    }

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddLineCommand &&
        other.newLine == newLine &&
        const DeepCollectionEquality()
            .equals(other.lineChildren, lineChildren) &&
        other.lineStartScreenPosition == lineStartScreenPosition &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        newLine,
        Object.hashAll(lineChildren),
        lineStartScreenPosition,
      );
}
