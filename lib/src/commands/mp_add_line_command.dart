part of 'mp_command.dart';

class MPAddLineCommand extends MPCommand {
  final THLine newLine;
  final int linePositionInParent;
  final List<THElement> lineChildren;
  final Offset? lineStartScreenPosition;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addLine;

  MPAddLineCommand.forCWJM({
    required this.newLine,
    required this.linePositionInParent,
    required this.lineChildren,
    this.lineStartScreenPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddLineCommand({
    required this.newLine,
    this.linePositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    required this.lineChildren,
    this.lineStartScreenPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPAddLineCommand.fromExisting({
    required THLine existingLine,
    int? linePositionInParent,
    this.lineStartScreenPosition,
    required TH2FileEditController th2FileEditController,
    super.descriptionType = _defaultDescriptionType,
  }) : newLine = existingLine,
       linePositionInParent =
           linePositionInParent ??
           existingLine
               .parent(th2FileEditController.thFile)
               .getChildPosition(existingLine),
       lineChildren = existingLine
           .getChildren(th2FileEditController.thFile)
           .toList(),
       super();

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
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    elementEditController.applyAddLine(
      newLine: newLine,
      linePositionInParent: linePositionInParent,
      lineChildren: lineChildren,
      lineStartScreenPosition: lineStartScreenPosition,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveLineCommand(
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
  MPAddLineCommand copyWith({
    THLine? newLine,
    int? linePositionInParent,
    List<THElement>? lineChildren,
    Offset? lineStartScreenPosition,
    bool makeLineStartScreenPositionNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddLineCommand.forCWJM(
      newLine: newLine ?? this.newLine,
      linePositionInParent: linePositionInParent ?? this.linePositionInParent,
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
      linePositionInParent: map['linePositionInParent'],
      lineChildren: List<THElement>.from(
        map['lineChildren'].map((x) => THElement.fromMap(x)),
      ),
      lineStartScreenPosition: map.containsKey('lineStartScreenPosition')
          ? Offset(
              map['lineStartScreenPosition']['x'],
              map['lineStartScreenPosition']['y'],
            )
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
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
      'linePositionInParent': linePositionInParent,
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
    if (!super.equalsBase(other)) return false;

    return other is MPAddLineCommand &&
        other.newLine == newLine &&
        other.linePositionInParent == linePositionInParent &&
        other.lineStartScreenPosition == lineStartScreenPosition &&
        const DeepCollectionEquality().equals(other.lineChildren, lineChildren);
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newLine,
    linePositionInParent,
    lineStartScreenPosition,
    Object.hashAll(lineChildren),
  );
}
