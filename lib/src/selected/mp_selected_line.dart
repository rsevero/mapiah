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
    THLine currentLine,
    TH2FileEditController th2FileEditController,
  ) {
    final THFile thFile = th2FileEditController.thFile;

    /// We need to use the childrenMPIDs directly from the line, because
    /// using originalLine.getLineSegments(thFile) or
    /// originalLine.getLineSegmentMPIDs(thFile,) here messes with the updating
    /// of the control points during interactive editing.
    final Iterable<int> lineSegmentMPIDs = currentLine.childrenMPIDs;

    originalLineSegmentsMapClone.clear();

    for (final int mpID in lineSegmentMPIDs) {
      final THElement lineSegment = thFile.elementByMPID(mpID);

      if (lineSegment is! THLineSegment) {
        continue;
      }

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

    final List<int> childrenMPIDsClone = currentLine.childrenMPIDs.toList();
    final SplayTreeMap<THCommandOptionType, THCommandOption> optionsMapClone =
        SplayTreeMap<THCommandOptionType, THCommandOption>();
    final SplayTreeMap<String, THAttrCommandOption> attrOptionsMapClone =
        SplayTreeMap<String, THAttrCommandOption>();

    currentLine.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });
    currentLine.attrOptionsMap.forEach((key, value) {
      attrOptionsMapClone[key] = value.copyWith();
    });

    originalLineClone = currentLine.copyWith(
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
