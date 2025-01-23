import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/commands/move_bezier_line_segment_command.dart';
import 'package:mapiah/src/commands/move_straight_line_segment_command.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

class MoveLineCommand extends Command {
  final THLine originalLine;
  final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap;
  late final THLine newLine;
  late final LinkedHashMap<int, THLineSegment> newLineSegmentsMap;
  final Offset deltaOnCanvas;
  final bool isFromDelta;

  MoveLineCommand.forCWJM({
    required this.originalLine,
    required this.originalLineSegmentsMap,
    required this.newLine,
    required this.newLineSegmentsMap,
    required super.oppositeCommand,
    super.description = mpMoveLineCommandDescription,
    this.deltaOnCanvas = Offset.zero,
    this.isFromDelta = false,
  }) : super.forCWJM();

  MoveLineCommand({
    required this.originalLine,
    required this.originalLineSegmentsMap,
    required this.newLine,
    required this.newLineSegmentsMap,
    super.description = mpMoveLineCommandDescription,
    this.deltaOnCanvas = Offset.zero,
    this.isFromDelta = false,
  }) : super();

  MoveLineCommand.fromDelta({
    required this.originalLine,
    required this.originalLineSegmentsMap,
    required this.deltaOnCanvas,
    super.description = mpMoveLineCommandDescription,
  })  : newLine = originalLine.copyWith(),
        isFromDelta = true,
        super() {
    newLineSegmentsMap = LinkedHashMap<int, THLineSegment>();
    for (var entry in originalLineSegmentsMap.entries) {
      final int originalLineSegmentMapiahID = entry.key;
      final THLineSegment originalLineSegment = entry.value;
      late THLineSegment newLineSegment;

      switch (originalLineSegment) {
        case THStraightLineSegment _:
          newLineSegment = originalLineSegment.copyWith(
              endPoint: originalLineSegment.endPoint.copyWith(
            coordinates:
                originalLineSegment.endPoint.coordinates + deltaOnCanvas,
          ));
          break;
        case THBezierCurveLineSegment _:
          newLineSegment = originalLineSegment.copyWith(
              endPoint: originalLineSegment.endPoint.copyWith(
                  coordinates:
                      originalLineSegment.endPoint.coordinates + deltaOnCanvas),
              controlPoint1: originalLineSegment.controlPoint1.copyWith(
                  coordinates: originalLineSegment.controlPoint1.coordinates +
                      deltaOnCanvas),
              controlPoint2: originalLineSegment.controlPoint2.copyWith(
                  coordinates: originalLineSegment.controlPoint2.coordinates +
                      deltaOnCanvas));
          break;
      }

      newLineSegmentsMap[originalLineSegmentMapiahID] = newLineSegment;
    }
  }

  @override
  CommandType get type => CommandType.moveLine;

  @override
  Map<String, dynamic> toMap() {
    return {
      'commandType': type.name,
      'originalLine': originalLine.toMap(),
      'originalLineSegmentsMap': originalLineSegmentsMap
          .map((key, value) => MapEntry(key, value.toMap())),
      'newLine': newLine.toMap(),
      'newLineSegmentsMap':
          newLineSegmentsMap.map((key, value) => MapEntry(key, value.toMap())),
      'oppositeCommand': oppositeCommand?.toMap(),
      'deltaOnCanvas': {'dx': deltaOnCanvas.dx, 'dy': deltaOnCanvas.dy},
      'isFromDelta': isFromDelta,
      'description': description,
    };
  }

  factory MoveLineCommand.fromMap(Map<String, dynamic> map) {
    return MoveLineCommand.forCWJM(
      originalLine: THLine.fromMap(map['originalLine']),
      originalLineSegmentsMap: LinkedHashMap<int, THLineSegment>.from(
        map['originalLineSegmentsMap']
            .map((key, value) => MapEntry(key, THLineSegment.fromMap(value))),
      ),
      newLine: THLine.fromMap(map['newLine']),
      newLineSegmentsMap: LinkedHashMap<int, THLineSegment>.from(
        map['newLineSegmentsMap']
            .map((key, value) => MapEntry(key, THLineSegment.fromMap(value))),
      ),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : UndoRedoCommand.fromMap(map['oppositeCommand']),
      deltaOnCanvas:
          Offset(map['deltaOnCanvas']['dx'], map['deltaOnCanvas']['dy']),
      isFromDelta: map['isFromDelta'],
      description: map['description'],
    );
  }

  factory MoveLineCommand.fromJson(String jsonString) {
    return MoveLineCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  MoveLineCommand copyWith({
    THLine? originalLine,
    LinkedHashMap<int, THLineSegment>? originalLineSegmentsMap,
    THLine? newLine,
    LinkedHashMap<int, THLineSegment>? newLineSegmentsMap,
    UndoRedoCommand? oppositeCommand,
    Offset? deltaOnCanvas,
    bool? isFromDelta,
    String? description,
  }) {
    return MoveLineCommand.forCWJM(
      originalLine: originalLine ?? this.originalLine,
      originalLineSegmentsMap:
          originalLineSegmentsMap ?? this.originalLineSegmentsMap,
      newLine: newLine ?? this.newLine,
      newLineSegmentsMap: newLineSegmentsMap ?? this.newLineSegmentsMap,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      deltaOnCanvas: deltaOnCanvas ?? this.deltaOnCanvas,
      isFromDelta: isFromDelta ?? this.isFromDelta,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(covariant MoveLineCommand other) {
    if (identical(this, other)) return true;

    return other.originalLine == originalLine &&
        other.originalLineSegmentsMap == originalLineSegmentsMap &&
        other.newLine == newLine &&
        other.newLineSegmentsMap == newLineSegmentsMap &&
        other.oppositeCommand == oppositeCommand &&
        other.deltaOnCanvas == deltaOnCanvas &&
        other.isFromDelta == isFromDelta &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        originalLine,
        originalLineSegmentsMap,
        newLine,
        newLineSegmentsMap,
        oppositeCommand,
        deltaOnCanvas,
        isFromDelta,
        description,
      );

  @override
  void actualExecute(THFileStore thFileStore) {
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
              description: description,
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
              description: description,
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
              description: description,
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
              description: description,
            );
          }
          break;
      }

      command.execute(thFileStore);
    }
  }

  @override
  UndoRedoCommand createOppositeCommand() {
    final MoveLineCommand oppositeCommand = MoveLineCommand(
      originalLine: newLine,
      originalLineSegmentsMap: newLineSegmentsMap,
      newLine: originalLine,
      newLineSegmentsMap: originalLineSegmentsMap,
      description: description,
    );

    return UndoRedoCommand(
        commandType: oppositeCommand.type,
        description: description,
        map: oppositeCommand.toMap());
  }
}
