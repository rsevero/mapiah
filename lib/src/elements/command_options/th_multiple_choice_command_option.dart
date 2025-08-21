part of 'th_command_option.dart';

abstract class THMultipleChoiceCommandOption extends THCommandOption {
  final THElementType parentElementType;

  THMultipleChoiceCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.parentElementType,
  }) : super.forCWJM();

  THMultipleChoiceCommandOption({
    required super.optionParent,
    super.originalLineInTH2File = '',
  }) : parentElementType = optionParent.elementType,
       super();

  Enum get choice;

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

    map.addAll({'parentElementType': parentElementType.name});

    return map;
  }

  @override
  bool equalsBase(Object other) {
    if (!super.equalsBase(other)) return false;

    return (other as THMultipleChoiceCommandOption).parentElementType ==
        parentElementType;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THMultipleChoiceCommandOption) return false;

    return equalsBase(other);
  }

  @override
  int get hashCode => super.hashCode ^ parentElementType.hashCode;
}
