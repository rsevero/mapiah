part of 'mp_command.dart';

class MPAddEmptyLineCommand extends MPCommand {
  final THEmptyLine newEmptyLine;
  final int emptyLinePositionInParent;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.addEmptyLine;

  MPAddEmptyLineCommand.forCWJM({
    required this.newEmptyLine,
    required this.emptyLinePositionInParent,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  MPAddEmptyLineCommand({
    required this.newEmptyLine,
    this.emptyLinePositionInParent =
        mpAddChildAtEndMinusOneOfParentChildrenList,
    super.descriptionType = defaultDescriptionType,
  }) : super();

  MPAddEmptyLineCommand.fromExisting({
    required THEmptyLine existingEmptyLine,
    int? emptyLinePositionInParent,
    required THFile thFile,
    super.descriptionType = defaultDescriptionType,
  }) : newEmptyLine = existingEmptyLine,
       emptyLinePositionInParent =
           emptyLinePositionInParent ??
           existingEmptyLine.parent(thFile).getChildPosition(existingEmptyLine),
       super();

  @override
  MPCommandType get type => MPCommandType.addEmptyLine;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    elementEditController.executeAddElement(
      newElement: newEmptyLine,
      childPositionInParent: emptyLinePositionInParent,
    );
    elementEditController.afterAddElement(newEmptyLine);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveEmptyLineCommand(
      emptyLineMPID: newEmptyLine.mpID,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPAddEmptyLineCommand copyWith({
    THEmptyLine? newEmptyLine,
    int? emptyLinePositionInParent,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddEmptyLineCommand.forCWJM(
      newEmptyLine: newEmptyLine ?? this.newEmptyLine,
      emptyLinePositionInParent:
          emptyLinePositionInParent ?? this.emptyLinePositionInParent,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddEmptyLineCommand.fromMap(Map<String, dynamic> map) {
    return MPAddEmptyLineCommand.forCWJM(
      newEmptyLine: THEmptyLine.fromMap(map['newEmptyLine']),
      emptyLinePositionInParent: map['emptyLinePositionInParent'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPAddEmptyLineCommand.fromJson(String source) {
    return MPAddEmptyLineCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newEmptyLine': newEmptyLine.toMap(),
      'emptyLinePositionInParent': emptyLinePositionInParent,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddEmptyLineCommand &&
        other.newEmptyLine == newEmptyLine &&
        other.emptyLinePositionInParent == emptyLinePositionInParent;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, newEmptyLine, emptyLinePositionInParent);
}
