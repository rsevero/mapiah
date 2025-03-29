part of 'mp_selected_element.dart';

class MPSelectedPoint extends MPSelectedElement {
  late THPoint originalPointClone;

  MPSelectedPoint({required THPoint originalPoint}) {
    _createClone(originalPoint);
  }

  void _createClone(THPoint originalPoint) {
    final LinkedHashMap<THCommandOptionType, THCommandOption> optionsMapClone =
        LinkedHashMap<THCommandOptionType, THCommandOption>();

    originalPoint.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalPointClone = originalPoint.copyWith(optionsMap: optionsMapClone);
  }

  @override
  void updateClone(THFile thFile) {
    final THPoint updatedOriginalPoint = thFile.pointByMPID(mpID);

    _createClone(updatedOriginalPoint);
  }

  @override
  THPoint get originalElementClone => originalPointClone;
}
