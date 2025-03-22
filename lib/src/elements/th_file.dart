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
  final LinkedHashMap<int, THElement> _elementByMPID =
      LinkedHashMap<int, THElement>();
  String filename = '';

  String encoding = thDefaultEncoding;

  late final int _mpID;

  final Set<int> _scrapMPIDs = {};

  final Set<int> _drawableElementMPIDs = {};

  /// Here are registered all items with a Therion ID (thID), the one mentioned
  /// in Therion Book. These thIDs should be unique inside a survey. As Mapiah
  /// doesn´t deals with surveys yet, it will guarantee that thIDs are unique
  /// inside a THFile for now.
  ///
  /// Not to be confused with Mapiah IDs, which are internal and unique only
  /// during a run.
  final LinkedHashMap<String, int> _mpIDByTHID = LinkedHashMap<String, int>();
  final LinkedHashMap<int, String> _thIDByMPID = LinkedHashMap<int, String>();

  THFile.forCWJM({
    required this.filename,
    required this.encoding,
    required int mpID,
    required Set<int> childrenMPID,
    required Set<int> scrapMPIDs,
    required Set<int> drawableElementsMPID,
    required LinkedHashMap<String, int> mpIDByTHID,
    required LinkedHashMap<int, String> thIDByMPID,
    required LinkedHashMap<int, THElement> elementByMPID,
  }) : _mpID = mpID {
    this.childrenMPID.addAll(childrenMPID);
    _scrapMPIDs.addAll(scrapMPIDs);
    _drawableElementMPIDs.addAll(drawableElementsMPID);
    _mpIDByTHID.addAll(mpIDByTHID);
    _thIDByMPID.addAll(thIDByMPID);
    _elementByMPID.addAll(elementByMPID);
  }

  THFile() {
    _mpID = mpLocator.mpGeneralController.nextMPIDForTHFiles();
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'filename': filename,
      'encoding': encoding,
      'mpID': _mpID,
      'childrenMPID': childrenMPID.toSet(),
      'scrapMPIDs': _scrapMPIDs.toSet(),
      'drawableElementMPIDs': _drawableElementMPIDs.toSet(),
      'elementByTHID': _mpIDByTHID.map((key, value) => MapEntry(key, value)),
      'thIDByMPID': _thIDByMPID,
      'elementByMPID':
          _elementByMPID.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory THFile.fromMap(Map<String, dynamic> map) {
    return THFile.forCWJM(
      filename: map['filename'],
      encoding: map['encoding'],
      mpID: map['mpID'],
      childrenMPID: Set<int>.from(map['childrenMPID']),
      scrapMPIDs: Set<int>.from(map['scrapMPIDs']),
      drawableElementsMPID: Set<int>.from(map['drawableElementMPIDs']),
      mpIDByTHID: LinkedHashMap<String, int>.from(map['elementByTHID']),
      thIDByMPID: LinkedHashMap<int, String>.from(map['thIDByMPID']),
      elementByMPID: LinkedHashMap<int, THElement>.from(
        map['elementByMPID']
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
    int? mpID,
    Set<int>? childrenMPID,
    Set<int>? scrapMPIDs,
    Set<int>? drawableElementMPIDs,
    LinkedHashMap<String, int>? mpIDByTHID,
    LinkedHashMap<int, String>? thIDByMPID,
    LinkedHashMap<int, THElement>? elementByMPID,
    bool makeFilenameNull = false,
    bool makeEncodingNull = false,
  }) {
    return THFile.forCWJM(
      filename: makeFilenameNull ? '' : (filename ?? this.filename),
      encoding: makeEncodingNull ? '' : (encoding ?? this.encoding),
      mpID: mpID ?? _mpID,
      childrenMPID: childrenMPID ?? this.childrenMPID,
      scrapMPIDs: scrapMPIDs ?? _scrapMPIDs,
      drawableElementsMPID: drawableElementMPIDs ?? _drawableElementMPIDs,
      mpIDByTHID: mpIDByTHID ?? _mpIDByTHID,
      thIDByMPID: thIDByMPID ?? _thIDByMPID,
      elementByMPID: elementByMPID ?? _elementByMPID,
    );
  }

  @override
  bool operator ==(covariant THFile other) {
    if (identical(this, other)) return true;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.filename == filename &&
        other.encoding == encoding &&
        other._mpID == _mpID &&
        deepEq(other.childrenMPID, childrenMPID) &&
        deepEq(other._scrapMPIDs, _scrapMPIDs) &&
        deepEq(other._drawableElementMPIDs, _drawableElementMPIDs) &&
        deepEq(other._mpIDByTHID, _mpIDByTHID) &&
        deepEq(other._thIDByMPID, _thIDByMPID) &&
        deepEq(other._elementByMPID, _elementByMPID);
  }

  @override
  int get hashCode => Object.hash(
        filename,
        encoding,
        _mpID,
        childrenMPID,
        _scrapMPIDs,
        _drawableElementMPIDs,
        _mpIDByTHID,
        _thIDByMPID,
        _elementByMPID,
      );

  Map<int, THElement> get elements {
    return _elementByMPID;
  }

  int countElements() {
    return _elementByMPID.length;
  }

  Set<int> get scrapMPIDs {
    return _scrapMPIDs;
  }

  Set<int> get drawableElementMPIDs {
    return _drawableElementMPIDs;
  }

  String thidByElement(THElement element) {
    return thidByMPID(element.mpID);
  }

  String thidByMPID(int mpID) {
    if (!_thIDByMPID.containsKey(mpID)) {
      throw THCustomException(
          "Element with mpID '$mpID' has no registered thID.");
    }

    return _thIDByMPID[mpID]!;
  }

  void unregisterElementTHIDByElement(THElement element) {
    final int mpID = element.mpID;

    unregisterElementTHIDByMPID(mpID);
  }

  void unregisterElementTHIDByMPID(int mpID) {
    if (!_thIDByMPID.containsKey(mpID)) {
      throw THCustomException(
          "Element with MPID '$mpID' has no registered thID.");
    }

    final String thID = _thIDByMPID[mpID]!;

    if (!_mpIDByTHID.containsKey(thID)) {
      throw THCustomException(
          "thID '$thID' gotten from element with Mapiah ID '$mpID' is not registered.");
    }

    _thIDByMPID.remove(mpID);
    _mpIDByTHID.remove(thID);
  }

  void unregisterElementTHIDByTHID(String thID) {
    if (!_mpIDByTHID.containsKey(thID)) {
      throw THCustomException("thID '$thID' is not registered.");
    }

    unregisterElementTHIDByMPID(_mpIDByTHID[thID]!);
  }

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    return calculateChildrenBoundingBox(th2FileEditController, childrenMPID);
  }

  /// Updates the thID of a given element of the THFile.
  /// @param element The element to have its thID updated.
  /// @param newTHID The new thID to be set.
  /// @throws THCustomException If the element has no registered thID.
  void updateTHID(THElement element, String newTHID) {
    final int mpID = element.mpID;

    if (!_thIDByMPID.containsKey(mpID)) {
      throw THCustomException("Element '$element' had no registered thID.");
    }
    final String oldTHID = _thIDByMPID[mpID]!;

    if (_mpIDByTHID.containsKey(newTHID)) {
      throw THCustomException("Duplicate element with thID '$newTHID'.");
    }

    _mpIDByTHID.remove(oldTHID);
    _mpIDByTHID[newTHID] = mpID;

    _thIDByMPID[mpID] = newTHID;
  }

  void registerElementWithTHID(THElement element, String thID) {
    if (_mpIDByTHID.containsKey(thID)) {
      throw THCustomException("Duplicate thID: '$thID'.");
    }
    final int mpID = element.mpID;
    _mpIDByTHID[thID] = mpID;

    if (_thIDByMPID.containsKey(mpID)) {
      throw THCustomException("'${element.elementType}' already included.");
    }
    _thIDByMPID[mpID] = thID;
  }

  bool hasElementByTHID(String thID) {
    return _mpIDByTHID.containsKey(thID);
  }

  bool hasTHIDByElement(THElement element) {
    return _thIDByMPID.containsKey(element.mpID);
  }

  THElement elementByTHID(String thID) {
    if (!hasElementByTHID(thID)) {
      throw THCustomException("No element with thID '$thID' found.");
    }

    return elementByMPID(_mpIDByTHID[thID]!);
  }

  int mpIDByTHID(String thID) {
    if (!hasElementByTHID(thID)) {
      throw THCustomException("No element with thID '$thID' found.");
    }

    return _mpIDByTHID[thID]!;
  }

  void _clearTHFileAndParentBoundingBoxes(THElement element) {
    clearBoundingBox();

    final int parentMPID = element.parentMPID;

    if (parentMPID > 0) {
      final THElement parentElement = elementByMPID(parentMPID);

      if (parentElement is THScrap) {
        parentElement.clearBoundingBox();
      }
    }
  }

  void substituteElement(THElement newElement) {
    final int mpID = newElement.mpID;
    final THElement oldElement = elementByMPID(mpID);

    _elementByMPID[mpID] = newElement;
    _clearTHFileAndParentBoundingBoxes(newElement);

    if (newElement is THHasTHID) {
      final String oldTHID = (oldElement as THHasTHID).thID;
      final String newTHID = (newElement as THHasTHID).thID;

      if (_mpIDByTHID.containsKey(oldTHID)) {
        _mpIDByTHID.remove(oldTHID);
      }
      if (_mpIDByTHID.containsKey(newTHID)) {
        throw THCustomException(
            "Duplicate thID in _elementByTHID: '$newTHID'.");
      }

      _mpIDByTHID[newTHID] = mpID;
      _thIDByMPID[mpID] = newTHID;
    }
  }

  bool hasOption(THElement element, THCommandOptionType optionType) {
    if (THElement is! THHasOptionsMixin) {
      return false;
    }

    return (element as THHasOptionsMixin).hasOption(optionType);
  }

  void addElement(THElement element) {
    _elementByMPID[element.mpID] = element;

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
      _scrapMPIDs.add(element.mpID);
    } else if ((element is THPoint) || (element is THLine)) {
      _drawableElementMPIDs.add(element.mpID);
    }
  }

  void removeElementByTHID(String thID) {
    final THElement element = elementByTHID(thID);
    removeElement(element);
  }

  void removeElement(THElement element) {
    if (element is THIsParentMixin) {
      final List<int> childrenMPIDsCopy =
          (element as THIsParentMixin).childrenMPID.toList();
      for (final int childMPID in childrenMPIDsCopy) {
        removeElement(elementByMPID(childMPID));
      }
    }

    if ((element is THHasTHID) || hasOption(element, THCommandOptionType.id)) {
      unregisterElementTHIDByElement(element);
    }

    if (element is THScrap) {
      _scrapMPIDs.remove(element.mpID);
    } else if ((element is THPoint) || (element is THLine)) {
      _drawableElementMPIDs.remove(element.mpID);
    }

    element.parent(this).removeElementFromParent(this, element);
    _elementByMPID.remove(element.mpID);
  }

  bool hasElementByMPID(int mpID) {
    if (mpID == 0) {
      return true;
    }
    return _elementByMPID.containsKey(mpID);
  }

  THElement elementByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    return _elementByMPID[mpID]!;
  }

  THElement elementByPosition(int position) {
    return _elementByMPID.values.elementAt(position);
  }

  void clear() {
    _elementByMPID.clear();
    _scrapMPIDs.clear();
    _mpIDByTHID.clear();
    _thIDByMPID.clear();
    filename = '';
    encoding = thDefaultEncoding;
    clearBoundingBox();
  }

  bool isSameClass(Object object) {
    return object is THFile;
  }

  @override
  int get mpID => _mpID;
}
