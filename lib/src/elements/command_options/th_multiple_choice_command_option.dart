part of 'th_command_option.dart';

abstract class THMultipleChoiceCommandOption extends THCommandOption {
  THElementType? parentElementType;

  THMultipleChoiceCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THMultipleChoiceCommandOption({
    required super.parentMPID,
    super.originalLineInTH2File = '',
  }) : super();

  Enum get choice;

  static String _getParentTypeNameForChecking(String parentTypeName) {
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

  THElementType getParentElementType(THFile thFile) {
    parentElementType ??= thFile.getElementTypeByMPID(parentMPID);

    return parentElementType!;
  }

  String getParentElementTypeName(THFile thFile) {
    return getParentElementType(thFile).name;
  }

  String getParentTypeNameForChecking(THFile thFile) =>
      _getParentTypeNameForChecking(getParentElementTypeName(thFile));

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    return map;
  }

  @override
  bool equalsBase(Object other) {
    if (!super.equalsBase(other)) return false;

    return other is THMultipleChoiceCommandOption;
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return equalsBase(other);
  }
}
