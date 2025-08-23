import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THIsParentMixin {
  // Here are registered all children mapiah IDs.
  final List<int> childrenMPID = [];

  void addElementToParent(
    THElement element, {
    bool positionInsideParent = true,
  }) {
    if (positionInsideParent && (element.parentMPID > 0)) {
      childrenMPID.insert(childrenMPID.length - 1, element.mpID);
    } else {
      childrenMPID.add(element.mpID);
    }
  }

  void removeElementFromParent(THFile thFile, THElement element) {
    if (!childrenMPID.remove(element.mpID)) {
      throw THCustomException("'$element' not found.");
    }

    if (thFile.hasTHIDByElement(element)) {
      thFile.unregisterElementTHIDByElement(element);
    }
  }

  Iterable<THElement> getChildren(THFile thFile) {
    return childrenMPID.map((mpID) => thFile.elementByMPID(mpID));
  }

  int get mpID;
}
