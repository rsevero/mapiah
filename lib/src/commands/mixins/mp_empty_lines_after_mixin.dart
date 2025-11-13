import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';

mixin MPEmptyLinesAfterMixin on MPCommand {
  List<int> getEmptyLinesAfter({
    required THFile thFile,
    required THIsParentMixin parent,
    required int positionInParent,
  }) {
    final List<int> emptyLinesAfter = [];
    final List<int> siblingsMPIDs = parent.childrenMPIDs;

    for (int i = positionInParent + 1; i < siblingsMPIDs.length; i++) {
      final int siblingMPID = siblingsMPIDs[i];
      final THElementType siblingElementType = thFile.getElementTypeByMPID(
        siblingMPID,
      );

      if (siblingElementType == THElementType.emptyLine) {
        emptyLinesAfter.add(siblingMPID);
      } else {
        break;
      }
    }

    return emptyLinesAfter;
  }

  void actualExecuteLinesAfterRemoval({
    required TH2FileEditElementEditController elementEditController,
    required List<int> emptyLinesAfter,
  }) {
    for (final int emptyLineMPID in emptyLinesAfter) {
      elementEditController.applyRemoveElementByMPID(emptyLineMPID);
    }
  }
}
