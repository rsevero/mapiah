// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_copy_element_result.dart';
import 'package:mapiah/src/auxiliary/mp_copy_template.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';

/// Materializes copied elements (templates) into live THElements and builds
/// the corresponding add commands in a single recursive pass.
///
/// Processing is depth-first: each entry's childrenResult is fully processed
/// before moving to the next sibling. This guarantees that when a
/// THAreaBorderTHID is processed, the border line's new THID is already
/// recorded in _oldToNewTHIDMap.
class MPTHElementPasteAux {
  final List<MPCopyElementWithChildren> copyResult;
  final TH2File th2File;
  final int activeScrapMPID;

  /// Map old MPID → new MPID for all pasted elements.
  final Map<int, int> _oldToNewMPIDMap = {};

  /// Map old MPID → new THID for elements with THID (THLine, THScrap, etc).
  final Map<int, String> _oldToNewTHIDMap = {};

  /// New MPIDs of the top-level pasted elements, in clipboard order.
  /// Populated by [materializeAndBuildCommands].
  final List<int> _topLevelPastedMPIDs = [];

  List<int> get topLevelPastedMPIDs => List.unmodifiable(_topLevelPastedMPIDs);

  MPTHElementPasteAux({
    required this.copyResult,
    required this.th2File,
    required this.activeScrapMPID,
  });

  /// Materialize and build commands in a single recursive pass.
  ///
  /// Returns a list of top-level add commands ready to execute.
  List<MPCommand> materializeAndBuildCommands() {
    final List<MPCommand> topLevelCommands = [];

    _topLevelPastedMPIDs.clear();

    for (final entry in copyResult) {
      /// Determine parent MPID for this top-level element.
      final THElement topElement = THElement.fromMap(entry.template.elementMap);
      final int parentMPID = topElement is THScrap
          ? th2File.mpID
          : activeScrapMPID;

      final MPCommand command = _processMaterializeAndBuild(entry, parentMPID);

      topLevelCommands.add(command);
      _topLevelPastedMPIDs.add(
        _oldToNewMPIDMap[entry.template.originalMPID ?? 0]!,
      );
    }

    return topLevelCommands;
  }

  /// Process a single copy entry with depth-first recursion.
  ///
  /// Materializes the element and builds its add command with children as posCommand.
  /// Returns the add command for this element.
  MPCommand _processMaterializeAndBuild(
    MPCopyElementWithChildren entry,
    int parentMPID,
  ) {
    /// Step 1: Allocate new MPID.
    final int newMPID = mpLocator.mpGeneralController.nextMPIDForElements();

    /// Step 2: Create element from template.
    final MPCopyTemplate template = entry.template;

    THElement element = THElement.fromMap(template.elementMap);

    /// Step 3 & 4: Check THID and update element with copyWith().
    /// Handle THScrap THID specially since it's not in options.
    if (element is THScrap) {
      final String originalTHID = element.thID;

      String newTHID = originalTHID;

      if (originalTHID.isNotEmpty) {
        if (th2File.hasElementByTHID(originalTHID)) {
          newTHID = th2File.getNewTHID(prefix: '$originalTHID-');
        }
        _oldToNewTHIDMap[template.originalMPID ?? 0] = newTHID;
      }

      element = element.copyWith(
        mpID: newMPID,
        parentMPID: parentMPID,
        originalLineInTH2File: '',
        thID: newTHID,
        childrenMPIDs: [],
      );
    } else {
      /// For all other elements, update MPID and parent.
      element = element.copyWith(
        mpID: newMPID,
        parentMPID: parentMPID,
        originalLineInTH2File: '',
      );

      /// If element has children, clear the children list.
      if (element is THIsParentMixin) {
        final THIsParentMixin parent = element as THIsParentMixin;

        parent.childrenMPIDs.clear();
      }

      /// Handle THID conflicts in optionsMap for elements with
      /// THIDCommandOption.
      if (element is THHasOptionsMixin) {
        final String? originalTHID = MPCommandOptionAux.getID(element);

        if ((originalTHID != null) && originalTHID.isNotEmpty) {
          String resolvedTHID = originalTHID;

          /// Check if THID already exists in th2File
          if (th2File.hasElementByTHID(originalTHID)) {
            /// Generate new THID with prefix
            resolvedTHID = th2File.getNewTHID(prefix: '$originalTHID-');
          }

          /// Register the original MPID → resolved THID mapping
          _oldToNewTHIDMap[template.originalMPID ?? 0] = resolvedTHID;

          /// If THID needed to be changed, update the option
          if (resolvedTHID != originalTHID) {
            /// Create new THIDCommandOption with resolved THID
            final THIDCommandOption newTHIDOption = THIDCommandOption(
              parentMPID: newMPID,
              thID: resolvedTHID,
            );

            /// Update the element's option with new THID
            element.addUpdateOption(newTHIDOption);
          }
        }
      }
    }

    /// Record MPID mapping.
    _oldToNewMPIDMap[template.originalMPID ?? 0] = newMPID;

    /// Step 5: Recursively process children and collect commands.
    final List<MPCommand> childCommands = [];

    for (final childEntry in entry.childrenResult) {
      final MPCommand childCmd = _processMaterializeAndBuild(
        childEntry,
        newMPID,
      );

      childCommands.add(childCmd);
    }

    /// Step 6: Handle THAreaBorderTHID special case (update THID if needed).
    if (element is THAreaBorderTHID) {
      final String? newReferencedTHID =
          _oldToNewTHIDMap[template.originalMPID ?? 0];

      if (newReferencedTHID != null) {
        element = element.copyWith(thID: newReferencedTHID);
      }
    }

    /// Step 7: Create appropriate add command based on element type.
    final MPCommand? posCommand = childCommands.isNotEmpty
        ? MPCommandFactory.multipleCommandsFromList(
            commandsList: childCommands,
            descriptionType: MPCommandDescriptionType.addElements,
            completionType:
                MPMultipleElementsCommandCompletionType.elementsListChanged,
          )
        : null;

    final int elementPosition = entry.positionAtParent;
    final MPCommand cmd;

    switch (element) {
      case THScrap scrap:
        cmd = MPAddScrapCommand(
          newScrap: scrap,
          scrapPositionInParent: elementPosition,
          scrapChildren: [],
          th2File: th2File,
          posCommand: posCommand,
        );
      case THLine line:
        cmd = MPAddLineCommand.forCWJM(
          newLine: line,
          linePositionInParent: elementPosition,
          lineChildren: [],
          preCommand: null,
          posCommand: posCommand,
        );
      case THArea area:
        cmd = MPAddAreaCommand.forCWJM(
          newArea: area,
          areaChildren: [],
          areaPositionInParent: elementPosition,
          posCommand: posCommand,
        );
      case THPoint point:
        cmd = MPAddPointCommand.forCWJM(
          newPoint: point,
          pointPositionInParent: elementPosition,
          posCommand: null,
        );
      case THLineSegment segment:
        cmd = MPAddLineSegmentCommand.forCWJM(
          newLineSegment: segment,
          lineSegmentPositionInParent: elementPosition,
          posCommand: null,
        );
      default:
        cmd = MPAddElementCommand.forCWJM(
          newElement: element,
          elementPositionInParent: elementPosition,
          posCommand: null,
        );
    }

    return cmd;
  }
}
