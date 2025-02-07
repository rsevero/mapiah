part of 'mp_selectable.dart';

class MPSelectableStraightLineSegment extends MPSelectableLineSegment {
  MPSelectableStraightLineSegment({
    required THStraightLineSegment straightLineSegment,
    required super.startPoint,
    required super.th2fileEditController,
  }) : super(lineSegment: straightLineSegment);

  @override
  bool _isPointOnLine(Offset point) {
    return MPNumericAux.isPointNearLineSegment(
      point: point,
      segmentStart: startPoint,
      segmentEnd: (element as THStraightLineSegment).endPoint.coordinates,
      toleranceSquared: th2fileEditController.selectionToleranceSquaredOnCanvas,
    );
  }

  @override
  List<THElement> get selectedElements =>
      List<THStraightLineSegment>.from([element]);
}
