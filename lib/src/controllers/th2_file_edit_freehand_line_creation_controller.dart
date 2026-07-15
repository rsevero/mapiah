// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_freehand_line_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/mp_pla_type_subtype.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_freehand_line_creation_controller.g.dart';

class TH2FileEditFreehandLineCreationController = TH2FileEditFreehandLineCreationControllerBase
    with _$TH2FileEditFreehandLineCreationController;

/// Captures an in-memory freehand pointer stroke and, on success, commits it
/// as one complete, undoable [THLine] made only of [THStraightLineSegment]
/// children. Kept separate from [TH2FileEditAreaLineCreationController]
/// (which edits the file model incrementally for the click-based line tool)
/// because freehand capture must stay transient until pointer-up.
abstract class TH2FileEditFreehandLineCreationControllerBase with Store {
  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditFreehandLineCreationControllerBase(this._th2FileEditController);

  @readonly
  bool _isCapturing = false;

  @readonly
  ObservableList<Offset> _sampledCanvasPoints = ObservableList<Offset>();

  @readonly
  Rect? _rawStrokeBoundingBox;

  @readonly
  double _activeSampleSpacingOnScreen = mpFreehandMinimumSampleSpacingOnScreen;

  Offset? _firstScreenPosition;

  Offset? _lastAcceptedScreenPosition;

  /// Starts a new stroke at [screenPosition], snapped like an ordinary new
  /// line start point. Abandons any previously unfinished stroke first.
  @action
  void startStroke(Offset screenPosition) {
    if (_isCapturing) {
      abandonStroke();
    }

    final Offset canvasPosition = _snapedCanvasPositionFromScreenPosition(
      screenPosition,
    );

    _isCapturing = true;
    _activeSampleSpacingOnScreen = mpFreehandMinimumSampleSpacingOnScreen;
    _firstScreenPosition = screenPosition;
    _lastAcceptedScreenPosition = screenPosition;
    _sampledCanvasPoints.clear();
    _sampledCanvasPoints.add(canvasPosition);
    _rawStrokeBoundingBox = Rect.fromPoints(canvasPosition, canvasPosition);

    _th2FileEditController.triggerFreehandLineRedraw();
  }

  /// Appends [screenPosition] as a new sample when it is at least
  /// [_activeSampleSpacingOnScreen] logical pixels away from the last
  /// accepted sample. Does nothing while no stroke is being captured.
  @action
  void appendStrokeSample(Offset screenPosition) {
    if (!_isCapturing) {
      return;
    }

    if (!MPFreehandLineAux.isSampleFarEnough(
      candidateScreenPosition: screenPosition,
      lastAcceptedScreenPosition: _lastAcceptedScreenPosition!,
      sampleSpacingOnScreen: _activeSampleSpacingOnScreen,
    )) {
      return;
    }

    _acceptSample(screenPosition, snap: false);

    if (_sampledCanvasPoints.length >= mpFreehandMaximumSampleCount) {
      _compactSampleBuffer();
    }

    _th2FileEditController.triggerFreehandLineRedraw();
  }

  /// Ends capture at [screenPosition], always retaining it as the snapped
  /// final point, then simplifies the stroke and commits one [THLine] in
  /// one undoable [MPAddLineCommand]. A stroke shorter than
  /// [mpFreehandMinimumCommittedStrokeLengthOnScreen] is abandoned instead of
  /// committed. Clears all transient state on every exit path.
  @action
  void finishStroke(Offset screenPosition) {
    if (!_isCapturing) {
      return;
    }

    final Offset firstScreenPosition = _firstScreenPosition!;

    _acceptSample(screenPosition, snap: true);

    if (!MPFreehandLineAux.meetsMinimumCommittedStrokeLength(
      firstScreenPosition: firstScreenPosition,
      lastScreenPosition: screenPosition,
    )) {
      abandonStroke();

      return;
    }

    try {
      final MPPLATypeSubtype typeSubtype = _th2FileEditController
          .elementEditController
          .getLineTypeAndSubtypeForNewLine();
      final THLine newLine = THLine.fromString(
        parentMPID: _th2FileEditController.activeScrapID,
        lineTypeString: typeSubtype.type,
      );
      final List<THStraightLineSegment>? straightLineSegments =
          MPFreehandLineAux.simplifyStrokeToStraightLineSegments(
            rawCanvasPoints: List<Offset>.of(_sampledCanvasPoints),
            rawBoundingBox: _rawStrokeBoundingBox!,
            lineMPID: newLine.mpID,
            decimalPositions: _th2FileEditController.currentDecimalPositions,
          );

      if (straightLineSegments == null) {
        return;
      }

      final List<THElement> lineChildren = [
        ...straightLineSegments,
        THEndline(parentMPID: newLine.mpID),
      ];
      final MPAddLineCommand addLineCommand = MPCommandFactory
          .addLineFromLineChildren(
            line: newLine,
            typeSubtype: typeSubtype,
            lineChildren: lineChildren,
            th2FileEditController: _th2FileEditController,
          );

      _th2FileEditController.execute(addLineCommand);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        'TH2FileEditFreehandLineCreationController.finishStroke() failed '
        'to commit the captured stroke.',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      _clearStrokeState();
    }
  }

  /// Discards the in-memory stroke without touching the file or the undo
  /// queue. Safe to call when no stroke is being captured.
  @action
  void abandonStroke() {
    _clearStrokeState();
  }

  void _acceptSample(Offset screenPosition, {required bool snap}) {
    final Offset canvasPosition = snap
        ? _snapedCanvasPositionFromScreenPosition(screenPosition)
        : _th2FileEditController.offsetScreenToCanvas(screenPosition);

    _sampledCanvasPoints.add(canvasPosition);
    _rawStrokeBoundingBox = _rawStrokeBoundingBox!.expandToInclude(
      Rect.fromPoints(canvasPosition, canvasPosition),
    );
    _lastAcceptedScreenPosition = screenPosition;
  }

  void _compactSampleBuffer() {
    final List<Offset> compacted = MPFreehandLineAux.compactSampleBuffer(
      List<Offset>.of(_sampledCanvasPoints),
    );

    _sampledCanvasPoints
      ..clear()
      ..addAll(compacted);
    _activeSampleSpacingOnScreen *= 2;
  }

  void _clearStrokeState() {
    _isCapturing = false;
    _sampledCanvasPoints.clear();
    _rawStrokeBoundingBox = null;
    _activeSampleSpacingOnScreen = mpFreehandMinimumSampleSpacingOnScreen;
    _firstScreenPosition = null;
    _lastAcceptedScreenPosition = null;

    _th2FileEditController.triggerFreehandLineRedraw();
  }

  Offset _snapedCanvasPositionFromScreenPosition(Offset screenPosition) {
    final THPositionPart? snapedPosition = _th2FileEditController
        .snapController
        .getCanvasSnapedPositionFromScreenOffset(screenPosition);

    return snapedPosition?.coordinates ??
        _th2FileEditController.offsetScreenToCanvas(screenPosition);
  }
}
