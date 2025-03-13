part of 'mp_command.dart';

class MPDeleteElementsCommand extends MPCommand {
  final List<int> mapiahIDs;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.deleteElements;

  MPDeleteElementsCommand.forCWJM({
    required this.mapiahIDs,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPDeleteElementsCommand({
    required this.mapiahIDs,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.deleteElements;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.deleteElements(mapiahIDs);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final List<MPAddElementCommandParams> oppositeParamsList = [];
    final THFile thFile = th2FileEditController.thFile;
    late MPAddElementCommandParams oppositeParams;

    for (final int mapiahID in mapiahIDs) {
      final THElement element = thFile.elementByMapiahID(mapiahID);

      switch (element) {
        case THLine _:
          final List<THElement> lineChildren = [];
          final Set<int> childMapiahIDs = element.childrenMapiahID;

          for (final int childMapiahID in childMapiahIDs) {
            lineChildren
                .add(thFile.elementByMapiahID(childMapiahID).copyWith());
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
    List<int>? mapiahIDs,
    MPCommandDescriptionType? descriptionType,
    bool? isUndoOf,
  }) {
    return MPDeleteElementsCommand.forCWJM(
      mapiahIDs: mapiahIDs ?? this.mapiahIDs,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeleteElementsCommand.fromMap(Map<String, dynamic> map) {
    return MPDeleteElementsCommand.forCWJM(
      mapiahIDs: List<int>.from(map['mapiahIDs']),
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
      'mapiahIDs': mapiahIDs.toList(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPDeleteElementsCommand &&
        const DeepCollectionEquality().equals(other.mapiahIDs, mapiahIDs) &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ mapiahIDs.hashCode;
}
