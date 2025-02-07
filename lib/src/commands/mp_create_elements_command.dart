part of 'mp_command.dart';

class MPCreateElementsCommand extends MPCommand {
  final List<MPCreateCommandParams> createParams;

  MPCreateElementsCommand.forCWJM({
    required this.createParams,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.createElements,
  }) : super.forCWJM();

  MPCreateElementsCommand({
    required this.createParams,
    super.descriptionType = MPCommandDescriptionType.createElements,
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
        case MPCreateLineCommandParams _:
          mapiahIDs.add(params.line.mapiahID);
          break;
        case MPCreatePointCommandParams _:
          mapiahIDs.add(params.point.mapiahID);
          break;
      }
    }

    final MPDeleteElementsCommand oppositeCommand =
        MPDeleteElementsCommand(mapiahIDs: mapiahIDs);

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        descriptionType: descriptionType,
        map: oppositeCommand.toMap());
  }

  @override
  MPCommand copyWith({
    List<MPCreateCommandParams>? createParams,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPCreateElementsCommand.forCWJM(
      createParams: createParams ?? this.createParams,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPCreateElementsCommand.fromMap(Map<String, dynamic> map) {
    return MPCreateElementsCommand.forCWJM(
      createParams: List<MPCreateCommandParams>.from(
        map['createParams'].map(
          (x) => MPCreateCommandParams.fromMap(x),
        ),
      ),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPCreateElementsCommand.fromJson(String source) {
    return MPCreateElementsCommand.fromMap(jsonDecode(source));
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

    return other is MPCreateElementsCommand &&
        const DeepCollectionEquality()
            .equals(other.createParams, createParams) &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hashAll(createParams);

  @override
  MPCommandType get type => MPCommandType.createElements;
}
