// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_hide_element_controller.g.dart';

class TH2FileHideElementController = TH2FileHideElementControllerBase
    with _$TH2FileHideElementController;

abstract class TH2FileHideElementControllerBase with Store {
  @readonly
  TH2File _th2File;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileHideElementControllerBase(this._th2FileEditController)
    : _th2File = _th2FileEditController.th2File;

  @readonly
  ObservableSet<int> _hiddenScrapMPIDs = ObservableSet<int>();

  @readonly
  ObservableSet<int> _hiddenElementMPIDs = ObservableSet<int>();

  bool isScrapVisible(int scrapMPID) {
    return !_hiddenScrapMPIDs.contains(scrapMPID);
  }

  @computed
  int get visibleScrapCount {
    _th2FileEditController.structureRevision;
    return _th2File.scrapMPIDs
        .where((mpID) => !_hiddenScrapMPIDs.contains(mpID))
        .length;
  }

  @computed
  bool get allScrapsVisible {
    _th2FileEditController.structureRevision;
    return _th2File.scrapMPIDs.every(isScrapVisible);
  }

  /// Drops MPIDs no longer in the file from the hidden sets.
  @action
  void pruneToModel() {
    _hiddenScrapMPIDs.removeWhere(
      (int mpID) => _th2File.tryElementByMPID(mpID) is! THScrap,
    );
    _hiddenElementMPIDs.removeWhere(
      (int mpID) => !_th2File.hasElementByMPID(mpID),
    );
  }

  /// Shows [scrapMPID] when it is hidden, without touching the active scrap
  /// or the selection. Snap targets are left to the caller.
  @action
  void ensureScrapVisible(int scrapMPID) {
    if (!_hiddenScrapMPIDs.remove(scrapMPID)) {
      return;
    }

    _th2FileEditController.userInteractionController
        .markTherionStationPointNameCoordinateCacheDirty();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  /// Sets the visibility of several scraps. The active scrap is never
  /// hidden.
  @action
  void setScrapsHidden(List<int> scrapMPIDs, bool hidden) {
    if (scrapMPIDs.isEmpty) {
      return;
    }

    final int activeID = _th2FileEditController.activeScrapID;

    for (final int id in scrapMPIDs) {
      if (hidden) {
        if (id != activeID) {
          _hiddenScrapMPIDs.add(id);
        }
      } else {
        _hiddenScrapMPIDs.remove(id);
      }
    }
    _th2FileEditController.userInteractionController
        .markTherionStationPointNameCoordinateCacheDirty();
    _th2FileEditController.snapController.updateSnapTargets();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  /// If all scraps are visible, hides all except the active one.
  /// If any scrap is hidden, makes all scraps visible.
  @action
  void toggleAllScrapsVisibility() {
    if (allScrapsVisible) {
      _hiddenScrapMPIDs.addAll(
        _th2File.scrapMPIDs.where(
          (mpID) => mpID != _th2FileEditController.activeScrapID,
        ),
      );
    } else {
      _hiddenScrapMPIDs.clear();
    }

    _th2FileEditController.userInteractionController
        .markTherionStationPointNameCoordinateCacheDirty();
    _th2FileEditController.snapController.updateSnapTargets();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  /// Shows a hidden scrap or hides a visible one. The active scrap is never
  /// hidden.
  @action
  void toggleScrapVisibility(int scrapMPID) {
    if (_hiddenScrapMPIDs.contains(scrapMPID)) {
      _hiddenScrapMPIDs.remove(scrapMPID);
    } else {
      if (scrapMPID == _th2FileEditController.activeScrapID) {
        return;
      }

      _hiddenScrapMPIDs.add(scrapMPID);
    }

    _th2FileEditController.userInteractionController
        .markTherionStationPointNameCoordinateCacheDirty();
    _th2FileEditController.snapController.updateSnapTargets();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  bool isElementVisible(int mpID) {
    return !_hiddenElementMPIDs.contains(mpID);
  }

  @computed
  bool get allElementsVisible => _hiddenElementMPIDs.isEmpty;

  @action
  void performHideSelectedOrClearHidden() {
    final Set<int> selectedMPIDs = _th2FileEditController
        .selectionController
        .mpSelectedElementsLogical
        .keys
        .toSet();

    if (selectedMPIDs.isNotEmpty) {
      _hiddenElementMPIDs.addAll(selectedMPIDs);
      _th2FileEditController.selectionController.deselectAllElements();
    } else {
      _hiddenElementMPIDs.clear();
    }

    _th2FileEditController.selectionController.resetSelectableElements();
    _th2FileEditController.userInteractionController
        .markTherionStationPointNameCoordinateCacheDirty();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }
}
