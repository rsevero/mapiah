part of 'mp_selectable.dart';

class MPSelectableBezierCurveLineSegment extends MPSelectableLineSegment {
  List<Offset>? _controlPointsOnCanvas;
  int? _numOfSegmentsToCalculate;

  MPSelectableBezierCurveLineSegment({
    required THBezierCurveLineSegment bezierCurveLineSegment,
    required super.startPoint,
    required super.th2fileEditController,
  }) : super(lineSegment: bezierCurveLineSegment);

  int get numOfSegmentsToCreate {
    _numOfSegmentsToCalculate ??= _calculateNumOfSegmentsToCreate();

    return _numOfSegmentsToCalculate!;
  }

  int _calculateNumOfSegmentsToCreate() {
    final List<Offset> controlPointsOnScreen =
        controlPointsOnCanvas.map((point) {
      return th2fileEditController.offsetCanvasToScreen(point);
    }).toList();

    final double estimatedLength =
        MPNumericAux.estimateBezierLength(controlPointsOnScreen);

    return MPNumericAux.calculateSegments(
      estimatedLength,
      thDesiredSegmentLengthOnScreen,
    );
  }

  List<Offset> get controlPointsOnCanvas {
    _controlPointsOnCanvas ??= [
      startPoint,
      (element as THBezierCurveLineSegment).controlPoint1.coordinates,
      (element as THBezierCurveLineSegment).controlPoint2.coordinates,
      (element as THBezierCurveLineSegment).endPoint.coordinates,
    ];

    return _controlPointsOnCanvas!;
  }

  bool _isPointNearBezierCurveAdaptative({
    required Offset point,
  }) {
    return MPNumericAux.isPointNearBezierCurve(
      point: point,
      controlPoints: controlPointsOnCanvas,
      toleranceSquared: th2fileEditController.selectionToleranceSquaredOnCanvas,
      numOfSegmentsToCreate: numOfSegmentsToCreate,
    );
  }

  @override
  bool _isPointOnLine(Offset point) {
    return _isPointNearBezierCurveAdaptative(point: point);
  }

  @override
  void canvasTransformChanged() {
    super.canvasTransformChanged();
    _numOfSegmentsToCalculate = null;
  }

  @override
  List<THElement> get selectedElements =>
      List<THBezierCurveLineSegment>.from([element]);
}
