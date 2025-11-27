part of 'mp_command.dart';

class MPAddPointCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPosCommandMixin {
  final THPoint newPoint;
  late final int pointPositionInParent;

  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addPoint;

        static MPCommandDescriptionType get defaultDescriptionTypeStatic =>
      _defaultDescriptionType;

  MPAddPointCommand.forCWJM({
    required this.newPoint,
    required this.pointPositionInParent,
    required MPCommand? posCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    this.posCommand = posCommand;
  }

  MPAddPointCommand({
    required this.newPoint,
    this.pointPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    required MPCommand? posCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    this.posCommand = posCommand;
  }

  MPAddPointCommand.fromExisting({
    required THPoint existingPoint,
    int? pointPositionInParent,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : newPoint = existingPoint,
       super() {
    final THIsParentMixin parent = existingPoint.parent(thFile);

    this.pointPositionInParent =
        pointPositionInParent ?? parent.getChildPosition(existingPoint);
    posCommand = getAddEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: this.pointPositionInParent,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.addPoint;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.applyAddElement(
      newElement: newPoint,
      childPositionInParent: pointPositionInParent,
    );
    th2FileEditController.elementEditController.afterAddElement(newPoint);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemovePointCommand.fromExisting(
      existingPointMPID: newPoint.mpID,
      thFile: th2FileEditController.thFile,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPAddPointCommand copyWith({
    THPoint? newPoint,
    int? pointPositionInParent,
    MPCommand? posCommand,
    bool makePosCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddPointCommand.forCWJM(
      newPoint: newPoint ?? this.newPoint,
      pointPositionInParent:
          pointPositionInParent ?? this.pointPositionInParent,
      posCommand: makePosCommandNull ? null : (posCommand ?? this.posCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddPointCommand.fromMap(Map<String, dynamic> map) {
    return MPAddPointCommand.forCWJM(
      newPoint: THPoint.fromMap(map['newPoint']),
      pointPositionInParent: map['pointPositionInParent'],
      posCommand: map.containsKey('posCommand') && (map['posCommand'] != null)
          ? MPCommand.fromMap(map['posCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPAddPointCommand.fromJson(String source) {
    return MPAddPointCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newPoint': newPoint.toMap(),
      'posCommand': posCommand?.toMap(),
      'pointPositionInParent': pointPositionInParent,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddPointCommand &&
        other.newPoint == newPoint &&
        other.pointPositionInParent == pointPositionInParent &&
        other.posCommand == posCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newPoint,
    pointPositionInParent,
    posCommand?.hashCode ?? 0,
  );
}
