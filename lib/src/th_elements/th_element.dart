import 'package:mapiah/src/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_has_id.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';
import 'package:mapiah/src/th_exceptions/th_duplicate_id_exception.dart';
import 'package:mapiah/src/th_exceptions/th_id_with_space_exception.dart';
import 'package:mapiah/src/th_exceptions/th_no_element_by_index_exception.dart';
import 'package:mapiah/src/th_exceptions/th_no_element_by_id_exception.dart';

/// Base class for all elements that form a THFile, including THFile itself.
abstract class THElement {
  late final int _index;
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

  int get index {
    return _index;
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
  final List<THElement> _children = [];

  int _addElement(THElement aElement) {
    _thFile._includeElementInFile(aElement);
    _children.add(aElement);

    return aElement.index;
  }

  List<THElement> get children {
    return _children;
  }
}

/// THFile represents the complete contents of a .th or .th2 file.
///
/// It should be defined in the same file as THElement so it can access
/// THElement parameterless private constructor.
class THFile extends THElement with THParent {
  final Map<int, THElement> _elements = {};
  var filename = 'unnamed file';

  final Map<String, THElement> _elementByID = {};
  final Map<THElement, String> _idByElement = {};

  var encoding = thDefaultEncoding;
  var _nextIndex = 0;

  THFile() : super._() {
    _index = -1;
    parent = this;
    _thFile = this;
  }

  Map<int, THElement> get elements {
    return _elements;
  }

  int countElements() {
    return _elements.length;
  }

  void _includeElementInFile(THElement aElement) {
    aElement._index = _nextIndex;
    _elements[_nextIndex] = aElement;
    _nextIndex++;
    if (aElement is THHasID) {
      addElementWithID(aElement, (aElement as THHasID).id);
    }
  }

  String _completeElementID(String elementType, String aID) {
    if (aID.contains(' ')) {
      throw THIDWithSpaceException(elementType, aID);
    }
    return '$elementType|$aID';
  }

  void removeElementIDByElement(THElement aElement) {
    final aElementType = aElement.type;

    if (!_idByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' has no registered ID.");
    }

    final aID = _idByElement[aElement];

    if (!_elementByID.containsKey(aID)) {
      throw THCustomException(
          "ID '$aID' gotten from element '$aElement' of type '$aElementType' is not registered.");
    }

    _idByElement.remove(aElement);
    _elementByID.remove(aID);
  }

  void removeElementIDByElementTypeID(String aElementType, String aID) {
    final completeID = _completeElementID(aElementType, aID);

    if (!_elementByID.containsKey(completeID)) {
      throw THCustomException(
          "ID '$aID' is not registered for type '$aElementType'.");
    }

    final aElement = _elementByID[completeID];

    if (!_idByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' has no registered ID.");
    }

    _idByElement.remove(aElement);
    _elementByID.remove(aID);
  }

  void updateElementID(THElement aElement, String newID) {
    final aElementType = aElement.type;
    final newCompleteID = _completeElementID(aElementType, newID);

    if (!_idByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' had no registered ID.");
    }
    final oldCompleteID = _idByElement[aElement];

    if (_elementByID.containsKey(newCompleteID)) {
      throw THCustomException(
          "Duplicate '$aElementType' element with ID '$newID'.");
    }

    _elementByID.remove(oldCompleteID);
    _elementByID[newCompleteID] = aElement;

    _idByElement[aElement] = newCompleteID;
  }

  void addElementWithID(THElement aElement, String aID) {
    final newCompleteID = _completeElementID(aElement.type, aID);

    if (_elementByID.containsKey(newCompleteID)) {
      throw THDuplicateIDException(newCompleteID, filename);
    }
    _elementByID[newCompleteID] = aElement;

    if (_idByElement.containsKey(aElement)) {
      throw THCustomException("'${aElement.type}' already included.");
    }
    _idByElement[aElement] = newCompleteID;
  }

  bool hasElementByID(String elementType, String aID) {
    return _elementByID.containsKey(_completeElementID(elementType, aID));
  }

  THElement elementByID(String elementType, String aID) {
    if (!hasElementByID(elementType, aID)) {
      throw THNoElementByIDException(elementType, aID, filename);
    }

    return _elementByID[_completeElementID(elementType, aID)]!;
  }

  bool hasElementByIndex(int aIndex) {
    return _elements.containsKey(aIndex);
  }

  THElement elementByIndex(int aIndex) {
    if (!hasElementByIndex(aIndex)) {
      throw THNoElementByIndexException(filename, aIndex);
    }

    return _elements[aIndex]!;
  }
}
