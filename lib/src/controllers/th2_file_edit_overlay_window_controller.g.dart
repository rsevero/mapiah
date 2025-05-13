// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_overlay_window_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditOverlayWindowController
    on TH2FileEditOverlayWindowControllerBase, Store {
  Computed<bool>? _$showChangeScrapOverlayWindowComputed;

  @override
  bool get showChangeScrapOverlayWindow =>
      (_$showChangeScrapOverlayWindowComputed ??= Computed<bool>(
              () => super.showChangeScrapOverlayWindow,
              name:
                  'TH2FileEditOverlayWindowControllerBase.showChangeScrapOverlayWindow'))
          .value;

  late final _$_thFileAtom = Atom(
      name: 'TH2FileEditOverlayWindowControllerBase._thFile', context: context);

  THFile get thFile {
    _$_thFileAtom.reportRead();
    return super._thFile;
  }

  @override
  THFile get _thFile => thFile;

  @override
  set _thFile(THFile value) {
    _$_thFileAtom.reportWrite(value, super._thFile, () {
      super._thFile = value;
    });
  }

  late final _$_th2FileEditControllerAtom = Atom(
      name: 'TH2FileEditOverlayWindowControllerBase._th2FileEditController',
      context: context);

  TH2FileEditController get th2FileEditController {
    _$_th2FileEditControllerAtom.reportRead();
    return super._th2FileEditController;
  }

  @override
  TH2FileEditController get _th2FileEditController => th2FileEditController;

  @override
  set _th2FileEditController(TH2FileEditController value) {
    _$_th2FileEditControllerAtom
        .reportWrite(value, super._th2FileEditController, () {
      super._th2FileEditController = value;
    });
  }

  late final _$_globalKeyWidgetKeyByTypeAtom = Atom(
      name: 'TH2FileEditOverlayWindowControllerBase._globalKeyWidgetKeyByType',
      context: context);

  Map<MPGlobalKeyWidgetType, GlobalKey<State<StatefulWidget>>>
      get globalKeyWidgetKeyByType {
    _$_globalKeyWidgetKeyByTypeAtom.reportRead();
    return super._globalKeyWidgetKeyByType;
  }

  @override
  Map<MPGlobalKeyWidgetType, GlobalKey<State<StatefulWidget>>>
      get _globalKeyWidgetKeyByType => globalKeyWidgetKeyByType;

  @override
  set _globalKeyWidgetKeyByType(
      Map<MPGlobalKeyWidgetType, GlobalKey<State<StatefulWidget>>> value) {
    _$_globalKeyWidgetKeyByTypeAtom
        .reportWrite(value, super._globalKeyWidgetKeyByType, () {
      super._globalKeyWidgetKeyByType = value;
    });
  }

  late final _$_isOverlayWindowShownAtom = Atom(
      name: 'TH2FileEditOverlayWindowControllerBase._isOverlayWindowShown',
      context: context);

  ObservableMap<MPWindowType, bool> get isOverlayWindowShown {
    _$_isOverlayWindowShownAtom.reportRead();
    return super._isOverlayWindowShown;
  }

  @override
  ObservableMap<MPWindowType, bool> get _isOverlayWindowShown =>
      isOverlayWindowShown;

  @override
  set _isOverlayWindowShown(ObservableMap<MPWindowType, bool> value) {
    _$_isOverlayWindowShownAtom.reportWrite(value, super._isOverlayWindowShown,
        () {
      super._isOverlayWindowShown = value;
    });
  }

  late final _$_activeWindowAtom = Atom(
      name: 'TH2FileEditOverlayWindowControllerBase._activeWindow',
      context: context);

  MPWindowType get activeWindow {
    _$_activeWindowAtom.reportRead();
    return super._activeWindow;
  }

  @override
  MPWindowType get _activeWindow => activeWindow;

  @override
  set _activeWindow(MPWindowType value) {
    _$_activeWindowAtom.reportWrite(value, super._activeWindow, () {
      super._activeWindow = value;
    });
  }

  late final _$_overlayWindowsAtom = Atom(
      name: 'TH2FileEditOverlayWindowControllerBase._overlayWindows',
      context: context);

  ObservableMap<MPWindowType, OverlayEntry> get overlayWindows {
    _$_overlayWindowsAtom.reportRead();
    return super._overlayWindows;
  }

  @override
  ObservableMap<MPWindowType, OverlayEntry> get _overlayWindows =>
      overlayWindows;

  @override
  set _overlayWindows(ObservableMap<MPWindowType, OverlayEntry> value) {
    _$_overlayWindowsAtom.reportWrite(value, super._overlayWindows, () {
      super._overlayWindows = value;
    });
  }

  late final _$_secondLevelOptionOpenedOverlayWindowAtom = Atom(
      name:
          'TH2FileEditOverlayWindowControllerBase._secondLevelOptionOpenedOverlayWindow',
      context: context);

  MPWindowType? get secondLevelOptionOpenedOverlayWindow {
    _$_secondLevelOptionOpenedOverlayWindowAtom.reportRead();
    return super._secondLevelOptionOpenedOverlayWindow;
  }

  @override
  MPWindowType? get _secondLevelOptionOpenedOverlayWindow =>
      secondLevelOptionOpenedOverlayWindow;

  @override
  set _secondLevelOptionOpenedOverlayWindow(MPWindowType? value) {
    _$_secondLevelOptionOpenedOverlayWindowAtom
        .reportWrite(value, super._secondLevelOptionOpenedOverlayWindow, () {
      super._secondLevelOptionOpenedOverlayWindow = value;
    });
  }

  late final _$_isAutoDismissWindowOpenAtom = Atom(
      name: 'TH2FileEditOverlayWindowControllerBase._isAutoDismissWindowOpen',
      context: context);

  bool get isAutoDismissWindowOpen {
    _$_isAutoDismissWindowOpenAtom.reportRead();
    return super._isAutoDismissWindowOpen;
  }

  @override
  bool get _isAutoDismissWindowOpen => isAutoDismissWindowOpen;

  @override
  set _isAutoDismissWindowOpen(bool value) {
    _$_isAutoDismissWindowOpenAtom
        .reportWrite(value, super._isAutoDismissWindowOpen, () {
      super._isAutoDismissWindowOpen = value;
    });
  }

  late final _$TH2FileEditOverlayWindowControllerBaseActionController =
      ActionController(
          name: 'TH2FileEditOverlayWindowControllerBase', context: context);

  @override
  void showOptionChoicesOverlayWindow(
      {required Offset outerAnchorPosition, required MPOptionInfo optionInfo}) {
    final _$actionInfo =
        _$TH2FileEditOverlayWindowControllerBaseActionController.startAction(
            name:
                'TH2FileEditOverlayWindowControllerBase.showOptionChoicesOverlayWindow');
    try {
      return super.showOptionChoicesOverlayWindow(
          outerAnchorPosition: outerAnchorPosition, optionInfo: optionInfo);
    } finally {
      _$TH2FileEditOverlayWindowControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setShowOverlayWindow(MPWindowType type, bool show,
      {Offset? outerAnchorPosition, MPWidgetPositionType? innerAnchorType}) {
    final _$actionInfo =
        _$TH2FileEditOverlayWindowControllerBaseActionController.startAction(
            name:
                'TH2FileEditOverlayWindowControllerBase.setShowOverlayWindow');
    try {
      return super.setShowOverlayWindow(type, show,
          outerAnchorPosition: outerAnchorPosition,
          innerAnchorType: innerAnchorType);
    } finally {
      _$TH2FileEditOverlayWindowControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void closeAutoDismissOverlayWindows() {
    final _$actionInfo =
        _$TH2FileEditOverlayWindowControllerBaseActionController.startAction(
            name:
                'TH2FileEditOverlayWindowControllerBase.closeAutoDismissOverlayWindows');
    try {
      return super.closeAutoDismissOverlayWindows();
    } finally {
      _$TH2FileEditOverlayWindowControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void clearOverlayWindows() {
    final _$actionInfo =
        _$TH2FileEditOverlayWindowControllerBaseActionController.startAction(
            name: 'TH2FileEditOverlayWindowControllerBase.clearOverlayWindows');
    try {
      return super.clearOverlayWindows();
    } finally {
      _$TH2FileEditOverlayWindowControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void performToggleShowPLATypeOverlayWindow(
      {required Offset outerAnchorPosition,
      required THElementType elementType,
      required String? selectedType}) {
    final _$actionInfo =
        _$TH2FileEditOverlayWindowControllerBaseActionController.startAction(
            name:
                'TH2FileEditOverlayWindowControllerBase.performToggleShowPLATypeOverlayWindow');
    try {
      return super.performToggleShowPLATypeOverlayWindow(
          outerAnchorPosition: outerAnchorPosition,
          elementType: elementType,
          selectedType: selectedType);
    } finally {
      _$TH2FileEditOverlayWindowControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void showPLATypeOverlayWindow(
      {required Offset outerAnchorPosition,
      required THElementType elementType,
      required String? selectedType}) {
    final _$actionInfo =
        _$TH2FileEditOverlayWindowControllerBaseActionController.startAction(
            name:
                'TH2FileEditOverlayWindowControllerBase.showPLATypeOverlayWindow');
    try {
      return super.showPLATypeOverlayWindow(
          outerAnchorPosition: outerAnchorPosition,
          elementType: elementType,
          selectedType: selectedType);
    } finally {
      _$TH2FileEditOverlayWindowControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
showChangeScrapOverlayWindow: ${showChangeScrapOverlayWindow}
    ''';
  }
}
