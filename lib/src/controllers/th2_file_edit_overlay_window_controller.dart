import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/widgets/factories/mp_overlay_window_factory.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';
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
    MPWindowType.availableScraps,
    MPWindowType.commandOptions,
    MPWindowType.multipleElementsClicked,
    MPWindowType.optionChoices,
    MPWindowType.plaTypes,
    MPWindowType.scrapOptions,
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
    Offset? outerAnchorPosition,
    MPWidgetPositionType? innerAnchorType,
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
      switch (type) {
        case MPWindowType.optionChoices:
          throw UnimplementedError(
            'Call showOptionChoicesOverlayWindow() to create option choices widgets.',
          );
        default:
          _overlayWindows[type] = MPOverlayWindowFactory.createOverlayWindow(
            th2FileEditController: _th2FileEditController,
            outerAnchorPosition:
                outerAnchorPosition ?? getPositionFromSelectedElements(),
            innerAnchorType: innerAnchorType,
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
    required Offset outerAnchorPosition,
    required MPOptionInfo optionInfo,
  }) {
    const MPWindowType overlayWindowType = MPWindowType.optionChoices;

    if (_overlayWindows.containsKey(overlayWindowType)) {
      _overlayWindows.remove(overlayWindowType);
    }

    _overlayWindows[overlayWindowType] =
        MPOverlayWindowFactory.createOptionChoices(
      th2FileEditController: _th2FileEditController,
      outerAnchorPosition: outerAnchorPosition,
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

    if (type == MPWindowType.multipleElementsClicked) {
      _th2FileEditController
          .selectionController.multipleElementsClickedSemaphore
          .complete();
    }

    if (_activeWindow == MPWindowType.mainTHFileEditWindow) {
      _th2FileEditController.thFileFocusNode.requestFocus();
    }
  }

  @action
  void setShowOverlayWindow(
    MPWindowType type,
    bool show, {
    Offset? outerAnchorPosition,
    MPWidgetPositionType? innerAnchorType,
  }) {
    _isOverlayWindowShown[type] = show;

    if (show) {
      _showOverlayWindow(
        type,
        outerAnchorPosition: outerAnchorPosition,
        innerAnchorType: innerAnchorType,
      );
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
    if (_th2FileEditController
        .selectionController.mpSelectedElementsLogical.isEmpty) {
      return _th2FileEditController.screenBoundingBox.center;
    } else {
      final Rect selectedElementsBoundingBoxOnCanvas = _th2FileEditController
          .selectionController.selectedElementsBoundingBox;
      final Offset selectedElementsCenterOnScreen = _th2FileEditController
          .offsetCanvasToScreen(selectedElementsBoundingBoxOnCanvas.center);

      return selectedElementsCenterOnScreen;
    }
  }

  Offset getPositionFromClickedElements() {
    if (_th2FileEditController.selectionController.clickedElements.isEmpty) {
      return _th2FileEditController.screenBoundingBox.center;
    } else {
      final Rect clickedElementsBoundingBoxOnCanvas = _th2FileEditController
          .selectionController
          .getSelectedElementsBoundingBox();
      final Offset clickedElementsCenterOnScreen = _th2FileEditController
          .offsetCanvasToScreen(clickedElementsBoundingBoxOnCanvas.center);

      return clickedElementsCenterOnScreen;
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

  void perfomToggleScrapOptionsOverlayWindow({
    required int scrapMPID,
    required Offset outerAnchorPosition,
  }) {
    final bool shouldShowScrapOptions =
        !_isOverlayWindowShown[MPWindowType.scrapOptions]!;

    if (shouldShowScrapOptions) {
      _th2FileEditController.optionEditController
          .setOptionsScrapMPID(scrapMPID);
      _th2FileEditController.optionEditController.updateElementOptionMapByMPID(
        scrapMPID,
      );
    }

    setShowOverlayWindow(
      MPWindowType.scrapOptions,
      shouldShowScrapOptions,
      outerAnchorPosition: outerAnchorPosition,
      innerAnchorType: MPWidgetPositionType.rightCenter,
    );
  }
}
