part of 'mp_command.dart';

class MPAddLineCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPosCommandMixin {
  final THLine newLine;
  late final int linePositionInParent;
  final List<THElement> lineChildren;
  final Offset? lineStartScreenPosition;
  late final MPAddAreaBorderTHIDCommand? addAreaTHIDCommand;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.addLine;

  MPAddLineCommand.forCWJM({
    required this.newLine,
    required this.linePositionInParent,
    required this.lineChildren,
    this.lineStartScreenPosition,
    this.addAreaTHIDCommand,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    this.posCommand = posCommand;
  }

  MPAddLineCommand({
    required this.newLine,
    this.linePositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    required this.lineChildren,
    this.lineStartScreenPosition,
    this.addAreaTHIDCommand,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super() {
    this.posCommand = posCommand;
  }

  @override
  MPCommandType get type => MPCommandType.addLine;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    elementEditController.executeAddLine(
      newLine: newLine,
      linePositionInParent: linePositionInParent,
      lineChildren: lineChildren,
      lineStartScreenPosition: lineStartScreenPosition,
    );

    if (addAreaTHIDCommand != null) {
      addAreaTHIDCommand!.execute(th2FileEditController);
    }
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveLineCommand.fromExisting(
      existingLineMPID: newLine.mpID,
      isInteractiveLineCreation: lineStartScreenPosition != null,
      thFile: th2FileEditController.thFile,
      descriptionType: descriptionType,
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
    MPAddAreaBorderTHIDCommand? addAreaTHIDCommand,
    bool makeAddAreaTHIDCommandNull = false,
    MPCommand? posCommand,
    bool makePosCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddLineCommand.forCWJM(
      newLine: newLine ?? this.newLine,
      linePositionInParent: linePositionInParent ?? this.linePositionInParent,
      lineChildren: lineChildren ?? this.lineChildren,
      lineStartScreenPosition: makeLineStartScreenPositionNull
          ? null
          : (lineStartScreenPosition ?? this.lineStartScreenPosition),
      addAreaTHIDCommand: makeAddAreaTHIDCommandNull
          ? null
          : (addAreaTHIDCommand ?? this.addAreaTHIDCommand),
      posCommand: makePosCommandNull ? null : (posCommand ?? this.posCommand),
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
      addAreaTHIDCommand: map.containsKey('addAreaTHIDCommand')
          ? MPAddAreaBorderTHIDCommand.fromMap(map['addAreaTHIDCommand'])
          : null,
      posCommand: (map.containsKey('posCommand') && (map['posCommand'] != null))
          ? MPCommand.fromMap(map['posCommand'])
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
      if (addAreaTHIDCommand != null)
        'addAreaTHIDCommand': addAreaTHIDCommand!.toMap(),
      'posCommand': posCommand?.toMap(),
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
        other.addAreaTHIDCommand == addAreaTHIDCommand &&
        other.posCommand == posCommand &&
        const DeepCollectionEquality().equals(other.lineChildren, lineChildren);
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newLine,
    linePositionInParent,
    lineStartScreenPosition,
    addAreaTHIDCommand ?? 0,
    posCommand?.hashCode ?? 0,
    DeepCollectionEquality().hash(lineChildren),
  );
}
