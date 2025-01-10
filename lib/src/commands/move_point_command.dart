part of 'command.dart';

@MappableClass()
final class MovePointCommand extends Command with MovePointCommandMappable {
  late final int _pointMapiahID;
  late final THPointPositionPart _newPosition;
  late final THPoint _currentPoint;

  static const String _thisDescription = 'Move Point';
  static const CommandType _thisType = CommandType.movePoint;

  /// Used by dart_mappable.
  MovePointCommand.withDescription(
    super.type,
    super.description,
    super.oppositeCommandJson,
    int pointMapiahID,
    THPointPositionPart newPosition,
  )   : _pointMapiahID = pointMapiahID,
        _newPosition = newPosition,
        super.withUndoRedo();

  MovePointCommand(
    int pointMapiahID,
    THPointPositionPart newPosition, {
    super.type = _thisType,
    super.description = _thisDescription,
  })  : _pointMapiahID = pointMapiahID,
        _newPosition = newPosition,
        super();

  @override
  UndoRedoCommand _createUndoRedo(THFile thFile) {
    _currentPoint = thFile.elementByMapiahID(_pointMapiahID) as THPoint;

    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MovePointCommand undoRedoCommand = MovePointCommand(
      _pointMapiahID,
      _currentPoint.position,
      description: description,
    );

    return UndoRedoCommand(
        type: undoRedoCommand.type,
        description: description,
        json: undoRedoCommand.toJson());
  }

  @override
  void _actualExecute(THFile thFile) {
    final THPoint newPoint = _currentPoint.copyWith(position: _newPosition);

    thFile.substituteElement(newPoint);
  }

  int get pointMapiahID => _pointMapiahID;

  THPointPositionPart get newPosition => _newPosition;
}
