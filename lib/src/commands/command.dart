library;

import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/parts/th_point_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';

part "command.mapper.dart";
part "move_point_command.dart";

/// Abstract class that defines the structure of a command.
///
/// It is responsible both for executing and undoing the command, therefore, all
/// actions that should support undo must be impmentend as a command.
@MappableClass()
abstract class Command with CommandMappable {
  late final String _description;
  late final String _oppositeCommandJson;

  /// Used by dart_mappable.
  Command.withOppositeCommandJson(
      String description, String oppositeCommandJson)
      : _description = description,
        _oppositeCommandJson = oppositeCommandJson;

  Command(String description) : _description = description;

  /// User presentable description of the command.
  String get description => _description;

  /// JSON representation of the state before the command was executed.
  String get oppositeCommandJson => _oppositeCommandJson;

  void execute(THFile thFile) {
    _oppositeCommandJson = _createOppositeCommandJson(thFile);
    _actualExecute(thFile);
  }

  String _createOppositeCommandJson(THFile thFile);

  void _actualExecute(THFile thFile);
}
