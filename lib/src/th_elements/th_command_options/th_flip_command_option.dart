import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_exceptions/th_convert_from_string_exception.dart';

enum THFlipMode {
  none,
  horizontal,
  vertical,
}

class THFlipCommandOption extends THCommandOption {
  late THFlipMode mode;

  static const stringToMode = {
    'none': THFlipMode.none,
    'horizontal': THFlipMode.horizontal,
    'vertical': THFlipMode.vertical,
  };

  static const modeToString = {
    THFlipMode.none: 'none',
    THFlipMode.horizontal: 'horizontal',
    THFlipMode.vertical: 'vertical',
  };

  THFlipCommandOption(super.parent, this.mode);

  THFlipCommandOption.fromString(super.parent, String aModeString) {
    fromString(aModeString);
  }

  static bool isMode(String aModeString) {
    return stringToMode.containsKey(aModeString);
  }

  bool fromString(String aModeString) {
    if (!isMode(aModeString)) {
      throw THConvertFromStringException('THFlipCommandOption', aModeString);
    }

    mode = stringToMode[aModeString]!;

    return true;
  }

  @override
  String get optionType {
    return 'flip';
  }

  @override
  String specToFile() {
    return modeToString[mode]!;
  }
}
