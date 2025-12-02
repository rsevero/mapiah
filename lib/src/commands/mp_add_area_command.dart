part of 'mp_command.dart';

class MPAddAreaCommand extends MPCommand with MPPosCommandMixin {
  final THArea newArea;
  late final int areaPositionInParent;
  final List<THElement> areaChildren;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.addArea;

  MPAddAreaCommand.forCWJM({
    required this.newArea,
    required this.areaPositionInParent,
    required this.areaChildren,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    this.posCommand = posCommand;
  }

  @override
  MPCommandType get type => MPCommandType.addArea;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    elementEditController.executeAddArea(
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
      preCommand: posCommand
          ?.getUndoRedoCommand(th2FileEditController)
          .undoCommand,
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
    MPCommand? posCommand,
    bool makePosCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddAreaCommand.forCWJM(
      newArea: newArea ?? this.newArea,
      areaPositionInParent: areaPositionInParent ?? this.areaPositionInParent,
      areaChildren: areaChildren ?? this.areaChildren,
      posCommand: makePosCommandNull ? null : (posCommand ?? this.posCommand),
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
      posCommand: (map.containsKey('posCommand') && (map['posCommand'] != null))
          ? MPCommand.fromMap(map['posCommand'])
          : null,
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
      'posCommand': posCommand?.toMap(),
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
        const DeepCollectionEquality().equals(
          other.areaChildren,
          areaChildren,
        ) &&
        other.posCommand == posCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newArea,
    areaPositionInParent,
    DeepCollectionEquality().hash(areaChildren),
    posCommand?.hashCode ?? 0,
  );
}
