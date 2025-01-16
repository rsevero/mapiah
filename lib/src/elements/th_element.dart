import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_has_id.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/exceptions/th_no_element_by_mapiah_id_exception.dart';

part 'th_element.mapper.dart';

/// Base class for all elements that form a THFile, including THFile itself.
@MappableClass()
abstract class THElement with THElementMappable {
  // Internal ID used by Mapiah to identify each element during this run. This
  // value is never saved anywhere.
  late final int _mapiahID;

  late THFile _thFile;
  late int parentMapiahID;

  String? sameLineComment;

  /// Generic private constructor.
  ///
  /// Only used for special descendants that set by themselves their essential
  /// properties.
  ///
  /// Special descendants: THFile.
  THElement._();

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
  THElement.addToParent(THParent parent)
      : parentMapiahID = parent.mapiahID,
        _thFile = parent.thFile {
    parent._addElementToParent(this);
  }

  int get mapiahID {
    return _mapiahID;
  }

  THFile get thFile {
    return _thFile;
  }

  THParent get parent {
    return _thFile.elementByMapiahID(parentMapiahID) as THParent;
  }

  String get elementType {
    return runtimeType.toString().substring(2).toLowerCase();
  }

  void removeSameLineComment() {
    sameLineComment = null;
  }

  void delete() {
    _thFile._deleteElement(this);
  }

  THElement clone() {
    final THElement newElement = copyWith();
    return newElement;
  }

  bool isSameClass(THElement element);
}

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THParent on THElement {
  // Here are registered all children mapiah IDs.
  final List<int> childrenMapiahID = <int>[];

  @override
  void delete() {
    final List<int> childrenList = childrenMapiahID.toList();
    for (final int childMapiahID in childrenList) {
      thFile.deleteElementByMapiahID(childMapiahID);
    }

    _thFile._deleteElement(this);
  }

  int _addElementToParent(THElement element) {
    _thFile._addElementToFile(element);
    childrenMapiahID.add(element.mapiahID);

    return element.mapiahID;
  }

  void _deleteElementFromParent(THElement element) {
    if (!childrenMapiahID.remove(element.mapiahID)) {
      throw THCustomException("'$element' not found.");
    }

    if (_thFile.hasTHIDByElement(element)) {
      _thFile.deleteElementTHIDByElement(element);
    }
  }
}

/// THFile represents the complete contents of a .th or .th2 file.
///
/// It should be defined in the same file as THElement so it can access
/// THElement parameterless private constructor.
@MappableClass()
class THFile extends THElement with THFileMappable, THParent {
  /// This is the internal, Mapiah-only IDs used to identify each element only
  /// during this run. This value is never saved anywhere.
  ///
  /// Not to be confused with the thID, which is the ID used by Therion, the
  /// ones mentioned in Therion Book.
  final Map<int, THElement> _elementByMapiahID = {};
  String filename = '';

  String encoding = thDefaultEncoding;
  int _nextMapiahID = 1;

  double _minX = 0.0;
  double _minY = 0.0;
  double _maxX = 0.0;
  double _maxY = 0.0;
  bool _isFirst = true;

  /// Here are registered all items with a Therion ID (thID), the one mentioned
  /// in Therion Book. These thIDs should be unique inside a survey. As Mapiah
  /// doesn´t deals with surveys yet, it will guarantee that thIDs are unique
  /// inside a THFile for now.
  ///
  /// Not to be confused with Mapiah IDs, which are internal and unique only
  /// during a run.
  final Map<String, THElement> _elementByTHID = {};
  final Map<int, String> _thIDByMapiahID = {};

  THFile() : super._() {
    _thFile = this;
    parentMapiahID = thTHFileNoParentID;
    _mapiahID = 0;
  }

  Map<int, THElement> get elements {
    return _elementByMapiahID;
  }

  int countElements() {
    return _elementByMapiahID.length;
  }

  String thidByElement(THElement element) {
    return thidByMapiahID(element.mapiahID);
  }

  String thidByMapiahID(int mapiahID) {
    if (!_thIDByMapiahID.containsKey(mapiahID)) {
      throw THCustomException(
          "Element with mapiahID '$mapiahID' has no registered thID.");
    }

    return _thIDByMapiahID[mapiahID]!;
  }

  void deleteElementTHIDByElement(THElement element) {
    final String elementType = element.elementType;
    final int mapiahID = element._mapiahID;

    if (!_thIDByMapiahID.containsKey(mapiahID)) {
      throw THCustomException(
          "Element '$element' of type '$elementType' has no registered thID.");
    }

    final String thID = _thIDByMapiahID[mapiahID]!;

    if (!_elementByTHID.containsKey(thID)) {
      throw THCustomException(
          "thID '$thID' gotten from element '$element' of type '$elementType' is not registered.");
    }

    _thIDByMapiahID.remove(mapiahID);
    _elementByTHID.remove(thID);
  }

  void deleteElementTHIDByElementTypeAndTHID(String aElementType, String thID) {
    if (!_elementByTHID.containsKey(thID)) {
      throw THCustomException(
          "thID '$thID' is not registered for type '$aElementType'.");
    }

    final THElement aElement = _elementByTHID[thID]!;
    final int mapiahID = aElement._mapiahID;

    if (!_thIDByMapiahID.containsKey(mapiahID)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' has no registered thID.");
    }

    _thIDByMapiahID.remove(mapiahID);
    _elementByTHID.remove(thID);
  }

  void _comparePoint(double x, double y) {
    if (_isFirst) {
      _minX = x;
      _minY = y;
      _maxX = x;
      _maxY = y;
      _isFirst = false;
    } else {
      if (x < _minX) {
        _minX = x;
      } else if (x > _maxX) {
        _maxX = x;
      }
      if (y < _minY) {
        _minY = y;
      } else if (y > _maxY) {
        _maxY = y;
      }
    }
  }

  Rect boundingBox() {
    _isFirst = true;
    for (final THElement element in _elementByMapiahID.values) {
      switch (element) {
        case THPoint _:
          _comparePoint(element.x, element.y);
          break;
        case THStraightLineSegment _:
          _comparePoint(element.x, element.y);
          break;
        case THBezierCurveLineSegment _:
          _comparePoint(element.x, element.y);
          _comparePoint(element.controlPoint1X, element.controlPoint1Y);
          _comparePoint(element.controlPoint2X, element.controlPoint2Y);
          break;
      }
    }

    return Rect.fromLTRB(_minX, _minY, _maxX, _maxY);
  }

  /// Updates the thID of a given element of the THFile.
  /// @param aElement The element to have its thID updated.
  /// @param newTHID The new thID to be set.
  /// @throws THCustomException If the element has no registered thID.
  void updateTHID(THElement element, String newTHID) {
    final String aElementType = element.elementType;
    final int mapiahID = element._mapiahID;

    if (!_thIDByMapiahID.containsKey(mapiahID)) {
      throw THCustomException(
          "Element '$element' of type '$aElementType' had no registered thID.");
    }
    final String oldTHID = _thIDByMapiahID[mapiahID]!;

    if (_elementByTHID.containsKey(newTHID)) {
      throw THCustomException(
          "Duplicate '$aElementType' element with thID '$newTHID'.");
    }

    _elementByTHID.remove(oldTHID);
    _elementByTHID[newTHID] = element;

    _thIDByMapiahID[mapiahID] = newTHID;
  }

  void addElementWithTHID(THElement element, String thID) {
    if (_elementByTHID.containsKey(thID)) {
      throw THCustomException("Duplicate thID: '$thID'.");
    }
    _elementByTHID[thID] = element;

    final int aMapiahID = element.mapiahID;
    if (_thIDByMapiahID.containsKey(aMapiahID)) {
      throw THCustomException("'${element.elementType}' already included.");
    }
    _thIDByMapiahID[aMapiahID] = thID;
  }

  bool hasElementByTHID(String thID) {
    return _elementByTHID.containsKey(thID);
  }

  bool hasTHIDByElement(THElement element) {
    return _thIDByMapiahID.containsKey(element._mapiahID);
  }

  THElement elementByTHID(String thID) {
    if (!hasElementByTHID(thID)) {
      throw THCustomException("No element with thID '$thID' found.");
    }

    return _elementByTHID[thID]!;
  }

  void substituteElement(THElement newElement) {
    final int mapiahID = newElement.mapiahID;
    final THElement oldElement = elementByMapiahID(mapiahID);

    if (newElement.elementType != oldElement.elementType) {
      throw THCustomException(
          "Cannot substitute element of type '${oldElement.elementType}' with element of type '${newElement.elementType}'.");
    }

    newElement._thFile = this;
    _elementByMapiahID[mapiahID] = newElement;

    if (newElement is THHasTHID) {
      final String oldTHID = (oldElement as THHasTHID).thID;
      final String newTHID = (newElement as THHasTHID).thID;

      if (_elementByTHID.containsKey(oldTHID)) {
        _elementByTHID.remove(oldTHID);
      }
      if (_elementByTHID.containsKey(newTHID)) {
        throw THCustomException(
            "Duplicate thID in _elementByTHID: '$newTHID'.");
      }

      _elementByTHID[newTHID] = newElement;
      _thIDByMapiahID[mapiahID] = newTHID;
    }
  }

  void _addElementToFile(THElement element) {
    element._mapiahID = _nextMapiahID;
    _elementByMapiahID[_nextMapiahID] = element;
    _nextMapiahID++;
    if (element is THHasTHID) {
      addElementWithTHID(element, (element as THHasTHID).thID);
    }
  }

  void deleteElementByMapiahID(int mapiahID) {
    if (mapiahID == 0) {
      throw THCustomException("Cannot delete THFile.");
    }
    elementByMapiahID(mapiahID).delete();
  }

  void deleteElementByTHID(String thID) {
    elementByTHID(thID).delete();
  }

  void _deleteElement(THElement element) {
    if (element == this) {
      for (final int childMapiahID in childrenMapiahID) {
        elementByMapiahID(childMapiahID).delete();
      }
      return;
    }

    if (element.thFile != this) {
      throw THCustomException(
          "Trying to delete element '$element' that is not from this THFile.");
    }
    element.parent._deleteElementFromParent(element);
    _elementByMapiahID.remove(element.mapiahID);
  }

  bool hasElementByMapiahID(int mapiahID) {
    if (mapiahID == 0) {
      return true;
    }
    return _elementByMapiahID.containsKey(mapiahID);
  }

  THElement elementByMapiahID(int mapiahID) {
    if (_elementByMapiahID.containsKey(mapiahID)) {
      return _elementByMapiahID[mapiahID]!;
    } else if (mapiahID == 0) {
      return _thFile;
    } else {
      throw THNoElementByMapiahIDException(filename, mapiahID);
    }
  }

  @override
  bool isSameClass(THElement element) {
    return element is THFile;
  }
}
