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
    parent._addElement(this);
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
    thFile.deleteElement(this);
  }
}

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THParent on THElement {
  // Here are registered all children.
  final List<THElement> _children = [];

  // Here are registered all items with a Therion ID (the one mentioned in
  // Therion Book).
  final Map<String, THElement> _elementByCompleteTHID = {};
  final Map<THElement, String> _completeTHIDByElement = {};

  int _addElement(THElement aElement) {
    _thFile._includeElementInFile(aElement);
    _children.add(aElement);

    return aElement.mapiahID;
  }

  List<THElement> get children {
    return _children;
  }

  void _deleteElement(THElement aElement) {
    if (!_children.remove(aElement)) {
      throw THCustomException("'$aElement' not found.");
    }

    if (hasTHIDByElement(aElement)) {
      deleteElementTHIDByElement(aElement);
    }
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

  void updateElementTHID(THElement aElement, String newTHID) {
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

  THElement elementByTHID(String elementType, String aTHID) {
    if (!hasElementByTHID(elementType, aTHID)) {
      throw THCustomException("No element with thID '$aTHID' found.");
    }

    return _elementByCompleteTHID[_completeElementTHID(elementType, aTHID)]!;
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
  var _nexMapiahID = 0;

  THFile() : super._() {
    _mapiahID = -1;
    parent = this;
    _thFile = this;
  }

  Map<int, THElement> get elements {
    return _elementByMapiahID;
  }

  int countElements() {
    return _elementByMapiahID.length;
  }

  void _includeElementInFile(THElement aElement) {
    aElement._mapiahID = _nexMapiahID;
    _elementByMapiahID[_nexMapiahID] = aElement;
    _nexMapiahID++;
    if (aElement is THHasID) {
      addElementWithTHID(aElement, (aElement as THHasID).id);
    }
  }

  void deleteElement(THElement aElement) {
    if (aElement.parent != this) {
      aElement.parent._deleteElement(aElement);
    }

    if (aElement.thFile != this) {
      throw THCustomException(
          "Trying to delete element '$aElement' that is not from this THFile.");
    }
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
