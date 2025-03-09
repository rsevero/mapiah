part of 'mp_command.dart';

class MPMoveElementsCommand extends MPCommand {
  late final List<MPMoveCommandCompleteParams> moveCommandParametersList;
  final List<MPUndoRedoCommand> oppositeCommandList = [];

  MPMoveElementsCommand.forCWJM({
    required this.moveCommandParametersList,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.moveElements,
  }) : super.forCWJM();

  MPMoveElementsCommand({
    required this.moveCommandParametersList,
    super.descriptionType = MPCommandDescriptionType.moveElements,
  }) : super();

  MPMoveElementsCommand.fromDelta({
    required List<MPMoveCommandOriginalParams>
        moveCommandOriginalParametersList,
    required Offset deltaOnCanvas,
    super.descriptionType = MPCommandDescriptionType.moveElements,
  }) : super() {
    moveCommandParametersList = [];
    for (final moveCommandOriginalParameters
        in moveCommandOriginalParametersList) {
      switch (moveCommandOriginalParameters) {
        case MPMoveCommandLineOriginalParams _:
          final MPMoveLineCommand moveLineCommand = MPMoveLineCommand.fromDelta(
            lineMapiahID: moveCommandOriginalParameters.mapiahID,
            originalLineSegmentsMap:
                moveCommandOriginalParameters.lineSegmentsMap,
            deltaOnCanvas: deltaOnCanvas,
          );

          moveCommandParametersList.add(
            MPMoveCommandLineCompleteParams(
              original: moveCommandOriginalParameters,
              modifiedLineSegmentsMap: moveLineCommand.modifiedLineSegmentsMap,
            ),
          );
          break;
        case MPMoveCommandPointOriginalParams _:
          final MPMovePointCommand movePointCommand =
              MPMovePointCommand.fromDelta(
            pointMapiahID: moveCommandOriginalParameters.mapiahID,
            originalCoordinates: moveCommandOriginalParameters.coordinates,
            deltaOnCanvas: deltaOnCanvas,
          );

          moveCommandParametersList.add(
            MPMoveCommandPointCompleteParams(
              original: moveCommandOriginalParameters,
              modifiedCoordinates: movePointCommand.modifiedCoordinates,
            ),
          );
          break;
      }
    }
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    late MPCommand moveCommand;
    late MPUndoRedoCommand oppositeCommand;

    for (final moveCommandParameters in moveCommandParametersList) {
      switch (moveCommandParameters) {
        case MPMoveCommandLineCompleteParams _:
          moveCommand = MPMoveLineCommand(
            lineMapiahID: moveCommandParameters.original.mapiahID,
            originalLineSegmentsMap:
                moveCommandParameters.original.lineSegmentsMap,
            modifiedLineSegmentsMap:
                moveCommandParameters.modifiedLineSegmentsMap,
          );
          break;
        case MPMoveCommandPointCompleteParams _:
          moveCommand = MPMovePointCommand(
            pointMapiahID: moveCommandParameters.original.mapiahID,
            originalCoordinates: moveCommandParameters.original.coordinates,
            modifiedCoordinates: moveCommandParameters.modifiedCoordinates,
          );
          break;
      }
      oppositeCommand = moveCommand.execute(th2FileEditController);
      oppositeCommandList.add(oppositeCommand);
    }
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
    TH2FileEditController th2FileEditController,
  ) {
    late MPMoveCommandCompleteParams oppositeMoveCommandParameters;
    final List<MPMoveCommandCompleteParams> oppositeMoveCommandParametersList =
        [];

    for (final moveCommandParameters in moveCommandParametersList) {
      switch (moveCommandParameters) {
        case MPMoveCommandLineCompleteParams _:
          oppositeMoveCommandParameters = MPMoveCommandLineCompleteParams(
            original: moveCommandParameters.original.copyWith(
              lineSegmentsMap: moveCommandParameters.modifiedLineSegmentsMap,
            ),
            modifiedLineSegmentsMap:
                moveCommandParameters.original.lineSegmentsMap,
          );
          break;
        case MPMoveCommandPointCompleteParams _:
          oppositeMoveCommandParameters = MPMoveCommandPointCompleteParams(
            original: moveCommandParameters.original.copyWith(
              coordinates: moveCommandParameters.modifiedCoordinates,
            ),
            modifiedCoordinates: moveCommandParameters.original.coordinates,
          );
          break;
      }
      oppositeMoveCommandParametersList.add(oppositeMoveCommandParameters);
    }

    final MPMoveElementsCommand oppositeCommand = MPMoveElementsCommand(
      moveCommandParametersList: oppositeMoveCommandParametersList,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      descriptionType: descriptionType,
      map: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommandType get type => MPCommandType.moveElements;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'moveCommandParametersList':
          moveCommandParametersList.map((x) => x.toMap()).toList(),
    });

    return map;
  }

  factory MPMoveElementsCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveElementsCommand.forCWJM(
      moveCommandParametersList: List<MPMoveCommandCompleteParams>.from(
        map['moveCommandParametersList'].map(
          (x) => MPMoveCommandCompleteParams.fromMap(x),
        ),
      ),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPMoveElementsCommand.fromJson(String source) {
    return MPMoveElementsCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveElementsCommand copyWith({
    List<MPMoveCommandCompleteParams>? moveCommandParametersList,
    MPUndoRedoCommand? oppositeCommand,
    bool makeOppositeCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveElementsCommand.forCWJM(
      moveCommandParametersList:
          moveCommandParametersList ?? this.moveCommandParametersList,
      oppositeCommand: makeOppositeCommandNull
          ? null
          : (oppositeCommand ?? this.oppositeCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveElementsCommand &&
        const DeepCollectionEquality().equals(
            other.moveCommandParametersList, moveCommandParametersList) &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^ Object.hashAll(moveCommandParametersList);
}
