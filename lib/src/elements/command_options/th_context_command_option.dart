import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// context <point/line/area> <symbol-type> . (to be used with symbol-hide and
// symbol-show layout options) symbol will be hidden/shown according to rules for spec-
// ified <symbol-type>.
@serializable
class THContextCommandOption extends THCommandOption
    with Dataclass<THContextCommandOption> {
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
    return dogs.toNative<THContextCommandOption>(this);
  }

  factory THContextCommandOption.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THContextCommandOption>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THContextCommandOption>(this);
  }

  factory THContextCommandOption.fromJson(String jsonString) {
    return dogs.fromJson<THContextCommandOption>(jsonString);
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
