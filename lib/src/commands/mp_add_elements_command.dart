part of 'mp_command.dart';

class MPAddElementsCommand extends MPCommand {
  final List<MPAddElementCommandParams> createParams;

  MPAddElementsCommand.forCWJM({
    required this.createParams,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.addElements,
  }) : super.forCWJM();

  MPAddElementsCommand({
    required this.createParams,
    super.descriptionType = MPCommandDescriptionType.addElements,
  }) : super();

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {}

  @override
  MPUndoRedoCommand _createOppositeCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final List<int> mapiahIDs = [];

    for (final params in createParams) {
      switch (params) {
        case MPAddLineCommandParams _:
          mapiahIDs.add(params.line.mapiahID);
          break;
        case MPAddPointCommandParams _:
          mapiahIDs.add(params.point.mapiahID);
          break;
      }
    }

    final MPDeleteElementsCommand oppositeCommand =
        MPDeleteElementsCommand(mapiahIDs: mapiahIDs);

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      descriptionType: descriptionType,
      map: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    List<MPAddElementCommandParams>? createParams,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPAddElementsCommand.forCWJM(
      createParams: createParams ?? this.createParams,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
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
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
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
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hashAll(createParams);

  @override
  MPCommandType get type => MPCommandType.addElements;
}
