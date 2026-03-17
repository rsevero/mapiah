// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';

class MPTHElementDuplicatorAux {
  final List<THElement> elements;
  final TH2File th2File;
  final bool updateTHIDs;

  final Set<int> _duplicatedLineMPIDs = {};

  MPDuplicateElementResult? _cachedDuplicate;
  Map<int, String>? _updatedTHIDsMap;

  MPTHElementDuplicatorAux({
    required this.elements,
    required this.th2File,
    required this.updateTHIDs,
  });

  MPDuplicateElementResult getDuplicate() {
    if (_cachedDuplicate != null) {
      return _cachedDuplicate!;
    }

    _updatedTHIDsMap = updateTHIDs ? {} : null;

    final List<THElement> duplicateMainElements = [];
    final List<THElement> duplicateChildrenElements = [];

    for (final THElement element in elements) {
      final MPDuplicateElementResult result = _duplicateElement(
        element: element,
      );

      duplicateMainElements.addAll(result.addAtEndMinusOneOfParent);
      duplicateChildrenElements.addAll(result.addAtEndOfParent);
    }

    _cachedDuplicate = MPDuplicateElementResult(
      addAtEndMinusOneOfParent: duplicateMainElements,
      addAtEndOfParent: duplicateChildrenElements,
    );

    return _cachedDuplicate!;
  }

  MPCommand getAddDuplicateCommand() {
    final MPDuplicateElementResult duplicate = getDuplicate();
    final MPCommand duplicateMainCommand = MPCommandFactory.addElements(
      elements: duplicate.addAtEndMinusOneOfParent,
      th2File: th2File,
      positionInParent: mpAddChildAtEndMinusOneOfParentChildrenList,
    );

    if (duplicate.addAtEndOfParent.isEmpty) {
      return duplicateMainCommand;
    }

    final MPCommand duplicateChildrenCommand = MPCommandFactory.addElements(
      elements: duplicate.addAtEndOfParent,
      th2File: th2File,
      positionInParent: mpAddChildAtEndOfParentChildrenList,
    );

    return MPCommandFactory.multipleCommandsFromList(
      commandsList: [duplicateMainCommand, duplicateChildrenCommand],
      descriptionType: MPCommandDescriptionType.duplicateElements,
      completionType:
          MPMultipleElementsCommandCompletionType.elementsListChanged,
    );
  }

  THElement _copyElement({
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
  }) {
    final int duplicatedAreaMPID = mpLocator.mpGeneralController
        .nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicatedOptions =
        _duplicateCommandOptions(
          options: area.optionsMap,
          parentMPID: duplicatedAreaMPID,
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
    final List<THElement> duplicateMain = [];
    final List<THElement> duplicateChildren = [];
    final List<THElement> duplicateLineMain = [];
    final List<THElement> duplicateLineChildren = [];
    final List<int> childrenMPIDs = area.childrenMPIDs;

    duplicateMain.add(duplicateArea);

    for (final int childMPID in childrenMPIDs) {
      final THElement childElement = th2File.elementByMPID(childMPID);

      if (childElement is THAreaBorderTHID) {
        final String borderTHID = childElement.thID;

        if (!th2File.hasElementByTHID(borderTHID)) {
          throw Exception(
            'Border THID $borderTHID not found in THFile when duplicating area with MPTHElementDuplicatorAux.',
          );
        }

        final THLine borderLine = th2File.elementByTHID(borderTHID) as THLine;

        if (!_duplicatedLineMPIDs.contains(borderLine.mpID)) {
          final MPDuplicateElementResult duplicateBorderLine = _duplicateLine(
            line: borderLine,
            newParentMPID: newParentMPID,
          );

          _duplicatedLineMPIDs.add(borderLine.mpID);
          duplicateLineMain.addAll(
            duplicateBorderLine.addAtEndMinusOneOfParent,
          );
          duplicateLineChildren.addAll(duplicateBorderLine.addAtEndOfParent);
        }

        String? newBorderTHID;

        if (_updatedTHIDsMap != null) {
          if (!_updatedTHIDsMap!.containsKey(borderLine.mpID)) {
            throw Exception(
              'Border line MPID ${borderLine.mpID} not found in updated THIDs map when duplicating area with MPTHElementDuplicatorAux.',
            );
          }

          newBorderTHID = _updatedTHIDsMap![borderLine.mpID]!;
        }

        final THAreaBorderTHID duplicateTHAreaBorderTHID = childElement
            .copyWith(
              mpID: mpCreateNewMPIDForElement,
              parentMPID: duplicatedAreaMPID,
              thID: newBorderTHID,
              originalLineInTH2File: '',
            );

        duplicateChildren.add(duplicateTHAreaBorderTHID);
      } else {
        final MPDuplicateElementResult duplicatedChild = _duplicateElement(
          element: childElement,
          newParentMPID: duplicatedAreaMPID,
        );

        duplicateMain.addAll(duplicatedChild.addAtEndMinusOneOfParent);
        duplicateChildren.addAll(duplicatedChild.addAtEndOfParent);
      }
    }

    /// Lines come before so when the area is created, its border lines already
    /// exist.
    return MPDuplicateElementResult(
      addAtEndMinusOneOfParent: duplicateLineMain + duplicateMain,
      addAtEndOfParent: duplicateLineChildren + duplicateChildren,
    );
  }

  MPDuplicateElementResult _duplicateChildren({
    required THIsParentMixin parent,
    int? newParentMPID,
  }) {
    final List<THElement> duplicatedMainElements = [];
    final List<THElement> duplicateChildren = [];

    for (final int childMPID in parent.childrenMPIDs) {
      final THElement childElement = th2File.elementByMPID(childMPID);
      final MPDuplicateElementResult duplicatedChild = _duplicateElement(
        element: childElement,
        newParentMPID: newParentMPID,
      );

      duplicatedMainElements.addAll(duplicatedChild.addAtEndMinusOneOfParent);
      duplicateChildren.addAll(duplicatedChild.addAtEndOfParent);
    }

    return MPDuplicateElementResult(
      addAtEndMinusOneOfParent: duplicatedMainElements,
      addAtEndOfParent: duplicateChildren,
    );
  }

  MPDuplicateElementResult _duplicateElement({
    required THElement element,
    int? newParentMPID,
  }) {
    final MPDuplicateElementResult duplicate;

    switch (element) {
      case THArea area:
        duplicate = _duplicateArea(area: area, newParentMPID: newParentMPID);
      case THLine line:
        duplicate = _duplicateLine(line: line, newParentMPID: newParentMPID);
      case THMultiLineComment multiComment:
        duplicate = _duplicateMultiLineComment(
          multiComment: multiComment,
          newParentMPID: newParentMPID,
        );
      case THPoint point:
        duplicate = _duplicatePoint(point: point, newParentMPID: newParentMPID);
      case THScrap scrap:
        duplicate = _duplicateScrap(scrap: scrap, newParentMPID: newParentMPID);
      case THEmptyLine _:
        duplicate = MPDuplicateElementResult(
          addAtEndMinusOneOfParent: [],
          addAtEndOfParent: [],
        );
      default:

        /// All THElements that should be treated as a main element in
        /// duplication should be covered by the cases above.
        duplicate = MPDuplicateElementResult(
          addAtEndMinusOneOfParent: [],
          addAtEndOfParent: [
            _copyElement(element: element, newParentMPID: newParentMPID),
          ],
        );
    }

    return duplicate;
  }

  MPDuplicateElementResult _duplicateLine({
    required THLine line,
    int? newParentMPID,
  }) {
    if (_duplicatedLineMPIDs.contains(line.mpID)) {
      /// This line has already been duplicated as a child of an area, so we skip
      /// it to avoid duplication loops.
      return MPDuplicateElementResult(
        addAtEndMinusOneOfParent: [],
        addAtEndOfParent: [],
      );
    }

    final int duplicatedLineMPID = mpLocator.mpGeneralController
        .nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicatedOptions =
        _duplicateCommandOptions(
          options: line.optionsMap,
          parentMPID: duplicatedLineMPID,
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
    );

    _duplicatedLineMPIDs.add(line.mpID);
    duplicateMainElements.addAll(duplicateChildren.addAtEndMinusOneOfParent);

    return MPDuplicateElementResult(
      addAtEndMinusOneOfParent: duplicateMainElements,
      addAtEndOfParent: duplicateChildren.addAtEndOfParent,
    );
  }

  MPDuplicateElementResult _duplicateMultiLineComment({
    required THMultiLineComment multiComment,
    int? newParentMPID,
  }) {
    final THMultiLineComment duplicateMultiComment =
        _copyElement(element: multiComment, newParentMPID: newParentMPID)
            as THMultiLineComment;
    final List<THElement> duplicatedMainElements = [duplicateMultiComment];
    final int duplicatedMultiCommentMPID = duplicateMultiComment.mpID;
    final MPDuplicateElementResult duplicateChildren = _duplicateChildren(
      parent: multiComment,
      newParentMPID: duplicatedMultiCommentMPID,
    );

    duplicatedMainElements.addAll(duplicateChildren.addAtEndMinusOneOfParent);

    return MPDuplicateElementResult(
      addAtEndMinusOneOfParent: duplicatedMainElements,
      addAtEndOfParent: duplicateChildren.addAtEndOfParent,
    );
  }

  MPDuplicateElementResult _duplicatePoint({
    required THPoint point,
    int? newParentMPID,
  }) {
    final int duplicatedPointMPID = mpLocator.mpGeneralController
        .nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicatedOptions =
        _duplicateCommandOptions(
          options: point.optionsMap,
          parentMPID: duplicatedPointMPID,
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
      addAtEndMinusOneOfParent: [duplicatePoint],
      addAtEndOfParent: [],
    );
  }

  MPDuplicateElementResult _duplicateScrap({
    required THScrap scrap,
    int? newParentMPID,
  }) {
    final int duplicatedScrapMPID = mpLocator.mpGeneralController
        .nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicatedOptions =
        _duplicateCommandOptions(
          options: scrap.optionsMap,
          parentMPID: duplicatedScrapMPID,
        );
    final SplayTreeMap<String, THAttrCommandOption> duplicatedAttrOptions =
        _duplicateCommandAttrOptions(
          attrOptions: scrap.attrOptionsMap,
          parentMPID: duplicatedScrapMPID,
        );
    final String duplicatedScrapTHID = th2File.getNewTHID(
      prefix: '${scrap.thID}-',
    );
    final THScrap duplicateScrap = scrap.copyWith(
      mpID: duplicatedScrapMPID,
      thID: duplicatedScrapTHID,
      parentMPID: newParentMPID,
      childrenMPIDs: [],
      attrOptionsMap: duplicatedAttrOptions,
      optionsMap: duplicatedOptions,
      originalLineInTH2File: '',
    );
    final List<THElement> duplicatedMainElements = [duplicateScrap];
    final MPDuplicateElementResult duplicateChildren = _duplicateChildren(
      parent: scrap,
      newParentMPID: duplicatedScrapMPID,
    );
    final List<THElement> duplicateChildrenComplete =
        duplicateChildren.addAtEndMinusOneOfParent +
        duplicateChildren.addAtEndOfParent;

    return MPDuplicateElementResult(
      addAtEndMinusOneOfParent: duplicatedMainElements,
      addAtEndOfParent: duplicateChildrenComplete,
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
    int? parentMPID,
  }) {
    final SplayTreeMap<THCommandOptionType, THCommandOption> duplicateOptions =
        SplayTreeMap();

    for (final MapEntry<THCommandOptionType, THCommandOption> optionEntry
        in options.entries) {
      final THCommandOptionType optionType = optionEntry.key;
      final THCommandOption option = optionEntry.value;
      final THCommandOption duplicateOption;

      if ((_updatedTHIDsMap != null) && (option is THIDCommandOption)) {
        final String newTHID =
            _updatedTHIDsMap![option.parentMPID] ??
            th2File.getNewTHID(prefix: '${option.thID}-');

        _updatedTHIDsMap![option.parentMPID] = newTHID;
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
  /// The addAtEndMinusOneOfParent elements should be added before the
  /// addAtEndOfParent elements because they usually are the parent of the
  /// addAtEndOfParent elements, so they need to exist before the children are
  /// added.
  ///
  /// The addAtEndOfParent elements are added at the end because their parents
  /// don´t have their respective end elements yet (THEndLine, THEndArea or
  /// THEndScrap).
  final List<THElement> addAtEndMinusOneOfParent;
  final List<THElement> addAtEndOfParent;

  MPDuplicateElementResult({
    required this.addAtEndMinusOneOfParent,
    required this.addAtEndOfParent,
  });
}
