import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/offset_mapper.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/commands/command_type.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

part 'move_point_command.mapper.dart';

@MappableClass(includeCustomMappers: [OffsetMapper()])
class MovePointCommand extends Command with MovePointCommandMappable {
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

  MovePointCommand.fromDelta({
    required int pointMapiahID,
    required Offset originalCoordinates,
    required Offset deltaOnCanvas,
    super.type = CommandType.movePoint,
    super.description = 'Move Point',
  }) : super() {
    _pointMapiahID = pointMapiahID;
    _originalCoordinates = originalCoordinates;
    _newCoordinates = originalCoordinates + deltaOnCanvas;
  }

  @override
  UndoRedoCommand createUndoRedo(THFile thFile) {
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
  void actualExecute(THFile thFile) {
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
