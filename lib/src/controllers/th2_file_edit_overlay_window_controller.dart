import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
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
    for (MPWindowType type in MPWindowType.values) {
      _isOverlayWindowShown[type] = false;
      _focusNodes[type] = FocusNode();
    }

    for (MPGlobalKeyWidgetType type in MPGlobalKeyWidgetType.values) {
      _globalKeyWidgetKeyByType[type] = GlobalKey();
    }
  }

  @readonly
  Map<MPGlobalKeyWidgetType, GlobalKey> _globalKeyWidgetKeyByType = {};

  @readonly
  ObservableMap<MPWindowType, bool> _isOverlayWindowShown =
      ObservableMap<MPWindowType, bool>();

  @readonly
  MPWindowType _activeWindow = MPWindowType.mainTHFileEditWindow;

  @readonly
  ObservableMap<MPWindowType, Widget> _overlayWindows =
      ObservableMap<MPWindowType, Widget>();

  @computed
  bool get showChangeScrapOverlayWindow =>
      _isOverlayWindowShown[MPWindowType.availableScraps]!;

  @readonly
  bool _isAutoDismissWindowOpen = false;

  bool processingPointerDownEvent = false;
  bool processingPointerMoveEvent = false;
  bool processingPointerUpEvent = false;
  bool processingPointerSignalEvent = false;

  final Map<MPWindowType, FocusNode> _focusNodes = {};

  final autoDismissOverlayWindowTypes = {
    MPWindowType.commandOptions,
    MPWindowType.optionChoices,
  };

  void close() {
    for (MPWindowType type in MPWindowType.values) {
      setShowOverlayWindow(type, false);
      _focusNodes[type]!.dispose();
    }
  }

  void toggleOverlayWindow(MPWindowType type) {
    setShowOverlayWindow(type, !_isOverlayWindowShown[type]!);
  }

  void _showOverlayWindow(MPWindowType type, {Offset? position}) {
    if (_overlayWindows.containsKey(type)) {
      final Widget overlayWindow = _overlayWindows[type]!;

      _overlayWindows.remove(type);
      _overlayWindows[type] = overlayWindow;
    } else {
      if (type == MPWindowType.optionChoices) {
        throw UnimplementedError(
          'Call showOptionChoicesOverlayWindow() to create option choices widgets.',
        );
      } else {
        _overlayWindows[type] = MPOverlayWindowFactory.createOverlayWindow(
          th2FileEditController: _th2FileEditController,
          position: getPositionFromSelectedElements(),
          type: type,
        );
      }
    }

    _activeWindow = type;
    _th2FileEditController.triggerOverlayWindowsRedraw();
  }

  void _hideOverlayWindow(MPWindowType type) {
    if (type == MPWindowType.optionChoices) {
      _th2FileEditController.optionEditController.clearCurrentOptionType();
    }
    _overlayWindows.remove(type);
    if (_activeWindow == type) {
      _activeWindow = _overlayWindows.isEmpty
          ? MPWindowType.mainTHFileEditWindow
          : _overlayWindows.keys.last;
    }
    _th2FileEditController.triggerOverlayWindowsRedraw();
  }

  @action
  void setShowOverlayWindow(
    MPWindowType type,
    bool show, {
    Offset? position,
  }) {
    _isOverlayWindowShown[type] = show;

    if (show) {
      if (autoDismissOverlayWindowTypes.contains(type)) {
        _isAutoDismissWindowOpen = true;
      }

      _showOverlayWindow(type, position: position);
    } else {
      if (_isAutoDismissWindowOpen) {
        /// Is there still an auto dismmisable overlay window open?
        bool autoDismiss = false;

        for (MPWindowType autoDismissType in autoDismissOverlayWindowTypes) {
          if (_isOverlayWindowShown[autoDismissType]!) {
            autoDismiss = true;
            break;
          }
        }
        _isAutoDismissWindowOpen = autoDismiss;
      }

      _hideOverlayWindow(type);
    }

    _focusNodes[_activeWindow]!.requestFocus();
  }

  @action
  void showOptionChoicesOverlayWindow({
    required Offset position,
    required MPOptionInfo optionInfo,
  }) {
    const MPWindowType overlayWindowType = MPWindowType.optionChoices;

    if (_overlayWindows.containsKey(overlayWindowType)) {
      _overlayWindows.remove(overlayWindowType);
    }

    _overlayWindows[overlayWindowType] =
        MPOverlayWindowFactory.createOptionChoices(
      th2FileEditController: _th2FileEditController,
      position: position,
      optionInfo: optionInfo,
    );

    _activeWindow = overlayWindowType;
    _isAutoDismissWindowOpen = true;
    _isOverlayWindowShown[overlayWindowType] = true;
    _th2FileEditController.triggerOverlayWindowsRedraw();
  }

  @action
  void closeAutoDismissOverlayWindows() {
    for (MPWindowType type in autoDismissOverlayWindowTypes) {
      if (_isOverlayWindowShown[type]!) {
        setShowOverlayWindow(type, false);
      }
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

  @action
  void clearOverlayWindows() {
    for (final type in MPWindowType.values) {
      setShowOverlayWindow(type, false);
    }
  }

  FocusNode getFocusNode(MPWindowType type) {
    return _focusNodes[type]!;
  }
}
