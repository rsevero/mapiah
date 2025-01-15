import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/commands/command_type.dart';
import 'package:mapiah/src/commands/move_bezier_line_segment_command.dart';
import 'package:mapiah/src/commands/move_line_command.dart';
import 'package:mapiah/src/commands/move_point_command.dart';
import 'package:mapiah/src/commands/move_straight_line_segment_command.dart';

class UndoRedoCommand {
  final CommandType _type;
  final String _description;
  final String _json;

  UndoRedoCommand(
      {required CommandType type,
      required String description,
      required String json})
      : _type = type,
        _description = description,
        _json = json;

  CommandType get type => _type;

  String get description => _description;

  String get json => _json;

  Command get command {
    switch (_type) {
      case CommandType.moveBezierLineSegment:
        return MoveBezierLineSegmentCommandMapper.fromJson(_json);
      case CommandType.moveLine:
        return MoveLineCommandMapper.fromJson(_json);
      case CommandType.movePoint:
        return MovePointCommandMapper.fromJson(_json);
      case CommandType.moveStraightLineSegment:
        return MoveStraightLineSegmentCommandMapper.fromJson(_json);
    }
  }
}
