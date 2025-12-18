part of 'mp_selected_element.dart';

class MPSelectedScrap extends MPSelectedElement {
  late THScrap originalScrapClone;

  MPSelectedScrap({required THScrap originalScrap}) {
    _createClone(originalScrap);
  }

  void _createClone(THScrap originalScrap) {
    final SplayTreeMap<THCommandOptionType, THCommandOption> optionsMapClone =
        SplayTreeMap<THCommandOptionType, THCommandOption>();
    final SplayTreeMap<String, THAttrCommandOption> attrOptionsMapClone =
        SplayTreeMap<String, THAttrCommandOption>();

    originalScrap.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });
    originalScrap.attrOptionsMap.forEach((key, value) {
      attrOptionsMapClone[key] = value.copyWith();
    });

    originalScrapClone = originalScrap.copyWith(
      optionsMap: optionsMapClone,
      attrOptionsMap: attrOptionsMapClone,
    );
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
