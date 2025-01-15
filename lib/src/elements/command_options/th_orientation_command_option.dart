import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

part 'th_orientation_command_option.mapper.dart';

// orientation/orient <number> . defines the orientation of the symbol. If not speci-
// fied, it’s oriented to north. 0 ≤ number < 360.
@MappableClass()
class THOrientationCommandOption extends THCommandOption
    with THOrientationCommandOptionMappable {
  static const String _thisOptionType = 'orientation';
  late THDoublePart _azimuth;

  /// Constructor necessary for dart_mappable support.
  THOrientationCommandOption.withExplicitParameters(super.thFile,
      super.parentMapiahID, super.optionType, THDoublePart azimuth)
      : super.withExplicitParameters() {
    _checkOptionParent(optionParent);
    this.azimuth = azimuth;
  }

  THOrientationCommandOption.fromString(
      THHasOptions optionParent, String azimuth)
      : super(optionParent, _thisOptionType) {
    _checkOptionParent(optionParent);
    azimuthFromString = azimuth;
  }

  void _checkOptionParent(THHasOptions aOptionParent) {
    if (optionParent is THLineSegment) {
      if ((optionParent.parent is! THLine) ||
          ((optionParent.parent as THLine).plaType != 'slope')) {
        throw THCustomException("Only available for 'slope' lines.");
      }
    } else if (optionParent is! THPoint) {
      throw THCustomException("Only available for 'point' and 'slope' lines.");
    }
  }

  set azimuth(THDoublePart aAzimuth) {
    if ((aAzimuth.value < 0) || (aAzimuth.value > 360)) {
      throw THCustomException(
          "Invalid azimuth value '$aAzimuth': should be 0 <= value <= 360");
    }

    _azimuth = aAzimuth;
  }

  set azimuthFromString(String aAzimuth) {
    final THDoublePart aDouble = THDoublePart.fromString(aAzimuth);

    azimuth = aDouble;
  }

  THDoublePart get azimuth {
    return _azimuth;
  }

  @override
  String specToFile() {
    return _azimuth.toString();
  }
}
