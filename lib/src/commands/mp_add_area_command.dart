part of 'mp_command.dart';

class MPAddAreaCommand extends MPCommand {
  final THArea newArea;
  final int areaPositionInParent;
  final List<THElement> areaChildren;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addArea;

  MPAddAreaCommand.forCWJM({
    required this.newArea,
    required this.areaPositionInParent,
    required this.areaChildren,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddAreaCommand.fromExisting({
    required THArea existingArea,
    int? areaPositionInParent,
    required TH2FileEditController th2FileEditController,
    super.descriptionType = _defaultDescriptionType,
  }) : newArea = existingArea,
       areaPositionInParent =
           areaPositionInParent ??
           existingArea
               .parent(th2FileEditController.thFile)
               .getChildPosition(existingArea),
       areaChildren = existingArea
           .getChildren(th2FileEditController.thFile)
           .toList(),
       super();

  @override
  MPCommandType get type => MPCommandType.addArea;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  bool get hasNewExecuteMethod => true;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    // Nothing to prepare for this command.
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    elementEditController.applyAddArea(
      newArea: newArea,
      areaChildren: areaChildren,
      areaPositionInParent: areaPositionInParent,
    );
    elementEditController.afterAddArea(newArea);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveAreaCommand(
      areaMPID: newArea.mpID,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPAddAreaCommand copyWith({
    THArea? newArea,
    int? areaPositionInParent,
    List<THElement>? areaChildren,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddAreaCommand.forCWJM(
      newArea: newArea ?? this.newArea,
      areaPositionInParent: areaPositionInParent ?? this.areaPositionInParent,
      areaChildren: areaChildren ?? this.areaChildren,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddAreaCommand.fromMap(Map<String, dynamic> map) {
    return MPAddAreaCommand.forCWJM(
      newArea: THArea.fromMap(map['newArea']),
      areaPositionInParent: map['areaPositionInParent'],
      areaChildren: List<THElement>.from(
        map['areaChildren'].map((x) => THElement.fromMap(x)),
      ),
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPAddAreaCommand.fromJson(String source) {
    return MPAddAreaCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newArea': newArea.toMap(),
      'areaPositionInParent': areaPositionInParent,
      'areaChildren': areaChildren.map((e) => e.toMap()).toList(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddAreaCommand &&
        other.newArea == newArea &&
        other.areaPositionInParent == areaPositionInParent &&
        const DeepCollectionEquality().equals(other.areaChildren, areaChildren);
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newArea,
    areaPositionInParent,
    DeepCollectionEquality().hash(areaChildren),
  );
}
