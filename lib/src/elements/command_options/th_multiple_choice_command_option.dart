// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
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

  THElementType getParentElementType(TH2File th2File) {
    parentElementType ??= th2File.getElementTypeByMPID(parentMPID);

    return parentElementType!;
  }

  String getParentElementTypeName(TH2File th2File) {
    return getParentElementType(th2File).name;
  }

  String getParentTypeNameForChecking(TH2File th2File) =>
      _getParentTypeNameForChecking(getParentElementTypeName(th2File));

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
