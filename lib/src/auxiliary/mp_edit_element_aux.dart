import 'dart:collection';
import 'dart:io' show File;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/auxiliary/mp_simplify_straight_to_bezier.dart';
import 'package:mapiah/src/auxiliary/mp_straight_line_simplification_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';

class MPEditElementAux {
  static THElement _getDuplicateElement({
    required THElement element,
    int mpID = mpCreateNewMPIDForElement,
    int? newParentMPID,
  }) {
    final THElement duplicate = element.copyWith(
      mpID: mpID,
      parentMPID: newParentMPID,
      originalLineInTH2File: '',
    );

    return duplicate;
  }

  static List<THElement> _getDuplicateArea({
    required THArea area,
    int? newParentMPID,
    required THFile thFile,
  }) {
    final int duplicatedAreaMPID = mpLocator.mpGeneralController
        .nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicatedOptions =
        _getDuplicateCommandOptions(
          options: area.optionsMap,
          parentMPID: duplicatedAreaMPID,
        );
    final SplayTreeMap<String, THAttrCommandOption> duplicatedAttrOptions =
        _getDuplicateCommandAttrOptions(
          attrOptions: area.attrOptionsMap,
          parentMPID: duplicatedAreaMPID,
        );
    final THArea duplicateArea = area.copyWith(
      mpID: duplicatedAreaMPID,
      parentMPID: newParentMPID,
      attrOptionsMap: duplicatedAttrOptions,
      optionsMap: duplicatedOptions,
      originalLineInTH2File: '',
    );
    final List<THElement> duplicateChildren = [];
    final List<int> childrenMPIDs = area.childrenMPIDs;

    for (final int childMPID in childrenMPIDs) {
      final THElement childElement = thFile.elementByMPID(childMPID);

      if (childElement is THAreaBorderTHID) {
        final String borderTHID = childElement.thID;

        if (!thFile.hasElementByTHID(borderTHID)) {
          throw Exception(
            'Border THID $borderTHID not found in THFile when duplicating area with MPEditElementAux.getDuplicateArea().',
          );
        }

        final THLine borderLine = thFile.elementByTHID(borderTHID) as THLine;
        final THAreaBorderTHID duplicateBorderTHID =
            _getDuplicateElement(
                  element: childElement,
                  newParentMPID: duplicatedAreaMPID,
                )
                as THAreaBorderTHID;
        final List<THElement> duplicatedBorderLine = _getDuplicateLine(
          line: borderLine,
          newParentMPID: duplicatedAreaMPID,
          thFile: thFile,
        );

        duplicateChildren.addAll(duplicatedBorderLine);
        duplicateChildren.add(duplicateBorderTHID);
      } else {
        final List<THElement> duplicatedChild = getDuplicateElement(
          element: childElement,
          newParentMPID: duplicatedAreaMPID,
          thFile: thFile,
        );

        duplicateChildren.addAll(duplicatedChild);
      }
    }

    return [duplicateArea, ...duplicateChildren];
  }

  static List<THElement> _getDuplicateChildren({
    required THIsParentMixin parent,
    int? newParentMPID,
    required THFile thFile,
  }) {
    final List<THElement> duplicateChildren = [];

    for (final int childMPID in parent.childrenMPIDs) {
      final THElement childElement = thFile.elementByMPID(childMPID);
      final List<THElement> duplicatedChild = getDuplicateElement(
        element: childElement,
        newParentMPID: newParentMPID,
        thFile: thFile,
      );

      duplicateChildren.addAll(duplicatedChild);
    }

    return duplicateChildren;
  }

  static List<THElement> getDuplicateElement({
    required THElement element,
    int? newParentMPID,
    required THFile thFile,
  }) {
    final List<THElement> duplicate;

    switch (element) {
      case THArea area:
        duplicate = _getDuplicateArea(
          area: area,
          newParentMPID: newParentMPID,
          thFile: thFile,
        );
      case THLine line:
        duplicate = _getDuplicateLine(
          line: line,
          newParentMPID: newParentMPID,
          thFile: thFile,
        );
      case THMultiLineComment multiComment:
        duplicate = _getDuplicateMultiLineComment(
          multiComment: multiComment,
          newParentMPID: newParentMPID,
          thFile: thFile,
        );
      case THPoint point:
        duplicate = _getDuplicatePoint(
          point: point,
          newParentMPID: newParentMPID,
        );
      case THScrap scrap:
        duplicate = _getDuplicateScrap(
          scrap: scrap,
          newParentMPID: newParentMPID,
          thFile: thFile,
        );
      default:
        duplicate = [
          _getDuplicateElement(element: element, newParentMPID: newParentMPID),
        ];
    }

    return duplicate;
  }

  static List<THElement> _getDuplicateLine({
    required THLine line,
    int? newParentMPID,
    required THFile thFile,
  }) {
    final int duplicatedLineMPID = mpLocator.mpGeneralController
        .nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicatedOptions =
        _getDuplicateCommandOptions(
          options: line.optionsMap,
          parentMPID: duplicatedLineMPID,
        );
    final SplayTreeMap<String, THAttrCommandOption> duplicatedAttrOptions =
        _getDuplicateCommandAttrOptions(
          attrOptions: line.attrOptionsMap,
          parentMPID: duplicatedLineMPID,
        );
    final THLine duplicateLine = line.copyWith(
      mpID: duplicatedLineMPID,
      parentMPID: newParentMPID,
      optionsMap: duplicatedOptions,
      attrOptionsMap: duplicatedAttrOptions,
      originalLineInTH2File: '',
    );
    final List<THElement> duplicateChildren = _getDuplicateChildren(
      parent: line,
      newParentMPID: duplicatedLineMPID,
      thFile: thFile,
    );

    return [duplicateLine, ...duplicateChildren];
  }

  static List<THElement> _getDuplicateMultiLineComment({
    required THMultiLineComment multiComment,
    int? newParentMPID,
    required THFile thFile,
  }) {
    final THMultiLineComment duplicateMultiComment =
        _getDuplicateElement(
              element: multiComment,
              newParentMPID: newParentMPID,
            )
            as THMultiLineComment;
    final int duplicatedMultiCommentMPID = duplicateMultiComment.mpID;
    final List<THElement> duplicateChildren = _getDuplicateChildren(
      parent: multiComment,
      newParentMPID: duplicatedMultiCommentMPID,
      thFile: thFile,
    );

    return [duplicateMultiComment, ...duplicateChildren];
  }

  static SplayTreeMap<String, THAttrCommandOption>
  _getDuplicateCommandAttrOptions({
    required SplayTreeMap<String, THAttrCommandOption> attrOptions,
    int? parentMPID,
  }) {
    final SplayTreeMap<String, THAttrCommandOption> duplicateAttrOptions =
        SplayTreeMap();

    for (final attrOptionEntry in attrOptions.entries) {
      final THAttrCommandOption duplicateAttrOption = attrOptionEntry.value
          .copyWith(parentMPID: parentMPID, originalLineInTH2File: '');

      duplicateAttrOptions[attrOptionEntry.key] = duplicateAttrOption;
    }

    return duplicateAttrOptions;
  }

  static SplayTreeMap<THCommandOptionType, THCommandOption>
  _getDuplicateCommandOptions({
    required SplayTreeMap<THCommandOptionType, THCommandOption> options,

    int? parentMPID,
  }) {
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicateOptions =
        SplayTreeMap();

    for (final optionEntry in options.entries) {
      final THCommandOption duplicateOption = optionEntry.value.copyWith(
        parentMPID: parentMPID,
        originalLineInTH2File: '',
      );

      duplicateOptions[optionEntry.key] = duplicateOption;
    }

    return duplicateOptions;
  }

  static List<THElement> _getDuplicatePoint({
    required THPoint point,
    int? newParentMPID,
  }) {
    final int duplicatedPointMPID = mpLocator.mpGeneralController
        .nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicatedOptions =
        _getDuplicateCommandOptions(
          options: point.optionsMap,
          parentMPID: duplicatedPointMPID,
        );
    final SplayTreeMap<String, THAttrCommandOption> duplicatedAttrOptions =
        _getDuplicateCommandAttrOptions(
          attrOptions: point.attrOptionsMap,
          parentMPID: duplicatedPointMPID,
        );
    final THPoint duplicatePoint = point.copyWith(
      mpID: duplicatedPointMPID,
      parentMPID: newParentMPID,
      optionsMap: duplicatedOptions,
      attrOptionsMap: duplicatedAttrOptions,
      originalLineInTH2File: '',
    );

    return [duplicatePoint];
  }

  static List<THElement> _getDuplicateScrap({
    required THScrap scrap,
    int? newParentMPID,
    required THFile thFile,
  }) {
    final THScrap duplicateScrap =
        _getDuplicateElement(element: scrap, newParentMPID: newParentMPID)
            as THScrap;
    final int duplicatedScrapMPID = duplicateScrap.mpID;
    final List<THElement> duplicateChildren = _getDuplicateChildren(
      parent: scrap,
      newParentMPID: duplicatedScrapMPID,
      thFile: thFile,
    );

    return [duplicateScrap, ...duplicateChildren];
  }

  static THStraightLineSegment createStraightLineSegmentFromCanvasCoordinates({
    required Offset endPointCanvasCoordinates,
    required int lineMPID,
    required TH2FileEditController th2FileEditController,
  }) {
    final THStraightLineSegment lineSegment = THStraightLineSegment(
      parentMPID: lineMPID,
      endPoint: THPositionPart(
        coordinates: endPointCanvasCoordinates,
        decimalPositions: th2FileEditController.currentDecimalPositions,
      ),
    );

    return lineSegment;
  }

  static THStraightLineSegment createStraightLineSegmentFromScreenCoordinates({
    required Offset endPointScreenCoordinates,
    required int lineMPID,
    required TH2FileEditController th2FileEditController,
  }) {
    final Offset endPointCanvasCoordinates = th2FileEditController
        .offsetScreenToCanvas(endPointScreenCoordinates);

    return createStraightLineSegmentFromCanvasCoordinates(
      endPointCanvasCoordinates: endPointCanvasCoordinates,
      lineMPID: lineMPID,
      th2FileEditController: th2FileEditController,
    );
  }

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

  static List<int> getEmptyLinesAfter({
    required THFile thFile,
    required THIsParentMixin parent,
    required int positionInParent,
  }) {
    final List<int> emptyLinesAfter = [];
    final List<int> siblingsMPIDs = parent.childrenMPIDs;

    for (int i = positionInParent + 1; i < siblingsMPIDs.length; i++) {
      final int siblingMPID = siblingsMPIDs[i];
      final THElementType siblingElementType = thFile.getElementTypeByMPID(
        siblingMPID,
      );

      if (siblingElementType == THElementType.emptyLine) {
        emptyLinesAfter.add(siblingMPID);
      } else {
        break;
      }
    }

    return emptyLinesAfter;
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

  static MPCommand getReplaceLineSegmentsCommand({
    required THLine originalLine,
    required THFile thFile,
    required List<THLineSegment> newLineSegmentsList,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.replaceLineSegments,
  }) {
    final List<({THLineSegment lineSegment, int lineSegmentPosition})>
    originalLineSegments = originalLine.getLineSegmentsChildPositionList(
      thFile,
    );
    final List<({THLineSegment lineSegment, int lineSegmentPosition})>
    newLineSegments = convertTHLineSegmentListToLineSegmentWithPositionList(
      newLineSegmentsList,
    );
    final MPCommand replaceCommand = MPReplaceLineSegmentsCommand(
      lineMPID: originalLine.mpID,
      originalLineSegments: originalLineSegments,
      newLineSegments: newLineSegments,
      descriptionType: descriptionType,
    );

    return replaceCommand;
  }

  static List<({THLineSegment lineSegment, int lineSegmentPosition})>
  convertTHLineSegmentListToLineSegmentWithPositionList(
    List<THLineSegment> lineSegmentsList,
  ) {
    final List<({THLineSegment lineSegment, int lineSegmentPosition})>
    lineSegmentsWithPosition = lineSegmentsList
        .map<({THLineSegment lineSegment, int lineSegmentPosition})>(
          (s) => (
            lineSegment: s,
            lineSegmentPosition: mpAddChildAtEndMinusOneOfParentChildrenList,
          ),
        )
        .toList();

    return lineSegmentsWithPosition;
  }

  static MPCommand?
  getSimplifyCommandForStraightLineSegmentsConvertedToBezierCurves({
    required THFile thFile,
    required THLine originalLine,
    required List<THLineSegment> originalLineSegmentsList,
    required double accuracy,
    required int decimalPositions,
  }) {
    final List<THLineSegment> bezierLineSegments =
        mpConvertTHStraightToTHBezierLineSegments(
          originalStraightLineSegmentsList: originalLineSegmentsList,
          accuracy: accuracy,
          decimalPositions: decimalPositions,
        );
    final List<({THLineSegment lineSegment, int lineSegmentPosition})>
    newLineSegments =
        MPEditElementAux.convertTHLineSegmentListToLineSegmentWithPositionList(
          bezierLineSegments,
        );
    final List<({THLineSegment lineSegment, int lineSegmentPosition})>
    originalLineSegments = originalLine.getLineSegmentsChildPositionList(
      thFile,
    );
    final MPCommand simplifyCommand = MPReplaceLineSegmentsCommand(
      lineMPID: originalLine.mpID,
      originalLineSegments: originalLineSegments,
      newLineSegments: newLineSegments,
    );

    return simplifyCommand;
  }

  static List<THLineSegment>
  mpSimplifyBezierCurveLineSegmentsToStraightLineSegments({
    required THFile thFile,
    required THLine originalLine,
    required List<THLineSegment> originalLineSegmentsList,
    required double convertToStraightRefTolerance,
    required double accuracy,
    required int decimalPositions,
  }) {
    if (originalLineSegmentsList.length <= 1) {
      return originalLineSegmentsList;
    }

    // Strategy:
    // 1) Ensure first segment is a straight "move-to" point (defines start).
    // 2) For each following segment:
    //    - If straight: keep it.
    //    - If Bézier: flatten adaptively using de Casteljau with a large
    //      flatness tolerance eps = accuracy * 10, and emit straight segments
    //      approximating the curve.

    final double tolerance =
        convertToStraightRefTolerance * mpConvertBezierToStraightFactor;
    final double toleranceSquared = tolerance * tolerance;
    final List<THLineSegment> straightSegments = <THLineSegment>[];

    // 1) First segment defines the starting point; ensure it's straight.
    final THLineSegment firstSeg = originalLineSegmentsList.first;

    straightSegments.add(
      firstSeg is THStraightLineSegment
          ? firstSeg
          : THStraightLineSegment(
              parentMPID: firstSeg.parentMPID,
              endPoint: firstSeg.endPoint,
              optionsMap: firstSeg.optionsMap,
              attrOptionsMap: firstSeg.attrOptionsMap,
            ),
    );

    Offset start = firstSeg.endPoint.coordinates;

    // 2) Convert remaining segments.
    for (final THLineSegment seg in originalLineSegmentsList.skip(1)) {
      if (seg is THStraightLineSegment) {
        straightSegments.add(seg);
        start = seg.endPoint.coordinates;
      } else if (seg is THBezierCurveLineSegment) {
        final Offset p0 = start;
        final Offset p1 = seg.controlPoint1.coordinates;
        final Offset p2 = seg.controlPoint2.coordinates;
        final Offset p3 = seg.endPoint.coordinates;
        final List<Offset> endPoints = MPNumericAux.flattenCubic(
          p0,
          p1,
          p2,
          p3,
          toleranceSquared,
        );
        endPoints.removeLast();
        for (final Offset endPoint in endPoints) {
          straightSegments.add(
            THStraightLineSegment(
              parentMPID: seg.parentMPID,
              endPoint: THPositionPart(
                coordinates: endPoint,
                decimalPositions: decimalPositions,
              ),
            ),
          );
        }
        straightSegments.add(
          THStraightLineSegment(
            parentMPID: seg.parentMPID,
            endPoint: seg.endPoint,
            optionsMap: seg.optionsMap,
            attrOptionsMap: seg.attrOptionsMap,
          ),
        );
        start = p3;
      } else {
        throw Exception(
          'Unsupported line segment type for simplification to straight lines at MPEditElementAux.flattenCubic().',
        );
      }
    }

    final List<THLineSegment> simplifiedLineSegments =
        MPStraightLineSimplificationAux.raumerDouglasPeuckerIterative(
          originalStraightLineSegments: straightSegments,
          accuracy: accuracy,
        );

    return simplifiedLineSegments;
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

class MPSingleTypeLineSegmentList {
  final THElementType type;
  final List<THLineSegment> lineSegments;

  MPSingleTypeLineSegmentList({required this.type, required this.lineSegments});
}
