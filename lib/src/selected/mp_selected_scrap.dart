part of 'mp_selected_element.dart';

class MPSelectedScrap extends MPSelectedElement {
  late THScrap originalScrapClone;

  MPSelectedScrap({required THScrap originalScrap}) {
    _createClone(originalScrap);
  }

  void _createClone(THScrap originalScrap) {
    final SplayTreeMap<THCommandOptionType, THCommandOption> optionsMapClone =
        SplayTreeMap<THCommandOptionType, THCommandOption>();

    originalScrap.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalScrapClone = originalScrap.copyWith(optionsMap: optionsMapClone);
  }

  @override
  void updateClone(TH2FileEditController th2FileEditController) {
    final THScrap updatedOriginalScrap = th2FileEditController.thFile
        .scrapByMPID(mpID);

    _createClone(updatedOriginalScrap);
  }

  @override
  THScrap get originalElementClone => originalScrapClone;
}
