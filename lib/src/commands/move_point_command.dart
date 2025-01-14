part of 'command.dart';

@MappableClass()
final class MovePointCommand extends Command with MovePointCommandMappable {
  late final int _pointMapiahID;
  late final Offset _originalCoordinates;
  late final Offset _newCoordinates;

  MovePointCommand({
    required int pointMapiahID,
    required Offset originalCoordinates,
    required Offset newCoordinates,
    super.type = CommandType.movePoint,
    super.description = 'Move Point',
  }) : super() {
    _pointMapiahID = pointMapiahID;
    _originalCoordinates = originalCoordinates;
    _newCoordinates = newCoordinates;
  }

  @override
  UndoRedoCommand _createUndoRedo(THFile thFile) {
    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MovePointCommand undoRedoCommand = MovePointCommand(
      pointMapiahID: _pointMapiahID,
      originalCoordinates: _newCoordinates,
      newCoordinates: _originalCoordinates,
      description: description,
    );

    return UndoRedoCommand(
        type: undoRedoCommand.type,
        description: description,
        json: undoRedoCommand.toJson());
  }

  @override
  void _actualExecute(THFile thFile) {
    final THPoint newPoint =
        (thFile.elementByMapiahID(_pointMapiahID) as THPoint)
            .copyWith
            .position(coordinates: _newCoordinates);

    thFile.substituteElement(newPoint);
  }

  int get pointMapiahID => _pointMapiahID;

  Offset get newCoordinates => _newCoordinates;

  Offset get originalCoordinates => _originalCoordinates;
}
