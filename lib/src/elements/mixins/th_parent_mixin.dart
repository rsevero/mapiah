import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THIsParentMixin {
  // Here are registered all children mapiah IDs.
  final Set<int> childrenMPID = <int>{};

  void addElementToParent(THElement element) {
    childrenMPID.add(element.mpID);
  }

  void removeElementFromParent(THFile thFile, THElement element) {
    if (!childrenMPID.remove(element.mpID)) {
      throw THCustomException("'$element' not found.");
    }

    if (thFile.hasTHIDByElement(element)) {
      thFile.unregisterElementTHIDByElement(element);
    }
  }

  int get mpID;
}
