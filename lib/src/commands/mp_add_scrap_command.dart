part of 'mp_command.dart';

class MPAddScrapCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPosCommandMixin, MPScrapChildrenMixin {
  final THScrap newScrap;
  late final int scrapPositionInParent;

  /// The addScrapChildrenCommand should have a THEndScrap element as the last
  /// child added.
  late final MPCommand addScrapChildrenCommand;

  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addScrap;

        static MPCommandDescriptionType get defaultDescriptionTypeStatic =>
      _defaultDescriptionType;

  MPAddScrapCommand.forCWJM({
    required this.newScrap,
    required this.scrapPositionInParent,
    required this.addScrapChildrenCommand,
    required MPCommand? posCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    this.posCommand = posCommand;
  }

  MPAddScrapCommand({
    required this.newScrap,
    this.scrapPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    required List<THElement> scrapChildren,
    required THFile thFile,
    required MPCommand? posCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    this.posCommand = posCommand;

    addScrapChildrenCommand = MPCommandFactory.addElements(
      elements: scrapChildren,
      thFile: thFile,
    );
  }

  MPAddScrapCommand.fromExisting({
    required THScrap existingScrap,
    int? scrapPositionInParent,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : newScrap = existingScrap,
       super() {
    final THIsParentMixin parent = existingScrap.parent(thFile);

    this.scrapPositionInParent =
        scrapPositionInParent ?? parent.getChildPosition(existingScrap);
    addScrapChildrenCommand = getAddScrapChildrenCommand(
      scrap: existingScrap,
      thFile: thFile,
    );
    posCommand = getAddEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: this.scrapPositionInParent,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.addScrap;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    elementEditController.applyAddScrap(
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
    final MPCommand oppositeCommand = MPRemoveScrapCommand.fromExisting(
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
