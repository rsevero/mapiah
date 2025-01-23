import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_id_command_option.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_id.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/exceptions/th_no_element_by_mapiah_id_exception.dart';
import 'package:mapiah/src/stores/general_store.dart';

/// THFile represents the complete contents of a .th or .th2 file.
///
/// It should be defined in the same file as THElement so it can access
/// THElement parameterless private constructor.
class THFile with THParent {
  /// This is the internal, Mapiah-only IDs used to identify each element only
  /// during this run. This value is never saved anywhere.
  ///
  /// Not to be confused with the thID, which is the ID used by Therion, the
  /// ones mentioned in Therion Book.
  final LinkedHashMap<int, THElement> _elementByMapiahID =
      LinkedHashMap<int, THElement>();
  String filename = '';

  String encoding = thDefaultEncoding;

  double _minX = 0.0;
  double _minY = 0.0;
  double _maxX = 0.0;
  double _maxY = 0.0;
  bool _isFirst = true;

  late final int _mapiahID;

  final LinkedHashMap<int, THScrap> _scrapByMapiahID =
      LinkedHashMap<int, THScrap>();

  /// Here are registered all items with a Therion ID (thID), the one mentioned
  /// in Therion Book. These thIDs should be unique inside a survey. As Mapiah
  /// doesn´t deals with surveys yet, it will guarantee that thIDs are unique
  /// inside a THFile for now.
  ///
  /// Not to be confused with Mapiah IDs, which are internal and unique only
  /// during a run.
  final LinkedHashMap<String, int> _mapiahIDByTHID =
      LinkedHashMap<String, int>();
  final LinkedHashMap<int, String> _thIDByMapiahID =
      LinkedHashMap<int, String>();

  THFile.forCWJM({
    required this.filename,
    required this.encoding,
    required int mapiahID,
    required List<int> childrenMapiahID,
    required LinkedHashMap<int, THScrap> scrapByMapiahID,
    required LinkedHashMap<String, int> mapiahIDByTHID,
    required LinkedHashMap<int, String> thIDByMapiahID,
    required LinkedHashMap<int, THElement> elementByMapiahID,
  }) : _mapiahID = mapiahID {
    this.childrenMapiahID.addAll(childrenMapiahID);
    _scrapByMapiahID.addAll(scrapByMapiahID);
    _mapiahIDByTHID.addAll(mapiahIDByTHID);
    _thIDByMapiahID.addAll(thIDByMapiahID);
    _elementByMapiahID.addAll(elementByMapiahID);
  }

  THFile() {
    _mapiahID = getIt<GeneralStore>().nextMapiahIDForTHFiles();
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'filename': filename,
      'encoding': encoding,
      'mapiahID': _mapiahID,
      'childrenMapiahID': childrenMapiahID.toList(),
      'scrapByMapiahID':
          _scrapByMapiahID.map((key, value) => MapEntry(key, value.toMap())),
      'elementByTHID':
          _mapiahIDByTHID.map((key, value) => MapEntry(key, value)),
      'thIDByMapiahID': _thIDByMapiahID,
      'elementByMapiahID':
          _elementByMapiahID.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory THFile.fromMap(Map<String, dynamic> map) {
    return THFile.forCWJM(
      filename: map['filename'],
      encoding: map['encoding'],
      mapiahID: map['mapiahID'],
      childrenMapiahID: List<int>.from(map['childrenMapiahID']),
      scrapByMapiahID: LinkedHashMap<int, THScrap>.from(
        map['scrapByMapiahID']
            .map((key, value) => MapEntry(key, THScrap.fromMap(value))),
      ),
      mapiahIDByTHID: LinkedHashMap<String, int>.from(map['elementByTHID']),
      thIDByMapiahID: LinkedHashMap<int, String>.from(map['thIDByMapiahID']),
      elementByMapiahID: LinkedHashMap<int, THElement>.from(
        map['elementByMapiahID']
            .map((key, value) => MapEntry(key, THElement.fromMap(value))),
      ),
    );
  }

  factory THFile.fromJson(String jsonString) {
    return THFile.fromMap(jsonDecode(jsonString));
  }

  THFile copyWith({
    String? filename,
    String? encoding,
    int? mapiahID,
    List<int>? childrenMapiahID,
    LinkedHashMap<int, THScrap>? scrapByMapiahID,
    LinkedHashMap<String, int>? mapiahIDByTHID,
    LinkedHashMap<int, String>? thIDByMapiahID,
    LinkedHashMap<int, THElement>? elementByMapiahID,
    bool makeFilenameNull = false,
    bool makeEncodingNull = false,
  }) {
    return THFile.forCWJM(
      filename: makeFilenameNull ? '' : (filename ?? this.filename),
      encoding: makeEncodingNull ? '' : (encoding ?? this.encoding),
      mapiahID: mapiahID ?? _mapiahID,
      childrenMapiahID: childrenMapiahID ?? this.childrenMapiahID,
      scrapByMapiahID: scrapByMapiahID ?? _scrapByMapiahID,
      mapiahIDByTHID: mapiahIDByTHID ?? _mapiahIDByTHID,
      thIDByMapiahID: thIDByMapiahID ?? _thIDByMapiahID,
      elementByMapiahID: elementByMapiahID ?? _elementByMapiahID,
    );
  }

  @override
  bool operator ==(covariant THFile other) {
    if (identical(this, other)) return true;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.filename == filename &&
        other.encoding == encoding &&
        other._mapiahID == _mapiahID &&
        deepEq(other.childrenMapiahID, childrenMapiahID) &&
        deepEq(other._scrapByMapiahID, _scrapByMapiahID) &&
        deepEq(other._mapiahIDByTHID, _mapiahIDByTHID) &&
        deepEq(other._thIDByMapiahID, _thIDByMapiahID) &&
        deepEq(other._elementByMapiahID, _elementByMapiahID);
  }

  @override
  int get hashCode => Object.hash(
        filename,
        encoding,
        _mapiahID,
        childrenMapiahID,
        _scrapByMapiahID,
        _mapiahIDByTHID,
        _thIDByMapiahID,
        _elementByMapiahID,
      );

  Map<int, THElement> get elements {
    return _elementByMapiahID;
  }

  int countElements() {
    return _elementByMapiahID.length;
  }

  LinkedHashMap<int, THScrap> get scraps {
    return _scrapByMapiahID;
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

  void unregisterElementTHIDByElement(THElement element) {
    final int mapiahID = element.mapiahID;

    unregisterElementTHIDByMapiahID(mapiahID);
  }

  void unregisterElementTHIDByMapiahID(int mapiahID) {
    if (!_thIDByMapiahID.containsKey(mapiahID)) {
      throw THCustomException(
          "Element with MapiahID '$mapiahID' has no registered thID.");
    }

    final String thID = _thIDByMapiahID[mapiahID]!;

    if (!_mapiahIDByTHID.containsKey(thID)) {
      throw THCustomException(
          "thID '$thID' gotten from element with Mapiah ID '$mapiahID' is not registered.");
    }

    _thIDByMapiahID.remove(mapiahID);
    _mapiahIDByTHID.remove(thID);
  }

  void unregisterElementTHIDByTHID(String thID) {
    if (!_mapiahIDByTHID.containsKey(thID)) {
      throw THCustomException("thID '$thID' is not registered.");
    }

    unregisterElementTHIDByMapiahID(_mapiahIDByTHID[thID]!);
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
  /// @param element The element to have its thID updated.
  /// @param newTHID The new thID to be set.
  /// @throws THCustomException If the element has no registered thID.
  void updateTHID(THElement element, String newTHID) {
    final int mapiahID = element.mapiahID;

    if (!_thIDByMapiahID.containsKey(mapiahID)) {
      throw THCustomException("Element '$element' had no registered thID.");
    }
    final String oldTHID = _thIDByMapiahID[mapiahID]!;

    if (_mapiahIDByTHID.containsKey(newTHID)) {
      throw THCustomException("Duplicate element with thID '$newTHID'.");
    }

    _mapiahIDByTHID.remove(oldTHID);
    _mapiahIDByTHID[newTHID] = mapiahID;

    _thIDByMapiahID[mapiahID] = newTHID;
  }

  void registerElementWithTHID(THElement element, String thID) {
    if (_mapiahIDByTHID.containsKey(thID)) {
      throw THCustomException("Duplicate thID: '$thID'.");
    }
    final int mapiahID = element.mapiahID;
    _mapiahIDByTHID[thID] = mapiahID;

    if (_thIDByMapiahID.containsKey(mapiahID)) {
      throw THCustomException("'${element.elementType}' already included.");
    }
    _thIDByMapiahID[mapiahID] = thID;
  }

  bool hasElementByTHID(String thID) {
    return _mapiahIDByTHID.containsKey(thID);
  }

  bool hasTHIDByElement(THElement element) {
    return _thIDByMapiahID.containsKey(element.mapiahID);
  }

  THElement elementByTHID(String thID) {
    if (!hasElementByTHID(thID)) {
      throw THCustomException("No element with thID '$thID' found.");
    }

    return elementByMapiahID(_mapiahIDByTHID[thID]!);
  }

  int mapiahIDByTHID(String thID) {
    if (!hasElementByTHID(thID)) {
      throw THCustomException("No element with thID '$thID' found.");
    }

    return _mapiahIDByTHID[thID]!;
  }

  void substituteElement(THElement newElement) {
    final int mapiahID = newElement.mapiahID;
    final THElement oldElement = elementByMapiahID(mapiahID);

    if (newElement.elementType != oldElement.elementType) {
      throw THCustomException(
          "Cannot substitute element of type '${oldElement.elementType}' with element of type '${newElement.elementType}'.");
    }

    _elementByMapiahID[mapiahID] = newElement;

    if (newElement is THHasTHID) {
      final String oldTHID = (oldElement as THHasTHID).thID;
      final String newTHID = (newElement as THHasTHID).thID;

      if (_mapiahIDByTHID.containsKey(oldTHID)) {
        _mapiahIDByTHID.remove(oldTHID);
      }
      if (_mapiahIDByTHID.containsKey(newTHID)) {
        throw THCustomException(
            "Duplicate thID in _elementByTHID: '$newTHID'.");
      }

      _mapiahIDByTHID[newTHID] = mapiahID;
      _thIDByMapiahID[mapiahID] = newTHID;
    }
  }

  bool hasOption(THElement element, String optionType) {
    if (THElement is! THHasOptions) {
      return false;
    }

    return (element as THHasOptions).hasOption(optionType);
  }

  void addElement(THElement element) {
    _elementByMapiahID[element.mapiahID] = element;

    if (element is THHasTHID) {
      registerElementWithTHID(element, (element as THHasTHID).thID);
    } else if (hasOption(element, 'id')) {
      registerElementWithTHID(
        element,
        ((element as THHasOptions).optionByType('id')! as THIDCommandOption)
            .thID,
      );
    }

    if (element is THScrap) {
      _scrapByMapiahID[element.mapiahID] = element;
    }
  }

  void deleteElementByTHID(String thID) {
    final THElement element = elementByTHID(thID);
    deleteElement(element);
  }

  void deleteElement(THElement element) {
    if (element is THParent) {
      final List<int> childrenMapiahIDsCopy =
          (element as THParent).childrenMapiahID.toList();
      for (final int childMapiahID in childrenMapiahIDsCopy) {
        deleteElement(elementByMapiahID(childMapiahID));
      }
    }

    if ((element is THHasTHID) || hasOption(element, 'id')) {
      unregisterElementTHIDByElement(element);
    }

    if (element is THScrap) {
      _scrapByMapiahID[element.mapiahID] = element;
    }

    element.parent(this).deleteElementFromParent(this, element);
    _elementByMapiahID.remove(element.mapiahID);
  }

  bool hasElementByMapiahID(int mapiahID) {
    if (mapiahID == 0) {
      return true;
    }
    return _elementByMapiahID.containsKey(mapiahID);
  }

  THElement elementByMapiahID(int mapiahID) {
    if (!_elementByMapiahID.containsKey(mapiahID)) {
      throw THNoElementByMapiahIDException(filename, mapiahID);
    }

    return _elementByMapiahID[mapiahID]!;
  }

  THElement elementByPosition(int position) {
    return _elementByMapiahID.values.elementAt(position);
  }

  void clear() {
    _elementByMapiahID.clear();
    _scrapByMapiahID.clear();
    _mapiahIDByTHID.clear();
    _thIDByMapiahID.clear();
    filename = '';
    encoding = thDefaultEncoding;
    _isFirst = true;
  }

  bool isSameClass(Object object) {
    return object is THFile;
  }

  @override
  int get mapiahID => _mapiahID;
}
