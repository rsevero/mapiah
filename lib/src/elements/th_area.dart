import 'dart:collection';
import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

class THArea extends THElement
    with THHasOptions, THParent
    implements THHasPLAType {
  late final String _areaType;

  static final _areaTypes = <String>{
    'bedrock',
    'blocks',
    'clay',
    'debris',
    'flowstone',
    'ice',
    'moonmilk',
    'mudcrack',
    'pebbles',
    'pillar',
    'pillar-with-curtains',
    'pillars',
    'pillars-with-curtains',
    'sand',
    'snow',
    'stalactite',
    'stalactite-stalagmite',
    'stalagmite',
    'sump',
    'u',
    'water',
  };

  THArea({
    required super.mapiahID,
    required super.parentMapiahID,
    required super.sameLineComment,
    required String areaType,
    required LinkedHashMap<String, THCommandOption> optionsMap,
  }) : super() {
    _areaType = areaType;
    addOptionsMap(optionsMap);
  }

  THArea.addToParent({
    required super.parentMapiahID,
    required String areaType,
  })  : _areaType = areaType,
        super.addToParent() {
    if (!hasAreaType(areaType)) {
      throw THCustomException("Unrecognized THArea type '$areaType'.");
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'areaType': _areaType,
      'optionsMap':
          optionsMap.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory THArea.fromMap(Map<String, dynamic> map) {
    return THArea(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      areaType: map['areaType'],
      optionsMap: LinkedHashMap<String, THCommandOption>.from(
        map['optionsMap']
            .map((key, value) => MapEntry(key, THCommandOption.fromMap(value))),
      ),
    );
  }

  factory THArea.fromJson(String jsonString) {
    return THArea.fromMap(jsonDecode(jsonString));
  }

  @override
  THArea copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    String? areaType,
    LinkedHashMap<String, THCommandOption>? optionsMap,
  }) {
    return THArea(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: sameLineComment ?? this.sameLineComment,
      areaType: areaType ?? _areaType,
      optionsMap: optionsMap ?? this.optionsMap,
    );
  }

  @override
  bool operator ==(covariant THArea other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other._areaType == _areaType &&
        other.optionsMap == optionsMap;
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
        _areaType,
        optionsMap,
      );

  static bool hasAreaType(String aAreaType) {
    return _areaTypes.contains(aAreaType);
  }

  // @override
  // set plaType(String aAreaType) {
  //   if (!hasAreaType(aAreaType)) {
  //     throw THCustomException("Unrecognized THArea type '$aAreaType'.");
  //   }

  //   _areaType = aAreaType;
  // }

  @override
  String get plaType {
    return _areaType;
  }

  String get areaType {
    return _areaType;
  }

  @override
  bool isSameClass(Object object) {
    return object is THArea;
  }
}
