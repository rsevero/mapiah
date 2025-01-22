import 'dart:collection';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/selection/th_selected_element.dart';

class THSelectedPoint extends THSelectedElement {
  THPoint modifiedPoint;
  late THPoint originalPoint;

  THSelectedPoint({required this.modifiedPoint}) {
    final LinkedHashMap<String, THCommandOption> clonedOptionsMap =
        LinkedHashMap<String, THCommandOption>();
    modifiedPoint.optionsMap.forEach((key, value) {
      clonedOptionsMap[key] = value.copyWith();
    });

    originalPoint = modifiedPoint.copyWith(optionsMap: clonedOptionsMap);
  }

  @override
  THPoint get modifiedElement => modifiedPoint;

  @override
  THPoint get originalElement => originalPoint;

  @override
  set modifiedElement(THElement element) {
    if (element is! THPoint) {
      throw ArgumentError(
          'The element is should be a THPoint in modifiedElement of THSelectedPoint.');
    }

    modifiedPoint = element;
  }

  @override
  set originalElement(THElement element) {
    if (element is! THPoint) {
      throw ArgumentError(
          'The element is should be a THPoint in originalElement of THSelectedPoint.');
    }

    originalPoint = element;
  }
}
