part of 'mp_command.dart';

class MPAddElementCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPosCommandMixin {
  final THElement newElement;
  late final int elementPositionInParent;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addElement;

  MPAddElementCommand.forCWJM({
    required this.newElement,
    required this.elementPositionInParent,
    required MPCommand? posCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    this.posCommand = posCommand;
  }

  MPAddElementCommand({
    required this.newElement,
    this.elementPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    required MPCommand? posCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    this.posCommand = posCommand;
  }

  MPAddElementCommand.fromExisting({
    required THElement existingElement,
    int? elementPositionInParent,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : newElement = existingElement,

       super() {
    final THIsParentMixin parent = existingElement.parent(thFile);

    elementPositionInParent =
        elementPositionInParent ?? parent.getChildPosition(existingElement);
    posCommand = getAddEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: elementPositionInParent,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.addElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    elementEditController.applyAddElement(
      newElement: newElement,
      childPositionInParent: elementPositionInParent,
    );
    elementEditController.afterAddElement(newElement);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveElementCommand(
      elementMPID: newElement.mpID,
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
  MPAddElementCommand copyWith({
    THElement? newElement,
    int? elementPositionInParent,
    MPCommand? posCommand,
    bool makePosCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddElementCommand.forCWJM(
      newElement: newElement ?? this.newElement,
      elementPositionInParent:
          elementPositionInParent ?? this.elementPositionInParent,
      posCommand: makePosCommandNull ? null : (posCommand ?? this.posCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddElementCommand.fromMap(Map<String, dynamic> map) {
    return MPAddElementCommand.forCWJM(
      newElement: THElement.fromMap(map['newElement']),
      elementPositionInParent: map['elementPositionInParent'],
      posCommand: map.containsKey('posCommand') && (map['posCommand'] != null)
          ? MPCommand.fromMap(map['posCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPAddElementCommand.fromJson(String source) {
    return MPAddElementCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newElement': newElement.toMap(),
      'elementPositionInParent': elementPositionInParent,
      'posCommand': posCommand?.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddElementCommand &&
        other.newElement == newElement &&
        other.elementPositionInParent == elementPositionInParent &&
        other.posCommand == posCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newElement,
    elementPositionInParent,
    posCommand ?? 0,
  );
}
