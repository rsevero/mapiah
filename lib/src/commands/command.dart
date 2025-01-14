library;

import 'dart:ui';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

part "command.mapper.dart";
part "command_type.dart";
part "move_point_command.dart";

/// Abstract class that defines the structure of a command.
///
/// It is responsible both for executing and undoing the command, therefore, all
/// actions that should support undo must be impmentend as a command.
@MappableClass()
abstract class Command with CommandMappable {
  late final CommandType _type;
  late final String _description;
  late final UndoRedoCommand _undoRedo;

  Command({required CommandType type, required String description}) {
    _type = type;
    _description = description;
  }

  /// User presentable description of the command.
  String get description => _description;

  CommandType get type => _type;

  UndoRedoCommand execute(THFile thFile) {
    _undoRedo = _createUndoRedo(thFile);
    _actualExecute(thFile);

    return _undoRedo;
  }

  /// The description for the undo/redo command should be the description of
  /// the original command so the message on undo and redo are the same even
  /// if the actual original and opposite commands are different.
  UndoRedoCommand _createUndoRedo(THFile thFile);

  void _actualExecute(THFile thFile);
}
