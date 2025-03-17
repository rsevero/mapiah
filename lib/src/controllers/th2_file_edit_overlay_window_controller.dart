import 'package:flutter/material.dart';
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
      _isOverlayWindowShown[type] = Observable(false);
    }

    for (MPGlobalKeyWidgetType type in MPGlobalKeyWidgetType.values) {
      _globalKeyWidgetKeyByType[type] = GlobalKey();
    }
  }

  @readonly
  Map<MPGlobalKeyWidgetType, GlobalKey> _globalKeyWidgetKeyByType = {};

  @readonly
  ObservableMap<MPOverlayWindowType, Observable<bool>> _isOverlayWindowShown =
      ObservableMap<MPOverlayWindowType, Observable<bool>>();

  @readonly
  MPOverlayWindowType? _activeOverlayWindow;

  @readonly
  ObservableMap<MPOverlayWindowType, Widget> _overlayWindows =
      ObservableMap<MPOverlayWindowType, Widget>();

  @computed
  bool get showChangeScrapOverlayWindow =>
      _isOverlayWindowShown[MPOverlayWindowType.availableScraps]!.value;

  bool processingPointerDownEvent = false;
  bool processingPointerMoveEvent = false;
  bool processingPointerUpEvent = false;
  bool processingPointerSignalEvent = false;

  toggleOverlayWindow(MPOverlayWindowType type) {
    setShowOverlayWindow(type, !_isOverlayWindowShown[type]!.value);
  }

  void _showOverlayWindow(MPOverlayWindowType type) {
    if (_overlayWindows.containsKey(type)) {
      final Widget overlayWindow = _overlayWindows[type]!;

      _overlayWindows.remove(type);
      _overlayWindows[type] = overlayWindow;
    } else {
      _overlayWindows[type] = MPOverlayWindowFactory.create(
        th2FileEditController: _th2FileEditController,
        position: getPositionFromSelectedElements(),
        type: type,
      );
    }

    _activeOverlayWindow = type;
    _th2FileEditController.triggerOverlayWindowsRedraw();
  }

  void _hideOverlayWindow(MPOverlayWindowType type) {
    if (_activeOverlayWindow == type) {
      _activeOverlayWindow = null;
    }
    _overlayWindows.remove(type);
    _th2FileEditController.triggerOverlayWindowsRedraw();
  }

  @action
  void toggleOverlayWindowVisibility(MPOverlayWindowType type) {
    setShowOverlayWindow(type, !_isOverlayWindowShown[type]!.value);
  }

  @action
  void setShowOverlayWindow(MPOverlayWindowType type, bool show) {
    _isOverlayWindowShown[type] = Observable(show);
    // mpLocator.mpLog.fine(
    //     "TH2FileEditOverlayWindowController.setShowOverlayWindow() type: $type, show: $show");
    if (show) {
      // mpLocator.mpLog.fine(
      //     "TH2FileEditOverlayWindowController.setShowOverlayWindow() showing overlay window");
      _showOverlayWindow(type);
    } else {
      // mpLocator.mpLog.fine(
      //     "TH2FileEditOverlayWindowController.setShowOverlayWindow() hiding overlay window");
      _hideOverlayWindow(type);
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
