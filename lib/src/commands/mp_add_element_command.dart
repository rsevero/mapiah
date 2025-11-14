part of 'mp_command.dart';

class MPAddElementCommand extends MPCommand {
  final THElement newElement;
  final int elementPositionInParent;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addElement;

  MPAddElementCommand.forCWJM({
    required this.newElement,
    required this.elementPositionInParent,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddElementCommand({
    required this.newElement,
    this.elementPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPAddElementCommand.fromExisting({
    required THElement existingElement,
    int? elementPositionInParent,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : newElement = existingElement,
       elementPositionInParent =
           elementPositionInParent ??
           existingElement.parent(thFile).getChildPosition(existingElement),
       super();

  @override
  MPCommandType get type => MPCommandType.addElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyAddElement(
      newElement: newElement,
      childPositionInParent: elementPositionInParent,
    );
    th2FileEditController.elementEditController.afterAddElement(newElement);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveElementCommand(
      elementMPID: newElement.mpID,
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
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddElementCommand.forCWJM(
      newElement: newElement ?? this.newElement,
      elementPositionInParent:
          elementPositionInParent ?? this.elementPositionInParent,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddElementCommand.fromMap(Map<String, dynamic> map) {
    return MPAddElementCommand.forCWJM(
      newElement: THElement.fromMap(map['newElement']),
      elementPositionInParent: map['elementPositionInParent'],
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
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddElementCommand &&
        other.newElement == newElement &&
        other.elementPositionInParent == elementPositionInParent;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, newElement, elementPositionInParent);
}
