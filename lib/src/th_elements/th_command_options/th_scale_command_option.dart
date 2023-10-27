import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';

class THScaleCommandOption extends THCommandOption {
  THScaleCommandOption(super.parent, super.value);

  @override
  String type() {
    return 'scale';
  }

  @override
  String valueToString() {
    var asString = '';

    final valueCount = value.length;

    switch (valueCount) {
      // case 1:
    }

    return asString;
  }
}
