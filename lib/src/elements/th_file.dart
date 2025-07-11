import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
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
  Uint8List? fileBytes;

  String encoding = thDefaultEncoding;
  String lineEnding = MPDirectoryAux.getDefaultLineEnding();

  late final int _mpID;

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

  final Set<int> _areasMPIDs = {};
  final Set<int> _linesMPIDs = {};
  final Set<int> _pointsMPIDs = {};
  final Set<int> _scrapMPIDs = {};

  Map<int, int>? _areaMPIDByLineMPID;
  Map<String, int>? _areaMPIDByLineTHID;

  THFile.forCWJM({
    required this.filename,
    required this.encoding,
    required int mpID,
    required LinkedHashMap<int, THElement> elementByMPID,
  }) : _mpID = mpID {
    _elementByMPID.addAll(elementByMPID);
    _initializeSupportMaps();
  }

  THFile() {
    _mpID = mpLocator.mpGeneralController.nextMPIDForTHFiles();
  }

  void _initializeSupportMaps() {
    final elements = _elementByMPID.values;

    for (final THElement element in elements) {
      if (element.parentMPID == _mpID) {
        childrenMPID.add(element.mpID);
      }

      _updateSupportMaps(element);
    }
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
      'elementByMPID':
          _elementByMPID.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory THFile.fromMap(Map<String, dynamic> map) {
    return THFile.forCWJM(
      filename: map['filename'],
      encoding: map['encoding'],
      mpID: map['mpID'],
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
    LinkedHashMap<int, THElement>? elementByMPID,
    bool makeFilenameNull = false,
    bool makeEncodingNull = false,
  }) {
    return THFile.forCWJM(
      filename: makeFilenameNull ? '' : (filename ?? this.filename),
      encoding: makeEncodingNull ? '' : (encoding ?? this.encoding),
      mpID: mpID ?? _mpID,
      elementByMPID: elementByMPID ?? _elementByMPID,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THFile) return false;

    final Function deepEq = const DeepCollectionEquality().equals;

    return other.filename == filename &&
        other.encoding == encoding &&
        other._mpID == _mpID &&
        deepEq(other._elementByMPID, _elementByMPID);
  }

  @override
  int get hashCode => Object.hash(
        filename,
        encoding,
        _mpID,
        _elementByMPID,
      );

  Map<int, THElement> get elements {
    return _elementByMPID;
  }

  int countElements() {
    return _elementByMPID.length;
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

  void registerMPIDWithTHID(int mpID, String thID) {
    if (_mpIDByTHID.containsKey(thID) && (_mpIDByTHID[thID] != mpID)) {
      throw THCustomException("Duplicate thID: '$thID'.");
    }

    _mpIDByTHID[thID] = mpID;
    _thIDByMPID[mpID] = thID;
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
    return (element is THHasOptionsMixin)
        ? element.hasOption(optionType)
        : false;
  }

  void addElement(THElement element) {
    _elementByMPID[element.mpID] = element;

    _updateSupportMaps(element);
  }

  void _updateSupportMaps(THElement element) {
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

    switch (element) {
      case THPoint _:
        _pointsMPIDs.add(element.mpID);
        _drawableElementMPIDs.add(element.mpID);
      case THLine _:
        _linesMPIDs.add(element.mpID);
        _drawableElementMPIDs.add(element.mpID);
      case THArea _:
        _areasMPIDs.add(element.mpID);
      case THAreaBorderTHID _:
        _clearAreaXLineInfo(element);
      case THScrap _:
        _scrapMPIDs.add(element.mpID);
    }
  }

  void _clearAreaXLineInfo(THElement element) {
    late final THArea area;

    switch (element) {
      case THAreaBorderTHID _:
        area = areaByMPID(element.parentMPID);
      case THArea _:
        area = element;
      default:
        throw THCustomException(
            "Element is not a THArea or THAreaBorderTHID in THFile._clearAreaXLineInfo.");
    }

    area.clearAreaXLineInfo();
    _areaMPIDByLineMPID = null;
    _areaMPIDByLineTHID = null;
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

    switch (element) {
      case THArea _:
        _clearAreaXLineInfo(element);
        _areasMPIDs.remove(element.mpID);
      case THAreaBorderTHID _:
        _clearAreaXLineInfo(element);
      case THLine _:
        _linesMPIDs.remove(element.mpID);
        _drawableElementMPIDs.remove(element.mpID);
      case THPoint _:
        _pointsMPIDs.remove(element.mpID);
        _drawableElementMPIDs.remove(element.mpID);
      case THScrap _:
        _scrapMPIDs.remove(element.mpID);
      default:
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

  THHasOptionsMixin hasOptionByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    final THElement element = _elementByMPID[mpID]!;

    if (element is! THHasOptionsMixin) {
      throw THCustomException(
          "Element with MPID '$mpID' is not a THHasOptionsMixin in THFile.hasOptionByMPID.");
    }

    return element;
  }

  THIsParentMixin parentByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    final THElement element = _elementByMPID[mpID]!;

    if (element is! THIsParentMixin) {
      throw THCustomException(
          "Element with MPID '$mpID' is not a parent in THFile.parentByMPID.");
    }

    return (element as THIsParentMixin);
  }

  THPoint pointByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    final THElement element = _elementByMPID[mpID]!;

    if (element is! THPoint) {
      throw THCustomException(
          "Element with MPID '$mpID' is not a point in THFile.pointByMPID.");
    }

    return element;
  }

  THLine lineByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    final THElement element = _elementByMPID[mpID]!;

    if (element is! THLine) {
      throw THCustomException(
          "Element with MPID '$mpID' is not a line in THFile.lineByMPID.");
    }

    return element;
  }

  THArea areaByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    final THElement element = _elementByMPID[mpID]!;

    if (element is! THArea) {
      throw THCustomException(
          "Element with MPID '$mpID' is not an area in THFile.areaByMPID.");
    }

    return element;
  }

  THAreaBorderTHID areaBorderTHIDByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    final THElement element = _elementByMPID[mpID]!;

    if (element is! THAreaBorderTHID) {
      throw THCustomException(
          "Element with MPID '$mpID' is not an area border in THFile.areaBorderByMPID.");
    }

    return element;
  }

  THScrap scrapByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    final THElement element = _elementByMPID[mpID]!;

    if (element is! THScrap) {
      throw THCustomException(
          "Element with MPID '$mpID' is not a scrap in THFile.scrapByMPID.");
    }

    return element;
  }

  THLineSegment lineSegmentByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    final THElement element = _elementByMPID[mpID]!;

    if (element is! THLineSegment) {
      throw THCustomException(
          "Element with MPID '$mpID' is not a line segment in THFile.lineSegmentByMPID.");
    }

    return element;
  }

  THBezierCurveLineSegment bezierCurveLineSegmentByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    final THElement element = _elementByMPID[mpID]!;

    if (element is! THBezierCurveLineSegment) {
      throw THCustomException(
          "Element with MPID '$mpID' is not a bezier curve line segment in THFile.bezierCurveLineSegmentByMPID.");
    }

    return element;
  }

  THStraightLineSegment straightLineSegmentByMPID(int mpID) {
    if (!_elementByMPID.containsKey(mpID)) {
      throw THNoElementByMPIDException(filename, mpID);
    }

    final THElement element = _elementByMPID[mpID]!;

    if (element is! THStraightLineSegment) {
      throw THCustomException(
          "Element with MPID '$mpID' is not a straight line segment in THFile.straightLineSegmentByMPID.");
    }

    return element;
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

  THElementType getElementTypeByMPID(int mpID) {
    return elementByMPID(mpID).elementType;
  }

  Set<int> get scrapMPIDs {
    return _scrapMPIDs;
  }

  Set<int> get areasMPIDs {
    return _areasMPIDs;
  }

  Set<int> get linesMPIDs {
    return _linesMPIDs;
  }

  Set<int> get pointsMPIDs {
    return _pointsMPIDs;
  }

  Iterable<THScrap> getScraps() {
    return _scrapMPIDs.map((int mpID) => scrapByMPID(mpID));
  }

  Iterable<THArea> getAreas() {
    return _areasMPIDs.map((int mpID) => areaByMPID(mpID));
  }

  Iterable<THLine> getLines() {
    return _linesMPIDs.map((int mpID) => lineByMPID(mpID));
  }

  Iterable<THPoint> getPoints() {
    return _pointsMPIDs.map((int mpID) => pointByMPID(mpID));
  }

  void _updateAreaXLineInfo() {
    _areaMPIDByLineMPID = <int, int>{};
    _areaMPIDByLineTHID = <String, int>{};

    for (final int areaMPID in _areasMPIDs) {
      final THArea area = areaByMPID(areaMPID);
      final Set<int> lineMPIDs = area.getLineMPIDs(this);
      final Set<String> lineTHIDs = area.getLineTHIDs(this);

      for (final int lineMPID in lineMPIDs) {
        _areaMPIDByLineMPID![lineMPID] = areaMPID;
      }
      for (final String lineTHID in lineTHIDs) {
        _areaMPIDByLineTHID![lineTHID] = areaMPID;
      }
    }
  }

  int? getAreaMPIDByLineMPID(int lineMPID) {
    if (_areaMPIDByLineMPID == null) {
      _updateAreaXLineInfo();
    }

    return _areaMPIDByLineMPID!.containsKey(lineMPID)
        ? _areaMPIDByLineMPID![lineMPID]
        : null;
  }

  int? getAreaMPIDByLineTHID(String lineTHID) {
    if (_areaMPIDByLineTHID == null) {
      _updateAreaXLineInfo();
    }

    return _areaMPIDByLineTHID!.containsKey(lineTHID)
        ? _areaMPIDByLineTHID![lineTHID]
        : null;
  }

  String getNewTHID({required THElement element, String prefix = ''}) {
    if (prefix == '') {
      prefix = element.elementType.name;
    }

    int counter = 1;
    String newTHID = '$prefix$counter';

    while (_mpIDByTHID.containsKey(newTHID)) {
      counter++;
      newTHID = '$prefix$counter';
    }

    return newTHID;
  }

  @override
  int get mpID => _mpID;
}
