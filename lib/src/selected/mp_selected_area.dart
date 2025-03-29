part of 'mp_selected_element.dart';

class MPSelectedArea extends MPSelectedElement {
  late THArea originalAreaClone;

  MPSelectedArea({required THArea originalArea}) {
    _createClone(originalArea);
  }

  void _createClone(THArea originalArea) {
    final LinkedHashMap<THCommandOptionType, THCommandOption> optionsMapClone =
        LinkedHashMap<THCommandOptionType, THCommandOption>();

    originalArea.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalAreaClone = originalArea.copyWith(optionsMap: optionsMapClone);
  }

  @override
  void updateClone(THFile thFile) {
    final THArea updatedOriginalArea = thFile.areaByMPID(mpID);

    _createClone(updatedOriginalArea);
  }

  @override
  THArea get originalElementClone => originalAreaClone;
}
