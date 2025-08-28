part of 'mp_command.dart';

class MPAddPointCommand extends MPCommand {
  final THPoint newPoint;
  final int pointPositionInParent;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addPoint;

  MPAddPointCommand.forCWJM({
    required this.newPoint,
    required this.pointPositionInParent,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddPointCommand({
    required this.newPoint,
    this.pointPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPAddPointCommand.fromExisting({
    required THPoint existingPoint,
    int? pointPositionInParent,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : newPoint = existingPoint,
       pointPositionInParent =
           pointPositionInParent ??
           existingPoint.parent(thFile).getChildPosition(existingPoint),
       super();

  @override
  MPCommandType get type => MPCommandType.addPoint;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
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
    final MPCommand oppositeCommand = MPRemovePointCommand(
      pointMPID: newPoint.mpID,
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
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddPointCommand.forCWJM(
      newPoint: newPoint ?? this.newPoint,
      pointPositionInParent:
          pointPositionInParent ?? this.pointPositionInParent,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddPointCommand.fromMap(Map<String, dynamic> map) {
    return MPAddPointCommand.forCWJM(
      newPoint: THPoint.fromMap(map['newPoint']),
      pointPositionInParent: map['pointPositionInParent'],
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
        other.pointPositionInParent == pointPositionInParent;
  }

  @override
  int get hashCode =>
      Object.hashAll([super.hashCode, newPoint, pointPositionInParent]);
}
