import 'dart:convert';

import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_serializeable.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/stores/general_store.dart';

/// Base class for all elements that form a THFile, including THFile itself.
abstract class THElement implements THSerializable {
  // Internal ID used by Mapiah to identify each element during this run. This
  // value is never saved anywhere.
  final int _mapiahID;
  final int parentMapiahID;
  final String? sameLineComment;

  THElement({
    required int mapiahID,
    required this.parentMapiahID,
    this.sameLineComment,
  }) : _mapiahID = mapiahID;

  /// Main constructor.
  ///
  /// Main constructor that sets all essential properties. Any change made here
  /// should eventually be reproduced in the special descendants that don´t use
  /// this constructor but the [Generic private constructor].
  THElement.addToParent({required this.parentMapiahID, this.sameLineComment})
      : _mapiahID = getIt<GeneralStore>().nextMapiahIDForElements();

  THParent parent(THFile thFile) {
    if (parentMapiahID < 0) {
      return thFile;
    }

    return thFile.elementByMapiahID(parentMapiahID) as THParent;
  }

  String get elementType {
    return runtimeType.toString().substring(2).toLowerCase();
  }

  @override
  String toJson() {
    return jsonEncode(toMap());
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
