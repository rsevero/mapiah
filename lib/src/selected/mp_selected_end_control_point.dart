part of 'mp_selected_element.dart';

class MPSelectedEndControlPoint extends MPSelectedElement {
  late THLineSegment originalLineSegmentClone;
  final MPEndControlPointType type;

  MPSelectedEndControlPoint({
    required THLineSegment originalLineSegment,
    required this.type,
  }) : super() {
    _createClone(originalLineSegment);
  }

  void _createClone(THLineSegment originalLineSegment) {
    final LinkedHashMap<THCommandOptionType, THCommandOption> optionsMapClone =
        LinkedHashMap<THCommandOptionType, THCommandOption>();

    originalLineSegment.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalLineSegmentClone = originalLineSegment.copyWith(
      optionsMap: optionsMapClone,
    );
  }

  @override
  void updateClone(TH2FileEditController th2FileEditController) {
    final THLineSegment updatedOriginalLineSegment = th2FileEditController
        .thFile
        .lineSegmentByMPID(mpID);

    _createClone(updatedOriginalLineSegment);
  }

  @override
  THLineSegment get originalElementClone => originalLineSegmentClone;
}
