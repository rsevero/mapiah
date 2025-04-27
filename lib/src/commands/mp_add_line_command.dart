part of 'mp_command.dart';

class MPAddLineCommand extends MPCommand {
  late final THLine newLine;
  late final List<THElement> lineChildren;
  late final Offset? lineStartScreenPosition;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addLine;

  MPAddLineCommand.forCWJM({
    required this.newLine,
    required this.lineChildren,
    this.lineStartScreenPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddLineCommand({
    required this.newLine,
    required this.lineChildren,
    this.lineStartScreenPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPAddLineCommand.fromLineMPID({
    required int lineMPID,
    required TH2FileEditController th2FileEditController,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    final THFile thFile = th2FileEditController.thFile;

    newLine = thFile.lineByMPID(lineMPID);
    lineChildren = [];

    final childrenMPIDs = newLine.childrenMPID;

    for (final childMPID in childrenMPIDs) {
      lineChildren.add(thFile.elementByMPID(childMPID));
    }

    lineStartScreenPosition = null;
  }

  @override
  MPCommandType get type => MPCommandType.addLine;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyAddLine(
      newLine: newLine,
      lineChildren: lineChildren,
      lineStartScreenPosition: lineStartScreenPosition,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPRemoveLineCommand oppositeCommand = MPRemoveLineCommand(
      lineMPID: newLine.mpID,
      descriptionType: descriptionType,
      isInteractiveLineCreation: lineStartScreenPosition != null,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    THLine? newLine,
    List<THElement>? lineChildren,
    Offset? lineStartScreenPosition,
    bool makeLineStartScreenPositionNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddLineCommand.forCWJM(
      newLine: newLine ?? this.newLine,
      lineChildren: lineChildren ?? this.lineChildren,
      lineStartScreenPosition: makeLineStartScreenPositionNull
          ? null
          : (lineStartScreenPosition ?? this.lineStartScreenPosition),
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
