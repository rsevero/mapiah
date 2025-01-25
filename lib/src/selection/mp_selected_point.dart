import 'dart:collection';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/selection/mp_selected_element.dart';

class MPSelectedPoint extends MPSelectedElement {
  late THPoint originalPointClone;

  MPSelectedPoint({required THPoint originalPoint}) {
    final LinkedHashMap<String, THCommandOption> optionsMapClone =
        LinkedHashMap<String, THCommandOption>();
    originalPoint.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalPointClone = originalPoint.copyWith(optionsMap: optionsMapClone);
  }

  @override
  THPoint get originalElementClone => originalPointClone;
}
