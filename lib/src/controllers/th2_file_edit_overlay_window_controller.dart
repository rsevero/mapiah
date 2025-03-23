import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
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
      _isOverlayWindowShown[type] = false;
    }

    for (MPGlobalKeyWidgetType type in MPGlobalKeyWidgetType.values) {
      _globalKeyWidgetKeyByType[type] = GlobalKey();
    }
  }

  @readonly
  Map<MPGlobalKeyWidgetType, GlobalKey> _globalKeyWidgetKeyByType = {};

  @readonly
  ObservableMap<MPOverlayWindowType, bool> _isOverlayWindowShown =
      ObservableMap<MPOverlayWindowType, bool>();

  @readonly
  MPOverlayWindowType? _activeOverlayWindow;

  @readonly
  ObservableMap<MPOverlayWindowType, Widget> _overlayWindows =
      ObservableMap<MPOverlayWindowType, Widget>();

  @computed
  bool get showChangeScrapOverlayWindow =>
      _isOverlayWindowShown[MPOverlayWindowType.availableScraps]!;

  @readonly
  bool _isAutoDismissWindowOpen = false;

  bool processingPointerDownEvent = false;
  bool processingPointerMoveEvent = false;
  bool processingPointerUpEvent = false;
  bool processingPointerSignalEvent = false;

  final autoDismissOverlayWindowTypes = {
    MPOverlayWindowType.commandOptions,
    MPOverlayWindowType.optionChoices,
  };

  toggleOverlayWindow(MPOverlayWindowType type) {
    setShowOverlayWindow(type, !_isOverlayWindowShown[type]!);
  }

  void _showOverlayWindow(MPOverlayWindowType type, {Offset? position}) {
    if (_overlayWindows.containsKey(type)) {
      final Widget overlayWindow = _overlayWindows[type]!;

      _overlayWindows.remove(type);
      _overlayWindows[type] = overlayWindow;
    } else {
      if (type == MPOverlayWindowType.optionChoices) {
        _overlayWindows[type] = MPOverlayWindowFactory.createOptionChoices(
          th2FileEditController: _th2FileEditController,
          position: position ?? getPositionFromSelectedElements(),
          type: _th2FileEditController.optionEditController.currentOptionType!,
        );
      } else {
        _overlayWindows[type] = MPOverlayWindowFactory.createOverlayWindow(
          th2FileEditController: _th2FileEditController,
          position: getPositionFromSelectedElements(),
          type: type,
        );
      }
    }

    _activeOverlayWindow = type;
    _th2FileEditController.triggerOverlayWindowsRedraw();
  }

  void _hideOverlayWindow(MPOverlayWindowType type) {
    if (_activeOverlayWindow == type) {
      _activeOverlayWindow = null;
    }
    if (type == MPOverlayWindowType.optionChoices) {
      _th2FileEditController.optionEditController.clearCurrentOptionType();
    }
    _overlayWindows.remove(type);
    _th2FileEditController.triggerOverlayWindowsRedraw();
  }

  @action
  void setShowOverlayWindow(
    MPOverlayWindowType type,
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
      /// Is there still an auto dismmisable overlay window open?
      bool autoDismiss = false;
      for (MPOverlayWindowType autoDismissType
          in autoDismissOverlayWindowTypes) {
        if (_isOverlayWindowShown[autoDismissType]!) {
          autoDismiss = true;
          break;
        }
      }
      _isAutoDismissWindowOpen = autoDismiss;

      _hideOverlayWindow(type);
    }
  }

  @action
  void showOptionChoicesOverlayWindow({
    required Offset position,
    required THCommandOptionType optionType,
    dynamic currentChoice,
    dynamic selectedChoice,
    dynamic defaultChoice,
  }) {
    const MPOverlayWindowType overlayWindowType =
        MPOverlayWindowType.optionChoices;

    if (_overlayWindows.containsKey(overlayWindowType)) {
      _overlayWindows.remove(overlayWindowType);
    }

    _overlayWindows[overlayWindowType] =
        MPOverlayWindowFactory.createOptionChoices(
      th2FileEditController: _th2FileEditController,
      position: position,
      type: optionType,
      currentChoice: currentChoice,
      defaultChoice: defaultChoice,
      selectedChoice: selectedChoice,
    );

    _activeOverlayWindow = overlayWindowType;
    _isAutoDismissWindowOpen = true;
    _isOverlayWindowShown[overlayWindowType] = true;
    _th2FileEditController.triggerOverlayWindowsRedraw();
  }

  @action
  void closeAutoDismissOverlayWindows() {
    for (MPOverlayWindowType type in autoDismissOverlayWindowTypes) {
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
}
