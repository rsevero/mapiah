import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_has_id.dart';
import 'package:mapiah/src/elements/th_line.dart';
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

  late final THFile _thFile;
  late int parentMapiahID;

  String? sameLineComment;

  /// Generic private constructor.
  ///
  /// Only used for special descendants that set by themselves their essential
  /// properties.
  ///
  /// Special descendants: THFile.
  THElement._();

  /// Constructor that sets the parentMapiahID and the thFile.
  /// Necessary for dart_mappable.
  THElement.withParentMapiahIDTHFile(this.parentMapiahID, this._thFile) {
    parent._addElementToParent(this);
  }

  /// Main constructor.
  ///
  /// Main constructor that sets all essential properties. Any change made here
  /// should eventually be reproduced in the special descendants that don´t use
  /// this constructor but the [Generic private constructor].
  THElement.withParent(THParent parent)
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

    _thFile._deleteElement(this);
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

    if (_thFile.hasTHIDByElement(aElement)) {
      _thFile.deleteElementTHIDByElement(aElement);
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
  String filename = 'unnamed file';

  String encoding = thDefaultEncoding;
  int _nextMapiahID = 0;

  late double _minX;
  late double _minY;
  late double _maxX;
  late double _maxY;
  late bool _isFirst;

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
    parentMapiahID = thThFileNoParentID;
    _addElementToFile(this);
  }

  Map<int, THElement> get elements {
    return _elementByMapiahID;
  }

  int countElements() {
    return _elementByMapiahID.length;
  }

  String thidByElement(THElement aElement) {
    return thidByMapiahID(aElement.mapiahID);
  }

  String thidByMapiahID(int aMapiahID) {
    if (!_thIDByMapiahID.containsKey(aMapiahID)) {
      throw THCustomException(
          "Element with mapiahID '$aMapiahID' has no registered thID.");
    }

    return _thIDByMapiahID[aMapiahID]!;
  }

  void deleteElementTHIDByElement(THElement aElement) {
    final String aElementType = aElement.elementType;
    final int aMapiahID = aElement._mapiahID;

    if (!_thIDByMapiahID.containsKey(aMapiahID)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' has no registered thID.");
    }

    final String aTHID = _thIDByMapiahID[aMapiahID]!;

    if (!_elementByTHID.containsKey(aTHID)) {
      throw THCustomException(
          "thID '$aTHID' gotten from element '$aElement' of type '$aElementType' is not registered.");
    }

    _thIDByMapiahID.remove(aMapiahID);
    _elementByTHID.remove(aTHID);
  }

  void deleteElementTHIDByElementTypeAndTHID(
      String aElementType, String aTHID) {
    if (!_elementByTHID.containsKey(aTHID)) {
      throw THCustomException(
          "thID '$aTHID' is not registered for type '$aElementType'.");
    }

    final THElement aElement = _elementByTHID[aTHID]!;
    final int aMapiahID = aElement._mapiahID;

    if (!_thIDByMapiahID.containsKey(aMapiahID)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' has no registered thID.");
    }

    _thIDByMapiahID.remove(aMapiahID);
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
    for (final THElement element in _elementByMapiahID.values) {
      if (element is THPoint) {
        _comparePoint(element.x, element.y);
      } else if (element is THLine) {
        for (final THElement aLineSegment in element.children) {
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

  /// Updates the thID of a given element of the THFile.
  /// @param aElement The element to have its thID updated.
  /// @param newTHID The new thID to be set.
  /// @throws THCustomException If the element has no registered thID.
  void updateTHID(THElement aElement, String newTHID) {
    final String aElementType = aElement.elementType;
    final int aMapiahID = aElement._mapiahID;

    if (!_thIDByMapiahID.containsKey(aMapiahID)) {
      throw THCustomException(
          "Element '$aElement' of type '$aElementType' had no registered thID.");
    }
    final String oldTHID = _thIDByMapiahID[aMapiahID]!;

    if (_elementByTHID.containsKey(newTHID)) {
      throw THCustomException(
          "Duplicate '$aElementType' element with thID '$newTHID'.");
    }

    _elementByTHID.remove(oldTHID);
    _elementByTHID[newTHID] = aElement;

    _thIDByMapiahID[aMapiahID] = newTHID;
  }

  void addElementWithTHID(THElement aElement, String aTHID) {
    if (_elementByTHID.containsKey(aTHID)) {
      throw THCustomException("Duplicate thID: '$aTHID'.");
    }
    _elementByTHID[aTHID] = aElement;

    final int aMapiahID = aElement.mapiahID;
    if (_thIDByMapiahID.containsKey(aMapiahID)) {
      throw THCustomException("'${aElement.elementType}' already included.");
    }
    _thIDByMapiahID[aMapiahID] = aTHID;
  }

  bool hasElementByTHID(String elementType, String aTHID) {
    return _elementByTHID.containsKey(aTHID);
  }

  bool hasTHIDByElement(THElement aElement) {
    return _thIDByMapiahID.containsKey(aElement._mapiahID);
  }

  THElement elementByTHID(String aElementType, String aTHID) {
    if (!hasElementByTHID(aElementType, aTHID)) {
      throw THCustomException("No element with thID '$aTHID' found.");
    }

    return _elementByTHID[aTHID]!;
  }

  void _addElementToFile(THElement aElement) {
    aElement._mapiahID = _nextMapiahID;
    _elementByMapiahID[_nextMapiahID] = aElement;
    _nextMapiahID++;
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
      final List<THElement> childrenList = children.toList();
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
    if (aMapiahID == 0) {
      return _thFile;
    } else if (!hasElementByMapiahID(aMapiahID)) {
      throw THNoElementByMapiahIDException(filename, aMapiahID);
    }

    return _elementByMapiahID[aMapiahID]!;
  }
}
