part of 'mp_selected_element.dart';

class MPSelectedArea extends MPSelectedElement {
  late THArea originalAreaClone;
  final List<MPSelectedLine> originalLines = [];

  MPSelectedArea({
    required THArea originalArea,
    required TH2FileEditController th2FileEditController,
  }) {
    _createClone(originalArea, th2FileEditController);
  }

  void _createClone(
    THArea originalArea,
    TH2FileEditController th2FileEditController,
  ) {
    final LinkedHashMap<THCommandOptionType, THCommandOption> optionsMapClone =
        LinkedHashMap<THCommandOptionType, THCommandOption>();

    originalArea.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalAreaClone = originalArea.copyWith(optionsMap: optionsMapClone);

    final List<int> lineMPIDs = originalArea.getLineMPIDs(
      th2FileEditController.thFile,
    );
    final Map<int, MPSelectable> mpSelectableElements = th2FileEditController
        .selectionController
        .getMPSelectableElements();

    for (final int lineMPID in lineMPIDs) {
      originalLines.add(
        MPSelectedLine(
          originalLine:
              (mpSelectableElements[lineMPID] as MPSelectableLine).element
                  as THLine,
          th2FileEditController: th2FileEditController,
        ),
      );
    }
  }

  @override
  void updateClone(TH2FileEditController th2FileEditController) {
    final THArea updatedOriginalArea = th2FileEditController.thFile.areaByMPID(
      mpID,
    );

    _createClone(updatedOriginalArea, th2FileEditController);
  }

  @override
  THArea get originalElementClone => originalAreaClone;
}
