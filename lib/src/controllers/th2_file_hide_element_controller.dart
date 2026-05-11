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
    return _th2File.scrapMPIDs
        .where((mpID) => !_hiddenScrapMPIDs.contains(mpID))
        .length;
  }

  @computed
  bool get allScrapsVisible => _hiddenScrapMPIDs.isEmpty;

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
        .markStationPointNameCoordinateCacheDirty();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  @action
  void toggleScrapVisibility(int scrapMPID) {
    if (_hiddenScrapMPIDs.contains(scrapMPID)) {
      _hiddenScrapMPIDs.remove(scrapMPID);
    } else {
      _hiddenScrapMPIDs.add(scrapMPID);
      _setActiveScrapForVisibilityHide(scrapMPID);
    }

    _th2FileEditController.userInteractionController
        .markStationPointNameCoordinateCacheDirty();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  void _setActiveScrapForVisibilityHide(int hiddenScrapMPID) {
    if (_th2FileEditController.activeScrapID != hiddenScrapMPID) {
      return;
    }

    final List<THScrap> visibleScraps = _th2File
        .getScraps()
        .where((s) => !_hiddenScrapMPIDs.contains(s.mpID))
        .toList();

    if (visibleScraps.isEmpty) {
      _th2FileEditController.setActiveScrap(0);
    } else {
      final List<THScrap> allScraps = _th2File.getScraps().toList();
      final int currentIndex = allScraps.indexWhere(
        (s) => s.mpID == hiddenScrapMPID,
      );

      /// Walk backwards from current position to find the nearest visible scrap.
      THScrap? newActiveScrap;

      for (int i = currentIndex - 1; i >= 0; i--) {
        if (!_hiddenScrapMPIDs.contains(allScraps[i].mpID)) {
          newActiveScrap = allScraps[i];
          break;
        }
      }

      /// If no visible scrap found before current, try after.
      if (newActiveScrap == null) {
        for (int i = currentIndex + 1; i < allScraps.length; i++) {
          if (!_hiddenScrapMPIDs.contains(allScraps[i].mpID)) {
            newActiveScrap = allScraps[i];
            break;
          }
        }
      }

      if (newActiveScrap != null) {
        _th2FileEditController.setActiveScrap(newActiveScrap.mpID);
      } else {
        _th2FileEditController.setActiveScrap(0);
      }
    }
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
        .markStationPointNameCoordinateCacheDirty();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }
}
