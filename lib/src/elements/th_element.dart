import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/stores/general_store.dart';

part 'th_element.mapper.dart';

/// Base class for all elements that form a THFile, including THFile itself.
@MappableClass()
abstract class THElement with THElementMappable {
  // Internal ID used by Mapiah to identify each element during this run. This
  // value is never saved anywhere.
  late final int _mapiahID;
  int parentMapiahID;

  String? sameLineComment;

  /// Used by dart_mappable to instantiate a THElement from a map and from
  /// copyWith.
  THElement.notAddToParent(
      int mapiahID, this.parentMapiahID, this.sameLineComment) {
    _mapiahID = mapiahID;
  }

  /// Main constructor.
  ///
  /// Main constructor that sets all essential properties. Any change made here
  /// should eventually be reproduced in the special descendants that don´t use
  /// this constructor but the [Generic private constructor].
  THElement(this.parentMapiahID) {
    _mapiahID = getIt<GeneralStore>().nextMapiahIDForElements();
  }

  THParent parent(THFile thFile) {
    if (parentMapiahID < 0) {
      return thFile;
    }

    return thFile.elementByMapiahID(parentMapiahID) as THParent;
  }

  String get elementType {
    return runtimeType.toString().substring(2).toLowerCase();
  }

  void removeSameLineComment() {
    sameLineComment = null;
  }

  THElement clone() {
    final THElement newElement = copyWith();
    return newElement;
  }

  int get mapiahID => _mapiahID;

  bool isSameClass(Object object);
}

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THParent {
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
