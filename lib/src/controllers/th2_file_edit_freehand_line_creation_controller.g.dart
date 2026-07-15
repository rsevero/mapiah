// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_freehand_line_creation_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditFreehandLineCreationController
    on TH2FileEditFreehandLineCreationControllerBase, Store {
  late final _$_th2FileEditControllerAtom = Atom(
    name:
        'TH2FileEditFreehandLineCreationControllerBase._th2FileEditController',
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

  late final _$_isCapturingAtom = Atom(
    name: 'TH2FileEditFreehandLineCreationControllerBase._isCapturing',
    context: context,
  );

  bool get isCapturing {
    _$_isCapturingAtom.reportRead();
    return super._isCapturing;
  }

  @override
  bool get _isCapturing => isCapturing;

  @override
  set _isCapturing(bool value) {
    _$_isCapturingAtom.reportWrite(value, super._isCapturing, () {
      super._isCapturing = value;
    });
  }

  late final _$_sampledCanvasPointsAtom = Atom(
    name: 'TH2FileEditFreehandLineCreationControllerBase._sampledCanvasPoints',
    context: context,
  );

  ObservableList<Offset> get sampledCanvasPoints {
    _$_sampledCanvasPointsAtom.reportRead();
    return super._sampledCanvasPoints;
  }

  @override
  ObservableList<Offset> get _sampledCanvasPoints => sampledCanvasPoints;

  @override
  set _sampledCanvasPoints(ObservableList<Offset> value) {
    _$_sampledCanvasPointsAtom.reportWrite(
      value,
      super._sampledCanvasPoints,
      () {
        super._sampledCanvasPoints = value;
      },
    );
  }

  late final _$_rawStrokeBoundingBoxAtom = Atom(
    name: 'TH2FileEditFreehandLineCreationControllerBase._rawStrokeBoundingBox',
    context: context,
  );

  Rect? get rawStrokeBoundingBox {
    _$_rawStrokeBoundingBoxAtom.reportRead();
    return super._rawStrokeBoundingBox;
  }

  @override
  Rect? get _rawStrokeBoundingBox => rawStrokeBoundingBox;

  @override
  set _rawStrokeBoundingBox(Rect? value) {
    _$_rawStrokeBoundingBoxAtom.reportWrite(
      value,
      super._rawStrokeBoundingBox,
      () {
        super._rawStrokeBoundingBox = value;
      },
    );
  }

  late final _$_activeSampleSpacingOnScreenAtom = Atom(
    name:
        'TH2FileEditFreehandLineCreationControllerBase._activeSampleSpacingOnScreen',
    context: context,
  );

  double get activeSampleSpacingOnScreen {
    _$_activeSampleSpacingOnScreenAtom.reportRead();
    return super._activeSampleSpacingOnScreen;
  }

  @override
  double get _activeSampleSpacingOnScreen => activeSampleSpacingOnScreen;

  @override
  set _activeSampleSpacingOnScreen(double value) {
    _$_activeSampleSpacingOnScreenAtom.reportWrite(
      value,
      super._activeSampleSpacingOnScreen,
      () {
        super._activeSampleSpacingOnScreen = value;
      },
    );
  }

  late final _$TH2FileEditFreehandLineCreationControllerBaseActionController =
      ActionController(
        name: 'TH2FileEditFreehandLineCreationControllerBase',
        context: context,
      );

  @override
  void startStroke(Offset screenPosition) {
    final _$actionInfo =
        _$TH2FileEditFreehandLineCreationControllerBaseActionController
            .startAction(
              name: 'TH2FileEditFreehandLineCreationControllerBase.startStroke',
            );
    try {
      return super.startStroke(screenPosition);
    } finally {
      _$TH2FileEditFreehandLineCreationControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void appendStrokeSample(Offset screenPosition) {
    final _$actionInfo =
        _$TH2FileEditFreehandLineCreationControllerBaseActionController.startAction(
          name:
              'TH2FileEditFreehandLineCreationControllerBase.appendStrokeSample',
        );
    try {
      return super.appendStrokeSample(screenPosition);
    } finally {
      _$TH2FileEditFreehandLineCreationControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void finishStroke(Offset screenPosition) {
    final _$actionInfo =
        _$TH2FileEditFreehandLineCreationControllerBaseActionController
            .startAction(
              name:
                  'TH2FileEditFreehandLineCreationControllerBase.finishStroke',
            );
    try {
      return super.finishStroke(screenPosition);
    } finally {
      _$TH2FileEditFreehandLineCreationControllerBaseActionController.endAction(
        _$actionInfo,
      );
    }
  }

  @override
  void abandonStroke() {
    final _$actionInfo =
        _$TH2FileEditFreehandLineCreationControllerBaseActionController
            .startAction(
              name:
                  'TH2FileEditFreehandLineCreationControllerBase.abandonStroke',
            );
    try {
      return super.abandonStroke();
    } finally {
      _$TH2FileEditFreehandLineCreationControllerBaseActionController.endAction(
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
