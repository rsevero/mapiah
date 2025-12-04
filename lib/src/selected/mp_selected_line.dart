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
    final THFile thFile = th2FileEditController.thFile;
    final Iterable<int> lineSegmentMPIDs = originalLine.getLineSegmentMPIDs(
      thFile,
    );

    originalLineSegmentsMapClone.clear();

    for (final int mpID in lineSegmentMPIDs) {
      final THLineSegment lineSegment = thFile.lineSegmentByMPID(mpID);
      final SplayTreeMap<THCommandOptionType, THCommandOption> optionsMap =
          SplayTreeMap<THCommandOptionType, THCommandOption>();
      final SplayTreeMap<String, THAttrCommandOption> attrOptionsMap =
          SplayTreeMap<String, THAttrCommandOption>();

      lineSegment.optionsMap.forEach((key, value) {
        optionsMap[key] = value.copyWith();
      });
      lineSegment.attrOptionsMap.forEach((key, value) {
        attrOptionsMap[key] = value.copyWith();
      });

      originalLineSegmentsMapClone[mpID] = lineSegment.copyWith(
        optionsMap: optionsMap,
        attrOptionsMap: attrOptionsMap,
      );
    }

    final List<int> childrenMPIDsClone = originalLine.childrenMPIDs.toList();
    final SplayTreeMap<THCommandOptionType, THCommandOption> optionsMapClone =
        SplayTreeMap<THCommandOptionType, THCommandOption>();
    final SplayTreeMap<String, THAttrCommandOption> attrOptionsMapClone =
        SplayTreeMap<String, THAttrCommandOption>();

    originalLine.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });
    originalLine.attrOptionsMap.forEach((key, value) {
      attrOptionsMapClone[key] = value.copyWith();
    });

    originalLineClone = originalLine.copyWith(
      childrenMPIDs: childrenMPIDsClone,
      optionsMap: optionsMapClone,
      attrOptionsMap: attrOptionsMapClone,
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
