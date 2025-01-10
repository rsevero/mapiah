import 'package:mapiah/src/commands/command.dart';

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
      case CommandType.movePoint:
        return MovePointCommandMapper.fromJson(_json);
    }
  }
}
