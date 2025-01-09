part of 'command.dart';

@MappableClass()
class MovePointCommand extends Command with MovePointCommandMappable {
  late final int _pointMapiahID;
  late final THPointPositionPart _newPosition;
  late final THPoint _currentPoint;

  static const String _thisDescription = 'Move Point';

  /// Used by dart_mappable.
  MovePointCommand.withDescription(
    super.description,
    super.oppositeCommandJson,
    int pointMapiahID,
    THPointPositionPart newPosition,
  )   : _pointMapiahID = pointMapiahID,
        _newPosition = newPosition,
        super.withOppositeCommandJson();

  MovePointCommand(
    int pointMapiahID,
    THPointPositionPart newPosition, {
    super.description = _thisDescription,
  })  : _pointMapiahID = pointMapiahID,
        _newPosition = newPosition,
        super();

  @override
  String _createOppositeCommandJson(THFile thFile) {
    _currentPoint = thFile.elementByMapiahID(_pointMapiahID) as THPoint;
    final MovePointCommand oppositeCommand = MovePointCommand(
      _pointMapiahID,
      _currentPoint.position,
      description: description,
    );

    return oppositeCommand.toJson();
  }

  @override
  void _actualExecute(THFile thFile) {
    final THPoint newPoint = _currentPoint.copyWith(position: _newPosition);

    thFile.substituteElement(newPoint);
  }

  int get pointMapiahID => _pointMapiahID;

  THPointPositionPart get newPosition => _newPosition;
}
