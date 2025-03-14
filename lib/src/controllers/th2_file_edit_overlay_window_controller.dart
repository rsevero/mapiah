import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/elements/mixins/mp_bounding_box.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/widgets/factories/mp_overlay_window_factory.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_overlay_window_controller.g.dart';

class TH2FileEditOverlayWindowController = TH2FileEditOverlayWindowControllerBase
    with _$TH2FileEditOverlayWindowController;

abstract class TH2FileEditOverlayWindowControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditOverlayWindowControllerBase(this._th2FileEditController)
      : _thFile = _th2FileEditController.thFile {
    for (MPOverlayWindowType type in MPOverlayWindowType.values) {
      _overlayWindowKeyByType[type] = GlobalKey();
      _isOverlayWindowShown[type] = false;
    }
  }

  @readonly
  Map<MPOverlayWindowType, GlobalKey> _overlayWindowKeyByType = {};

  @readonly
  ObservableMap<MPOverlayWindowType, bool> _isOverlayWindowShown =
      ObservableMap<MPOverlayWindowType, bool>();

  @readonly
  GlobalKey? _activeOverlayWindowKey;

  @readonly
  Map<int, Rect> _overlayWindowRects = {};

  @readonly
  ObservableMap<GlobalKey, int> _overlayWindowZOrders =
      ObservableMap<GlobalKey, int>();

  @readonly
  ObservableMap<GlobalKey, Widget> _overlayWindows =
      ObservableMap<GlobalKey, Widget>();

  int getNewZOrder() {
    if (_overlayWindowZOrders.isEmpty) {
      return 1;
    } else {
      return _overlayWindowZOrders.values.reduce((a, b) => a > b ? a : b) +
          mpDefaultZOrderIncrement;
    }
  }

  @action
  toggleOverlayWindow(MPOverlayWindowType type) {
    if (_isOverlayWindowShown[type]!) {
      hideOverlayWindow(type);
    } else {
      showOverlayWindow(type);
    }
  }

  @action
  void showOverlayWindow(
    MPOverlayWindowType type, {
    Offset position = Offset.zero,
  }) {
    final Widget widget = MPOverlayWindowFactory.create(
      th2FileEditController: _th2FileEditController,
      position: getPositionFromSelectedElements(),
      type: type,
    );
    final GlobalKey key = _overlayWindowKeyByType[type]!;

    _updateOverlayWindowAsActive(type);
    _overlayWindows[key] = widget;
    _isOverlayWindowShown[type] = true;
  }

  @action
  void updateOverlayWindowInfo(MPOverlayWindowType type) {
    _updateOverlayWindowAsActive(type);
  }

  void _updateOverlayWindowAsActive(MPOverlayWindowType type) {
    _removeOverlayWindowInfo(type);

    final GlobalKey key = _overlayWindowKeyByType[type]!;
    final Rect? rect = MPInteractionAux.getWidgetRect(key);

    if (rect != null) {
      final int zOrder = getNewZOrder();

      _overlayWindowZOrders[key] = zOrder;
      _overlayWindowRects[zOrder] = rect;
      _activeOverlayWindowKey = key;
    }
  }

  void _removeOverlayWindowInfo(MPOverlayWindowType type) {
    final GlobalKey key = _overlayWindowKeyByType[type]!;

    if (!_overlayWindowZOrders.containsKey(key)) {
      return;
    }

    _overlayWindowRects.remove(_overlayWindowZOrders[key]);
    _overlayWindowZOrders.remove(key);
  }

  @action
  void hideOverlayWindow(MPOverlayWindowType type) {
    final GlobalKey key = _overlayWindowKeyByType[type]!;

    if (_activeOverlayWindowKey == key) {
      _activeOverlayWindowKey = null;
    }

    _overlayWindows.remove(key);
    _isOverlayWindowShown[type] = false;

    _removeOverlayWindowInfo(type);
  }

  @action
  void toggleOverlayWindowVisibility(MPOverlayWindowType type) {
    if (_isOverlayWindowShown[type]!) {
      hideOverlayWindow(type);
    } else {
      showOverlayWindow(type);
    }
  }

  Offset getPositionFromSelectedElements() {
    if (_th2FileEditController.selectionController.selectedElements.isEmpty) {
      return _th2FileEditController.screenBoundingBox.center;
    } else {
      final Rect selectedElementsBoundingBox = _th2FileEditController
          .selectionController.selectedElementsBoundingBox;
      final Offset selectedElementsCenter = selectedElementsBoundingBox.center;

      return selectedElementsCenter;
    }
  }
}
