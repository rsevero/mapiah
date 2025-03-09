part of 'mp_command.dart';

class MPAddElementsCommand extends MPCommand {
  final List<MPAddElementCommandParams> createParams;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addElements;

  MPAddElementsCommand.forCWJM({
    required this.createParams,
    required super.oppositeCommand,
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
    final TH2FileEditAddElementController addElementController =
        th2FileEditController.addElementController;

    for (final MPAddElementCommandParams params in createParams) {
      switch (params) {
        case MPAddLineCommandParams _:
          addElementController.addLine(
            newLine: params.line,
            lineChildren: params.lineChildren,
          );
        case MPAddPointCommandParams _:
          th2FileEditController.addElement(newElement: params.point);
      }
    }

    th2FileEditController.triggerAllElementsRedraw();
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final List<int> mapiahIDs = [];

    for (final MPAddElementCommandParams params in createParams) {
      switch (params) {
        case MPAddLineCommandParams _:
          mapiahIDs.add(params.line.mapiahID);
        case MPAddPointCommandParams _:
          mapiahIDs.add(params.point.mapiahID);
      }
    }

    final MPDeleteElementsCommand oppositeCommand =
        MPDeleteElementsCommand(mapiahIDs: mapiahIDs);

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      map: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    List<MPAddElementCommandParams>? createParams,
    MPUndoRedoCommand? oppositeCommand,
    bool makeOppositeCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddElementsCommand.forCWJM(
      createParams: createParams ?? this.createParams,
      oppositeCommand: makeOppositeCommandNull
          ? null
          : (oppositeCommand ?? this.oppositeCommand),
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
}
