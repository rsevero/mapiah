part of 'mp_selected_element.dart';

class MPSelectedPoint extends MPSelectedElement {
  late THPoint originalPointClone;

  MPSelectedPoint({required THPoint originalPoint}) {
    _createClone(originalPoint);
  }

  void _createClone(THPoint originalPoint) {
    final SplayTreeMap<THCommandOptionType, THCommandOption> optionsMapClone =
        SplayTreeMap<THCommandOptionType, THCommandOption>();
    final SplayTreeMap<String, THAttrCommandOption> attrOptionsMapClone =
        SplayTreeMap<String, THAttrCommandOption>();

    originalPoint.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });
    originalPoint.attrOptionsMap.forEach((key, value) {
      attrOptionsMapClone[key] = value.copyWith();
    });

    originalPointClone = originalPoint.copyWith(
      optionsMap: optionsMapClone,
      attrOptionsMap: attrOptionsMapClone,
    );
  }

  @override
  void updateClone(TH2FileEditController th2FileEditController) {
    final THPoint updatedOriginalPoint = th2FileEditController.thFile
        .pointByMPID(mpID);

    _createClone(updatedOriginalPoint);
  }

  @override
  THPoint get originalElementClone => originalPointClone;
}
