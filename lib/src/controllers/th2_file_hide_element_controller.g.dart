// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_hide_element_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileHideElementController
    on TH2FileHideElementControllerBase, Store {
  Computed<int>? _$visibleScrapCountComputed;

  @override
  int get visibleScrapCount => (_$visibleScrapCountComputed ??= Computed<int>(
    () => super.visibleScrapCount,
    name: 'TH2FileHideElementControllerBase.visibleScrapCount',
  )).value;
  Computed<bool>? _$allScrapsVisibleComputed;

  @override
  bool get allScrapsVisible => (_$allScrapsVisibleComputed ??= Computed<bool>(
    () => super.allScrapsVisible,
    name: 'TH2FileHideElementControllerBase.allScrapsVisible',
  )).value;
  Computed<bool>? _$allElementsVisibleComputed;

  @override
  bool get allElementsVisible =>
      (_$allElementsVisibleComputed ??= Computed<bool>(
        () => super.allElementsVisible,
        name: 'TH2FileHideElementControllerBase.allElementsVisible',
      )).value;

  late final _$_th2FileAtom = Atom(
    name: 'TH2FileHideElementControllerBase._th2File',
    context: context,
  );

  TH2File get th2File {
    _$_th2FileAtom.reportRead();
    return super._th2File;
  }

  @override
  TH2File get _th2File => th2File;

  @override
  set _th2File(TH2File value) {
    _$_th2FileAtom.reportWrite(value, super._th2File, () {
      super._th2File = value;
    });
  }

  late final _$_th2FileEditControllerAtom = Atom(
    name: 'TH2FileHideElementControllerBase._th2FileEditController',
    context: context,
  );

  TH2FileEditController get th2FileEditController {
    _$_th2FileEditControllerAtom.reportRead();
    return super._th2FileEditController;
  }

  @override
  TH2FileEditController get _th2FileEditController => th2FileEditController;

  @override
  set _th2FileEditController(TH2FileEditController value) {
    _$_th2FileEditControllerAtom.reportWrite(
      value,
      super._th2FileEditController,
      () {
        super._th2FileEditController = value;
      },
    );
  }

  late final _$_hiddenScrapMPIDsAtom = Atom(
    name: 'TH2FileHideElementControllerBase._hiddenScrapMPIDs',
    context: context,
  );

  ObservableSet<int> get hiddenScrapMPIDs {
    _$_hiddenScrapMPIDsAtom.reportRead();
    return super._hiddenScrapMPIDs;
  }

  @override
  ObservableSet<int> get _hiddenScrapMPIDs => hiddenScrapMPIDs;

  @override
  set _hiddenScrapMPIDs(ObservableSet<int> value) {
    _$_hiddenScrapMPIDsAtom.reportWrite(value, super._hiddenScrapMPIDs, () {
      super._hiddenScrapMPIDs = value;
    });
  }

  late final _$_hiddenElementMPIDsAtom = Atom(
    name: 'TH2FileHideElementControllerBase._hiddenElementMPIDs',
    context: context,
  );

  ObservableSet<int> get hiddenElementMPIDs {
    _$_hiddenElementMPIDsAtom.reportRead();
    return super._hiddenElementMPIDs;
  }

  @override
  ObservableSet<int> get _hiddenElementMPIDs => hiddenElementMPIDs;

  @override
  set _hiddenElementMPIDs(ObservableSet<int> value) {
    _$_hiddenElementMPIDsAtom.reportWrite(value, super._hiddenElementMPIDs, () {
      super._hiddenElementMPIDs = value;
    });
  }

  late final _$TH2FileHideElementControllerBaseActionController =
      ActionController(
        name: 'TH2FileHideElementControllerBase',
        context: context,
      );

  @override
  void toggleAllScrapsVisibility() {
    final _$actionInfo = _$TH2FileHideElementControllerBaseActionController
        .startAction(
          name: 'TH2FileHideElementControllerBase.toggleAllScrapsVisibility',
        );
    try {
      return super.toggleAllScrapsVisibility();
    } finally {
      _$TH2FileHideElementControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void toggleScrapVisibility(int scrapMPID) {
    final _$actionInfo = _$TH2FileHideElementControllerBaseActionController
        .startAction(
          name: 'TH2FileHideElementControllerBase.toggleScrapVisibility',
        );
    try {
      return super.toggleScrapVisibility(scrapMPID);
    } finally {
      _$TH2FileHideElementControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void performHideSelectedOrClearHidden() {
    final _$actionInfo = _$TH2FileHideElementControllerBaseActionController
        .startAction(
          name:
              'TH2FileHideElementControllerBase.performHideSelectedOrClearHidden',
        );
    try {
      return super.performHideSelectedOrClearHidden();
    } finally {
      _$TH2FileHideElementControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  String toString() {
    return '''
visibleScrapCount: ${visibleScrapCount},
allScrapsVisible: ${allScrapsVisible},
allElementsVisible: ${allElementsVisible}
    ''';
  }
}
