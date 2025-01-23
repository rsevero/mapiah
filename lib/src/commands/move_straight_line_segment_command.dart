import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

class MoveStraightLineSegmentCommand extends Command {
  late final THStraightLineSegment lineSegment;
  late final Offset endPointOriginalCoordinates;
  late final Offset endPointNewCoordinates;

  MoveStraightLineSegmentCommand.forCWJM({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required this.endPointNewCoordinates,
    required super.undoRedo,
    required super.description,
  }) : super.forCWJM();

  MoveStraightLineSegmentCommand({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required this.endPointNewCoordinates,
    super.description = mpMoveStraightLineSegmentCommandDescription,
  }) : super();

  MoveStraightLineSegmentCommand.fromDelta({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required Offset deltaOnCanvas,
    super.description = mpMoveStraightLineSegmentCommandDescription,
  })  : endPointNewCoordinates = endPointOriginalCoordinates + deltaOnCanvas,
        super();

  @override
  CommandType get type => CommandType.moveStraightLineSegment;

  @override
  Map<String, dynamic> toMap() {
    return {
      'commandType': type.name,
      'lineSegment': lineSegment.toMap(),
      'endPointOriginalCoordinates': {
        'dx': endPointOriginalCoordinates.dx,
        'dy': endPointOriginalCoordinates.dy
      },
      'endPointNewCoordinates': {
        'dx': endPointNewCoordinates.dx,
        'dy': endPointNewCoordinates.dy
      },
      'undoRedo': undoRedo?.toMap(),
      'description': description,
    };
  }

  factory MoveStraightLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MoveStraightLineSegmentCommand.forCWJM(
      lineSegment: THStraightLineSegment.fromMap(map['lineSegment']),
      endPointOriginalCoordinates: Offset(
          map['endPointOriginalCoordinates']['dx'],
          map['endPointOriginalCoordinates']['dy']),
      endPointNewCoordinates: Offset(map['endPointNewCoordinates']['dx'],
          map['endPointNewCoordinates']['dy']),
      undoRedo: map['undoRedo'] == null
          ? null
          : UndoRedoCommand.fromMap(map['undoRedo']),
      description: map['description'],
    );
  }

  factory MoveStraightLineSegmentCommand.fromJson(String jsonString) {
    return MoveStraightLineSegmentCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  MoveStraightLineSegmentCommand copyWith({
    THStraightLineSegment? lineSegment,
    Offset? endPointOriginalCoordinates,
    Offset? endPointNewCoordinates,
    UndoRedoCommand? undoRedo,
    String? description,
  }) {
    return MoveStraightLineSegmentCommand.forCWJM(
      lineSegment: lineSegment ?? this.lineSegment,
      endPointOriginalCoordinates:
          endPointOriginalCoordinates ?? this.endPointOriginalCoordinates,
      endPointNewCoordinates:
          endPointNewCoordinates ?? this.endPointNewCoordinates,
      undoRedo: undoRedo ?? this.undoRedo,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(covariant MoveStraightLineSegmentCommand other) {
    if (identical(this, other)) return true;

    return other.lineSegment == lineSegment &&
        other.endPointOriginalCoordinates == endPointOriginalCoordinates &&
        other.endPointNewCoordinates == endPointNewCoordinates &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        lineSegment,
        endPointOriginalCoordinates,
        endPointNewCoordinates,
        description,
      );

  @override
  void actualExecute(THFile thFile) {
    final THStraightLineSegment originalLineSegment = lineSegment;
    final THStraightLineSegment newLineSegment = originalLineSegment.copyWith(
        endPoint: originalLineSegment.endPoint
            .copyWith(coordinates: endPointNewCoordinates));

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
        map: undoRedoCommand.toMap());
  }
}
