// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_state_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditStateController on TH2FileEditStateControllerBase, Store {
  late final _$_th2FileEditControllerAtom = Atom(
      name: 'TH2FileEditStateControllerBase._th2FileEditController',
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

  late final _$_stateAtom =
      Atom(name: 'TH2FileEditStateControllerBase._state', context: context);

  MPTH2FileEditState get state {
    _$_stateAtom.reportRead();
    return super._state;
  }

  @override
  MPTH2FileEditState get _state => state;

  @override
  set _state(MPTH2FileEditState value) {
    _$_stateAtom.reportWrite(value, super._state, () {
      super._state = value;
    });
  }

  late final _$TH2FileEditStateControllerBaseActionController =
      ActionController(
          name: 'TH2FileEditStateControllerBase', context: context);

  @override
  bool setState(MPTH2FileEditStateType type) {
    final _$actionInfo = _$TH2FileEditStateControllerBaseActionController
        .startAction(name: 'TH2FileEditStateControllerBase.setState');
    try {
      return super.setState(type);
    } finally {
      _$TH2FileEditStateControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
