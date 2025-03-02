import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/mp_bounding_box.dart';
import 'package:mapiah/src/elements/mixins/th_calculate_children_bounding_box_mixin.dart';
import 'package:mapiah/src/elements/mixins/th_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_id.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/exceptions/th_no_element_by_mapiah_id_exception.dart';

/// THFile represents the complete contents of a .th or .th2 file.
///
/// It should be defined in the same file as THElement so it can access
/// THElement parameterless private constructor.
class THFile
    with THIsParentMixin, THCalculateChildrenBoundingBoxMixin, MPBoundingBox {
  /// This is the internal, Mapiah-only IDs used to identify each element only
  /// during this run. This value is never saved anywhere.
  ///
  /// Not to be confused with the thID, which is the ID used by Therion, the
  /// ones mentioned in Therion Book.
  final LinkedHashMap<int, THElement> _elementByMapiahID =
      LinkedHashMap<int, THElement>();
  String filename = '';

  String encoding = thDefaultEncoding;

  late final int _mapiahID;

  final Set<int> _scrapMapiahIDs = {};

  final Set<int> _drawableElementMapiahIDs = {};

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
    required Set<int> childrenMapiahID,
    required Set<int> scrapMapiahIDs,
    required Set<int> drawableElementsMapiahID,
    required LinkedHashMap<String, int> mapiahIDByTHID,
    required LinkedHashMap<int, String> thIDByMapiahID,
    required LinkedHashMap<int, THElement> elementByMapiahID,
  }) : _mapiahID = mapiahID {
    this.childrenMapiahID.addAll(childrenMapiahID);
    _scrapMapiahIDs.addAll(scrapMapiahIDs);
    _drawableElementMapiahIDs.addAll(drawableElementsMapiahID);
    _mapiahIDByTHID.addAll(mapiahIDByTHID);
    _thIDByMapiahID.addAll(thIDByMapiahID);
    _elementByMapiahID.addAll(elementByMapiahID);
  }

  THFile() {
    _mapiahID = mpLocator.mpGeneralController.nextMapiahIDForTHFiles();
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'filename': filename,
      'encoding': encoding,
      'mapiahID': _mapiahID,
      'childrenMapiahID': childrenMapiahID.toSet(),
      'scrapMapiahIDs': _scrapMapiahIDs.toSet(),
      'drawableElementMapiahIDs': _drawableElementMapiahIDs.toSet(),
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
      childrenMapiahID: Set<int>.from(map['childrenMapiahID']),
      scrapMapiahIDs: Set<int>.from(map['scrapMapiahIDs']),
      drawableElementsMapiahID: Set<int>.from(map['drawableElementMapiahIDs']),
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
    Set<int>? childrenMapiahID,
    Set<int>? scrapMapiahIDs,
    Set<int>? drawableElementMapiahIDs,
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
      scrapMapiahIDs: scrapMapiahIDs ?? _scrapMapiahIDs,
      drawableElementsMapiahID:
          drawableElementMapiahIDs ?? _drawableElementMapiahIDs,
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
        deepEq(other._scrapMapiahIDs, _scrapMapiahIDs) &&
        deepEq(other._drawableElementMapiahIDs, _drawableElementMapiahIDs) &&
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
        _scrapMapiahIDs,
        _drawableElementMapiahIDs,
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

  Set<int> get scrapMapiahIDs {
    return _scrapMapiahIDs;
  }

  Set<int> get drawableElementMapiahIDs {
    return _drawableElementMapiahIDs;
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

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    return calculateChildrenBoundingBox(
        th2FileEditController, childrenMapiahID);
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

  void _clearTHFileAndParentBoundingBoxes(THElement element) {
    clearBoundingBox();

    final int parentMapiahID = element.parentMapiahID;

    if (parentMapiahID > 0) {
      final THElement parentElement = elementByMapiahID(parentMapiahID);

      if (parentElement is THScrap) {
        parentElement.clearBoundingBox();
      }
    }
  }

  void substituteElement(THElement newElement) {
    final int mapiahID = newElement.mapiahID;
    final THElement oldElement = elementByMapiahID(mapiahID);

    _elementByMapiahID[mapiahID] = newElement;
    _clearTHFileAndParentBoundingBoxes(newElement);

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

  bool hasOption(THElement element, THCommandOptionType optionType) {
    if (THElement is! THHasOptionsMixin) {
      return false;
    }

    return (element as THHasOptionsMixin).hasOption(optionType);
  }

  void addElement(THElement element) {
    _elementByMapiahID[element.mapiahID] = element;

    if (element is THHasTHID) {
      registerElementWithTHID(element, (element as THHasTHID).thID);
    } else if (hasOption(element, THCommandOptionType.id)) {
      registerElementWithTHID(
        element,
        ((element as THHasOptionsMixin).optionByType(THCommandOptionType.id)!
                as THIDCommandOption)
            .thID,
      );
    }

    if (element is THScrap) {
      _scrapMapiahIDs.add(element.mapiahID);
    } else if ((element is THPoint) || (element is THLine)) {
      _drawableElementMapiahIDs.add(element.mapiahID);
    }
  }

  void deleteElementByTHID(String thID) {
    final THElement element = elementByTHID(thID);
    deleteElement(element);
  }

  void deleteElement(THElement element) {
    if (element is THIsParentMixin) {
      final List<int> childrenMapiahIDsCopy =
          (element as THIsParentMixin).childrenMapiahID.toList();
      for (final int childMapiahID in childrenMapiahIDsCopy) {
        deleteElement(elementByMapiahID(childMapiahID));
      }
    }

    if ((element is THHasTHID) || hasOption(element, THCommandOptionType.id)) {
      unregisterElementTHIDByElement(element);
    }

    if (element is THScrap) {
      _scrapMapiahIDs.remove(element.mapiahID);
    } else if ((element is THPoint) || (element is THLine)) {
      _drawableElementMapiahIDs.remove(element.mapiahID);
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
    _scrapMapiahIDs.clear();
    _mapiahIDByTHID.clear();
    _thIDByMapiahID.clear();
    filename = '';
    encoding = thDefaultEncoding;
    clearBoundingBox();
  }

  bool isSameClass(Object object) {
    return object is THFile;
  }

  @override
  int get mapiahID => _mapiahID;
}
