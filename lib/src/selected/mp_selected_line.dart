part of 'mp_selected_element.dart';

class MPSelectedLine extends MPSelectedElement {
  late THLine originalLineClone;
  final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
      LinkedHashMap<int, THLineSegment>();

  MPSelectedLine({
    required THLine originalLine,
    required TH2FileEditController th2FileEditController,
  }) {
    _createClone(originalLine, th2FileEditController);
  }

  void _createClone(
    THLine originalLine,
    TH2FileEditController th2FileEditController,
  ) {
    final Iterable<int> lineSegmentMPIDs = originalLine.childrenMPIDs;

    originalLineSegmentsMapClone.clear();

    for (final int mpID in lineSegmentMPIDs) {
      final THElement element = th2FileEditController.thFile.elementByMPID(
        mpID,
      );

      if (element is! THLineSegment) {
        continue;
      }

      final LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap =
          LinkedHashMap<THCommandOptionType, THCommandOption>();

      element.optionsMap.forEach((key, value) {
        optionsMap[key] = value.copyWith();
      });

      originalLineSegmentsMapClone[element.mpID] = element.copyWith(
        optionsMap: optionsMap,
      );
    }

    final List<int> childrenMPIDsClone = originalLine.childrenMPIDs.toList();

    final LinkedHashMap<THCommandOptionType, THCommandOption> optionsMapClone =
        LinkedHashMap<THCommandOptionType, THCommandOption>();
    originalLine.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalLineClone = originalLine.copyWith(
      childrenMPIDs: childrenMPIDsClone,
      optionsMap: optionsMapClone,
    );
  }

  @override
  void updateClone(TH2FileEditController th2FileEditController) {
    final THLine updatedOriginalLine = th2FileEditController.thFile.lineByMPID(
      mpID,
    );

    _createClone(updatedOriginalLine, th2FileEditController);
  }

  @override
  THElement get originalElementClone => originalLineClone;
}
