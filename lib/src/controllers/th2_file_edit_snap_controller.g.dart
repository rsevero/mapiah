// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_snap_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditSnapController on TH2FileEditSnapControllerBase, Store {
  late final _$_thFileAtom = Atom(
    name: 'TH2FileEditSnapControllerBase._thFile',
    context: context,
  );

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
    name: 'TH2FileEditSnapControllerBase._th2FileEditController',
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

  late final _$_snapTargetsAtom = Atom(
    name: 'TH2FileEditSnapControllerBase._snapTargets',
    context: context,
  );

  List<THPositionPart> get snapTargets {
    _$_snapTargetsAtom.reportRead();
    return super._snapTargets;
  }

  @override
  List<THPositionPart> get _snapTargets => snapTargets;

  @override
  set _snapTargets(List<THPositionPart> value) {
    _$_snapTargetsAtom.reportWrite(value, super._snapTargets, () {
      super._snapTargets = value;
    });
  }

  late final _$_snapPointTargetTypeAtom = Atom(
    name: 'TH2FileEditSnapControllerBase._snapPointTargetType',
    context: context,
  );

  MPSnapPointTarget get snapPointTargetType {
    _$_snapPointTargetTypeAtom.reportRead();
    return super._snapPointTargetType;
  }

  @override
  MPSnapPointTarget get _snapPointTargetType => snapPointTargetType;

  @override
  set _snapPointTargetType(MPSnapPointTarget value) {
    _$_snapPointTargetTypeAtom.reportWrite(
      value,
      super._snapPointTargetType,
      () {
        super._snapPointTargetType = value;
      },
    );
  }

  late final _$_snapLinePointTargetTypeAtom = Atom(
    name: 'TH2FileEditSnapControllerBase._snapLinePointTargetType',
    context: context,
  );

  MPSnapLinePointTarget get snapLinePointTargetType {
    _$_snapLinePointTargetTypeAtom.reportRead();
    return super._snapLinePointTargetType;
  }

  @override
  MPSnapLinePointTarget get _snapLinePointTargetType => snapLinePointTargetType;

  @override
  set _snapLinePointTargetType(MPSnapLinePointTarget value) {
    _$_snapLinePointTargetTypeAtom.reportWrite(
      value,
      super._snapLinePointTargetType,
      () {
        super._snapLinePointTargetType = value;
      },
    );
  }

  late final _$_pointTargetPLATypesAtom = Atom(
    name: 'TH2FileEditSnapControllerBase._pointTargetPLATypes',
    context: context,
  );

  Set<String> get pointTargetPLATypes {
    _$_pointTargetPLATypesAtom.reportRead();
    return super._pointTargetPLATypes;
  }

  @override
  Set<String> get _pointTargetPLATypes => pointTargetPLATypes;

  @override
  set _pointTargetPLATypes(Set<String> value) {
    _$_pointTargetPLATypesAtom.reportWrite(
      value,
      super._pointTargetPLATypes,
      () {
        super._pointTargetPLATypes = value;
      },
    );
  }

  late final _$_linePointTargetPLATypesAtom = Atom(
    name: 'TH2FileEditSnapControllerBase._linePointTargetPLATypes',
    context: context,
  );

  Set<String> get linePointTargetPLATypes {
    _$_linePointTargetPLATypesAtom.reportRead();
    return super._linePointTargetPLATypes;
  }

  @override
  Set<String> get _linePointTargetPLATypes => linePointTargetPLATypes;

  @override
  set _linePointTargetPLATypes(Set<String> value) {
    _$_linePointTargetPLATypesAtom.reportWrite(
      value,
      super._linePointTargetPLATypes,
      () {
        super._linePointTargetPLATypes = value;
      },
    );
  }

  late final _$_snapXVIFileTargetsAtom = Atom(
    name: 'TH2FileEditSnapControllerBase._snapXVIFileTargets',
    context: context,
  );

  Set<MPSnapXVIFileTarget> get snapXVIFileTargets {
    _$_snapXVIFileTargetsAtom.reportRead();
    return super._snapXVIFileTargets;
  }

  @override
  Set<MPSnapXVIFileTarget> get _snapXVIFileTargets => snapXVIFileTargets;

  @override
  set _snapXVIFileTargets(Set<MPSnapXVIFileTarget> value) {
    _$_snapXVIFileTargetsAtom.reportWrite(value, super._snapXVIFileTargets, () {
      super._snapXVIFileTargets = value;
    });
  }

  late final _$_snapTargetsGridAtom = Atom(
    name: 'TH2FileEditSnapControllerBase._snapTargetsGrid',
    context: context,
  );

  Map<MPSnapGridCell, List<THPositionPart>> get snapTargetsGrid {
    _$_snapTargetsGridAtom.reportRead();
    return super._snapTargetsGrid;
  }

  @override
  Map<MPSnapGridCell, List<THPositionPart>> get _snapTargetsGrid =>
      snapTargetsGrid;

  @override
  set _snapTargetsGrid(Map<MPSnapGridCell, List<THPositionPart>> value) {
    _$_snapTargetsGridAtom.reportWrite(value, super._snapTargetsGrid, () {
      super._snapTargetsGrid = value;
    });
  }

  late final _$TH2FileEditSnapControllerBaseActionController = ActionController(
    name: 'TH2FileEditSnapControllerBase',
    context: context,
  );

  @override
  void setSnapPointTargetType(MPSnapPointTarget target) {
    final _$actionInfo = _$TH2FileEditSnapControllerBaseActionController
        .startAction(
          name: 'TH2FileEditSnapControllerBase.setSnapPointTargetType',
        );
    try {
      return super.setSnapPointTargetType(target);
    } finally {
      _$TH2FileEditSnapControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSnapLinePointTargetType(MPSnapLinePointTarget target) {
    final _$actionInfo = _$TH2FileEditSnapControllerBaseActionController
        .startAction(
          name: 'TH2FileEditSnapControllerBase.setSnapLinePointTargetType',
        );
    try {
      return super.setSnapLinePointTargetType(target);
    } finally {
      _$TH2FileEditSnapControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPointTargetPLATypes(Iterable<String> types) {
    final _$actionInfo = _$TH2FileEditSnapControllerBaseActionController
        .startAction(
          name: 'TH2FileEditSnapControllerBase.setPointTargetPLATypes',
        );
    try {
      return super.setPointTargetPLATypes(types);
    } finally {
      _$TH2FileEditSnapControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLinePointTargetPLATypes(Iterable<String> types) {
    final _$actionInfo = _$TH2FileEditSnapControllerBaseActionController
        .startAction(
          name: 'TH2FileEditSnapControllerBase.setLinePointTargetPLATypes',
        );
    try {
      return super.setLinePointTargetPLATypes(types);
    } finally {
      _$TH2FileEditSnapControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSnapTargets() {
    final _$actionInfo = _$TH2FileEditSnapControllerBaseActionController
        .startAction(name: 'TH2FileEditSnapControllerBase.clearSnapTargets');
    try {
      return super.clearSnapTargets();
    } finally {
      _$TH2FileEditSnapControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addPointTargetPLAType(String type) {
    final _$actionInfo = _$TH2FileEditSnapControllerBaseActionController
        .startAction(
          name: 'TH2FileEditSnapControllerBase.addPointTargetPLAType',
        );
    try {
      return super.addPointTargetPLAType(type);
    } finally {
      _$TH2FileEditSnapControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removePointTargetPLAType(String type) {
    final _$actionInfo = _$TH2FileEditSnapControllerBaseActionController
        .startAction(
          name: 'TH2FileEditSnapControllerBase.removePointTargetPLAType',
        );
    try {
      return super.removePointTargetPLAType(type);
    } finally {
      _$TH2FileEditSnapControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addLinePointTargetPLAType(String type) {
    final _$actionInfo = _$TH2FileEditSnapControllerBaseActionController
        .startAction(
          name: 'TH2FileEditSnapControllerBase.addLinePointTargetPLAType',
        );
    try {
      return super.addLinePointTargetPLAType(type);
    } finally {
      _$TH2FileEditSnapControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeLinePointTargetPLAType(String type) {
    final _$actionInfo = _$TH2FileEditSnapControllerBaseActionController
        .startAction(
          name: 'TH2FileEditSnapControllerBase.removeLinePointTargetPLAType',
        );
    try {
      return super.removeLinePointTargetPLAType(type);
    } finally {
      _$TH2FileEditSnapControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
