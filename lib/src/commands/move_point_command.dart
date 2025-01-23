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
    required super.oppositeCommand,
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
      'oppositeCommand': oppositeCommand?.toMap(),
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
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : UndoRedoCommand.fromMap(map['oppositeCommand']),
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
    UndoRedoCommand? oppositeCommand,
    String? description,
  }) {
    return MovePointCommand.forCWJM(
      pointMapiahID: pointMapiahID ?? this.pointMapiahID,
      originalCoordinates: originalCoordinates ?? this.originalCoordinates,
      modifiedCoordinates: modifiedCoordinates ?? this.modifiedCoordinates,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(covariant MovePointCommand other) {
    if (identical(this, other)) return true;

    return other.pointMapiahID == pointMapiahID &&
        other.originalCoordinates == originalCoordinates &&
        other.modifiedCoordinates == modifiedCoordinates &&
        other.oppositeCommand == oppositeCommand &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        pointMapiahID,
        originalCoordinates,
        modifiedCoordinates,
        oppositeCommand,
        description,
      );

  @override
  UndoRedoCommand createOppositeCommand(THFile thFile) {
    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MovePointCommand oppositeCommand = MovePointCommand(
      pointMapiahID: pointMapiahID,
      originalCoordinates: modifiedCoordinates,
      modifiedCoordinates: originalCoordinates,
      description: description,
    );

    return UndoRedoCommand(
        commandType: oppositeCommand.type,
        description: description,
        map: oppositeCommand.toMap());
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
