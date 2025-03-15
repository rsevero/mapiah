import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
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

    for (MPGlobalKeyWidgetType type in MPGlobalKeyWidgetType.values) {
      _globalKeyWidgetKeyByType[type] = GlobalKey();
    }

    reaction(
      (_) => _th2FileEditController.showChangeScrapOverlayWindow,
      (bool show) {
        if (show) {
          showOverlayWindow(MPOverlayWindowType.availableScraps);
        } else {
          hideOverlayWindow(MPOverlayWindowType.availableScraps);
        }
      },
    );
  }

  @readonly
  Map<MPGlobalKeyWidgetType, GlobalKey> _globalKeyWidgetKeyByType = {};

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
  void showOverlayWindow(MPOverlayWindowType type) {
    final GlobalKey key = _overlayWindowKeyByType[type]!;

    if (_overlayWindows.containsKey(key)) {
      final Widget overlayWindow = _overlayWindows[key]!;

      _overlayWindows.remove(key);
      _overlayWindows[key] = overlayWindow;
    } else {
      _overlayWindows[key] = MPOverlayWindowFactory.create(
        th2FileEditController: _th2FileEditController,
        position: getPositionFromSelectedElements(),
        type: type,
      );
    }

    _updateOverlayWindowAsActive(type);
    _isOverlayWindowShown[type] = true;
  }

  @action
  void updateOverlayWindowInfo(MPOverlayWindowType type) {
    _updateOverlayWindowAsActive(type);
  }

  @action
  void updateOverlayWindowWithBoundingBox(
    MPOverlayWindowType type,
    Rect boundingBox,
  ) {
    _removeOverlayWindowInfo(type);

    final int zOrder = getNewZOrder();

    final GlobalKey key = _overlayWindowKeyByType[type]!;

    _overlayWindowZOrders[key] = zOrder;
    _overlayWindowRects[zOrder] = boundingBox;
    _activeOverlayWindowKey = key;
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

    if (_activeOverlayWindowKey == key) {
      _activeOverlayWindowKey = null;
    }

    if (!_overlayWindowZOrders.containsKey(key)) {
      return;
    }

    _overlayWindowRects.remove(_overlayWindowZOrders[key]);
    _overlayWindowZOrders.remove(key);
  }

  @action
  void hideOverlayWindow(MPOverlayWindowType type) {
    final GlobalKey key = _overlayWindowKeyByType[type]!;

    _isOverlayWindowShown[type] = false;
    _removeOverlayWindowInfo(type);
    _overlayWindows.remove(key);
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
      final Offset selectedElementsCenter = _th2FileEditController
          .offsetCanvasToScreen(selectedElementsBoundingBox.center);

      return selectedElementsCenter;
    }
  }
}
