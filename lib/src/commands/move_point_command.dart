part of 'command.dart';

@MappableClass()
final class MovePointCommand extends Command with MovePointCommandMappable {
  late final int _pointMapiahID;
  late final THPositionPart _originalPosition;
  late final THPositionPart _newPosition;

  MovePointCommand({
    required int pointMapiahID,
    required THPositionPart originalPosition,
    required THPositionPart newPosition,
    super.type = CommandType.movePoint,
    super.description = 'Move Point',
  }) : super() {
    _pointMapiahID = pointMapiahID;
    _originalPosition = originalPosition;
    _newPosition = newPosition;
  }

  @override
  UndoRedoCommand _createUndoRedo(THFile thFile) {
    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MovePointCommand undoRedoCommand = MovePointCommand(
      pointMapiahID: _pointMapiahID,
      originalPosition: _newPosition,
      newPosition: _originalPosition,
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
            .copyWith(position: _newPosition);

    thFile.substituteElement(newPoint);
  }

  int get pointMapiahID => _pointMapiahID;

  THPositionPart get newPosition => _newPosition;

  THPositionPart get originalPosition => _originalPosition;
}
