part of 'mp_selected_element.dart';

class MPSelectedPoint extends MPSelectedElement {
  late THPoint originalPointClone;

  MPSelectedPoint({required THPoint originalPoint}) {
    _createClone(originalPoint);
  }

  void _createClone(THPoint originalPoint) {
    final LinkedHashMap<String, THCommandOption> optionsMapClone =
        LinkedHashMap<String, THCommandOption>();
    originalPoint.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalPointClone = originalPoint.copyWith(optionsMap: optionsMapClone);
  }

  @override
  void updateClone(THFile thFile) {
    final THPoint updatedOriginalPoint =
        thFile.elementByMapiahID(mapiahID) as THPoint;
    _createClone(updatedOriginalPoint);
  }

  @override
  THPoint get originalElementClone => originalPointClone;
}
