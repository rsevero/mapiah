part of 'mp_command.dart';

class MPAddScrapCommand extends MPCommand {
  final THScrap newScrap;
  final int scrapPositionInParent;
  late final List<Object> scrapChildren;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addScrap;

  MPAddScrapCommand.forCWJM({
    required this.newScrap,
    required this.scrapPositionInParent,
    required this.scrapChildren,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddScrapCommand({
    required this.newScrap,
    this.scrapPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    required this.scrapChildren,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPAddScrapCommand.fromExisting({
    required THScrap existingScrap,
    required TH2FileEditController th2FileEditController,
    super.descriptionType = _defaultDescriptionType,
  }) : newScrap = existingScrap,
       scrapPositionInParent = existingScrap
           .parent(th2FileEditController.thFile)
           .getChildPosition(existingScrap),
       super() {
    final THFile thFile = th2FileEditController.thFile;
    final List<THElement> scrapChildrenAsElements = existingScrap
        .getChildren(thFile)
        .toList();

    scrapChildren = [];

    for (final THElement child in scrapChildrenAsElements) {
      switch (child) {
        case THLine _:
          scrapChildren.add(
            MPAddLineCommand.fromExisting(
              existingLine: child,
              linePositionInParent: mpAddChildAtEndOfParentChildrenList,
              thFile: thFile,
            ),
          );
        case THArea _:
          scrapChildren.add(
            MPAddAreaCommand.fromExisting(
              existingArea: child,
              areaPositionInParent: mpAddChildAtEndOfParentChildrenList,
              th2FileEditController: th2FileEditController,
            ),
          );
        default:
          scrapChildren.add(child);
      }
    }
  }

  @override
  MPCommandType get type => MPCommandType.addScrap;

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

    elementEditController.applyAddScrap(
      newScrap: newScrap,
      scrapPositionAtParent: scrapPositionInParent,
      scrapChildren: scrapChildren,
    );
    elementEditController.afterAddScrap(newScrap);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveScrapCommand(
      scrapMPID: newScrap.mpID,
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
    List<Object>? scrapChildren,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddScrapCommand.forCWJM(
      newScrap: newScrap ?? this.newScrap,
      scrapPositionInParent:
          scrapPositionInParent ?? this.scrapPositionInParent,
      scrapChildren: scrapChildren ?? this.scrapChildren,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddScrapCommand.fromMap(Map<String, dynamic> map) {
    final List<Object> parsedScrapChildren = [];
    final dynamic rawChildren = map['scrapChildren'];

    if (rawChildren is List) {
      for (final dynamic rawChild in rawChildren) {
        if (rawChild is Map) {
          final childMap = Map<String, dynamic>.from(rawChild);

          if (childMap.containsKey('commandType')) {
            parsedScrapChildren.add(MPCommand.fromMap(childMap));
          } else if (childMap.containsKey('elementType')) {
            parsedScrapChildren.add(THElement.fromMap(childMap));
          } else {
            throw ArgumentError(
              "At MPAddScrapCommand.fromMap: unrecognized scrapChildren entry (missing 'commandType' / 'elementType'): $childMap",
            );
          }
        } else {
          throw ArgumentError(
            "At MPAddScrapCommand.fromMap: invalid scrapChildren entry type (expected Map): $rawChild",
          );
        }
      }
    }

    return MPAddScrapCommand.forCWJM(
      newScrap: THScrap.fromMap(map['newScrap']),
      scrapPositionInParent: map['scrapPositionInParent'],
      scrapChildren: parsedScrapChildren,
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
      'scrapChildren': scrapChildren.map((obj) {
        if (obj is MPCommand) return obj.toMap();
        if (obj is THElement) return obj.toMap();
        throw ArgumentError(
          "At MPAddScrapCommand.toMap: unsupported scrapChildren object: $obj",
        );
      }).toList(),
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
        const DeepCollectionEquality().equals(
          other.scrapChildren,
          scrapChildren,
        );
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newScrap,
    scrapPositionInParent,
    DeepCollectionEquality().hash(scrapChildren),
  );
}
