part of 'mp_command.dart';

class MPElementMove {
  final int elementMPID;
  final int newParentMPID;
  final int positionInNewParent;

  const MPElementMove({
    required this.elementMPID,
    required this.newParentMPID,
    required this.positionInNewParent,
  });

  Map<String, dynamic> toMap() => {
    'elementMPID': elementMPID,
    'newParentMPID': newParentMPID,
    'positionInNewParent': positionInNewParent,
  };

  factory MPElementMove.fromMap(Map<String, dynamic> map) => MPElementMove(
    elementMPID: map['elementMPID'],
    newParentMPID: map['newParentMPID'],
    positionInNewParent: map['positionInNewParent'],
  );

  @override
  bool operator ==(Object other) => other is MPElementMove &&
      other.elementMPID == elementMPID &&
      other.newParentMPID == newParentMPID &&
      other.positionInNewParent == positionInNewParent;

  @override
  int get hashCode => Object.hash(elementMPID, newParentMPID, positionInNewParent);
}

class MPMoveElementsCommand extends MPCommand {
  final List<MPElementMove> moves;
  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.moveElements;

  MPMoveElementsCommand({required List<MPElementMove> moves,
    super.descriptionType = defaultDescriptionType}) : moves = List.unmodifiable(moves), super();
  MPMoveElementsCommand.forCWJM({required List<MPElementMove> moves,
    super.descriptionType = defaultDescriptionType}) : moves = List.unmodifiable(moves), super.forCWJM();

  @override MPCommandType get type => MPCommandType.moveElements;

  @override
  void _prepareUndoRedoInfo(
    TH2FileEditController th2FileEditController,
  ) {
    final TH2FileEditController controller = th2FileEditController;
    final Map<int, List<int>> lists = <int, List<int>>{};
    final Map<int, int> parents = <int, int>{};
    for (final THElement element in controller.th2File.elements.values) {
      parents[element.mpID] = element.parentMPID < 0
          ? controller.th2File.mpID : element.parentMPID;
    }
    List<int> listFor(int parent) => lists.putIfAbsent(parent, () =>
        parent == controller.th2File.mpID
            ? controller.th2File.childrenMPIDs.toList()
            : controller.th2File.parentByMPID(parent).childrenMPIDs.toList());
    final List<Map<String, dynamic>> originals = <Map<String, dynamic>>[];
    for (final MPElementMove move in moves) {
      final int oldParent = parents[move.elementMPID]!;
      final List<int> oldList = listFor(oldParent);
      final int oldIndex = oldList.indexOf(move.elementMPID);
      if (oldIndex < 0) throw StateError('Moved element is absent from its parent.');
      oldList.removeAt(oldIndex);
      final List<int> newList = listFor(move.newParentMPID);
      final int position = move.positionInNewParent;
      if (position < 0 || position > newList.length) throw StateError('Invalid move position.');
      newList.insert(position, move.elementMPID);
      parents[move.elementMPID] = move.newParentMPID;
      originals.add({'parentMPID': oldParent, 'position': oldIndex});
    }
    _undoRedoInfo = {'originals': originals};
  }

  @override
  void _actualExecute(TH2FileEditController controller) {
    controller.elementEditController.executeMoveElements(moves);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(TH2FileEditController controller) {
    final List<Map<String, dynamic>> originals =
        List<Map<String, dynamic>>.from(_undoRedoInfo!['originals']);
    final List<MPElementMove> inverse = <MPElementMove>[];
    for (int i = moves.length - 1; i >= 0; i--) {
      inverse.add(MPElementMove(
        elementMPID: moves[i].elementMPID,
        newParentMPID: originals[i]['parentMPID'],
        positionInNewParent: originals[i]['position'],
      ));
    }
    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: MPMoveElementsCommand.forCWJM(
        moves: inverse, descriptionType: descriptionType,
      ).toMap(),
    );
  }

  @override
  MPMoveElementsCommand copyWith({MPCommandDescriptionType? descriptionType}) =>
      MPMoveElementsCommand.forCWJM(moves: moves,
        descriptionType: descriptionType ?? this.descriptionType);

  factory MPMoveElementsCommand.fromMap(Map<String, dynamic> map) =>
      MPMoveElementsCommand.forCWJM(
        moves: (map['moves'] as List).map((dynamic value) =>
          MPElementMove.fromMap(Map<String, dynamic>.from(value))).toList(),
        descriptionType: MPCommandDescriptionType.values.byName(map['descriptionType']),
      );
  factory MPMoveElementsCommand.fromJson(String source) =>
      MPMoveElementsCommand.fromMap(jsonDecode(source));

  @override Map<String, dynamic> toMap() => {
    ...super.toMap(), 'moves': moves.map((MPElementMove move) => move.toMap()).toList(),
  };
  @override bool operator ==(Object other) => super.equalsBase(other) &&
      other is MPMoveElementsCommand && const ListEquality<MPElementMove>().equals(other.moves, moves);
  @override int get hashCode => Object.hash(super.hashCode, const ListEquality<MPElementMove>().hash(moves));
}
