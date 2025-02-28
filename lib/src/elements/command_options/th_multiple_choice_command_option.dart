part of 'th_command_option.dart';

abstract class THMultipleChoiceCommandOption extends THCommandOption {
  final THElementType parentElementType;

  THMultipleChoiceCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.parentElementType,
  }) : super.forCWJM();

  THMultipleChoiceCommandOption({
    required super.optionParent,
    super.originalLineInTH2File = '',
  })  : parentElementType = optionParent.elementType,
        super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.multipleChoice;

  static String getParentTypeNameForChecking(String parentTypeName) {
    String parentTypeNameForChecking = parentTypeName;

    if ((parentTypeNameForChecking == THElementType.straightLineSegment.name) ||
        (parentTypeNameForChecking ==
            THElementType.bezierCurveLineSegment.name)) {
      parentTypeNameForChecking = 'linesegment';
    } else {
      parentTypeNameForChecking = parentTypeNameForChecking.toLowerCase();
    }

    return parentTypeNameForChecking;
  }

  String get parentTypeNameForChecking =>
      getParentTypeNameForChecking(parentElementType.name);

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'parentElementType': parentElementType.name,
    });

    return map;
  }

  @override
  bool operator ==(covariant THMultipleChoiceCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType;
  }

  @override
  int get hashCode => super.hashCode ^ parentElementType.hashCode;

  // static bool hasOptionType(THHasOptionsMixin optionParent, String optionType) {
  //   final String optionParentElementType =
  //       getParentTypeNameForChecking(optionParent.elementType.name);

  //   if (!_supportedOptions.containsKey(optionParentElementType)) {
  //     return false;
  //   }

  //   if (!_supportedOptions[optionParentElementType]!.containsKey(optionType)) {
  //     return false;
  //   }

  //   if (optionParent is THHasPLATypeMixin) {
  //     final String plaType = (optionParent as THHasPLATypeMixin).plaType;

  //     final Set<String> plaTypesSupported = _supportedOptions[
  //             optionParentElementType]![optionType]!['plaTypesSupported']
  //         as Set<String>;

  //     if (plaTypesSupported.isEmpty) {
  //       return true;
  //     } else {
  //       return plaTypesSupported.contains(plaType);
  //     }
  //   }

  //   return true;
  // }
}
