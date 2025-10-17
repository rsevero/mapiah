import 'dart:io' show File;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';

class MPEditElementAux {
  static THBezierCurveLineSegment
  getBezierCurveLineSegmentFromStraightLineSegment({
    required Offset start,
    required THStraightLineSegment straightLineSegment,
    int? decimalPositions,
  }) {
    final Offset end = straightLineSegment.endPoint.coordinates;
    final double dxThird = (end.dx - start.dx) / 3;
    final double dyThird = (end.dy - start.dy) / 3;
    final Offset controlPoint1 = Offset(start.dx + dxThird, start.dy + dyThird);
    final Offset controlPoint2 = Offset(
      controlPoint1.dx + dxThird,
      controlPoint1.dy + dyThird,
    );

    return THBezierCurveLineSegment.forCWJM(
      mpID: straightLineSegment.mpID,
      parentMPID: straightLineSegment.parentMPID,
      endPoint: straightLineSegment.endPoint,
      controlPoint1: THPositionPart(
        coordinates: controlPoint1,
        decimalPositions: decimalPositions,
      ),
      controlPoint2: THPositionPart(
        coordinates: controlPoint2,
        decimalPositions: decimalPositions,
      ),
      optionsMap: straightLineSegment.optionsMap,
      attrOptionsMap: straightLineSegment.attrOptionsMap,
      originalLineInTH2File: '',
    );
  }

  static bool isEndPoint(MPEndControlPointType type) {
    return ((type == MPEndControlPointType.endPointStraight) ||
        (type == MPEndControlPointType.endPointBezierCurve));
  }

  static bool isControlPoint(MPEndControlPointType type) {
    return ((type == MPEndControlPointType.controlPoint1) ||
        (type == MPEndControlPointType.controlPoint2));
  }

  static Offset? moveMirrorControlPoint(
    MPMoveControlPointSmoothInfo moveControlPointSmoothInfo,
    Offset point,
  ) {
    final Offset junction = moveControlPointSmoothInfo.junction!;
    final Offset newDirectionVector = point - junction;
    final double newDirectionVectorDistance = newDirectionVector.distance;

    if (newDirectionVectorDistance == 0) {
      return null;
    }

    final Offset newUnitDirection = Offset(
      newDirectionVector.dx / newDirectionVectorDistance,
      newDirectionVector.dy / newDirectionVectorDistance,
    );
    final double currentLength =
        moveControlPointSmoothInfo.adjacentControlPointLength!;
    final Offset newAdjacentControlPointPosition =
        junction - newUnitDirection * currentLength;

    return newAdjacentControlPointPosition;
  }

  static Offset moveControlPointInLine(
    MPMoveControlPointSmoothInfo moveControlPointSmoothInfo,
    Offset point,
  ) {
    final Offset start = moveControlPointSmoothInfo.straightStart!;
    final Offset junction = moveControlPointSmoothInfo.junction!;
    final Offset line = moveControlPointSmoothInfo.straightLine!;
    final Offset toPoint = point - start;
    final double lineDx = line.dx;
    final double lineDy = line.dy;
    final double t =
        (toPoint.dx * lineDx + toPoint.dy * lineDy) /
        (lineDx * lineDx + lineDy * lineDy);
    final Offset newPosition = (t > 1.0) ? start + line * t : junction;

    return newPosition;
  }

  static List<THBezierCurveLineSegment> getSmoothedBezierLineSegments({
    required THBezierCurveLineSegment lineSegment,
    required THBezierCurveLineSegment nextLineSegment,
    required THFile thFile,
  }) {
    final List<THBezierCurveLineSegment> smoothedSegments = [];
    final Offset junction = lineSegment.endPoint.coordinates;
    final MPAlignedBezierHandlesWeightedResult? result =
        alignAdjacentBezierHandlesWeighted(
          junction: junction,
          currentControlPoint2: lineSegment.controlPoint2.coordinates,
          nextControlPoint1: nextLineSegment.controlPoint1.coordinates,
        );

    // If unchanged (either length zero), return empty list of modified line
    // segments.
    if (result == null) {
      return smoothedSegments;
    }

    final THBezierCurveLineSegment newLineSegment = lineSegment.copyWith(
      controlPoint2: THPositionPart(
        coordinates: result.newCurrentControlPoint2,
      ),
      originalLineInTH2File: '',
    );
    final THBezierCurveLineSegment newNextLineSegment = nextLineSegment
        .copyWith(
          controlPoint1: THPositionPart(
            coordinates: result.newNextControlPoint1,
          ),
          originalLineInTH2File: '',
        );

    smoothedSegments.add(newLineSegment);
    smoothedSegments.add(newNextLineSegment);

    return smoothedSegments;
  }

  /// Separate helper: returns null if either handle length is zero (no change),
  /// otherwise a result with the re-aligned control points using
  /// length-weighted direction.
  static MPAlignedBezierHandlesWeightedResult?
  alignAdjacentBezierHandlesWeighted({
    required Offset junction,
    required Offset currentControlPoint2,
    required Offset nextControlPoint1,
    double epsilon = mpDoubleComparisonEpsilon,
  }) {
    final Offset vCurrentControlPoint2 =
        currentControlPoint2 -
        junction; // Outgoing from junction (left segment)
    final Offset vNextControlPoint1 =
        junction - nextControlPoint1; // Outgoing from junction (right segment)
    final double lenCurrentControlPoint2 = vCurrentControlPoint2.distance;
    final double lenNextControlPoint1 = vNextControlPoint1.distance;

    if (lenCurrentControlPoint2 == 0 || lenNextControlPoint1 == 0) {
      return null;
    }

    Offset dirVector =
        vCurrentControlPoint2 +
        vNextControlPoint1; // Weighted by length inherently.
    double dirLen = dirVector.distance;

    if (dirLen < epsilon) {
      dirVector = (lenCurrentControlPoint2 >= lenNextControlPoint1)
          ? vCurrentControlPoint2
          : vNextControlPoint1;
      dirLen = dirVector.distance;
    }

    final Offset dir = Offset(dirVector.dx / dirLen, dirVector.dy / dirLen);
    final Offset newC2 = junction + dir * lenCurrentControlPoint2;
    final Offset newC1 = junction - dir * lenNextControlPoint1;

    return MPAlignedBezierHandlesWeightedResult(
      newCurrentControlPoint2: newC2,
      newNextControlPoint1: newC1,
    );
  }

  static Offset? getControlPointAlignedToStraight({
    required Offset controlPoint,
    required Offset startStraightLineSegment,
    required Offset junction,
    required THFile thFile,
  }) {
    final Offset straightLineVector = junction - startStraightLineSegment;
    final Offset controlPointVector = controlPoint - junction;
    final double straightLineDistance = straightLineVector.distance;
    final double controlPointDistance = controlPointVector.distance;

    if (straightLineDistance == 0 || controlPointDistance == 0) {
      return null;
    }

    final Offset straightLineDirection = Offset(
      straightLineVector.dx / straightLineDistance,
      straightLineVector.dy / straightLineDistance,
    );

    final Offset newControlPoint =
        junction + straightLineDirection * controlPointDistance;

    return newControlPoint;
  }

  static Future<ui.Image> getRasterImageFrameInfo(
    TH2FileEditController th2FileEditController,
    String imageFilename,
  ) {
    final String resolvedPath = MPDirectoryAux.getResolvedPath(
      th2FileEditController.thFile.filename,
      imageFilename,
    );

    final File file = File(resolvedPath);

    if (file.existsSync()) {
      final Uint8List bytes = file.readAsBytesSync();

      return ui
          .instantiateImageCodec(bytes)
          .then((ui.Codec codec) => codec.getNextFrame())
          .then((ui.FrameInfo frame) => frame.image);
    } else {
      return rootBundle
          .load('assets/images/image_not_found.png')
          .then(
            (ByteData assetData) =>
                ui.instantiateImageCodec(assetData.buffer.asUint8List()),
          )
          .then((ui.Codec codec) => codec.getNextFrame())
          .then((ui.FrameInfo frame) => frame.image);
    }
  }

  /// Normalizes a string to be a valid THID (matching /^[a-zA-Z0-9_][a-zA-Z0-9_\-]*$/).
  /// - Removes invalid leading characters.
  /// - Replaces invalid characters with '_'.
  static String normalizeToTHID(String input) {
    if (input.isEmpty) return '';

    // Remove invalid leading characters
    String normalized = input.replaceFirst(RegExp(r'^[^a-zA-Z0-9_]+'), '');

    // Replace invalid characters in the rest of the string with '_'
    normalized = normalized.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

    return normalized;
  }

  static String getFilenameFromPath(String path) {
    // Handles both '/' and '\' as separators
    return path.split(RegExp(r'[\\/]+')).last;
  }

  static void addOptionToElement({
    required THCommandOption option,
    required THHasOptionsMixin element,
    THFile? thFile,
  }) {
    final bool elementUpdated = element.addUpdateOption(option);

    if (elementUpdated && (thFile != null)) {
      thFile.substituteElement(element);
    }
  }
}

class MPAlignedBezierHandlesWeightedResult {
  final Offset newCurrentControlPoint2;
  final Offset newNextControlPoint1;

  const MPAlignedBezierHandlesWeightedResult({
    required this.newCurrentControlPoint2,
    required this.newNextControlPoint1,
  });
}

class MPMoveControlPointSmoothInfo {
  final bool shouldSmooth;
  final bool? isAdjacentStraight;
  final THBezierCurveLineSegment? adjacentLineSegment;
  final THBezierCurveLineSegment lineSegment;
  final MPEndControlPointType controlPointType;
  final Offset? straightLine;
  final Offset? straightStart;
  final Offset? junction;
  final double? adjacentControlPointLength;

  MPMoveControlPointSmoothInfo({
    required this.shouldSmooth,
    this.isAdjacentStraight,
    this.adjacentLineSegment,
    required this.lineSegment,
    required this.controlPointType,
    this.straightLine,
    this.straightStart,
    this.junction,
    this.adjacentControlPointLength,
  }) {
    if (shouldSmooth) {
      assert(isAdjacentStraight != null);
      assert(junction != null);
      if (isAdjacentStraight!) {
        assert(straightLine != null);
        assert(straightStart != null);
      } else {
        assert(adjacentLineSegment != null);
        assert(adjacentControlPointLength != null);
      }
    }
  }
}
