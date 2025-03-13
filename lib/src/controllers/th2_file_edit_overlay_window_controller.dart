import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_file.dart';
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
      : _thFile = _th2FileEditController.thFile;

  @readonly
  GlobalKey? _activeOverlayWindowKey;

  @readonly
  ObservableList<GlobalKey> _overlayWindowKeys = ObservableList<GlobalKey>();

  @readonly
  Map<int, Rect> _overlayWindowRects = {};

  @readonly
  Map<GlobalKey, int> _overlayWindowZOrders = {};

  @readonly
  int _refZOrder = mpInitialZOrder;

  int getNewZOrder() {
    _refZOrder += mpDefaultZOrderIncrement;

    return _refZOrder;
  }

  void removeOverlayWindowInfo(GlobalKey key) {
    if (!_overlayWindowZOrders.containsKey(key)) {
      return;
    }

    final int zOrder = _overlayWindowZOrders[key]!;

    _overlayWindowZOrders.remove(key);

    if (!_overlayWindowRects.containsKey(zOrder)) {
      return;
    }

    _overlayWindowRects.remove(zOrder);

    if (_overlayWindowZOrders.values.isEmpty) {
      _refZOrder = mpInitialZOrder;
    } else {
      _refZOrder = _overlayWindowZOrders.values.reduce((a, b) => a > b ? a : b);
    }
  }

  void updateOverlayWindowInfo(GlobalKey key, int zOrder) {
    removeOverlayWindowInfo(key);

    while (_overlayWindowZOrders.containsValue(zOrder)) {
      zOrder++;
    }

    final Rect? rect = MPInteractionAux.getWidgetRect(key);

    if (rect == null) {
      removeOverlayWindowInfo(key);
    } else {
      _overlayWindowZOrders[key] = zOrder;
      _overlayWindowRects[zOrder] = rect;
    }
  }
}
