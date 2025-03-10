import 'dart:collection';

import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/mixins/th_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_page_element_edit_controller.g.dart';

class TH2FileEditElementEditController = TH2FileEditElementEditControllerBase
    with _$TH2FileEditElementEditController;

abstract class TH2FileEditElementEditControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditElementEditControllerBase(this._th2FileEditController)
      : _thFile = _th2FileEditController.thFile;

  List<THLineSegment> getLineSegmentsList({
    required THLine line,
    required bool clone,
  }) {
    final List<THLineSegment> lineSegments = <THLineSegment>[];
    final Set<int> lineSegmentMapiahIDs = line.childrenMapiahID;

    for (final int lineSegmentMapiahID in lineSegmentMapiahIDs) {
      final THElement lineSegment =
          _thFile.elementByMapiahID(lineSegmentMapiahID);

      if (lineSegment is THLineSegment) {
        lineSegments.add(clone ? lineSegment.copyWith() : lineSegment);
      }
    }

    return lineSegments;
  }

  LinkedHashMap<int, THLineSegment> getLineSegmentsMap(THLine line) {
    final LinkedHashMap<int, THLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final Set<int> lineSegmentMapiahIDs = line.childrenMapiahID;

    for (final int lineSegmentMapiahID in lineSegmentMapiahIDs) {
      final THElement lineSegment =
          _thFile.elementByMapiahID(lineSegmentMapiahID);

      if (lineSegment is THLineSegment) {
        lineSegmentsMap[lineSegment.mapiahID] = lineSegment;
      }
    }

    return lineSegmentsMap;
  }

  void substituteElement(THElement modifiedElement) {
    _thFile.substituteElement(modifiedElement);
    _th2FileEditController.selectionController
        .addSelectableElement(modifiedElement);
    mpLocator.mpLog.finer('Substituted element ${modifiedElement.mapiahID}');
  }

  void substituteElements(List<THElement> modifiedElements) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    for (final THElement modifiedElement in modifiedElements) {
      _thFile.substituteElement(modifiedElement);
      selectionController.addSelectableElement(modifiedElement);
      mpLocator.mpLog
          .finer('Substituted element ${modifiedElement.mapiahID} from list');
    }
  }

  void substituteElementWithoutAddSelectableElement(THElement modifiedElement) {
    _thFile.substituteElement(modifiedElement);
    mpLocator.mpLog.finer(
        'Substituted element without add selectable element ${modifiedElement.mapiahID}');
  }

  void substituteLineSegments(
    LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap,
  ) {
    for (final THLineSegment lineSegment in modifiedLineSegmentsMap.values) {
      _thFile.substituteElement(lineSegment);
    }

    final THLine line = _thFile.elementByMapiahID(
        modifiedLineSegmentsMap.values.first.parentMapiahID) as THLine;
    line.clearBoundingBox();
  }

  @action
  void addElement({required THElement newElement}) {
    _thFile.addElement(newElement);

    final int parentMapiahID = newElement.parentMapiahID;

    if (parentMapiahID < 0) {
      _thFile.addElementToParent(newElement);
    } else {
      final THIsParentMixin parent =
          _thFile.elementByMapiahID(parentMapiahID) as THIsParentMixin;

      parent.addElementToParent(newElement);
    }

    _th2FileEditController.selectionController.addSelectableElement(newElement);
  }

  void addElementWithParentMapiahIDWithoutSelectableElement({
    required THElement newElement,
    required int parentMapiahID,
  }) {
    addElementWithParentWithoutSelectableElement(
      newElement: newElement,
      parent: _thFile.elementByMapiahID(parentMapiahID) as THIsParentMixin,
    );
  }

  @action
  void addElementWithParentWithoutSelectableElement({
    required THElement newElement,
    required THIsParentMixin parent,
  }) {
    _thFile.addElement(newElement);
    parent.addElementToParent(newElement);
  }

  @action
  void deleteElement(THElement element) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    _thFile.deleteElement(element);
    selectionController.removeSelectableElement(element.mapiahID);
    selectionController.removeSelectedElement(element);
  }

  void deleteElementByMapiahID(int mapiahID) {
    final THElement element = _thFile.elementByMapiahID(mapiahID);

    deleteElement(element);
  }

  @action
  void deleteElementByTHID(String thID) {
    final THElement element = _thFile.elementByTHID(thID);

    deleteElement(element);
  }

  @action
  void deleteElements(List<int> mapiahIDs) {
    for (final int mapiahID in mapiahIDs) {
      deleteElementByMapiahID(mapiahID);
    }
  }

  @action
  void registerElementWithTHID(THElement element, String thID) {
    _thFile.registerElementWithTHID(element, thID);
  }
}
