import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
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
  List<Offset> _snapTargets = [];

  @readonly
  MPSnapPointTarget _snapPointTargetType = MPSnapPointTarget.none;

  @readonly
  MPSnapLinePointTarget _snapLinePointTargetType = MPSnapLinePointTarget.none;

  @readonly
  Set<String> _pointTargetPLATypes = {};

  @readonly
  Set<String> _linePointTargetPLATypes = {};

  @action
  void setSnapPointTargetType(MPSnapPointTarget target) {
    if (target == _snapPointTargetType) {
      return;
    }

    _snapPointTargetType = target;
    updateSnapTargets();
  }

  @action
  void setSnapLinePointTargetType(MPSnapLinePointTarget target) {
    if (target == _snapLinePointTargetType) {
      return;
    }

    _snapLinePointTargetType = target;
    updateSnapTargets();
  }

  @action
  void setPointTargetPLATypes(Iterable<String> types) {
    _pointTargetPLATypes = types.toSet();
    updateSnapTargets();
  }

  @action
  void setLinePointTargetPLATypes(Iterable<String> types) {
    _linePointTargetPLATypes = types.toSet();
    updateSnapTargets();
  }

  @action
  void clearSnapTargets() {
    _snapPointTargetType = MPSnapPointTarget.none;
    _snapLinePointTargetType = MPSnapLinePointTarget.none;
    _pointTargetPLATypes = {};
    _linePointTargetPLATypes = {};
    updateSnapTargets();
  }

  @action
  void addPointTargetPLAType(String type) {
    _pointTargetPLATypes.add(type);
    updateSnapTargets();
  }

  @action
  void removePointTargetPLAType(String type) {
    _pointTargetPLATypes.remove(type);
    updateSnapTargets();
  }

  @action
  void addLinePointTargetPLAType(String type) {
    _linePointTargetPLATypes.add(type);
    updateSnapTargets();
  }

  @action
  void removeLinePointTargetPLAType(String type) {
    _linePointTargetPLATypes.remove(type);
    updateSnapTargets();
  }

  void updateSnapTargets() {
    _snapTargets.clear();

    if ((_snapLinePointTargetType == MPSnapLinePointTarget.none) &&
        (_snapPointTargetType == MPSnapPointTarget.none)) {
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

        _snapTargets.add(element.position.coordinates);
      } else if (element is THLine) {
        if ((_snapLinePointTargetType == MPSnapLinePointTarget.none) ||
            (_snapLinePointTargetType ==
                    MPSnapLinePointTarget.linePointByType &&
                !_linePointTargetPLATypes.contains(element.plaType))) {
          continue;
        }

        for (final int segmentMPID in element.lineSegmentMPIDs) {
          final THElement segmentElement = _thFile.elementByMPID(segmentMPID);

          if (segmentElement is THLineSegment) {
            _snapTargets.add(segmentElement.endPoint.coordinates);
          }
        }
      }
    }
  }
}

enum MPSnapLinePointTarget { none, linePoint, linePointByType }

enum MPSnapPointTarget { none, point, pointByType }
