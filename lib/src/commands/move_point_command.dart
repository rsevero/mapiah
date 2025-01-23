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
  late final Offset modifiedCoordinates;

  MovePointCommand.forCWJM({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required this.modifiedCoordinates,
    required super.undoRedo,
    super.description = mpMovePointCommandDescription,
  }) : super.forCWJM();

  MovePointCommand({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required this.modifiedCoordinates,
    super.description = mpMovePointCommandDescription,
  }) : super();

  MovePointCommand.fromDelta({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required Offset deltaOnCanvas,
    super.description = mpMovePointCommandDescription,
  }) : super() {
    modifiedCoordinates = originalCoordinates + deltaOnCanvas;
  }

  @override
  CommandType get type => CommandType.movePoint;

  @override
  Map<String, dynamic> toMap() {
    return {
      'commandType': type.name,
      'pointMapiahID': pointMapiahID,
      'originalCoordinates': {
        'dx': originalCoordinates.dx,
        'dy': originalCoordinates.dy
      },
      'modifiedCoordinates': {
        'dx': modifiedCoordinates.dx,
        'dy': modifiedCoordinates.dy
      },
      'undoRedo': undoRedo?.toMap(),
      'description': description,
    };
  }

  factory MovePointCommand.fromMap(Map<String, dynamic> map) {
    return MovePointCommand.forCWJM(
      pointMapiahID: map['pointMapiahID'],
      originalCoordinates: Offset(
          map['originalCoordinates']['dx'], map['originalCoordinates']['dy']),
      modifiedCoordinates: Offset(
          map['modifiedCoordinates']['dx'], map['modifiedCoordinates']['dy']),
      undoRedo: map['undoRedo'] == null
          ? null
          : UndoRedoCommand.fromMap(map['undoRedo']),
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
    Offset? modifiedCoordinates,
    UndoRedoCommand? undoRedo,
    String? description,
  }) {
    return MovePointCommand.forCWJM(
      pointMapiahID: pointMapiahID ?? this.pointMapiahID,
      originalCoordinates: originalCoordinates ?? this.originalCoordinates,
      modifiedCoordinates: modifiedCoordinates ?? this.modifiedCoordinates,
      undoRedo: undoRedo ?? this.undoRedo,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(covariant MovePointCommand other) {
    if (identical(this, other)) return true;

    return other.pointMapiahID == pointMapiahID &&
        other.originalCoordinates == originalCoordinates &&
        other.modifiedCoordinates == modifiedCoordinates &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        pointMapiahID,
        originalCoordinates,
        modifiedCoordinates,
        description,
      );

  @override
  UndoRedoCommand createUndoRedo(THFile thFile) {
    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MovePointCommand undoRedoCommand = MovePointCommand(
      pointMapiahID: pointMapiahID,
      originalCoordinates: modifiedCoordinates,
      modifiedCoordinates: originalCoordinates,
      description: description,
    );

    return UndoRedoCommand(
        type: undoRedoCommand.type,
        description: description,
        map: undoRedoCommand.toMap());
  }

  @override
  void actualExecute(THFile thFile) {
    final THPoint originalPoint =
        thFile.elementByMapiahID(pointMapiahID) as THPoint;
    final THPoint modifiedPoint = originalPoint.copyWith(
        position:
            originalPoint.position.copyWith(coordinates: modifiedCoordinates));

    thFile.substituteElement(modifiedPoint);
  }
}
