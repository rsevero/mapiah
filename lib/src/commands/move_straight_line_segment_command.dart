import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/offset_mapper.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/commands/command_type.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

part 'move_straight_line_segment_command.mapper.dart';

@MappableClass(includeCustomMappers: [OffsetMapper()])
class MoveStraightLineSegmentCommand extends Command
    with MoveStraightLineSegmentCommandMappable {
  late final THStraightLineSegment lineSegment;
  late final Offset endPointOriginalCoordinates;
  late final Offset endPointNewCoordinates;

  MoveStraightLineSegmentCommand({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required this.endPointNewCoordinates,
    super.type = CommandType.moveStraightLineSegment,
    super.description = 'Move Straight Line Segment',
  }) : super();

  MoveStraightLineSegmentCommand.fromDelta({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required Offset deltaOnCanvas,
    super.type = CommandType.moveStraightLineSegment,
    super.description = 'Move Straight Line Segment',
  })  : endPointNewCoordinates = endPointOriginalCoordinates + deltaOnCanvas,
        super();

  @override
  void actualExecute(THFile thFile) {
    final THStraightLineSegment newLineSegment =
        lineSegment.copyWith.endPoint(coordinates: endPointNewCoordinates);

    thFile.substituteElement(newLineSegment);
  }

  @override
  UndoRedoCommand createUndoRedo(THFile thFile) {
    final MoveStraightLineSegmentCommand undoRedoCommand =
        MoveStraightLineSegmentCommand(
      lineSegment: lineSegment,
      endPointOriginalCoordinates: endPointNewCoordinates,
      endPointNewCoordinates: endPointOriginalCoordinates,
      description: description,
    );

    return UndoRedoCommand(
        type: undoRedoCommand.type,
        description: description,
        json: undoRedoCommand.toJson());
  }
}
