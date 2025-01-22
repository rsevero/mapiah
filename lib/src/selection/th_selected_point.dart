import 'dart:collection';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/selection/th_selected_element.dart';

class THSelectedPoint extends THSelectedElement {
  final THPoint point;
  late final THPoint originalPoint;

  THSelectedPoint({required this.point}) {
    final LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap =
        LinkedHashMap<THCommandOptionType, THCommandOption>();
    point.optionsMap.forEach((key, value) {
      optionsMap[key] = value.copyWith();
    });

    originalPoint = point.copyWith(optionsMap: optionsMap);
    assert(!identical(point, originalPoint));
  }

  @override
  THPoint get element => point;

  @override
  THPoint get originalElement => originalPoint;
}
