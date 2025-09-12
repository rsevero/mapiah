import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/auxiliary/mp_snap_grid_cell.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/elements/xvi/xvi_shot.dart';
import 'package:mapiah/src/elements/xvi/xvi_sketchline.dart';
import 'package:mapiah/src/elements/xvi/xvi_station.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_snap_controller.g.dart';

class TH2FileEditSnapController = TH2FileEditSnapControllerBase
    with _$TH2FileEditSnapController;

abstract class TH2FileEditSnapControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditSnapControllerBase(this._th2FileEditController)
    : _thFile = _th2FileEditController.thFile;

  @readonly
  List<THPositionPart> _snapTargets = [];

  @readonly
  MPSnapPointTarget _snapPointTargetType = MPSnapPointTarget.none;

  @readonly
  MPSnapLinePointTarget _snapLinePointTargetType = MPSnapLinePointTarget.none;

  @readonly
  Set<String> _pointTargetPLATypes = {};

  @readonly
  Set<String> _linePointTargetPLATypes = {};

  @readonly
  Set<MPSnapXVIFileTarget> _snapXVIFileTargets = {};

  @readonly
  Map<MPSnapGridCell, List<THPositionPart>> _snapTargetsGrid = {};

  @action
  void setSnapPointTargetType(MPSnapPointTarget target) {
    if (target == _snapPointTargetType) {
      return;
    }

    _snapPointTargetType = target;
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  @action
  void setSnapLinePointTargetType(MPSnapLinePointTarget target) {
    if (target == _snapLinePointTargetType) {
      return;
    }

    _snapLinePointTargetType = target;
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  @action
  void setPointTargetPLATypes(Iterable<String> types) {
    _pointTargetPLATypes = types.toSet();
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  @action
  void setLinePointTargetPLATypes(Iterable<String> types) {
    _linePointTargetPLATypes = types.toSet();
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  @action
  void clearSnapTargets() {
    _snapPointTargetType = MPSnapPointTarget.none;
    _snapLinePointTargetType = MPSnapLinePointTarget.none;
    _pointTargetPLATypes = {};
    _linePointTargetPLATypes = {};
    _snapXVIFileTargets = {};
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  @action
  void addPointTargetPLAType(String type) {
    _pointTargetPLATypes.add(type);
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  @action
  void removePointTargetPLAType(String type) {
    _pointTargetPLATypes.remove(type);
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  @action
  void addLinePointTargetPLAType(String type) {
    _linePointTargetPLATypes.add(type);
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  @action
  void removeLinePointTargetPLAType(String type) {
    _linePointTargetPLATypes.remove(type);
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  void updateSnapTargets() {
    _snapTargets.clear();

    if ((_snapLinePointTargetType == MPSnapLinePointTarget.none) &&
        (_snapPointTargetType == MPSnapPointTarget.none) &&
        _snapXVIFileTargets.isEmpty) {
      return;
    }

    final List<int> elementMPIDs = _thFile
        .scrapByMPID(_th2FileEditController.activeScrapID)
        .childrenMPIDs;
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    for (final int elementMPID in elementMPIDs) {
      if (selectionController.isElementSelectedByMPID(elementMPID)) {
        continue;
      }

      final THElement element = _thFile.elementByMPID(elementMPID);

      if (element is THPoint) {
        if ((_snapPointTargetType == MPSnapPointTarget.none) ||
            (_snapPointTargetType == MPSnapPointTarget.pointByType &&
                !_pointTargetPLATypes.contains(element.plaType))) {
          continue;
        }

        _snapTargets.add(element.position);
      } else if (element is THLine) {
        if ((_snapLinePointTargetType == MPSnapLinePointTarget.none) ||
            (_snapLinePointTargetType ==
                    MPSnapLinePointTarget.linePointByType &&
                !_linePointTargetPLATypes.contains(element.plaType))) {
          continue;
        }

        for (final int segmentMPID in element.lineSegmentMPIDs) {
          final THLineSegment lineSegmentElement = _thFile.lineSegmentByMPID(
            segmentMPID,
          );

          _snapTargets.add(lineSegmentElement.endPoint);
        }
      }
    }

    if (_snapXVIFileTargets.isNotEmpty) {
      final Set<int> imageInsetConfigMPIDs = _thFile.imageMPIDs;

      for (final int imageInsertConfigMPID in imageInsetConfigMPIDs) {
        final THXTherionImageInsertConfig imageInsertConfig = _thFile
            .imageByMPID(imageInsertConfigMPID);

        if (!imageInsertConfig.isXVI) {
          continue;
        }

        final XVIFile? xviFile = imageInsertConfig.getXVIFile(
          _th2FileEditController,
        );

        if (xviFile == null) {
          continue;
        }

        final double xx = imageInsertConfig.xviRootedXX;
        final double yy = imageInsertConfig.xviRootedYY;
        final Offset imageBaseOffset = Offset(xx, yy);
        // Understaing xTherion variables:
        // shx: The horizontal offset between the image’s position (px) and the grid origin (gx).
        // shy: The vertical offset between the image’s position (py) and the grid origin (gy).
        // These original xTherion variables are used to calculate imageGridOffset.
        final Offset imageOffset =
            imageBaseOffset -
            Offset(xviFile.grid.gx.value, xviFile.grid.gy.value);

        if (_snapXVIFileTargets.contains(
          MPSnapXVIFileTarget.gridLineIntersection,
        )) {
          final XVIGrid xviGrid = xviFile.grid;
          final List<Offset> intersections = xviGrid
              .calculateGridLineIntersections();

          for (final Offset intersection in intersections) {
            _snapTargets.add(
              THPositionPart(coordinates: intersection + imageOffset),
            );
          }
        }

        if (_snapXVIFileTargets.contains(MPSnapXVIFileTarget.shot)) {
          for (final XVIShot xviShot in xviFile.shots) {
            _snapTargets.add(
              xviShot.start.copyWith(
                coordinates: xviShot.start.coordinates + imageOffset,
              ),
            );
            _snapTargets.add(
              xviShot.end.copyWith(
                coordinates: xviShot.end.coordinates + imageOffset,
              ),
            );
          }
        }

        if (_snapXVIFileTargets.contains(MPSnapXVIFileTarget.sketchLine)) {
          for (final XVISketchLine xviSketchLine in xviFile.sketchLines) {
            final List<THPositionPart> xviSketchLinePoints =
                xviSketchLine.points;

            _snapTargets.add(
              xviSketchLine.start.copyWith(
                coordinates: xviSketchLine.start.coordinates + imageOffset,
              ),
            );

            for (final sketchLinePoint in xviSketchLinePoints) {
              _snapTargets.add(
                sketchLinePoint.copyWith(
                  coordinates: sketchLinePoint.coordinates + imageOffset,
                ),
              );
            }
          }
        }

        if (_snapXVIFileTargets.contains(MPSnapXVIFileTarget.station)) {
          final List<XVIStation> xviStations = xviFile.stations;

          for (final XVIStation xviStation in xviStations) {
            _snapTargets.add(
              xviStation.position.copyWith(
                coordinates: xviStation.position.coordinates + imageOffset,
              ),
            );
          }
        }
      }
    }

    updateSnapTargetsGrid();
  }

  MPSnapGridCell getSnapGridCellPosition(Offset canvasPosition) {
    final double snapGridSize = _th2FileEditController.currentSnapGridCellSize;

    return MPSnapGridCell(
      (canvasPosition.dx / snapGridSize).floor(),
      (canvasPosition.dy / snapGridSize).floor(),
    );
  }

  void updateSnapTargetsGrid() {
    _snapTargetsGrid.clear();

    if (_snapTargets.isEmpty) {
      return;
    }

    for (final THPositionPart snapTarget in _snapTargets) {
      final MPSnapGridCell cell = getSnapGridCellPosition(
        snapTarget.coordinates,
      );

      if (!_snapTargetsGrid.containsKey(cell)) {
        _snapTargetsGrid[cell] = [];
      }

      _snapTargetsGrid[cell]!.add(snapTarget);
    }
  }

  Offset getCanvasSnapedOffsetFromScreenOffset(Offset screenPosition) {
    final THPositionPart? snapTarget = getCanvasSnapedPositionFromScreenOffset(
      screenPosition,
    );

    return (snapTarget == null) ? screenPosition : snapTarget.coordinates;
  }

  Offset getCanvasSnapedOffsetFromCanvasOffset(Offset canvasPosition) {
    final THPositionPart? snapTarget = getCanvasSnapedPositionFromCanvasOffset(
      canvasPosition,
    );

    return (snapTarget == null) ? canvasPosition : snapTarget.coordinates;
  }

  THPositionPart? getCanvasSnapedPositionFromScreenOffset(
    Offset screenPosition,
  ) {
    final Offset canvasPosition = _th2FileEditController.offsetScreenToCanvas(
      screenPosition,
    );

    return getCanvasSnapedPositionFromCanvasOffset(canvasPosition);
  }

  THPositionPart? getCanvasSnapedPositionFromCanvasOffset(
    Offset canvasPosition,
  ) {
    if (_snapTargets.isEmpty) {
      return null;
    }

    double closestDistanceSquared = double.infinity;
    THPositionPart? closestSnapTarget;
    final double currentSnapOnCanvasDistanceSquaredLimit =
        _th2FileEditController.currentSnapOnCanvasDistanceSquaredLimit;
    final MPSnapGridCell centerCell = getSnapGridCellPosition(canvasPosition);
    final List<MPSnapGridCell> cellsToCheck = [];

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        cellsToCheck.add(MPSnapGridCell(centerCell.x + dx, centerCell.y + dy));
      }
    }

    for (final MPSnapGridCell cellToCheck in cellsToCheck) {
      if (!_snapTargetsGrid.containsKey(cellToCheck)) {
        continue;
      }

      final List<THPositionPart> cellTargets = _snapTargetsGrid[cellToCheck]!;

      for (final target in cellTargets) {
        final double distanceSquared =
            (target.coordinates - canvasPosition).distanceSquared;

        if ((distanceSquared < currentSnapOnCanvasDistanceSquaredLimit) &&
            (distanceSquared < closestDistanceSquared)) {
          closestDistanceSquared = distanceSquared;
          closestSnapTarget = target;
        }
      }
    }

    return closestSnapTarget;
  }

  THElement? getNearerSelectedElement(Offset canvasCoordinates) {
    final Iterable<MPSelectedElement> mpSelectedElements =
        _th2FileEditController
            .selectionController
            .mpSelectedElementsLogical
            .values;

    THElement? nearerElement;
    double nearerDistanceSquared = double.infinity;

    for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
      switch (mpSelectedElement) {
        case MPSelectedPoint _:
          final double pointDistanceSquared =
              (mpSelectedElement.originalElementClone.position.coordinates -
                      canvasCoordinates)
                  .distanceSquared;

          if (pointDistanceSquared < nearerDistanceSquared) {
            nearerDistanceSquared = pointDistanceSquared;
            nearerElement = mpSelectedElement.originalElementClone;
          }
        case MPSelectedLine _:
          final ({THLineSegment? lineSegment, double distanceSquared})
          nearerLineSegment = getNearerLineSegmentFromLine(
            canvasCoordinates,
            mpSelectedElement.originalLineClone,
          );

          if ((nearerLineSegment.lineSegment != null) &&
              (nearerLineSegment.distanceSquared < nearerDistanceSquared)) {
            nearerDistanceSquared = nearerLineSegment.distanceSquared;
            nearerElement = nearerLineSegment.lineSegment;
          }
        case MPSelectedArea _:
          final ({THLineSegment? lineSegment, double distanceSquared})
          nearerLineSegment = getNearerLineSegmentFromArea(
            canvasCoordinates,
            mpSelectedElement.originalAreaClone,
          );

          if ((nearerLineSegment.lineSegment != null) &&
              (nearerLineSegment.distanceSquared < nearerDistanceSquared)) {
            nearerDistanceSquared = nearerLineSegment.distanceSquared;
            nearerElement = nearerLineSegment.lineSegment;
          }
        default:
          throw Exception(
            'TH2FileEditSelectionController.getNearerSelectedElement() found unknown selected element type',
          );
      }
    }

    return nearerElement;
  }

  THElement? getNearerSelectedLineSegment(Offset canvasCoordinates) {
    final Iterable<MPSelectedEndControlPoint> mpSelectedEndControlPoints =
        _th2FileEditController
            .selectionController
            .selectedEndControlPoints
            .values;

    THLineSegment? nearerLineSegment;
    double nearerDistanceSquared = double.infinity;

    for (final MPSelectedEndControlPoint mpSelectedEndControlPoint
        in mpSelectedEndControlPoints) {
      final MPEndControlPointType endControlPointType =
          mpSelectedEndControlPoint.type;

      if ((endControlPointType == MPEndControlPointType.endPointBezierCurve) ||
          (endControlPointType == MPEndControlPointType.endPointStraight)) {
        final double pointDistanceSquared =
            (mpSelectedEndControlPoint
                        .originalElementClone
                        .endPoint
                        .coordinates -
                    canvasCoordinates)
                .distanceSquared;

        if (pointDistanceSquared < nearerDistanceSquared) {
          nearerDistanceSquared = pointDistanceSquared;
          nearerLineSegment = mpSelectedEndControlPoint.originalElementClone;
        }
        continue;
      }
    }

    return nearerLineSegment;
  }

  ({THLineSegment? lineSegment, double distanceSquared})
  getNearerLineSegmentFromLine(Offset canvasCoordinates, THLine line) {
    final List<THLineSegment> lineSegments = line.getLineSegments(_thFile);

    if (lineSegments.isEmpty) {
      return (lineSegment: null, distanceSquared: double.infinity);
    }

    THLineSegment nearerElement = lineSegments.first;
    double nearerDistanceSquared =
        (nearerElement.endPoint.coordinates - canvasCoordinates)
            .distanceSquared;

    for (final THLineSegment lineSegment in lineSegments.skip(1)) {
      final double endPointDistanceSquared =
          (lineSegment.endPoint.coordinates - canvasCoordinates)
              .distanceSquared;

      if (endPointDistanceSquared < nearerDistanceSquared) {
        nearerDistanceSquared = endPointDistanceSquared;
        nearerElement = lineSegment;
      }
    }

    return (lineSegment: nearerElement, distanceSquared: nearerDistanceSquared);
  }

  ({THLineSegment? lineSegment, double distanceSquared})
  getNearerLineSegmentFromArea(Offset canvasCoordinates, THArea area) {
    final Set<int> areaLineSegments = area.getLineMPIDs(_thFile);

    if (areaLineSegments.isEmpty) {
      return (lineSegment: null, distanceSquared: double.infinity);
    }

    THLineSegment? nearerLineSegmentFinal;
    double nearerDistanceSquaredFinal = double.infinity;
    final Iterable<int> areaLineMPIDs = area.getLineMPIDs(_thFile);

    for (final int lineMPID in areaLineMPIDs) {
      final THLine line = _thFile.lineByMPID(lineMPID);
      final ({double distanceSquared, THLineSegment? lineSegment})
      nearerPerLine = getNearerLineSegmentFromLine(canvasCoordinates, line);

      if (nearerPerLine.distanceSquared < nearerDistanceSquaredFinal) {
        nearerDistanceSquaredFinal = nearerPerLine.distanceSquared;
        nearerLineSegmentFinal = nearerPerLine.lineSegment;
      }
    }

    return (
      lineSegment: nearerLineSegmentFinal,
      distanceSquared: nearerDistanceSquaredFinal,
    );
  }

  void clearSnapXVITargets() {
    _snapXVIFileTargets = {};
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  void addSnapXVITarget(MPSnapXVIFileTarget target) {
    if (_snapXVIFileTargets.contains(target)) {
      return;
    }

    _snapXVIFileTargets.add(target);
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  void removeSnapXVITarget(MPSnapXVIFileTarget target) {
    if (!_snapXVIFileTargets.contains(target)) {
      return;
    }

    _snapXVIFileTargets.remove(target);
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  void setSnapXVITargets(Iterable<MPSnapXVIFileTarget> targets) {
    _snapXVIFileTargets = targets.toSet();
    updateSnapTargets();
    _th2FileEditController.triggerSnapTargetsWindowRedraw();
  }
}

enum MPSnapLinePointTarget { none, linePoint, linePointByType }

enum MPSnapPointTarget { none, point, pointByType }

enum MPSnapXVIFileTarget { gridLineIntersection, shot, sketchLine, station }
