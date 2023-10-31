import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';
import 'package:mapiah/src/th_parts/th_double_part.dart';

class THOrientationCommandOption extends THCommandOption {
  late THDoublePart _azimuth;

  THOrientationCommandOption(super.parentOption, THDoublePart aAzimuth) {
    azimuth = aAzimuth;
  }

  THOrientationCommandOption.fromString(super.parentOption, String aAzimuth) {
    azimuthFromString = aAzimuth;
  }

  set azimuth(THDoublePart aAzimuth) {
    if ((aAzimuth.value < 0) || (aAzimuth.value > 360)) {
      throw THCustomException(
          "Invalid azimuth value '$aAzimuth': should be 0 <= value <= 360");
    }

    _azimuth = aAzimuth;
  }

  set azimuthFromString(String aAzimuth) {
    final aDouble = THDoublePart.fromString(aAzimuth);

    azimuth = aDouble;
  }

  THDoublePart get azimuth {
    return _azimuth;
  }

  @override
  String get optionType => 'orientation';

  @override
  String specToFile() {
    return _azimuth.toString();
  }
}
