import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THIsParentMixin {
  // Here are registered all children mapiah IDs.
  final List<int> childrenMapiahID = <int>[];

  void addElementToParent(THElement element) {
    childrenMapiahID.add(element.mapiahID);
  }

  void deleteElementFromParent(THFile thFile, THElement element) {
    if (!childrenMapiahID.remove(element.mapiahID)) {
      throw THCustomException("'$element' not found.");
    }

    if (thFile.hasTHIDByElement(element)) {
      thFile.unregisterElementTHIDByElement(element);
    }
  }

  int get mapiahID;
}
