import 'dart:collection';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/commands/command_type.dart';
import 'package:mapiah/src/commands/move_bezier_line_segment_command.dart';
import 'package:mapiah/src/commands/move_straight_line_segment_command.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

part 'move_line_command.mapper.dart';

@MappableClass()
class MoveLineCommand extends Command with MoveLineCommandMappable {
  final THLine originalLine;
  final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap;
  late final THLine newLine;
  late final LinkedHashMap<int, THLineSegment> newLineSegmentsMap;
  late final Offset deltaOnCanvas;
  bool isFromDelta = false;

  MoveLineCommand({
    required this.originalLine,
    required this.originalLineSegmentsMap,
    required this.newLine,
    required this.newLineSegmentsMap,
    super.type = CommandType.moveLine,
    super.description = 'Move Line',
  }) : super();

  MoveLineCommand.fromDelta({
    required this.originalLine,
    required this.originalLineSegmentsMap,
    required this.deltaOnCanvas,
    super.type = CommandType.moveLine,
    super.description = 'Move Line',
  })  : newLine = originalLine.copyWith(),
        isFromDelta = true,
        super();

  @override
  void actualExecute(THFile thFile) {
    for (final entry in originalLineSegmentsMap.entries) {
      final int originalLineSegmentMapiahID = entry.key;
      final THLineSegment originalLineSegment = entry.value;
      late Command command;

      switch (originalLineSegment) {
        case THStraightLineSegment _:
          if (isFromDelta) {
            command = MoveStraightLineSegmentCommand.fromDelta(
              lineSegment: originalLineSegment,
              endPointOriginalCoordinates:
                  originalLineSegment.endPoint.coordinates,
              deltaOnCanvas: deltaOnCanvas,
            );
          } else {
            command = MoveStraightLineSegmentCommand(
              lineSegment: originalLineSegment,
              endPointOriginalCoordinates:
                  originalLineSegment.endPoint.coordinates,
              endPointNewCoordinates:
                  newLineSegmentsMap[originalLineSegmentMapiahID]!
                      .endPoint
                      .coordinates,
            );
          }
          break;
        case THBezierCurveLineSegment _:
          THBezierCurveLineSegment newLineSegment =
              newLineSegmentsMap[originalLineSegmentMapiahID]
                  as THBezierCurveLineSegment;

          if (isFromDelta) {
            command = MoveBezierLineSegmentCommand.fromDelta(
              lineSegment: originalLineSegment,
              endPointOriginalCoordinates:
                  originalLineSegment.endPoint.coordinates,
              controlPoint1OriginalCoordinates:
                  originalLineSegment.controlPoint1.coordinates,
              controlPoint2OriginalCoordinates:
                  originalLineSegment.controlPoint2.coordinates,
              deltaOnCanvas: deltaOnCanvas,
            );
          } else {
            command = MoveBezierLineSegmentCommand(
              lineSegment: originalLineSegment,
              endPointOriginalCoordinates:
                  originalLineSegment.endPoint.coordinates,
              endPointNewCoordinates: newLineSegment.endPoint.coordinates,
              controlPoint1OriginalCoordinates:
                  originalLineSegment.controlPoint1.coordinates,
              controlPoint1NewCoordinates:
                  newLineSegment.controlPoint1.coordinates,
              controlPoint2OriginalCoordinates:
                  originalLineSegment.controlPoint2.coordinates,
              controlPoint2NewCoordinates:
                  newLineSegment.controlPoint2.coordinates,
            );
          }
          break;
      }

      command.execute(thFile);
    }
  }

  @override
  UndoRedoCommand createUndoRedo(THFile thFile) {
    final MoveLineCommand undoRedoCommand = MoveLineCommand(
      originalLine: newLine,
      originalLineSegmentsMap: newLineSegmentsMap,
      newLine: originalLine,
      newLineSegmentsMap: originalLineSegmentsMap,
      description: description,
    );

    return UndoRedoCommand(
        type: undoRedoCommand.type,
        description: description,
        json: undoRedoCommand.toJson());
  }
}
