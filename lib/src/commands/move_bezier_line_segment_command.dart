import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/offset_mapper.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/commands/command_type.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

part 'move_bezier_line_segment_command.mapper.dart';

@MappableClass(includeCustomMappers: [OffsetMapper()])
class MoveBezierLineSegmentCommand extends Command
    with MoveBezierLineSegmentCommandMappable {
  late final THBezierCurveLineSegment lineSegment;
  late final Offset endPointOriginalCoordinates;
  late final Offset endPointNewCoordinates;
  late final Offset controlPoint1OriginalCoordinates;
  late final Offset controlPoint1NewCoordinates;
  late final Offset controlPoint2OriginalCoordinates;
  late final Offset controlPoint2NewCoordinates;

  MoveBezierLineSegmentCommand({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required this.endPointNewCoordinates,
    required this.controlPoint1OriginalCoordinates,
    required this.controlPoint1NewCoordinates,
    required this.controlPoint2OriginalCoordinates,
    required this.controlPoint2NewCoordinates,
    super.type = CommandType.moveBezierLineSegment,
    super.description = 'Move Bezier Line Segment',
  }) : super();

  MoveBezierLineSegmentCommand.fromDelta({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required this.controlPoint1OriginalCoordinates,
    required this.controlPoint2OriginalCoordinates,
    required Offset deltaOnCanvas,
    super.type = CommandType.moveBezierLineSegment,
    super.description = 'Move Bezier Line Segment',
  })  : endPointNewCoordinates = endPointOriginalCoordinates + deltaOnCanvas,
        controlPoint1NewCoordinates =
            controlPoint1OriginalCoordinates + deltaOnCanvas,
        controlPoint2NewCoordinates =
            controlPoint2OriginalCoordinates + deltaOnCanvas,
        super();

  @override
  void actualExecute(THFile thFile) {
    final THBezierCurveLineSegment newLineSegment = lineSegment.copyWith
        .endPoint(coordinates: endPointNewCoordinates)
        .copyWith
        .controlPoint1(coordinates: controlPoint1NewCoordinates)
        .copyWith
        .controlPoint2(coordinates: controlPoint2NewCoordinates);

    thFile.substituteElement(newLineSegment);
  }

  @override
  UndoRedoCommand createUndoRedo(THFile thFile) {
    final MoveBezierLineSegmentCommand undoRedoCommand =
        MoveBezierLineSegmentCommand(
      lineSegment: lineSegment,
      endPointOriginalCoordinates: endPointNewCoordinates,
      endPointNewCoordinates: endPointOriginalCoordinates,
      controlPoint1OriginalCoordinates: controlPoint1NewCoordinates,
      controlPoint1NewCoordinates: controlPoint1OriginalCoordinates,
      controlPoint2OriginalCoordinates: controlPoint2NewCoordinates,
      controlPoint2NewCoordinates: controlPoint2OriginalCoordinates,
      description: description,
    );

    return UndoRedoCommand(
        type: undoRedoCommand.type,
        description: description,
        json: undoRedoCommand.toJson());
  }
}
