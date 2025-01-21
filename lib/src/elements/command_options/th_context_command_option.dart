import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// context <point/line/area> <symbol-type> . (to be used with symbol-hide and
// symbol-show layout options) symbol will be hidden/shown according to rules for spec-
// ified <symbol-type>.
class THContextCommandOption extends THCommandOption {
  static const String _thisOptionType = 'context';
  late final String elementType;
  late final String symbolType;

  // static const _supportedElementTypes = <String>{'point', 'line', 'area'};

  /// Constructor necessary for dart_mappable support.
  THContextCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.elementType,
    required this.symbolType,
  }) : super();

  THContextCommandOption.addToOptionParent({
    required super.optionParent,
    required this.elementType,
    required this.symbolType,
  }) : super.addToOptionParent(optionType: _thisOptionType);

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'elementType': elementType,
      'symbolType': symbolType,
    };
  }

  factory THContextCommandOption.fromMap(Map<String, dynamic> map) {
    return THContextCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      elementType: map['elementType'],
      symbolType: map['symbolType'],
    );
  }

  factory THContextCommandOption.fromJson(String jsonString) {
    return THContextCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THContextCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    String? elementType,
    String? symbolType,
  }) {
    return THContextCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      elementType: elementType ?? this.elementType,
      symbolType: symbolType ?? this.symbolType,
    );
  }

  @override
  bool operator ==(covariant THContextCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.elementType == elementType &&
        other.symbolType == symbolType;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        elementType,
        symbolType,
      );

  // set elementType(String aElementType) {
  //   if (!_supportedElementTypes.contains(aElementType)) {
  //     throw THCustomException("Unsupported element type '$aElementType'.");
  //   }
  //   _elementType = aElementType;
  // }

  // set symbolType(String aSymbolType) {
  //   switch (elementType) {
  //     case 'point':
  //       if (!THPoint.hasPointType(aSymbolType)) {
  //         throw THCustomException("Unsupported point type '$aSymbolType'.");
  //       }
  //     case 'line':
  //       if (!THLine.hasLineType(aSymbolType)) {
  //         throw THCustomException("Unsupported line type '$aSymbolType'.");
  //       }
  //     case 'area':
  //       if (!THArea.hasAreaType(aSymbolType)) {
  //         throw THCustomException("Unsupported area type '$aSymbolType'.");
  //       }
  //     default:
  //       throw THCustomException("Unsupported element type '$elementType'.");
  //   }
  //   _symbolType = aSymbolType;
  // }

  @override
  String specToFile() {
    return "$elementType $symbolType";
  }
}
