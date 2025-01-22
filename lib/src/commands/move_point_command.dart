import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

class MovePointCommand extends Command {
  late final int pointMapiahID;
  late final Offset originalCoordinates;
  late final Offset newCoordinates;

  MovePointCommand.forCWJM({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required this.newCoordinates,
    required super.undoRedo,
    super.description = mpMovePointCommandDescription,
  }) : super.forCWJM();

  MovePointCommand({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required this.newCoordinates,
    super.description = mpMovePointCommandDescription,
  }) : super();

  MovePointCommand.fromDelta({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required Offset deltaOnCanvas,
    super.description = mpMovePointCommandDescription,
  }) : super() {
    newCoordinates = originalCoordinates + deltaOnCanvas;
  }

  @override
  CommandType get type => CommandType.movePoint;

  @override
  Map<String, dynamic> toMap() {
    return {
      'pointMapiahID': pointMapiahID,
      'originalCoordinates': {
        'dx': originalCoordinates.dx,
        'dy': originalCoordinates.dy
      },
      'newCoordinates': {'dx': newCoordinates.dx, 'dy': newCoordinates.dy},
      'undoRedo': undoRedo.toMap(),
      'description': description,
    };
  }

  factory MovePointCommand.fromMap(Map<String, dynamic> map) {
    return MovePointCommand.forCWJM(
      pointMapiahID: map['pointMapiahID'],
      originalCoordinates: Offset(
          map['originalCoordinates']['dx'], map['originalCoordinates']['dy']),
      newCoordinates:
          Offset(map['newCoordinates']['dx'], map['newCoordinates']['dy']),
      undoRedo: UndoRedoCommand.fromMap(map['undoRedo']),
      description: map['description'],
    );
  }

  factory MovePointCommand.fromJson(String jsonString) {
    return MovePointCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  MovePointCommand copyWith({
    int? pointMapiahID,
    Offset? originalCoordinates,
    Offset? newCoordinates,
    UndoRedoCommand? undoRedo,
    String? description,
  }) {
    return MovePointCommand.forCWJM(
      pointMapiahID: pointMapiahID ?? this.pointMapiahID,
      originalCoordinates: originalCoordinates ?? this.originalCoordinates,
      newCoordinates: newCoordinates ?? this.newCoordinates,
      undoRedo: undoRedo ?? this.undoRedo,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(covariant MovePointCommand other) {
    if (identical(this, other)) return true;

    return other.pointMapiahID == pointMapiahID &&
        other.originalCoordinates == originalCoordinates &&
        other.newCoordinates == newCoordinates &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        pointMapiahID,
        originalCoordinates,
        newCoordinates,
        description,
      );

  @override
  UndoRedoCommand createUndoRedo(THFile thFile) {
    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MovePointCommand undoRedoCommand = MovePointCommand(
      pointMapiahID: pointMapiahID,
      originalCoordinates: newCoordinates,
      newCoordinates: originalCoordinates,
      description: description,
    );

    return UndoRedoCommand(
        type: undoRedoCommand.type,
        description: description,
        json: undoRedoCommand.toJson());
  }

  @override
  void actualExecute(THFile thFile) {
    final THPoint originalPoint =
        thFile.elementByMapiahID(pointMapiahID) as THPoint;
    final THPoint newPoint = originalPoint.copyWith(
        position: originalPoint.position.copyWith(coordinates: newCoordinates));

    thFile.substituteElement(newPoint);
  }
}
