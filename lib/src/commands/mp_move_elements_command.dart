part of 'mp_command.dart';

class MPMoveElementsCommand extends MPCommand {
  late final List<MPMoveCommandCompleteParameters> moveCommandParametersList;
  final List<MPUndoRedoCommand> oppositeCommandList = [];

  MPMoveElementsCommand.forCWJM({
    required this.moveCommandParametersList,
    required super.oppositeCommand,
    super.description = mpMoveElementsCommandDescription,
  }) : super.forCWJM();

  MPMoveElementsCommand({
    required this.moveCommandParametersList,
    super.description = mpMoveElementsCommandDescription,
  }) : super();

  MPMoveElementsCommand.fromDelta({
    required List<MPMoveCommandOriginalParameters>
        moveCommandOriginalParametersList,
    required Offset deltaOnCanvas,
    super.description = mpMoveElementsCommandDescription,
  }) : super() {
    moveCommandParametersList = [];
    for (final moveCommandOriginalParameters
        in moveCommandOriginalParametersList) {
      switch (moveCommandOriginalParameters) {
        case MPMoveCommandLineOriginalParameters _:
          final MPMoveLineCommand moveLineCommand = MPMoveLineCommand.fromDelta(
            lineMapiahID: moveCommandOriginalParameters.mapiahID,
            originalLineSegmentsMap:
                moveCommandOriginalParameters.lineSegmentsMap,
            deltaOnCanvas: deltaOnCanvas,
          );

          moveCommandParametersList.add(
            MPMoveCommandLineCompleteParameters(
              original: moveCommandOriginalParameters,
              modifiedLineSegmentsMap: moveLineCommand.modifiedLineSegmentsMap,
            ),
          );
          break;
        case MPMoveCommandPointOriginalParameters _:
          final MPMovePointCommand movePointCommand =
              MPMovePointCommand.fromDelta(
            pointMapiahID: moveCommandOriginalParameters.mapiahID,
            originalCoordinates: moveCommandOriginalParameters.coordinates,
            deltaOnCanvas: deltaOnCanvas,
          );

          moveCommandParametersList.add(
            MPMoveCommandPointCompleteParameters(
              original: moveCommandOriginalParameters,
              modifiedCoordinates: movePointCommand.modifiedCoordinates,
            ),
          );
          break;
      }
    }
  }

  @override
  void _actualExecute(TH2FileEditStore th2FileEditStore) {
    late MPCommand moveCommand;
    late MPUndoRedoCommand oppositeCommand;

    for (final moveCommandParameters in moveCommandParametersList) {
      switch (moveCommandParameters) {
        case MPMoveCommandLineCompleteParameters _:
          moveCommand = MPMoveLineCommand(
            lineMapiahID: moveCommandParameters.original.mapiahID,
            originalLineSegmentsMap:
                moveCommandParameters.original.lineSegmentsMap,
            modifiedLineSegmentsMap:
                moveCommandParameters.modifiedLineSegmentsMap,
          );
          break;
        case MPMoveCommandPointCompleteParameters _:
          moveCommand = MPMovePointCommand(
            pointMapiahID: moveCommandParameters.original.mapiahID,
            originalCoordinates: moveCommandParameters.original.coordinates,
            modifiedCoordinates: moveCommandParameters.modifiedCoordinates,
          );
          break;
      }
      oppositeCommand = moveCommand.execute(th2FileEditStore);
      oppositeCommandList.add(oppositeCommand);
    }
  }

  @override
  MPUndoRedoCommand _createOppositeCommand() {
    late MPMoveCommandCompleteParameters oppositeMoveCommandParameters;
    final List<MPMoveCommandCompleteParameters>
        oppositeMoveCommandParametersList = [];

    for (final moveCommandParameters in moveCommandParametersList) {
      switch (moveCommandParameters) {
        case MPMoveCommandLineCompleteParameters _:
          oppositeMoveCommandParameters = MPMoveCommandLineCompleteParameters(
            original: moveCommandParameters.original.copyWith(
              lineSegmentsMap: moveCommandParameters.modifiedLineSegmentsMap,
            ),
            modifiedLineSegmentsMap:
                moveCommandParameters.original.lineSegmentsMap,
          );
          break;
        case MPMoveCommandPointCompleteParameters _:
          oppositeMoveCommandParameters = MPMoveCommandPointCompleteParameters(
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
      description: description,
      map: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommandType get type => MPCommandType.moveElements;

  @override
  Map<String, dynamic> toMap() {
    return {
      'commandType': type.name,
      'moveCommandParametersList':
          moveCommandParametersList.map((x) => x.toMap()).toList(),
      'oppositeCommand': oppositeCommand?.toMap(),
      'description': description,
    };
  }

  factory MPMoveElementsCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveElementsCommand.forCWJM(
      moveCommandParametersList: List<MPMoveCommandCompleteParameters>.from(
        map['moveCommandParametersList'].map(
          (x) => MPMoveCommandCompleteParameters.fromMap(x),
        ),
      ),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      description: map['description'],
    );
  }

  factory MPMoveElementsCommand.fromJson(String source) {
    return MPMoveElementsCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveElementsCommand copyWith({
    List<MPMoveCommandCompleteParameters>? moveCommandParametersList,
    MPUndoRedoCommand? oppositeCommand,
    String? description,
  }) {
    return MPMoveElementsCommand.forCWJM(
      moveCommandParametersList:
          moveCommandParametersList ?? this.moveCommandParametersList,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveElementsCommand &&
        const DeepCollectionEquality().equals(
            other.moveCommandParametersList, moveCommandParametersList) &&
        other.oppositeCommand == oppositeCommand &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(moveCommandParametersList),
        oppositeCommand,
        description,
      );
}
