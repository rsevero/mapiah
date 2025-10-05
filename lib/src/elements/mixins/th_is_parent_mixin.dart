import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THIsParentMixin {
  // Here are registered all children mapiah IDs.
  final List<int> childrenMPIDs = [];

  /// The elementPositionInParent parameter determines the position at which the
  /// new element will be inserted in the parent's children list:
  /// >= 0 => indicates the specific position in the list;
  /// = -1 => indicates the element should be added to the last minus 1 position
  ///         at the end of the list so it gets just before the
  ///         THEnd[line|area|scrap] element;
  /// = -2 => indicates the element should be added to the end of the list;
  void addElementToParent(
    THElement element, {
    int elementPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    final int elementMPID = element.mpID;

    if (childrenMPIDs.contains(elementMPID)) {
      return;
    }

    if (elementPositionInParent == mpAddChildAtEndOfParentChildrenList) {
      childrenMPIDs.add(elementMPID);
    } else if (elementPositionInParent ==
        mpAddChildAtEndMinusOneOfParentChildrenList) {
      if (element.parentMPID > 0) {
        childrenMPIDs.insert(childrenMPIDs.length - 1, elementMPID);
      } else {
        childrenMPIDs.add(elementMPID);
      }
    } else if (elementPositionInParent >= 0) {
      if (elementPositionInParent > childrenMPIDs.length) {
        throw THCustomException(
          "At THIsParentMixin.addElementToParent too big 'childPositionInParent' value : '$elementPositionInParent'.",
        );
      }

      childrenMPIDs.insert(elementPositionInParent, elementMPID);
    } else {
      throw THCustomException(
        "At THIsParentMixin.addElementToParent unsupported 'childPositionInParent' value : '$elementPositionInParent'.",
      );
    }
  }

  int getChildPosition(THElement element) {
    final int index = childrenMPIDs.indexOf(element.mpID);

    if (index < 0) {
      throw THCustomException(
        "At THIsParentMixin.getChildPosition: '$element' not found.",
      );
    }

    return index;
  }

  void removeElementFromParent(THFile thFile, THElement element) {
    if (!childrenMPIDs.remove(element.mpID)) {
      throw THCustomException("'$element' not found.");
    }

    if (thFile.hasTHIDByElement(element)) {
      thFile.unregisterElementTHIDByElement(element);
    }
  }

  Iterable<THElement> getChildren(THFile thFile) {
    return childrenMPIDs.map((mpID) => thFile.elementByMPID(mpID));
  }

  int get mpID;
}
