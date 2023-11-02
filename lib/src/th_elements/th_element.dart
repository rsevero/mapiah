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
}

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THParent on THElement {
  // Here are registered all children.
  final List<THElement> _children = [];

  // Here are registered all items with a Therion ID (the one mentioned in
  // Therion Book).
  final Map<String, THElement> _elementByTHID = {};
  final Map<THElement, String> _thIDByElement = {};

  int _addElement(THElement aElement) {
    _thFile._includeElementInFile(aElement);
    _children.add(aElement);

    return aElement.mapiahID;
  }

  List<THElement> get children {
    return _children;
  }

  String _completeElementTHID(String elementType, String aTHID) {
    if (aTHID.contains(' ')) {
      throw THIDWithSpaceException(elementType, aTHID);
    }
    return '$elementType|$aTHID';
  }

  void removeElementTHIDByElement(THElement aElement) {
    final aElementType = aElement.type;

    if (!_thIDByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' has no registered thID.");
    }

    final aTHID = _thIDByElement[aElement];

    if (!_elementByTHID.containsKey(aTHID)) {
      throw THCustomException(
          "thID '$aTHID' gotten from element '$aElement' of type '$aElementType' is not registered.");
    }

    _thIDByElement.remove(aElement);
    _elementByTHID.remove(aTHID);
  }

  void removeElementTHIDByElementTypeAndTHID(
      String aElementType, String aTHID) {
    final completeTHID = _completeElementTHID(aElementType, aTHID);

    if (!_elementByTHID.containsKey(completeTHID)) {
      throw THCustomException(
          "thID '$aTHID' is not registered for type '$aElementType'.");
    }

    final aElement = _elementByTHID[completeTHID];

    if (!_thIDByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' has no registered thID.");
    }

    _thIDByElement.remove(aElement);
    _elementByTHID.remove(aTHID);
  }

  void updateElementTHID(THElement aElement, String newTHID) {
    final aElementType = aElement.type;
    final newCompleteTHID = _completeElementTHID(aElementType, newTHID);

    if (!_thIDByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' had no registered thID.");
    }
    final oldCompleteTHID = _thIDByElement[aElement];

    if (_elementByTHID.containsKey(newCompleteTHID)) {
      throw THCustomException(
          "Duplicate '$aElementType' element with thID '$newTHID'.");
    }

    _elementByTHID.remove(oldCompleteTHID);
    _elementByTHID[newCompleteTHID] = aElement;

    _thIDByElement[aElement] = newCompleteTHID;
  }

  void addElementWithTHID(THElement aElement, String aTHID) {
    final newCompleteTHID = _completeElementTHID(aElement.type, aTHID);

    if (_elementByTHID.containsKey(newCompleteTHID)) {
      throw THCustomException("Duplicate thID: '$newCompleteTHID'.");
    }
    _elementByTHID[newCompleteTHID] = aElement;

    if (_thIDByElement.containsKey(aElement)) {
      throw THCustomException("'${aElement.type}' already included.");
    }
    _thIDByElement[aElement] = newCompleteTHID;
  }

  bool hasElementByTHID(String elementType, String aTHID) {
    return _elementByTHID.containsKey(_completeElementTHID(elementType, aTHID));
  }

  THElement elementByTHID(String elementType, String aTHID) {
    if (!hasElementByTHID(elementType, aTHID)) {
      throw THCustomException("No element with thID '$aTHID' found.");
    }

    return _elementByTHID[_completeElementTHID(elementType, aTHID)]!;
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
