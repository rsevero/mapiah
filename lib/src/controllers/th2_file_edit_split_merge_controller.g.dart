// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_split_merge_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditSplitMergeController
    on TH2FileEditSplitMergeControllerBase, Store {
  late final _$_th2FileAtom = Atom(
    name: 'TH2FileEditSplitMergeControllerBase._th2File',
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
    name: 'TH2FileEditSplitMergeControllerBase._th2FileEditController',
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

  late final _$TH2FileEditSplitMergeControllerBaseActionController =
      ActionController(
        name: 'TH2FileEditSplitMergeControllerBase',
        context: context,
      );

  @override
  void prepareJoinLinesAtCoincidingExtremities() {
    final _$actionInfo = _$TH2FileEditSplitMergeControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditSplitMergeControllerBase.prepareJoinLinesAtCoincidingExtremities',
        );
    try {
      return super.prepareJoinLinesAtCoincidingExtremities();
    } finally {
      _$TH2FileEditSplitMergeControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void prepareSplitLineAtSelectedEndPoints() {
    final _$actionInfo = _$TH2FileEditSplitMergeControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditSplitMergeControllerBase.prepareSplitLineAtSelectedEndPoints',
        );
    try {
      return super.prepareSplitLineAtSelectedEndPoints();
    } finally {
      _$TH2FileEditSplitMergeControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void prepareSplitLinesAtCrossings() {
    final _$actionInfo = _$TH2FileEditSplitMergeControllerBaseActionController
        .startAction(
          name:
              'TH2FileEditSplitMergeControllerBase.prepareSplitLinesAtCrossings',
        );
    try {
      return super.prepareSplitLinesAtCrossings();
    } finally {
      _$TH2FileEditSplitMergeControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
