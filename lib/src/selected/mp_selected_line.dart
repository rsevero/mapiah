part of 'mp_selected_element.dart';

class MPSelectedLine extends MPSelectedElement {
  late THLine originalLineClone;
  final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
      LinkedHashMap<int, THLineSegment>();

  MPSelectedLine({required THLine originalLine, required THFile thFile}) {
    _createClone(originalLine, thFile);
  }

  void _createClone(THLine originalLine, THFile thFile) {
    final Iterable<int> lineSegmentMPIDs = originalLine.childrenMPID;

    originalLineSegmentsMapClone.clear();

    for (final int mpID in lineSegmentMPIDs) {
      final THElement element = thFile.elementByMPID(mpID);

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

    final Set<int> childrenMPIDsClone = originalLine.childrenMPID.toSet();

    final LinkedHashMap<THCommandOptionType, THCommandOption> optionsMapClone =
        LinkedHashMap<THCommandOptionType, THCommandOption>();
    originalLine.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalLineClone = originalLine.copyWith(
      childrenMPID: childrenMPIDsClone,
      optionsMap: optionsMapClone,
    );
  }

  @override
  void updateClone(THFile thFile) {
    final THLine updatedOriginalLine = thFile.elementByMPID(mpID) as THLine;
    _createClone(updatedOriginalLine, thFile);
  }

  @override
  THElement get originalElementClone => originalLineClone;
}
