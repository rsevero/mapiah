part of 'mp_command.dart';

class MPAddScrapCommand extends MPCommand with MPPosCommandMixin {
  final THScrap newScrap;
  late final int scrapPositionInParent;

  /// The addScrapChildrenCommand should have a THEndScrap element as the last
  /// child added.
  late final MPCommand addScrapChildrenCommand;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.addScrap;

  MPAddScrapCommand.forCWJM({
    required this.newScrap,
    required this.scrapPositionInParent,
    required this.addScrapChildrenCommand,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    this.posCommand = posCommand;
  }

  MPAddScrapCommand({
    required this.newScrap,
    this.scrapPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    required List<THElement> scrapChildren,
    required THFile thFile,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super() {
    this.posCommand = posCommand;

    addScrapChildrenCommand = MPCommandFactory.addElements(
      elements: scrapChildren,
      thFile: thFile,
    );
  }

  @override
  MPCommandType get type => MPCommandType.addScrap;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    elementEditController.executeAddScrap(
      newScrap: newScrap,
      scrapPositionAtParent: scrapPositionInParent,
    );
    addScrapChildrenCommand.execute(th2FileEditController);
    elementEditController.afterAddScrap(newScrap);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPCommandFactory.removeScrapFromExisting(
      existingScrapMPID: newScrap.mpID,
      thFile: th2FileEditController.thFile,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPAddScrapCommand copyWith({
    THScrap? newScrap,
    int? scrapPositionInParent,
    MPCommand? addScrapChildrenCommand,
    MPCommand? posCommand,
    bool makePosCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddScrapCommand.forCWJM(
      newScrap: newScrap ?? this.newScrap,
      scrapPositionInParent:
          scrapPositionInParent ?? this.scrapPositionInParent,
      addScrapChildrenCommand:
          addScrapChildrenCommand ?? this.addScrapChildrenCommand,
      posCommand: makePosCommandNull ? null : (posCommand ?? this.posCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddScrapCommand.fromMap(Map<String, dynamic> map) {
    return MPAddScrapCommand.forCWJM(
      newScrap: THScrap.fromMap(map['newScrap']),
      scrapPositionInParent: map['scrapPositionInParent'],
      addScrapChildrenCommand: MPCommand.fromMap(
        map['addScrapChildrenCommand'],
      ),
      posCommand: map.containsKey('posCommand') && (map['posCommand'] != null)
          ? MPCommand.fromMap(map['posCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPAddScrapCommand.fromJson(String source) {
    return MPAddScrapCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'newScrap': newScrap.toMap(),
      'scrapPositionInParent': scrapPositionInParent,
      'addScrapChildrenCommand': addScrapChildrenCommand.toMap(),
      'posCommand': posCommand?.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddScrapCommand &&
        other.newScrap == newScrap &&
        other.scrapPositionInParent == scrapPositionInParent &&
        other.posCommand == posCommand &&
        other.addScrapChildrenCommand == addScrapChildrenCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newScrap,
    scrapPositionInParent,
    addScrapChildrenCommand,
    posCommand?.hashCode ?? 0,
  );
}
