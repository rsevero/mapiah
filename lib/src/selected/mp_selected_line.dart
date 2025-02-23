part of 'mp_selected_element.dart';

class MPSelectedLine extends MPSelectedElement {
  late THLine originalLineClone;
  final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
      LinkedHashMap<int, THLineSegment>();

  MPSelectedLine({required THLine originalLine, required THFile thFile}) {
    _createClone(originalLine, thFile);
  }

  void _createClone(THLine originalLine, THFile thFile) {
    final Iterable<int> lineSegmentMapiahIDs = originalLine.childrenMapiahID;

    originalLineSegmentsMapClone.clear();

    for (final int mapiahID in lineSegmentMapiahIDs) {
      final THElement element = thFile.elementByMapiahID(mapiahID);

      if (element is! THLineSegment) {
        continue;
      }

      final LinkedHashMap<String, THCommandOption> optionsMap =
          LinkedHashMap<String, THCommandOption>();

      element.optionsMap.forEach((key, value) {
        optionsMap[key] = value.copyWith();
      });

      originalLineSegmentsMapClone[element.mapiahID] = element.copyWith(
        optionsMap: optionsMap,
      );
    }

    final Set<int> childrenMapiahIDsClone =
        originalLine.childrenMapiahID.toSet();

    final LinkedHashMap<String, THCommandOption> optionsMapClone =
        LinkedHashMap<String, THCommandOption>();
    originalLine.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalLineClone = originalLine.copyWith(
      childrenMapiahID: childrenMapiahIDsClone,
      optionsMap: optionsMapClone,
    );
  }

  @override
  void updateClone(THFile thFile) {
    final THLine updatedOriginalLine =
        thFile.elementByMapiahID(mapiahID) as THLine;
    _createClone(updatedOriginalLine, thFile);
  }

  @override
  THElement get originalElementClone => originalLineClone;
}
