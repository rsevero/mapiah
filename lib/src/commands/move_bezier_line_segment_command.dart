import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

class MoveBezierLineSegmentCommand extends Command {
  late final THBezierCurveLineSegment lineSegment;
  late final Offset endPointOriginalCoordinates;
  late final Offset endPointNewCoordinates;
  late final Offset controlPoint1OriginalCoordinates;
  late final Offset controlPoint1NewCoordinates;
  late final Offset controlPoint2OriginalCoordinates;
  late final Offset controlPoint2NewCoordinates;

  MoveBezierLineSegmentCommand.forCWJM({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required this.endPointNewCoordinates,
    required this.controlPoint1OriginalCoordinates,
    required this.controlPoint1NewCoordinates,
    required this.controlPoint2OriginalCoordinates,
    required this.controlPoint2NewCoordinates,
    required super.undoRedo,
    super.description = mpMoveBezierLineSegmentCommandDescription,
  }) : super.forCWJM();

  MoveBezierLineSegmentCommand({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required this.endPointNewCoordinates,
    required this.controlPoint1OriginalCoordinates,
    required this.controlPoint1NewCoordinates,
    required this.controlPoint2OriginalCoordinates,
    required this.controlPoint2NewCoordinates,
    super.description = mpMoveBezierLineSegmentCommandDescription,
  }) : super();

  MoveBezierLineSegmentCommand.fromDelta({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required this.controlPoint1OriginalCoordinates,
    required this.controlPoint2OriginalCoordinates,
    required Offset deltaOnCanvas,
    super.description = mpMoveBezierLineSegmentCommandDescription,
  })  : endPointNewCoordinates = endPointOriginalCoordinates + deltaOnCanvas,
        controlPoint1NewCoordinates =
            controlPoint1OriginalCoordinates + deltaOnCanvas,
        controlPoint2NewCoordinates =
            controlPoint2OriginalCoordinates + deltaOnCanvas,
        super();

  @override
  CommandType get type => CommandType.moveBezierLineSegment;

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
      'controlPoint1OriginalCoordinates': {
        'dx': controlPoint1OriginalCoordinates.dx,
        'dy': controlPoint1OriginalCoordinates.dy
      },
      'controlPoint1NewCoordinates': {
        'dx': controlPoint1NewCoordinates.dx,
        'dy': controlPoint1NewCoordinates.dy
      },
      'controlPoint2OriginalCoordinates': {
        'dx': controlPoint2OriginalCoordinates.dx,
        'dy': controlPoint2OriginalCoordinates.dy
      },
      'controlPoint2NewCoordinates': {
        'dx': controlPoint2NewCoordinates.dx,
        'dy': controlPoint2NewCoordinates.dy
      },
      'undoRedo': undoRedo.toMap(),
      'description': description,
    };
  }

  factory MoveBezierLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MoveBezierLineSegmentCommand.forCWJM(
      lineSegment: THBezierCurveLineSegment.fromMap(map['lineSegment']),
      endPointOriginalCoordinates: Offset(
          map['endPointOriginalCoordinates']['dx'],
          map['endPointOriginalCoordinates']['dy']),
      endPointNewCoordinates: Offset(map['endPointNewCoordinates']['dx'],
          map['endPointNewCoordinates']['dy']),
      controlPoint1OriginalCoordinates: Offset(
          map['controlPoint1OriginalCoordinates']['dx'],
          map['controlPoint1OriginalCoordinates']['dy']),
      controlPoint1NewCoordinates: Offset(
          map['controlPoint1NewCoordinates']['dx'],
          map['controlPoint1NewCoordinates']['dy']),
      controlPoint2OriginalCoordinates: Offset(
          map['controlPoint2OriginalCoordinates']['dx'],
          map['controlPoint2OriginalCoordinates']['dy']),
      controlPoint2NewCoordinates: Offset(
          map['controlPoint2NewCoordinates']['dx'],
          map['controlPoint2NewCoordinates']['dy']),
      undoRedo: UndoRedoCommand.fromMap(map['undoRedo']),
      description: map['description'],
    );
  }

  factory MoveBezierLineSegmentCommand.fromJson(String jsonString) {
    return MoveBezierLineSegmentCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  MoveBezierLineSegmentCommand copyWith({
    THBezierCurveLineSegment? lineSegment,
    Offset? endPointOriginalCoordinates,
    Offset? endPointNewCoordinates,
    Offset? controlPoint1OriginalCoordinates,
    Offset? controlPoint1NewCoordinates,
    Offset? controlPoint2OriginalCoordinates,
    Offset? controlPoint2NewCoordinates,
    UndoRedoCommand? undoRedo,
    String? description,
  }) {
    return MoveBezierLineSegmentCommand.forCWJM(
      lineSegment: lineSegment ?? this.lineSegment,
      endPointOriginalCoordinates:
          endPointOriginalCoordinates ?? this.endPointOriginalCoordinates,
      endPointNewCoordinates:
          endPointNewCoordinates ?? this.endPointNewCoordinates,
      controlPoint1OriginalCoordinates: controlPoint1OriginalCoordinates ??
          this.controlPoint1OriginalCoordinates,
      controlPoint1NewCoordinates:
          controlPoint1NewCoordinates ?? this.controlPoint1NewCoordinates,
      controlPoint2OriginalCoordinates: controlPoint2OriginalCoordinates ??
          this.controlPoint2OriginalCoordinates,
      controlPoint2NewCoordinates:
          controlPoint2NewCoordinates ?? this.controlPoint2NewCoordinates,
      undoRedo: undoRedo ?? this.undoRedo,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(covariant MoveBezierLineSegmentCommand other) {
    if (identical(this, other)) return true;

    return other.lineSegment == lineSegment &&
        other.endPointOriginalCoordinates == endPointOriginalCoordinates &&
        other.endPointNewCoordinates == endPointNewCoordinates &&
        other.controlPoint1OriginalCoordinates ==
            controlPoint1OriginalCoordinates &&
        other.controlPoint1NewCoordinates == controlPoint1NewCoordinates &&
        other.controlPoint2OriginalCoordinates ==
            controlPoint2OriginalCoordinates &&
        other.controlPoint2NewCoordinates == controlPoint2NewCoordinates &&
        other.undoRedo == undoRedo &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        lineSegment,
        endPointOriginalCoordinates,
        endPointNewCoordinates,
        controlPoint1OriginalCoordinates,
        controlPoint1NewCoordinates,
        controlPoint2OriginalCoordinates,
        controlPoint2NewCoordinates,
        undoRedo,
        description,
      );

  @override
  void actualExecute(THFile thFile) {
    final THBezierCurveLineSegment originalLineSegment = lineSegment;
    final THBezierCurveLineSegment newLineSegment = lineSegment.copyWith(
        endPoint: originalLineSegment.endPoint
            .copyWith(coordinates: endPointNewCoordinates),
        controlPoint1: originalLineSegment.controlPoint1
            .copyWith(coordinates: controlPoint1NewCoordinates),
        controlPoint2: originalLineSegment.controlPoint2
            .copyWith(coordinates: controlPoint2NewCoordinates));

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
      map: undoRedoCommand.toMap(),
    );
  }
}
