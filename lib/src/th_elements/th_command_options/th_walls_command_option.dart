import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_exceptions/th_convert_from_string_exception.dart';

enum THWallsMode {
  on,
  off,
  auto,
}

class THWallsCommandOption extends THCommandOption {
  late THWallsMode mode;

  static const stringToMode = {
    'on': THWallsMode.on,
    'off': THWallsMode.off,
    'auto': THWallsMode.auto,
  };

  static const modeToString = {
    THWallsMode.on: 'on',
    THWallsMode.off: 'off',
    THWallsMode.auto: 'auto',
  };

  THWallsCommandOption(super.parent, this.mode);

  THWallsCommandOption.fromString(super.parent, String aModeString) {
    fromString(aModeString);
  }

  static bool isMode(String aModeString) {
    return stringToMode.containsKey(aModeString);
  }

  bool fromString(String aModeString) {
    if (!isMode(aModeString)) {
      throw THConvertFromStringException('THWallsCommandOption', aModeString);
    }

    mode = stringToMode[aModeString]!;

    return true;
  }

  @override
  String optionType() {
    return 'walls';
  }

  @override
  String specToFile() {
    return modeToString[mode]!;
  }
}
