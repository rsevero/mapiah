part of 'mp_command.dart';

class MPRemoveElementCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPreCommandMixin {
  final int elementMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeElement;

  MPRemoveElementCommand.forCWJM({
    required this.elementMPID,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    this.preCommand = preCommand;
  }

  MPRemoveElementCommand({
    required this.elementMPID,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    this.preCommand = preCommand;
  }

  MPRemoveElementCommand.fromExisting({
    required int existingElementMPID,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : elementMPID = existingElementMPID,
       super() {
    preCommand = getRemoveEmptyLinesAfterCommand(
      elementMPID: existingElementMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.removeElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THElement element = thFile.elementByMPID(elementMPID);
    final THIsParentMixin elementParent = element.parent(thFile);
    final int elementPositionInParent = elementParent.getChildPosition(element);

    _undoRedoInfo = {
      'removedElement': element,
      'removedElementPositionInParent': elementPositionInParent,
    };
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      elementMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPAddElementCommand.forCWJM(
      newElement: _undoRedoInfo!['removedElement'],
      elementPositionInParent: _undoRedoInfo!['removedElementPositionInParent'],
      posCommand: preCommand
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
  MPRemoveElementCommand copyWith({
    int? elementMPID,
    MPCommand? preCommand,
    bool makePreCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveElementCommand.forCWJM(
      elementMPID: elementMPID ?? this.elementMPID,
      preCommand: makePreCommandNull ? null : (preCommand ?? this.preCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveElementCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveElementCommand.forCWJM(
      elementMPID: map['elementMPID'],
      preCommand: map.containsKey('preCommand') && (map['preCommand'] != null)
          ? MPCommand.fromMap(map['preCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveElementCommand.fromJson(String source) {
    return MPRemoveElementCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'elementMPID': elementMPID, 'preCommand': preCommand?.toMap()});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveElementCommand &&
        other.elementMPID == elementMPID &&
        other.preCommand == preCommand;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, elementMPID, preCommand ?? 0);
}
