import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
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
  ObservableMap<MPWindowType, OverlayEntry> _overlayWindows =
      ObservableMap<MPWindowType, OverlayEntry>();

  @computed
  bool get showChangeScrapOverlayWindow =>
      _isOverlayWindowShown[MPWindowType.availableScraps]!;

  @readonly
  bool _isAutoDismissWindowOpen = false;

  final autoDismissOverlayWindowTypes = {
    MPWindowType.commandOptions,
    MPWindowType.optionChoices,
    MPWindowType.plaTypes,
  };

  THElementType? _currentPLATypeShown;

  void close() {
    for (MPWindowType type in MPWindowType.values) {
      setShowOverlayWindow(type, false);
    }
  }

  void toggleOverlayWindow(MPWindowType type) {
    setShowOverlayWindow(type, !_isOverlayWindowShown[type]!);
  }

  void _showOverlayWindow(
    MPWindowType type, {
    Offset? position,
  }) {
    if (autoDismissOverlayWindowTypes.contains(type)) {
      _isAutoDismissWindowOpen = true;
    }

    if (_overlayWindows.containsKey(type)) {
      final OverlayEntry overlayWindow = _overlayWindows[type]!;

      _overlayWindows[type]!.remove();
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

    BuildContext? context =
        _th2FileEditController.thFileWidgetKey.currentContext;

    if (context == null) {
      throw StateError(
          "The context of the THFileWidget is null. Can't create options overlay window in TH2FileEditOverlayWindowController._showOverlayWindow().");
    }

    Overlay.of(context, rootOverlay: true).insert(_overlayWindows[type]!);
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

    BuildContext? context =
        _th2FileEditController.thFileWidgetKey.currentContext;

    if (context == null) {
      throw StateError(
          "The context of the THFileWidget is null. Can't create options overlay window in TH2FileEditOverlayWindowController.showOptionChoicesOverlayWindow().");
    }

    Overlay.of(context, rootOverlay: true)
        .insert(_overlayWindows[overlayWindowType]!);
  }

  void _hideOverlayWindow(MPWindowType type) {
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

    _overlayWindows[type]?.remove();
    if (type == MPWindowType.optionChoices) {
      _th2FileEditController.optionEditController.clearCurrentOptionType();
    }
    _overlayWindows.remove(type);
    if (_activeWindow == type) {
      _activeWindow = _overlayWindows.isEmpty
          ? MPWindowType.mainTHFileEditWindow
          : _overlayWindows.keys.last;
    }

    if (_activeWindow == MPWindowType.mainTHFileEditWindow) {
      _th2FileEditController.thFileFocusNode.requestFocus();
    }
  }

  @action
  void setShowOverlayWindow(
    MPWindowType type,
    bool show, {
    Offset? position,
  }) {
    _isOverlayWindowShown[type] = show;

    if (show) {
      _showOverlayWindow(type, position: position);
    } else {
      _hideOverlayWindow(type);
    }
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

  @action
  void performToggleShowPLATypeOverlayWindow({
    required Offset position,
    required THElementType elementType,
    required String? selectedType,
  }) {
    if (elementType == _currentPLATypeShown) {
      _currentPLATypeShown = null;
      setShowOverlayWindow(MPWindowType.plaTypes, false);
    } else {
      _currentPLATypeShown = elementType;
      showPLATypeOverlayWindow(
        position: position,
        elementType: elementType,
        selectedType: selectedType,
      );
    }
  }

  @action
  void showPLATypeOverlayWindow({
    required Offset position,
    required THElementType elementType,
    required String? selectedType,
  }) {
    const MPWindowType overlayWindowType = MPWindowType.plaTypes;

    if (_overlayWindows.containsKey(overlayWindowType)) {
      _overlayWindows.remove(overlayWindowType);
    }

    _overlayWindows[overlayWindowType] =
        MPOverlayWindowFactory.createPLATypeOptions(
      th2FileEditController: _th2FileEditController,
      position: position,
      elementType: elementType,
      selectedType: selectedType,
    );

    _activeWindow = overlayWindowType;
    _isAutoDismissWindowOpen = true;
    _isOverlayWindowShown[overlayWindowType] = true;

    BuildContext? context =
        _th2FileEditController.thFileWidgetKey.currentContext;

    if (context == null) {
      throw StateError(
          "The context of the THFileWidget is null. Can't create options overlay window in TH2FileEditOverlayWindowController.showPLATypeOverlayWindow().");
    }

    Overlay.of(context, rootOverlay: true)
        .insert(_overlayWindows[overlayWindowType]!);
  }
}
