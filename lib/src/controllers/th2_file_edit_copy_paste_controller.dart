// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_copy_element_result.dart';
import 'package:mapiah/src/auxiliary/mp_copy_template.dart';
import 'package:mapiah/src/auxiliary/mp_thelement_paste_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_copy_paste_controller.g.dart';

class TH2FileEditCopyPasteController = TH2FileEditCopyPasteControllerBase
    with _$TH2FileEditCopyPasteController;

abstract class TH2FileEditCopyPasteControllerBase with Store {
  @readonly
  TH2File _th2File;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditCopyPasteControllerBase(this._th2FileEditController)
    : _th2File = _th2FileEditController.th2File;

  @action
  void copySelectedElements() {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final Iterable<MPSelectedElement> selectedElements =
        selectionController.mpSelectedElementsLogical.values;

    if (selectedElements.isEmpty) {
      return;
    }

    /// Filter selection to only top elements (THScrap, THPoint, THLine, THArea).
    final List<THElement> topElements = [];
    for (final MPSelectedElement selectedElement in selectedElements) {
      final THElement element = selectedElement.originalElementClone;

      if ((element is THScrap) ||
          (element is THPoint) ||
          (element is THLine) ||
          (element is THArea)) {
        topElements.add(element);
      }
    }

    if (topElements.isEmpty) {
      return;
    }

    /// Initialize tracking set for copied MPIDs (for deduplication).
    final Set<int> trackedMPIDs = {};

    /// Build clipboard with new structure.
    final List<MPCopyElementWithChildren> result = [];

    for (final THElement element in topElements) {
      final List<MPCopyElementWithChildren> entries = _buildCopyResult(
        element,
        mpAddChildAtEndMinusOneOfParentChildrenList,
        trackedMPIDs,
      );

      result.addAll(entries);
    }

    /// Store as List<MPCopyElementWithChildren> in clipboard.
    mpLocator.mpGeneralController.setClipboard(result);
  }

  /// Build copy result recursively for one element with its children.
  ///
  /// Returns a List<MPCopyElementWithChildren> which may include pre-sibling
  /// entries (e.g., border lines for areas, already duplicated lines).
  List<MPCopyElementWithChildren> _buildCopyResult(
    THElement element,
    int positionAtParent,
    Set<int> trackedMPIDs,
  ) {
    final List<MPCopyElementWithChildren> result = [];

    /// Handle THArea special case: extract border lines first.
    if (element is THArea) {
      final THIsParentMixin parent = element as THIsParentMixin;

      for (final int childMPID in parent.childrenMPIDs) {
        final THElement child = _th2File.elementByMPID(childMPID);

        if (child is THAreaBorderTHID) {
          /// Extract referenced border line's MPID from thID.
          final String borderTHID = child.thID;

          if (_th2File.hasElementByTHID(borderTHID)) {
            final THElement borderLine = _th2File.elementByTHID(borderTHID);

            if (!trackedMPIDs.contains(borderLine.mpID)) {
              /// Call _buildCopyResult recursively with SAME position as area.
              final List<MPCopyElementWithChildren> borderLineEntries =
                  _buildCopyResult(borderLine, positionAtParent, trackedMPIDs);

              result.addAll(borderLineEntries);
            }
          }
        }
      }
    }

    /// Handle THLine special case: check if already copied.
    if (element is THLine) {
      if (trackedMPIDs.contains(element.mpID)) {
        return [];
      }
      trackedMPIDs.add(element.mpID);
    }

    /// Create entry for this element.
    final List<MPCopyElementWithChildren> childrenList = [];

    if (element is THIsParentMixin) {
      final THIsParentMixin parent = element as THIsParentMixin;

      for (final int childMPID in parent.childrenMPIDs) {
        final THElement child = _th2File.elementByMPID(childMPID);
        final List<MPCopyElementWithChildren> childEntries = _buildCopyResult(
          child,
          mpAddChildAtEndOfParentChildrenList,
          trackedMPIDs,
        );

        childrenList.addAll(childEntries);
      }
    }

    final MPCopyTemplate template = MPCopyTemplate.fromElement(element);
    final MPCopyElementWithChildren entry = MPCopyElementWithChildren(
      template: template,
      positionAtParent: positionAtParent,
      childrenResult: childrenList,
    );

    result.add(entry);

    return result;
  }

  @action
  void pasteElements() {
    final List<MPCopyElementWithChildren>? clipboard = mpLocator
        .mpGeneralController
        .getClipboard();

    if ((clipboard == null) || clipboard.isEmpty) {
      return;
    }

    final int activeScrapMPID = _th2FileEditController.activeScrapID;

    /// Materialize and build commands from clipboard.
    final MPTHElementPasteAux pasteAux = MPTHElementPasteAux(
      copyResult: clipboard,
      th2File: _th2File,
      activeScrapMPID: activeScrapMPID,
    );
    final List<MPCommand> topLevelCommands = pasteAux
        .materializeAndBuildCommands();

    if (topLevelCommands.isEmpty) {
      return;
    }

    /// Execute as single undo action.
    final MPCommand pasteCommand;

    if (topLevelCommands.length == 1) {
      pasteCommand = topLevelCommands.first;
    } else {
      pasteCommand = MPCommandFactory.multipleCommandsFromList(
        commandsList: topLevelCommands,
        descriptionType: MPCommandDescriptionType.pasteElements,
        completionType:
            MPMultipleElementsCommandCompletionType.elementsListChanged,
      );
    }

    _th2FileEditController.execute(pasteCommand);
    _th2FileEditController.triggerSelectedElementsRedraw();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  @action
  void duplicateSelectedElements() {
    copySelectedElements();
    pasteElements();
  }

  @action
  void cutSelectedElements() {
    copySelectedElements();
    _th2FileEditController.selectionController.removeSelected(
      descriptionType: MPCommandDescriptionType.cutElements,
    );
  }

  void duplicateScrap(int scrapMPID) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final THScrap scrap = _th2File.scrapByMPID(scrapMPID);

    selectionController.setSelectedElements([scrap]);
    duplicateSelectedElements();

    final int newScrapMPID =
        selectionController.mpSelectedElementsLogical.keys.first;

    _th2FileEditController.setActiveScrap(newScrapMPID);
    selectionController.clearSelectedElements();
    _th2FileEditController.triggerSelectedListChanged();
    _th2FileEditController.triggerSelectedElementsRedraw(setState: true);
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  void copyScrap(int scrapMPID) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final THScrap scrap = _th2File.scrapByMPID(scrapMPID);

    selectionController.setSelectedElements([scrap]);
    copySelectedElements();
    selectionController.clearSelectedElements();
    _th2FileEditController.triggerSelectedListChanged();
    _th2FileEditController.triggerSelectedElementsRedraw(setState: true);
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  void cutScrap(int scrapMPID) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final THScrap scrap = _th2File.scrapByMPID(scrapMPID);

    selectionController.setSelectedElements([scrap]);
    cutSelectedElements();
    selectionController.clearSelectedElements();
    _th2FileEditController.triggerSelectedListChanged();
    _th2FileEditController.triggerSelectedElementsRedraw(setState: true);
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }
}
