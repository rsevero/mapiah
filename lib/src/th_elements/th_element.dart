import 'package:flutter/material.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/th_elements/th_has_id.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_elements/th_straight_line_segment.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';
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

  String get elementType {
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
  final _children = <THElement>[];

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
  /// This is the internal, Mapiah-only IDs used to identify each element only
  /// during this run. This value is never saved anywhere.
  final Map<int, THElement> _elementByMapiahID = {};
  var filename = 'unnamed file';

  var encoding = thDefaultEncoding;
  var _nexMapiahID = 1;

  late double _minX;
  late double _minY;
  late double _maxX;
  late double _maxY;
  late bool _isFirst;

  /// Here are registered all items with a Therion ID (thID), the one mentioned
  /// in Therion Book. These thIDs should be unique inside a survey. As Mapiah
  /// doesn´t deals with surveys yet, it will guarantee that thIDs are unique
  /// inside a THFile for now.
  final Map<String, THElement> _elementByTHID = {};
  final Map<THElement, String> _thIDByElement = {};

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

  void deleteElementTHIDByElement(THElement aElement) {
    final aElementType = aElement.elementType;

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

  void deleteElementTHIDByElementTypeAndTHID(
      String aElementType, String aTHID) {
    if (!_elementByTHID.containsKey(aTHID)) {
      throw THCustomException(
          "thID '$aTHID' is not registered for type '$aElementType'.");
    }

    final aElement = _elementByTHID[aTHID];

    if (!_thIDByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' has no registered thID.");
    }

    _thIDByElement.remove(aElement);
    _elementByTHID.remove(aTHID);
  }

  void _comparePoint(double aX, double aY) {
    if (_isFirst) {
      _minX = aX;
      _minY = aY;
      _maxX = aX;
      _maxY = aY;
      _isFirst = false;
    } else {
      if (aX < _minX) {
        _minX = aX;
      } else if (aX > _maxX) {
        _maxX = aX;
      }
      if (aY < _minY) {
        _minY = aY;
      } else if (aY > _maxY) {
        _maxY = aY;
      }
    }
  }

  Rect boundingBox() {
    _isFirst = true;
    for (final element in _elementByMapiahID.values) {
      if (element is THPoint) {
        _comparePoint(element.x, element.y);
      } else if (element is THLine) {
        for (final aLineSegment in element.children) {
          if (aLineSegment is THStraightLineSegment) {
            _comparePoint(aLineSegment.endPointX, aLineSegment.endPointY);
          } else if (aLineSegment is THBezierCurveLineSegment) {
            _comparePoint(aLineSegment.endPointX, aLineSegment.endPointY);
            _comparePoint(
                aLineSegment.controlPoint1X, aLineSegment.controlPoint1Y);
            _comparePoint(
                aLineSegment.controlPoint2X, aLineSegment.controlPoint2Y);
          }
        }
      }
    }

    return Rect.fromLTRB(_minX, _minY, _maxX, _maxY);
  }

  void updateTHID(THElement aElement, String newTHID) {
    final aElementType = aElement.elementType;

    if (!_thIDByElement.containsKey(aElement)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' had no registered thID.");
    }
    final oldTHID = _thIDByElement[aElement];

    if (_elementByTHID.containsKey(newTHID)) {
      throw THCustomException(
          "Duplicate '$aElementType' element with thID '$newTHID'.");
    }

    _elementByTHID.remove(oldTHID);
    _elementByTHID[newTHID] = aElement;

    _thIDByElement[aElement] = newTHID;
  }

  void addElementWithTHID(THElement aElement, String aTHID) {
    if (_elementByTHID.containsKey(aTHID)) {
      throw THCustomException("Duplicate thID: '$aTHID'.");
    }
    _elementByTHID[aTHID] = aElement;

    if (_thIDByElement.containsKey(aElement)) {
      throw THCustomException("'${aElement.elementType}' already included.");
    }
    _thIDByElement[aElement] = aTHID;
  }

  bool hasElementByTHID(String elementType, String aTHID) {
    return _elementByTHID.containsKey(aTHID);
  }

  bool hasTHIDByElement(THElement aElement) {
    return _thIDByElement.containsKey(aElement);
  }

  THElement elementByTHID(String aElementType, String aTHID) {
    if (!hasElementByTHID(aElementType, aTHID)) {
      throw THCustomException("No element with thID '$aTHID' found.");
    }

    return _elementByTHID[aTHID]!;
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
