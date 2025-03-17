part of 'mp_command.dart';

class MPDeleteElementsCommand extends MPCommand {
  final List<int> mpIDs;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.deleteElements;

  MPDeleteElementsCommand.forCWJM({
    required this.mpIDs,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPDeleteElementsCommand({
    required this.mpIDs,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.deleteElements;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.deleteElements(mpIDs);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final List<MPAddElementCommandParams> oppositeParamsList = [];
    final THFile thFile = th2FileEditController.thFile;
    late MPAddElementCommandParams oppositeParams;

    for (final int mpID in mpIDs) {
      final THElement element = thFile.elementByMPID(mpID);

      switch (element) {
        case THLine _:
          final List<THElement> lineChildren = [];
          final Set<int> childMPIDs = element.childrenMPID;

          for (final int childMPID in childMPIDs) {
            lineChildren.add(thFile.elementByMPID(childMPID).copyWith());
          }

          oppositeParams = MPAddLineCommandParams(
            line: element.copyWith(),
            lineChildren: lineChildren,
          );
        case THPoint _:
          oppositeParams = MPAddPointCommandParams(point: element.copyWith());
      }
      oppositeParamsList.add(oppositeParams);
    }

    final MPAddElementsCommand oppositeCommand = MPAddElementsCommand(
      createParams: oppositeParamsList,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      mapUndo: oppositeCommand.toMap(),
      mapRedo: toMap(),
    );
  }

  @override
  MPCommand copyWith({
    List<int>? mpIDs,
    MPCommandDescriptionType? descriptionType,
    bool? isUndoOf,
  }) {
    return MPDeleteElementsCommand.forCWJM(
      mpIDs: mpIDs ?? this.mpIDs,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeleteElementsCommand.fromMap(Map<String, dynamic> map) {
    return MPDeleteElementsCommand.forCWJM(
      mpIDs: List<int>.from(map['mpIDs']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPDeleteElementsCommand.fromJson(String source) {
    return MPDeleteElementsCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'mpIDs': mpIDs.toList(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPDeleteElementsCommand &&
        const DeepCollectionEquality().equals(other.mpIDs, mpIDs) &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ mpIDs.hashCode;
}
