import 'package:mapiah/src/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_has_id.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';
import 'package:mapiah/src/th_exceptions/th_id_with_space_exception.dart';
import 'package:mapiah/src/th_exceptions/th_no_element_by_mapiah_id_exception.dart';

/// Base class for all elements that form a THFile, including THFile itself.
abstract class THElement {
  // Internal ID used by Mapiah to identify each element during this run. This
  // value is never saved anywhere.
  late final int _mapiahID;

  late final THFile _thFile;
  late THParent parent;

  String? sameLineComment;

  /// Generic private constructor.
  ///
  /// Only used for special descendants that set by themselves their essential
  /// properties.
  ///
  /// Special descendants: THFile.
  THElement._();

  /// Main constructor.
  ///
  /// Main constructor that sets all essential properties. Any change made here
  /// should eventually be reproduced in the special descendants that don´t use
  /// this constructor but the [Generic private constructor].
  THElement.withParent(this.parent) {
    _thFile = parent.thFile;
    parent._addElementToParent(this);
  }

  int get mapiahID {
    return _mapiahID;
  }

  THFile get thFile {
    return _thFile;
  }

  String get type {
    return runtimeType.toString().substring(2).toLowerCase();
  }

  void removeSameLineComment() {
    sameLineComment = null;
  }

  void delete() {
    thFile._deleteElement(this);
  }
}

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THParent on THElement {
  // Here are registered all children.
  final List<THElement> _children = [];

  @override
  void delete() {
    final childrenList = children.toList();
    for (final aChild in childrenList) {
      aChild.delete();
    }

    thFile._deleteElement(this);
  }

  int _addElementToParent(THElement aElement) {
    _thFile._addElementToFile(aElement);
    _children.add(aElement);

    return aElement.mapiahID;
  }

  List<THElement> get children {
    return _children;
  }

  void _deleteElementFromParent(THElement aElement) {
    if (!_children.remove(aElement)) {
      throw THCustomException("'$aElement' not found.");
    }

    if (thFile.hasTHIDByElement(aElement)) {
      thFile.deleteElementTHIDByElement(aElement);
    }
  }
}

/// THFile represents the complete contents of a .th or .th2 file.
///
/// It should be defined in the same file as THElement so it can access
/// THElement parameterless private constructor.
class THFile extends THElement with THParent {
  final Map<int, THElement> _elementByMapiahID = {};
  var filename = 'unnamed file';

  var encoding = thDefaultEncoding;
  var _nexMapiahID = 1;

  // Here are registered all items with a Therion ID (thID), the one mentioned
  // in Therion Book. These thIDs should be unique inside a survey. As Mapiah
  // doesn´t deals with surveys yet, it will guarantee that thIDs are unique
  // inside a THFile for now.
  final Map<String, THElement> _elementByCompleteTHID = {};
  final Map<THElement, String> _completeTHIDByElement = {};

  THFile() : super._() {
    _mapiahID = 0;
    parent = this;
    _thFile = this;
  }

  Map<int, THElement> get elements {
    return _elementByMapiahID;
  }

  int countElements() {
    return _elementByMapiahID.length;
  }

  String _completeElementTHID(String elementType, String aTHID) {
    if (aTHID.contains(' ')) {
      throw THIDWithSpaceException(elementType, aTHID);
    }
    return '$elementType|$aTHID';
  }

  void deleteElementTHIDByElement(THElement aElement) {
    final aElementType = aElement.type;

    if (!_completeTHIDByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' has no registered thID.");
    }

    final aCompleteTHID = _completeTHIDByElement[aElement];

    if (!_elementByCompleteTHID.containsKey(aCompleteTHID)) {
      throw THCustomException(
          "thID '$aCompleteTHID' gotten from element '$aElement' of type '$aElementType' is not registered.");
    }

    _completeTHIDByElement.remove(aElement);
    _elementByCompleteTHID.remove(aCompleteTHID);
  }

  void deleteElementTHIDByElementTypeAndTHID(
      String aElementType, String aTHID) {
    final completeTHID = _completeElementTHID(aElementType, aTHID);

    if (!_elementByCompleteTHID.containsKey(completeTHID)) {
      throw THCustomException(
          "thID '$aTHID' is not registered for type '$aElementType'.");
    }

    final aElement = _elementByCompleteTHID[completeTHID];

    if (!_completeTHIDByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' has no registered thID.");
    }

    _completeTHIDByElement.remove(aElement);
    _elementByCompleteTHID.remove(completeTHID);
  }

  void updateTHID(THElement aElement, String newTHID) {
    final aElementType = aElement.type;
    final newCompleteTHID = _completeElementTHID(aElementType, newTHID);

    if (!_completeTHIDByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' had no registered thID.");
    }
    final oldCompleteTHID = _completeTHIDByElement[aElement];

    if (_elementByCompleteTHID.containsKey(newCompleteTHID)) {
      throw THCustomException(
          "Duplicate '$aElementType' element with thID '$newTHID'.");
    }

    _elementByCompleteTHID.remove(oldCompleteTHID);
    _elementByCompleteTHID[newCompleteTHID] = aElement;

    _completeTHIDByElement[aElement] = newCompleteTHID;
  }

  void addElementWithTHID(THElement aElement, String aTHID) {
    final newCompleteTHID = _completeElementTHID(aElement.type, aTHID);

    if (_elementByCompleteTHID.containsKey(newCompleteTHID)) {
      throw THCustomException("Duplicate thID: '$newCompleteTHID'.");
    }
    _elementByCompleteTHID[newCompleteTHID] = aElement;

    if (_completeTHIDByElement.containsKey(aElement)) {
      throw THCustomException("'${aElement.type}' already included.");
    }
    _completeTHIDByElement[aElement] = newCompleteTHID;
  }

  bool hasElementByTHID(String elementType, String aTHID) {
    return _elementByCompleteTHID
        .containsKey(_completeElementTHID(elementType, aTHID));
  }

  bool hasTHIDByElement(THElement aElement) {
    return _completeTHIDByElement.containsKey(aElement);
  }

  THElement elementByTHID(String aElementType, String aTHID) {
    if (!hasElementByTHID(aElementType, aTHID)) {
      throw THCustomException("No element with thID '$aTHID' found.");
    }

    return _elementByCompleteTHID[_completeElementTHID(aElementType, aTHID)]!;
  }

  void _addElementToFile(THElement aElement) {
    aElement._mapiahID = _nexMapiahID;
    _elementByMapiahID[_nexMapiahID] = aElement;
    _nexMapiahID++;
    if (aElement is THHasTHID) {
      addElementWithTHID(aElement, (aElement as THHasTHID).thID);
    }
  }

  void deleteElementByMapiahID(int aMapiahID) {
    elementByMapiahID(aMapiahID).delete();
  }

  void deleteElementByTHID(String aElementType, String aTHID) {
    elementByTHID(aElementType, aTHID).delete();
  }

  void _deleteElement(THElement aElement) {
    if (aElement == this) {
      final childrenList = children.toList();
      for (final aChild in childrenList) {
        aChild.delete();
      }
      return;
    }

    if (aElement.thFile != this) {
      throw THCustomException(
          "Trying to delete element '$aElement' that is not from this THFile.");
    }
    aElement.parent._deleteElementFromParent(aElement);
    _elementByMapiahID.remove(aElement.mapiahID);
  }

  bool hasElementByMapiahID(int aMapiahID) {
    return _elementByMapiahID.containsKey(aMapiahID);
  }

  THElement elementByMapiahID(int aMapiahID) {
    if (!hasElementByMapiahID(aMapiahID)) {
      throw THNoElementByMapiahIDException(filename, aMapiahID);
    }

    return _elementByMapiahID[aMapiahID]!;
  }
}
