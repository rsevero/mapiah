part of 'mp_command.dart';

class MPDeleteElementsCommand extends MPCommand {
  final List<int> mapiahIDs;

  MPDeleteElementsCommand.forCWJM({
    required this.mapiahIDs,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.deleteElements,
  }) : super.forCWJM();

  MPDeleteElementsCommand({
    required this.mapiahIDs,
    super.descriptionType = MPCommandDescriptionType.deleteElements,
  }) : super();

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;

    for (final int mapiahID in mapiahIDs) {
      final THElement element = thFile.elementByMapiahID(mapiahID);

      if (element is THLine) {
        final List<int> lineChildren = element.childrenMapiahID.toList();

        for (final int childMapiahID in lineChildren) {
          th2FileEditController.deleteElementByMapiahID(childMapiahID);
        }
      }

      th2FileEditController.deleteElementByMapiahID(mapiahID);
    }
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
      TH2FileEditController th2FileEditController) {
    final List<MPCreateCommandParams> oppositeParamsList = [];
    final THFile thFile = th2FileEditController.thFile;
    late MPCreateCommandParams oppositeParams;

    for (final int mapiahID in mapiahIDs) {
      final THElement element = thFile.elementByMapiahID(mapiahID);

      switch (element) {
        case THLine _:
          final MPDeleteLineCommand mpCommand =
              MPDeleteLineCommand(lineMapiahID: element.mapiahID);
          final MPUndoRedoCommand undoRedoCommand =
              mpCommand._createOppositeCommand(th2FileEditController);

          oppositeParams = MPCreateLineCommandParams(
            line: element,
            lineChildren: (undoRedoCommand.command.oppositeCommand!.command
                    as MPCreateLineCommand)
                .lineChildren,
          );
          break;
        case THPoint _:
          oppositeParams = MPCreatePointCommandParams(point: element);
          break;
      }
      oppositeParamsList.add(oppositeParams);
    }

    final MPCreateElementsCommand oppositeCommand = MPCreateElementsCommand(
      createParams: oppositeParamsList,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        descriptionType: descriptionType,
        map: oppositeCommand.toMap());
  }

  @override
  MPCommand copyWith({
    List<int>? mapiahIDs,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPDeleteElementsCommand.forCWJM(
      mapiahIDs: mapiahIDs ?? this.mapiahIDs,
      descriptionType: descriptionType ?? this.descriptionType,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
    );
  }

  factory MPDeleteElementsCommand.fromMap(Map<String, dynamic> map) {
    return MPDeleteElementsCommand.forCWJM(
      mapiahIDs: List<int>.from(map['pointMapiahID']),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
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
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ mapiahIDs.hashCode;

  @override
  MPCommandType get type => MPCommandType.deleteElements;
}
