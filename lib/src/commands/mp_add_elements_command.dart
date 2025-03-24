part of 'mp_command.dart';

class MPAddElementsCommand extends MPCommand {
  final List<MPAddElementCommandParams> createParams;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addElements;

  MPAddElementsCommand.forCWJM({
    required this.createParams,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddElementsCommand({
    required this.createParams,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.addElements;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.applyAddElements(createParams);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final List<int> mpIDs = [];

    for (final MPAddElementCommandParams params in createParams) {
      switch (params) {
        case MPAddLineCommandParams _:
          mpIDs.add(params.line.mpID);
        case MPAddPointCommandParams _:
          mpIDs.add(params.point.mpID);
      }
    }

    final MPRemoveElementsCommand oppositeCommand =
        MPRemoveElementsCommand(mpIDs: mpIDs);

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    List<MPAddElementCommandParams>? createParams,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddElementsCommand.forCWJM(
      createParams: createParams ?? this.createParams,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddElementsCommand.fromMap(Map<String, dynamic> map) {
    return MPAddElementsCommand.forCWJM(
      createParams: List<MPAddElementCommandParams>.from(
        map['createParams'].map(
          (x) => MPAddElementCommandParams.fromMap(x),
        ),
      ),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPAddElementsCommand.fromJson(String source) {
    return MPAddElementsCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'createParams': createParams.map((x) => x.toMap()).toList(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddElementsCommand &&
        const DeepCollectionEquality()
            .equals(other.createParams, createParams) &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hashAll(createParams);
}
