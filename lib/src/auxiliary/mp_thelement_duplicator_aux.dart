import 'dart:collection';

import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';

class MPTHElementDuplicatorAux {
  final List<THElement> elements;
  final THFile thFile;
  final bool updateTHIDs;

  MPDuplicateElementResult? _cachedDuplicate;

  MPTHElementDuplicatorAux({
    required this.elements,
    required this.thFile,
    required this.updateTHIDs,
  });

  MPDuplicateElementResult getDuplicate() {
    if (_cachedDuplicate != null) {
      return _cachedDuplicate!;
    }

    final Map<int, String>? updatedTHIDsMap = updateTHIDs ? {} : null;
    final List<THElement> duplicateMainElements = [];
    final List<THElement> duplicateChildrenElements = [];

    for (final THElement element in elements) {
      final MPDuplicateElementResult result = _duplicateElement(
        element: element,
        updatedTHIDs: updatedTHIDsMap,
      );

      duplicateMainElements.addAll(result.duplicatesMainElements);
      duplicateChildrenElements.addAll(result.duplicateChildren);
    }

    _cachedDuplicate = MPDuplicateElementResult(
      duplicatesMainElements: duplicateMainElements,
      duplicateChildren: duplicateChildrenElements,
    );

    return _cachedDuplicate!;
  }

  MPCommand getAddDuplicateCommand() {
    final MPDuplicateElementResult duplicate = getDuplicate();
    final MPCommand duplicateMainCommand = MPCommandFactory.addElements(
      elements: duplicate.duplicatesMainElements,
      thFile: thFile,
      positionInParent: mpAddChildAtEndMinusOneOfParentChildrenList,
    );

    if (duplicate.duplicateChildren.isEmpty) {
      return duplicateMainCommand;
    }

    final MPCommand duplicateChildrenCommand = MPCommandFactory.addElements(
      elements: duplicate.duplicateChildren,
      thFile: thFile,
      positionInParent: mpAddChildAtEndOfParentChildrenList,
    );

    return MPCommandFactory.multipleCommandsFromList(
      commandsList: [duplicateMainCommand, duplicateChildrenCommand],
      descriptionType: MPCommandDescriptionType.duplicateElements,
      completionType:
          MPMultipleElementsCommandCompletionType.elementsListChanged,
    );
  }

  static THElement _copyElement({
    required THElement element,
    int mpID = mpCreateNewMPIDForElement,
    int? newParentMPID,
  }) {
    final THElement duplicate = element.copyWith(
      mpID: mpID,
      parentMPID: newParentMPID,
      originalLineInTH2File: '',
    );

    return duplicate;
  }

  MPDuplicateElementResult _duplicateArea({
    required THArea area,
    int? newParentMPID,
    required Map<int, String>? updatedTHIDs,
  }) {
    final int duplicatedAreaMPID = mpLocator.mpGeneralController
        .nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicatedOptions =
        _duplicateCommandOptions(
          options: area.optionsMap,
          parentMPID: duplicatedAreaMPID,
          updatedTHIDs: updatedTHIDs,
        );
    final SplayTreeMap<String, THAttrCommandOption> duplicatedAttrOptions =
        _duplicateCommandAttrOptions(
          attrOptions: area.attrOptionsMap,
          parentMPID: duplicatedAreaMPID,
        );
    final THArea duplicateArea = area.copyWith(
      mpID: duplicatedAreaMPID,
      parentMPID: newParentMPID,
      attrOptionsMap: duplicatedAttrOptions,
      optionsMap: duplicatedOptions,
      originalLineInTH2File: '',
    );
    final List<THElement> duplicatedMain = [];
    final List<THElement> duplicateChildren = [];
    final List<int> childrenMPIDs = area.childrenMPIDs;

    for (final int childMPID in childrenMPIDs) {
      final THElement childElement = thFile.elementByMPID(childMPID);

      if (childElement is THAreaBorderTHID) {
        final String borderTHID = childElement.thID;

        if (!thFile.hasElementByTHID(borderTHID)) {
          throw Exception(
            'Border THID $borderTHID not found in THFile when duplicating area with THElementDuplicatorAux.',
          );
        }

        final THLine borderLine = thFile.elementByTHID(borderTHID) as THLine;
        final THAreaBorderTHID duplicateBorderTHID =
            _copyElement(
                  element: childElement,
                  newParentMPID: duplicatedAreaMPID,
                )
                as THAreaBorderTHID;
        final MPDuplicateElementResult duplicatedBorderLine = _duplicateLine(
          line: borderLine,
          newParentMPID: duplicatedAreaMPID,
          updatedTHIDs: updatedTHIDs,
        );

        duplicatedMain.addAll(duplicatedBorderLine.duplicatesMainElements);
        duplicateChildren.addAll(duplicatedBorderLine.duplicateChildren);
        duplicateChildren.add(duplicateBorderTHID);
      } else {
        final MPDuplicateElementResult duplicatedChild = _duplicateElement(
          element: childElement,
          newParentMPID: duplicatedAreaMPID,
          updatedTHIDs: updatedTHIDs,
        );

        duplicatedMain.addAll(duplicatedChild.duplicatesMainElements);
        duplicateChildren.addAll(duplicatedChild.duplicateChildren);
      }
    }

    duplicatedMain.add(duplicateArea);

    return MPDuplicateElementResult(
      duplicatesMainElements: duplicatedMain,
      duplicateChildren: duplicateChildren,
    );
  }

  MPDuplicateElementResult _duplicateChildren({
    required THIsParentMixin parent,
    int? newParentMPID,
    required Map<int, String>? updatedTHIDs,
  }) {
    final List<THElement> duplicatedMainElements = [];
    final List<THElement> duplicateChildren = [];

    for (final int childMPID in parent.childrenMPIDs) {
      final THElement childElement = thFile.elementByMPID(childMPID);
      final MPDuplicateElementResult duplicatedChild = _duplicateElement(
        element: childElement,
        newParentMPID: newParentMPID,
        updatedTHIDs: updatedTHIDs,
      );

      duplicatedMainElements.addAll(duplicatedChild.duplicatesMainElements);
      duplicateChildren.addAll(duplicatedChild.duplicateChildren);
    }

    return MPDuplicateElementResult(
      duplicatesMainElements: duplicatedMainElements,
      duplicateChildren: duplicateChildren,
    );
  }

  MPDuplicateElementResult _duplicateElement({
    required THElement element,
    int? newParentMPID,
    required Map<int, String>? updatedTHIDs,
  }) {
    final MPDuplicateElementResult duplicate;

    switch (element) {
      case THArea area:
        duplicate = _duplicateArea(
          area: area,
          newParentMPID: newParentMPID,
          updatedTHIDs: updatedTHIDs,
        );
      case THLine line:
        duplicate = _duplicateLine(
          line: line,
          newParentMPID: newParentMPID,
          updatedTHIDs: updatedTHIDs,
        );
      case THMultiLineComment multiComment:
        duplicate = _duplicateMultiLineComment(
          multiComment: multiComment,
          newParentMPID: newParentMPID,
          updatedTHIDs: updatedTHIDs,
        );
      case THPoint point:
        duplicate = _duplicatePoint(
          point: point,
          newParentMPID: newParentMPID,
          updatedTHIDs: updatedTHIDs,
        );
      case THScrap scrap:
        duplicate = _duplicateScrap(
          scrap: scrap,
          newParentMPID: newParentMPID,
          updatedTHIDs: updatedTHIDs,
        );
      default:

        /// All THElements that should be treated as a main element in
        /// duplication should be covered by the cases above.
        duplicate = MPDuplicateElementResult(
          duplicatesMainElements: [],
          duplicateChildren: [
            _copyElement(element: element, newParentMPID: newParentMPID),
          ],
        );
    }

    return duplicate;
  }

  MPDuplicateElementResult _duplicateLine({
    required THLine line,
    int? newParentMPID,
    required Map<int, String>? updatedTHIDs,
  }) {
    final int duplicatedLineMPID = mpLocator.mpGeneralController
        .nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicatedOptions =
        _duplicateCommandOptions(
          options: line.optionsMap,
          parentMPID: duplicatedLineMPID,
          updatedTHIDs: updatedTHIDs,
        );
    final SplayTreeMap<String, THAttrCommandOption> duplicatedAttrOptions =
        _duplicateCommandAttrOptions(
          attrOptions: line.attrOptionsMap,
          parentMPID: duplicatedLineMPID,
        );
    final THLine duplicateLine = line.copyWith(
      mpID: duplicatedLineMPID,
      parentMPID: newParentMPID,
      childrenMPIDs: [],
      optionsMap: duplicatedOptions,
      attrOptionsMap: duplicatedAttrOptions,
      originalLineInTH2File: '',
    );
    final List<THElement> duplicateMainElements = [duplicateLine];
    final MPDuplicateElementResult duplicateChildren = _duplicateChildren(
      parent: line,
      newParentMPID: duplicatedLineMPID,
      updatedTHIDs: updatedTHIDs,
    );

    duplicateMainElements.addAll(duplicateChildren.duplicatesMainElements);

    return MPDuplicateElementResult(
      duplicatesMainElements: duplicateMainElements,
      duplicateChildren: duplicateChildren.duplicateChildren,
    );
  }

  MPDuplicateElementResult _duplicateMultiLineComment({
    required THMultiLineComment multiComment,
    int? newParentMPID,
    required Map<int, String>? updatedTHIDs,
  }) {
    final THMultiLineComment duplicateMultiComment =
        _copyElement(element: multiComment, newParentMPID: newParentMPID)
            as THMultiLineComment;
    final List<THElement> duplicatedMainElements = [duplicateMultiComment];
    final int duplicatedMultiCommentMPID = duplicateMultiComment.mpID;
    final MPDuplicateElementResult duplicateChildren = _duplicateChildren(
      parent: multiComment,
      newParentMPID: duplicatedMultiCommentMPID,
      updatedTHIDs: updatedTHIDs,
    );

    duplicatedMainElements.addAll(duplicateChildren.duplicatesMainElements);

    return MPDuplicateElementResult(
      duplicatesMainElements: duplicatedMainElements,
      duplicateChildren: duplicateChildren.duplicateChildren,
    );
  }

  MPDuplicateElementResult _duplicatePoint({
    required THPoint point,
    int? newParentMPID,
    required Map<int, String>? updatedTHIDs,
  }) {
    final int duplicatedPointMPID = mpLocator.mpGeneralController
        .nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicatedOptions =
        _duplicateCommandOptions(
          options: point.optionsMap,
          parentMPID: duplicatedPointMPID,
          updatedTHIDs: updatedTHIDs,
        );
    final SplayTreeMap<String, THAttrCommandOption> duplicatedAttrOptions =
        _duplicateCommandAttrOptions(
          attrOptions: point.attrOptionsMap,
          parentMPID: duplicatedPointMPID,
        );
    final THPoint duplicatePoint = point.copyWith(
      mpID: duplicatedPointMPID,
      parentMPID: newParentMPID,
      optionsMap: duplicatedOptions,
      attrOptionsMap: duplicatedAttrOptions,
      originalLineInTH2File: '',
    );

    return MPDuplicateElementResult(
      duplicatesMainElements: [duplicatePoint],
      duplicateChildren: [],
    );
  }

  MPDuplicateElementResult _duplicateScrap({
    required THScrap scrap,
    int? newParentMPID,
    required Map<int, String>? updatedTHIDs,
  }) {
    final THScrap duplicateScrap =
        _copyElement(element: scrap, newParentMPID: newParentMPID) as THScrap;
    final List<THElement> duplicatedMainElements = [duplicateScrap];
    final int duplicatedScrapMPID = duplicateScrap.mpID;
    final MPDuplicateElementResult duplicateChildren = _duplicateChildren(
      parent: scrap,
      newParentMPID: duplicatedScrapMPID,
      updatedTHIDs: updatedTHIDs,
    );

    duplicatedMainElements.addAll(duplicateChildren.duplicatesMainElements);

    return MPDuplicateElementResult(
      duplicatesMainElements: duplicatedMainElements,
      duplicateChildren: duplicateChildren.duplicateChildren,
    );
  }

  static SplayTreeMap<String, THAttrCommandOption>
  _duplicateCommandAttrOptions({
    required SplayTreeMap<String, THAttrCommandOption> attrOptions,
    int? parentMPID,
  }) {
    final SplayTreeMap<String, THAttrCommandOption> duplicateAttrOptions =
        SplayTreeMap();

    for (final MapEntry<String, THAttrCommandOption> attrOptionEntry
        in attrOptions.entries) {
      final THAttrCommandOption duplicateAttrOption = attrOptionEntry.value
          .copyWith(parentMPID: parentMPID, originalLineInTH2File: '');

      duplicateAttrOptions[attrOptionEntry.key] = duplicateAttrOption;
    }

    return duplicateAttrOptions;
  }

  SplayTreeMap<THCommandOptionType, THCommandOption> _duplicateCommandOptions({
    required SplayTreeMap<THCommandOptionType, THCommandOption> options,
    required Map<int, String>? updatedTHIDs,
    int? parentMPID,
  }) {
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicateOptions =
        SplayTreeMap();

    for (final MapEntry<THCommandOptionType, THCommandOption> optionEntry
        in options.entries) {
      final THCommandOptionType optionType = optionEntry.key;
      final THCommandOption option = optionEntry.value;
      final THCommandOption duplicateOption;

      if ((updatedTHIDs != null) && (option is THIDCommandOption)) {
        final String newTHID =
            updatedTHIDs[option.parentMPID] ??
            thFile.getNewTHID(prefix: '${option.thID}-');

        updatedTHIDs[option.parentMPID] = newTHID;
        duplicateOption = option.copyWith(
          parentMPID: parentMPID,
          originalLineInTH2File: '',
          thID: newTHID,
        );
      } else {
        duplicateOption = option.copyWith(
          parentMPID: parentMPID,
          originalLineInTH2File: '',
        );
      }

      duplicateOptions[optionType] = duplicateOption;
    }

    return duplicateOptions;
  }
}

class MPDuplicateElementResult {
  /// The main elements should be added with position in parent ==
  /// mpAddChildAtEndMinusOneOfParentChildrenList because they are being added
  /// on previously existing full elements, probably a scrap (or a THFile if
  /// adding a duplicated scrap).
  /// The duplicate children should be added with position in parent ==
  /// mpAddChildAtEndOfParentChildrenList because they are being added on a
  /// new element, the duplicated main element which does not have its ending
  /// element yet (THEndLine, THEndArea or THEndScrap).
  final List<THElement> duplicatesMainElements;
  final List<THElement> duplicateChildren;

  MPDuplicateElementResult({
    required this.duplicatesMainElements,
    required this.duplicateChildren,
  });
}
