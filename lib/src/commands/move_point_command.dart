import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/elements/parts/th_point_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';

part 'move_point_command.mapper.dart';

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
  ) : super.withOppositeCommandJson() {
    _pointMapiahID = pointMapiahID;
    _newPosition = newPosition;
  }

  MovePointCommand(
    int pointMapiahID,
    THPointPositionPart newPosition,
  )   : _pointMapiahID = pointMapiahID,
        _newPosition = newPosition,
        super(_thisDescription);

  @override
  void actualExecute(THFile thFile) {
    final THPoint newPoint = _currentPoint.copyWith(position: _newPosition);

    thFile.substituteElement(newPoint);
  }

  @override
  String createOppositeCommandJson(THFile thFile) {
    _currentPoint = thFile.elementByMapiahID(_pointMapiahID) as THPoint;
    final MovePointCommand oppositeCommand = MovePointCommand(
      _pointMapiahID,
      _currentPoint.position,
    );

    return oppositeCommand.toJson();
  }

  int get pointMapiahID => _pointMapiahID;

  THPointPositionPart get newPosition => _newPosition;
}
